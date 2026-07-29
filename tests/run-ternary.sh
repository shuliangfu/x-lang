#!/usr/bin/env bash
# 三元运算符 cond ? then : else
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
fi
XLANG=${XLANG:-./compiler/xlang-c}

# return a > 10 ? 10 : a; a=15 -> 10
$XLANG build tests/ternary/main.x -o /tmp/xlang_ternary_main 2>&1
exitcode=0; /tmp/xlang_ternary_main >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 10 ] && { echo "expected 10 (main), got $exitcode"; exit 1; }

# clamp -3 -> 0
$XLANG build tests/ternary/clamp.x -o /tmp/xlang_ternary_clamp 2>&1
exitcode=0; /tmp/xlang_ternary_clamp >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected 0 (clamp), got $exitcode"; exit 1; }

echo "ternary test OK"
