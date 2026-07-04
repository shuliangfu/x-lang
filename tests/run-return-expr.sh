#!/usr/bin/env bash
# 验证显式 return expr；块尾可为 return 42 作为返回值。
set -e
cd "$(dirname "$0")/.."
if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler
fi
SHUX=${SHUX:-./compiler/shux}
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
LINK_SHUX="$RUN_SHUX"

$LINK_SHUX tests/return-expr/explicit.x -o /tmp/shux_return_explicit 2>&1
exitcode=0
/tmp/shux_return_explicit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 42 ] && { echo "expected 42 (explicit return), got $exitcode"; exit 1; }

# 边界：return 类型与声明不一致（当前 typeck 未检查，用例保留待后续补 typeck 后启用）
# err=$(./compiler/shux tests/return-expr/return_type_mismatch.x -o /tmp/shux_return_fail 2>&1) || true
# echo "$err" | grep -q "typeck error" || { echo "expected typeck error for return type mismatch"; exit 1; }

echo "return-expr test OK"
