#!/usr/bin/env bash
# 切片 T[]：从数组初始化、下标访问；core.slice len_i32；u8[] 字段 .data/.length
set -e
cd "$(dirname "$0")/.."
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q xlang-c 2>/dev/null || make -C compiler xlang-c
fi

if [ -n "$XLANG" ]; then
  :
elif [ -x ./compiler/xlang ]; then
  XLANG=./compiler/xlang
elif [ -x ./compiler/xlang-c ]; then
  XLANG=./compiler/xlang-c
else
  XLANG=./compiler/xlang-c
fi

# 非 x86_64：seed xlang -o 可能走 asm 产出 x86_64 .o，链接 EM:62 失败；可执行链用 xlang-c。
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
LINK_XLANG="$RUN_XLANG"
# 【Why】xlang-c 不支持 -backend 参数；默认空，仅 xlang_asm/xlang_asm2 需显式 -backend asm。
SLICE_LINK_BACKEND_ARGS="${XLANG_LINK_BACKEND_ARGS:-}"

# bstrict：-o 优先 xlang_asm(2)，但**禁止清空** SLICE_LINK_BACKEND_ARGS。
# 旧逻辑置空后 Linux 默认 asm，失败再拼 -E 回退 → 20KiB 截断 + slice 结构体重定义假路径。
# 保留 bootstrap-link-xlang / XLANG_FORCE_LINK_BACKEND 注入的 -backend c。
if [ -n "${XLANG_RUN_ALL_BOOTSTRAP_XLANG:-}" ] && [ -x ./compiler/xlang_asm2 ]; then
  LINK_XLANG=./compiler/xlang_asm2
elif [ -n "${XLANG_RUN_ALL_BOOTSTRAP_XLANG:-}" ] && [ -x ./compiler/xlang_asm ]; then
  LINK_XLANG=./compiler/xlang_asm
fi
# 产品 xlang_asm -o：Linux 默认 asm 对 slice 不完整；无显式 backend 时走 -backend c（与 Darwin 矩阵一致）。
case "$(basename "$LINK_XLANG")" in
  xlang|xlang_asm|xlang_asm2|xlang_asm_stage1)
    if [ -z "$SLICE_LINK_BACKEND_ARGS" ]; then
      if [ -n "${XLANG_FORCE_LINK_BACKEND:-}" ]; then
        SLICE_LINK_BACKEND_ARGS="-backend ${XLANG_FORCE_LINK_BACKEND}"
      else
        SLICE_LINK_BACKEND_ARGS="-backend c"
      fi
    fi
    ;;
esac

# core/slice C 实现（length.x / subslice_split_chunks 等依赖 runtime_slice_glue）。
# PLATFORM: SHARED — 始终确保 slice.o 存在。XLANG_SKIP_SUBSCRIPT_MAKE 只跳过 xlang-c
# 重建（防 seed 挂起），不得跳过本 glue；冷树缺 slice.o 时 -o 会 UNDEF core_subslice_*。
make -C compiler -q ../core/slice/slice.o 2>/dev/null \
  || make -C compiler ../core/slice/slice.o 2>/dev/null || true

# main.x / data_field.x：asm slice 栈槽问题或 exit 不符时回退 seed -E+cc。
slice_simple_link_o() {
  local x="$1" out="$2" struct_decl="$3" want_exit="$4"
  set +e
  $LINK_XLANG build $SLICE_LINK_BACKEND_ARGS "$x" -o "$out" 2>&1
  local ec=$?
  set -e
  if [ "$ec" -eq 0 ] && [ -x "$out" ]; then
    exitcode=0
    "$out" >/dev/null 2>&1 || exitcode=$?
    # asm 路径 exit 正确且非 SIGABRT(134) 时接受；否则回退 -E+cc（data_field 常见 exit 2≠0）。
    if [ "$exitcode" -ne 134 ] && [ "$exitcode" -eq "$want_exit" ]; then
      return 0
    fi
  fi
  # 禁止：手写 struct + -E 截断拼装（20KiB 截断 / int64_t vs size_t 双定义）。
  # 回退仅允许产品 -backend c -o（完整 KEEP_C 链）；失败则硬红。
  set +e
  $LINK_XLANG build -backend c "$x" -o "$out" 2>&1
  ec=$?
  set -e
  if [ "$ec" -eq 0 ] && [ -x "$out" ]; then
    exitcode=0
    "$out" >/dev/null 2>&1 || exitcode=$?
    if [ "$exitcode" -ne 134 ] && [ "$exitcode" -eq "$want_exit" ]; then
      return 0
    fi
  fi
  echo "slice_simple_link_o FAIL: $x (product -backend c -o; no -E splice fallback)" >&2
  return 1
}

slice_simple_link_o tests/slice/main.x /tmp/xlang_slice \
  'struct xlang_slice_int32_t { int32_t *data; int64_t length; };' 20
exitcode=0; /tmp/xlang_slice >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 20 ] && { echo "expected 20 (slice s[1]), got $exitcode"; exit 1; }

slice_simple_link_o tests/slice/data_field.x /tmp/xlang_slice_data_field \
  'struct xlang_slice_uint8_t { uint8_t *data; int64_t length; };' 0
exitcode=0; /tmp/xlang_slice_data_field >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (data_field), got $exitcode"; exit 1; }

# core.slice + core.option 全链：bootstrap asm 对多 dep -o 易缺 core_slice_* 符号；check 绿则链接失败可跳过（同 run-core-slice-api-gate）。
slice_dep_link_or_check() {
  local x="$1" out="$2" label="$3"
  local ck="${TYPECK_XLANG:-$XLANG}"
  if ! "$ck" check -L . "$x" >/dev/null 2>&1; then
    echo "expected typeck OK ($label)" >&2
    "$ck" check -L . "$x" 2>&1 | tail -8 >&2 || true
    return 1
  fi
  set +e
  # 与 simple 路径一致：产品 -o 带 backend（默认 c），禁止静默 SKIP 假绿
  $LINK_XLANG build $SLICE_LINK_BACKEND_ARGS -L . "$x" -o "$out" 2>/tmp/xlang_slice_dep_link.log
  local ec=$?
  set -e
  if [ "$ec" -ne 0 ] || [ ! -x "$out" ]; then
    tail -8 /tmp/xlang_slice_dep_link.log 2>/dev/null >&2 || true
    echo "slice_dep_link FAIL: $label (check OK but -o failed)" >&2
    return 1
  fi
  exitcode=0
  "$out" >/dev/null 2>&1 || exitcode=$?
  [ "$exitcode" -eq 0 ] || { echo "expected exit 0 ($label), got $exitcode"; return 1; }
}

slice_dep_link_or_check tests/slice/length.x /tmp/xlang_slice_length "len_i32"
slice_dep_link_or_check tests/slice/subslice_split_chunks.x /tmp/xlang_slice_subsplit "subslice_split_chunks"

# 边界：对非数组/切片取下标，应报 subscript base must be array, slice or pointer
err=$(${TYPECK_XLANG:-$XLANG} check tests/slice/subscript_not_slice.x 2>&1) || true
echo "$err" | grep -q "subscript base must be array" || { echo "expected subscript base error, got: $err"; exit 1; }

echo "slice test OK"
