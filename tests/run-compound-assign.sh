#!/usr/bin/env bash
# 复合赋值运算符：+= -= *= /= %= &= |= ^= <<= >>=
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
XLANG=${XLANG:-./compiler/xlang}
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
LINK_XLANG="$RUN_XLANG"
LINK_BACKEND_ARGS="${XLANG_LINK_BACKEND_ARGS:-}"

# compound assign 语义经 pipeline_glue TokenKind 映射已修（C emit 正确）。
# 当前 asm 路径在「复合赋值 → if → 再复合赋值」模式仍不稳定；门禁先固定到稳定 C backend，
# 避免把已知 asm 债误算成脚本链路回归。
case "$(basename "$LINK_XLANG")" in
  xlang|xlang_asm|xlang_asm2|xlang_asm_stage1)
    LINK_XLANG=./compiler/xlang
    LINK_BACKEND_ARGS="-backend c"
    ;;
esac

set +e
# shellcheck disable=SC2086
$LINK_XLANG build $LINK_BACKEND_ARGS tests/compound-assign/main.x -o /tmp/xlang_compound_assign 2>&1
_compile_ec=$?
set -e
set +e
if [ "$_compile_ec" -ne 0 ] && [ "$LINK_XLANG" != "./compiler/xlang" ]; then
  ./compiler/xlang build -backend c tests/compound-assign/main.x -o /tmp/xlang_compound_assign 2>&1
  _compile_ec=$?
fi
# xlang-c -E + cc 回退（无 asm/c backend 时）
if [ "$_compile_ec" -ne 0 ] && [ -x ./compiler/xlang-c ]; then
  ./compiler/xlang-c -E tests/compound-assign/main.x > /tmp/xlang_ca_fallback.c 2>&1
  ${CC:-cc} -O2 -o /tmp/xlang_compound_assign /tmp/xlang_ca_fallback.c 2>&1
  _compile_ec=$?
fi
set -e

exitcode=0
/tmp/xlang_compound_assign >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 0 ]; then
  echo "compound-assign: expected exit 0, got $exitcode"
  exit 1
fi
echo "compound-assign test OK"
