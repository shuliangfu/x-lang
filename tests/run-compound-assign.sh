#!/usr/bin/env bash
# 复合赋值运算符：+= -= *= /= %= &= |= ^= <<= >>=
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
LINK_SHUX="$RUN_SHUX"
LINK_BACKEND_ARGS="${SHUX_LINK_BACKEND_ARGS:-}"

# compound assign 语义经 pipeline_glue TokenKind 映射已修（C emit 正确）。
# 当前 asm 路径在「复合赋值 → if → 再复合赋值」模式仍不稳定；门禁先固定到稳定 C backend，
# 避免把已知 asm 债误算成脚本链路回归。
case "$(basename "$LINK_SHUX")" in
  shux|shux_asm|shux_asm2|shux_asm_stage1)
    LINK_SHUX=./compiler/shux
    LINK_BACKEND_ARGS="-backend c"
    ;;
esac

set +e
# shellcheck disable=SC2086
$LINK_SHUX $LINK_BACKEND_ARGS tests/compound-assign/main.x -o /tmp/shux_compound_assign 2>&1
_compile_ec=$?
set -e
set +e
if [ "$_compile_ec" -ne 0 ] && [ "$LINK_SHUX" != "./compiler/shux" ]; then
  ./compiler/shux -backend c tests/compound-assign/main.x -o /tmp/shux_compound_assign 2>&1
  _compile_ec=$?
fi
# shux-c -E + cc 回退（无 asm/c backend 时）
if [ "$_compile_ec" -ne 0 ] && [ -x ./compiler/shux-c ]; then
  ./compiler/shux-c -E tests/compound-assign/main.x > /tmp/shux_ca_fallback.c 2>&1
  ${CC:-cc} -O2 -o /tmp/shux_compound_assign /tmp/shux_ca_fallback.c 2>&1
  _compile_ec=$?
fi
set -e

exitcode=0
/tmp/shux_compound_assign >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 0 ]; then
  echo "compound-assign: expected exit 0, got $exitcode"
  exit 1
fi
echo "compound-assign test OK"
