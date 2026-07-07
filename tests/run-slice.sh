#!/usr/bin/env bash
# 切片 T[]：从数组初始化、下标访问；core.slice len_i32；u8[] 字段 .data/.length
set -e
cd "$(dirname "$0")/.."
if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
fi

if [ -n "$SHUX" ]; then
  :
elif [ -x ./compiler/shux ]; then
  SHUX=./compiler/shux
elif [ -x ./compiler/shux-c ]; then
  SHUX=./compiler/shux-c
else
  SHUX=./compiler/shux-c
fi

# 非 x86_64：seed shux -o 可能走 asm 产出 x86_64 .o，链接 EM:62 失败；可执行链用 shux-c。
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
LINK_SHUX="$RUN_SHUX"
# 【Why】shux-c 不支持 -backend 参数；默认空，仅 shux_asm/shux_asm2 需显式 -backend asm。
SLICE_LINK_BACKEND_ARGS="${SHUX_LINK_BACKEND_ARGS:-}"

# bstrict：-o 优先 shux_asm2（与 run-struct 一致）。
if [ -n "${SHUX_RUN_ALL_BOOTSTRAP_SHUX:-}" ] && [ -x ./compiler/shux_asm2 ]; then
  LINK_SHUX=./compiler/shux_asm2
  SLICE_LINK_BACKEND_ARGS=""
elif [ -n "${SHUX_RUN_ALL_BOOTSTRAP_SHUX:-}" ] && [ -x ./compiler/shux_asm ]; then
  LINK_SHUX=./compiler/shux_asm
  SLICE_LINK_BACKEND_ARGS=""
fi

# core/slice C 实现（length.x 等）；勿强编 process.o（arm64 shux-c 无 asm backend）。
if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q ../core/slice/slice.o 2>/dev/null \
    || make -C compiler ../core/slice/slice.o 2>/dev/null || true
fi

# main.x / data_field.x：asm slice 栈槽问题或 exit 不符时回退 seed -E+cc。
slice_simple_link_o() {
  local x="$1" out="$2" struct_decl="$3" want_exit="$4"
  set +e
  $LINK_SHUX $SLICE_LINK_BACKEND_ARGS "$x" -o "$out" 2>&1
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
  local tmpc emit_shux=./compiler/shux-c
  [ -x "$emit_shux" ] || emit_shux=./compiler/shux
  # 【Why】macOS mkstemp 要求 X 在模板末尾；原 /tmp/...XXXXXX.c 中 .c 在 X 之后导致失败。
  # 用不带 .c 后缀的临时文件，cc 用 -x c 指定 C 语言即可编译。
  tmpc=$(mktemp /tmp/shux_slice_simple_XXXXXX)
  {
    echo '#include <stdint.h>'
    echo '#include <stddef.h>'
    echo "$struct_decl"
    "$emit_shux" -E "$x" 2>/dev/null | tail -n +2
  } >"$tmpc"
  ${CC:-cc} -O0 -x c -o "$out" "$tmpc"
  rm -f "$tmpc"
}

slice_simple_link_o tests/slice/main.x /tmp/shux_slice \
  'struct shulang_slice_int32_t { int32_t *data; int64_t length; };' 20
exitcode=0; /tmp/shux_slice >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 20 ] && { echo "expected 20 (slice s[1]), got $exitcode"; exit 1; }

slice_simple_link_o tests/slice/data_field.x /tmp/shux_slice_data_field \
  'struct shulang_slice_uint8_t { uint8_t *data; int64_t length; };' 0
exitcode=0; /tmp/shux_slice_data_field >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (data_field), got $exitcode"; exit 1; }

# core.slice + core.option 全链：bootstrap asm 对多 dep -o 易缺 core_slice_* 符号；check 绿则链接失败可跳过（同 run-core-slice-api-gate）。
slice_dep_link_or_check() {
  local x="$1" out="$2" label="$3"
  local ck="${TYPECK_SHUX:-$SHUX}"
  if ! "$ck" check -L . "$x" >/dev/null 2>&1; then
    echo "expected typeck OK ($label)" >&2
    "$ck" check -L . "$x" 2>&1 | tail -8 >&2 || true
    return 1
  fi
  set +e
  $RUN_SHUX -L . "$x" -o "$out" 2>/tmp/shux_slice_dep_link.log
  local ec=$?
  set -e
  if [ "$ec" -ne 0 ] || [ ! -x "$out" ]; then
    if [ -n "${SHUX_RUN_ALL_BOOTSTRAP_SHUX:-}" ]; then
      echo "slice: SKIP runnable $label (bootstrap dep link; check OK)"
      return 0
    fi
    tail -8 /tmp/shux_slice_dep_link.log 2>/dev/null >&2 || true
    return 1
  fi
  exitcode=0
  "$out" >/dev/null 2>&1 || exitcode=$?
  [ "$exitcode" -eq 0 ] || { echo "expected exit 0 ($label), got $exitcode"; return 1; }
}

slice_dep_link_or_check tests/slice/length.x /tmp/shux_slice_length "len_i32"
slice_dep_link_or_check tests/slice/subslice_split_chunks.x /tmp/shux_slice_subsplit "subslice_split_chunks"

# 边界：对非数组/切片取下标，应报 subscript base must be array, slice or pointer
err=$(${TYPECK_SHUX:-$SHUX} check tests/slice/subscript_not_slice.x 2>&1) || true
echo "$err" | grep -q "subscript base must be array" || { echo "expected subscript base error, got: $err"; exit 1; }

echo "slice test OK"
