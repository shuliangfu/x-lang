#!/usr/bin/env bash
# run-export.sh — 模块 export / XLANG_VISIBILITY 金样
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
XLANG="${XLANG:-$ROOT/compiler/xlang}"
cd "$ROOT"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "OK: $*"; }

# 1) 语法：export function 可 parse
echo 'export function foo(): i32 { return 1; }
function main(): i32 { return foo(); }' > /tmp/xlang_export_syn.x
out="$($XLANG check /tmp/xlang_export_syn.x 2>&1 || true)"
echo "$out" | grep -q 'type check failed' && fail "export syntax should typeck"
pass "export syntax"

# 2) 默认（strict）：未 export 不可跨模块
out="$($XLANG check tests/export/user_private_should_fail.x 2>&1 || true)"
echo "$out" | grep -q 'type check failed' || fail "default strict must reject private_mul"
pass "default strict rejects non-export"

# 3) compat 回退：未 export 仍可跨模块
out="$(XLANG_VISIBILITY=compat $XLANG check tests/export/user_private_should_fail.x 2>&1 || true)"
echo "$out" | grep -q 'type check failed' && fail "compat should allow private_mul"
pass "compat allows non-export"

# 4) warn：告警仍放行
out="$(XLANG_VISIBILITY=warn $XLANG check tests/export/user_private_should_fail.x 2>&1 || true)"
echo "$out" | grep -q "is not exported" || fail "warn should mention not exported"
echo "$out" | grep -q 'type check failed' && fail "warn should still allow"
pass "warn diagnoses non-export"

# 5) 显式 strict + export API 成功
out="$(XLANG_VISIBILITY=strict $XLANG check tests/export/user_export.x 2>&1 || true)"
echo "$out" | grep -q 'type check failed' && fail "strict must allow export API"
pass "strict allows export API"

out="$($XLANG check tests/export/user_export.x 2>&1 || true)"
echo "$out" | grep -q 'type check failed' && fail "default must allow export API"
pass "default allows export API"

# 6) 运行 export 用户程序
$XLANG build -backend c -o /tmp/xlang_export_user tests/export/user_export.x >/dev/null 2>&1 || fail "build user_export"
rc=0
/tmp/xlang_export_user || rc=$?
[[ "$rc" -eq 9 ]] || fail "user_export exit want 9 got $rc"
pass "user_export runs exit=9"

# 7) L7 unused private：check 默认 warning（exit 0），不阻断；被调用则不报
set +e
out="$($XLANG check tests/export/lint_unused_private.x 2>&1)"
ec=$?
set -e
[[ "$ec" -eq 0 ]] || fail "L7 must be warning-only (check exit 0), got $ec"
echo "$out" | grep -q "unused private function" || fail "L7 should warn dead_private_helper"
echo "$out" | grep -qiE 'error:.*unused private|type check failed' && fail "L7 must not be error/typeck fail"
# 波浪线锚点：应落在 dead_private_helper 定义行（约第 2 行），而非强制 1:1
echo "$out" | grep -qE 'lint_unused_private\.x:2:' || true
pass "L7 warns unused private (exit 0)"

set +e
out="$($XLANG check tests/export/lint_used_private.x 2>&1)"
ec=$?
set -e
[[ "$ec" -eq 0 ]] || fail "used private check should exit 0, got $ec"
echo "$out" | grep -q "unused private function" && fail "L7 must not warn live private"
pass "L7 keeps used private silent"

set +e
out="$(XLANG_UNUSED_PRIVATE=0 $XLANG check tests/export/lint_unused_private.x 2>&1)"
ec=$?
set -e
[[ "$ec" -eq 0 ]] || fail "L7-off check should exit 0"
echo "$out" | grep -q "unused private function" && fail "XLANG_UNUSED_PRIVATE=0 should silence L7"
pass "L7 off via XLANG_UNUSED_PRIVATE=0"

# 8) 编译/运行路径：unused private 不阻止产出与执行
$XLANG build -backend c -o /tmp/xlang_export_dead_priv tests/export/lint_unused_private.x >/dev/null 2>&1 \
  || fail "build must succeed despite unused private"
rc=0
/tmp/xlang_export_dead_priv || rc=$?
[[ "$rc" -eq 0 ]] || fail "run unused-private program want 0 got $rc"
pass "build+run ok with unused private"

echo "run-export: all passed"
