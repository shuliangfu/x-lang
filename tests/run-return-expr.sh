#!/usr/bin/env bash
# 验证显式 return expr；块尾可为 return 42 作为返回值。
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
LINK_XLANG="$RUN_XLANG"

$LINK_XLANG build tests/return-expr/explicit.x -o /tmp/xlang_return_explicit 2>&1
exitcode=0
/tmp/xlang_return_explicit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 42 ] && { echo "expected 42 (explicit return), got $exitcode"; exit 1; }

# wave671 Cap residual: return true as i32 must hard-fail (BOOL_LIT→i32 removed).
# PLATFORM: SHARED typeck — mismatch diagnostic required.
err=$($LINK_XLANG build tests/return-expr/return_type_mismatch.x -o /tmp/xlang_return_fail 2>&1) || true
echo "$err" | grep -q "typeck error" || { echo "expected typeck error for return type mismatch"; echo "$err"; exit 1; }
echo "$err" | grep -q "return expression type mismatch" || {
  echo "expected return expression type mismatch diagnostic"; echo "$err"; exit 1
}

echo "return-expr test OK"
