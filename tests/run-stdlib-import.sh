#!/usr/bin/env bash
# 测试自举前标准库扩展（5.5）：多个 core/std 模块可 import 并有最小可用实现。
# 依赖：compiler/xlang 或 xlang-c、tests/stdlib-import/main.x、core/*.x、std/*.x（-L .）。
# P5 / ubuntu-gates：typeck 烟测与 -o 链接优先 xlang-c（bootstrap xlang 对 dep typeck/-o 易失败）。

set -e
cd "$(dirname "$0")/.."

# 可执行链接优先 xlang-c；无 xlang-c 时回退 XLANG / xlang。
stdlib_import_pick_link_shu() {
  # 产品冷链：优先 XLANG / XLANG_LINK_XLANG（xlang_asm）；勿默认 pin xlang-c
  if [ -n "${XLANG_LINK_XLANG:-}" ] && [ -x "${XLANG_LINK_XLANG}" ]; then
    case "$(basename "$XLANG_LINK_XLANG")" in
      xlang-c) ;;
      *) echo "$XLANG_LINK_XLANG"; return 0 ;;
    esac
  fi
  if [ -n "${XLANG:-}" ] && [ -x "$XLANG" ]; then
    case "$(basename "$XLANG")" in
      xlang-c) ;;
      *) echo "$XLANG"; return 0 ;;
    esac
  fi
  if [ -x ./compiler/xlang_asm ]; then
    echo "./compiler/xlang_asm"
    return 0
  fi
  if [ -x ./compiler/xlang ]; then
    echo "./compiler/xlang"
    return 0
  fi
  if [ -x ./compiler/xlang-c ]; then
    echo "./compiler/xlang-c"
    return 0
  fi
  echo "./compiler/xlang"
}

if [ -n "$XLANG" ]; then
  :
elif [ -x ./compiler/xlang-c ]; then
  XLANG=./compiler/xlang-c
elif [ -x ./compiler/xlang ]; then
  XLANG=./compiler/xlang
else
  make -C compiler -q xlang-c 2>/dev/null || make -C compiler xlang-c
  XLANG=./compiler/xlang-c
fi

# typeck / 烟测：产品冷链用 XLANG；仅 RUN_ALL_USE_C 时绑 xlang-c
CHECK_XLANG="$XLANG"
if [ -n "${RUN_ALL_USE_C:-}" ] && [ -x ./compiler/xlang-c ]; then
  CHECK_XLANG=./compiler/xlang-c
fi
LINK_XLANG="$(stdlib_import_pick_link_shu)"
# 产品 -o 默认 -backend c（Linux asm 不完整）
STDLIB_IMPORT_BACKEND=""
case "$(basename "$LINK_XLANG")" in
  xlang|xlang_asm|xlang_asm2|xlang_asm_stage1)
    STDLIB_IMPORT_BACKEND="${XLANG_FORCE_LINK_BACKEND:+-backend $XLANG_FORCE_LINK_BACKEND}"
    [ -n "$STDLIB_IMPORT_BACKEND" ] || STDLIB_IMPORT_BACKEND="-backend c"
    ;;
esac

# main.x 不 import std.process；process.o 需 asm backend，arm64 xlang-c 上可选。
make -C compiler -q ../std/process/process.o 2>/dev/null \
  || make -C compiler ../std/process/process.o 2>/dev/null || true
# run-all 入口已 make 时跳过（XLANG_SKIP_SUBSCRIPT_MAKE=1）。
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  if [ -n "${XLANG_RUN_ALL_BOOTSTRAP_XLANG:-}" ]; then
    make -C compiler bootstrap-driver-seed -q 2>/dev/null || make -C compiler bootstrap-driver-seed
  else
    make -C compiler -q 2>/dev/null || make -C compiler
  fi
fi
# bootstrap seed：typeck 走 .x pipeline（check）；多模块可执行链接仍用 xlang-c（seed -o 常 cc failed）。
if [ -n "${XLANG_RUN_ALL_BOOTSTRAP_XLANG:-}" ]; then
  # deno check 语义：成功时静默（exit 0、无输出）；与 tests/run-check.sh 一致。
  chk_out=$($XLANG check -L . tests/stdlib-import/main.x 2>&1) || chk_rc=$?
  chk_rc=${chk_rc:-0}
  if [ "$chk_rc" -ne 0 ]; then
    echo "stdlib-import: check failed on bootstrap xlang (exit $chk_rc)" >&2
    echo "$chk_out"
    exit 1
  fi
  if [ -n "$chk_out" ] && echo "$chk_out" | grep -qE " - error: |typeck error:|check failed|parse error"; then
    echo "stdlib-import: unexpected check diagnostics on bootstrap xlang" >&2
    echo "$chk_out"
    exit 1
  fi
  LINK_XLANG="$(stdlib_import_pick_link_shu)"
else
  out=$($CHECK_XLANG -L . tests/stdlib-import/main.x 2>&1)
  echo "$out" | grep -q "parse OK" || { echo "expected parse OK"; echo "$out"; exit 1; }
  echo "$out" | grep -q "typeck OK" || { echo "expected typeck OK"; echo "$out"; exit 1; }
fi
if [ "$LINK_XLANG" != "$CHECK_XLANG" ] && [ -n "$LINK_XLANG" ]; then
  echo "stdlib-import: link via $(basename "$LINK_XLANG") (check via $(basename "$CHECK_XLANG"))"
fi
if ! $LINK_XLANG build $STDLIB_IMPORT_BACKEND -L . tests/stdlib-import/main.x -o /tmp/xlang_stdlib_import >/dev/null 2>&1; then
  echo "stdlib-import: compile failed (link via ${LINK_XLANG##*/} $STDLIB_IMPORT_BACKEND)" >&2
  exit 1
fi
/tmp/xlang_stdlib_import
echo "stdlib-import test OK"
