#!/usr/bin/env bash
# match 表达式：整数字面量分支与 _
set -e
cd "$(dirname "$0")/.."
if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler
fi
SHUX=${SHUX:-./compiler/shux}
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
MATCH_LINK="${RUN_SHUX:-$SHUX}"

$MATCH_LINK -L . tests/match/main.x -o /tmp/shux_match 2>&1
exitcode=0; /tmp/shux_match >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 2 ] && { echo "expected 2 (match 1 => 2), got $exitcode"; exit 1; }

# 边界：match 分支使用枚举不存在的变体，应报 enum has no variant
err=$($MATCH_LINK -L . tests/match/enum_no_variant.x -o /tmp/shux_match_fail 2>&1) || true
echo "$err" | grep -q "has no variant" || { echo "expected enum no variant error, got: $err"; exit 1; }

echo "match test OK"
