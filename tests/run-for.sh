#!/usr/bin/env bash
# 验证 C 风格 for(init;cond;step){ body }；cond 空表示恒真。
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
fi
XLANG=${XLANG:-./compiler/xlang}
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
FOR_LINK="${RUN_XLANG:-$XLANG}"

# for ( ; n < 1 ; ) { break }; 42 -> 42
$FOR_LINK -L . tests/for/simple.x -o /tmp/xlang_for_simple 2>&1
exitcode=0
/tmp/xlang_for_simple >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 42 ] && { echo "expected 42 (for simple), got $exitcode"; exit 1; }

# 边界：continue 不在循环内，应报 only allowed inside a loop
err=$($FOR_LINK -L . tests/for/continue_outside.x -o /tmp/xlang_for_fail 2>&1) || true
echo "$err" | grep -q "only allowed inside a loop" || { echo "expected continue outside loop error, got: $err"; exit 1; }

echo "for test OK"
