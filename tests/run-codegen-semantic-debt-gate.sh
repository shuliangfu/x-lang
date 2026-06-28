#!/usr/bin/env bash
# §9.1 / P0#3：Codegen 语义债回归门禁
#
# 跑 W3 已知 workaround 对应 gate；默认允许 shux-c 回退（🟡）；
# SHUX_CODEGEN_DEBT_STRICT=1 时任一项 FAIL 即 exit 1。
#
# 用法：./tests/run-codegen-semantic-debt-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/gate-progress.sh
source tests/lib/gate-progress.sh

DOC="analysis/自举前必须清单.md"
[ -f "$DOC" ] || { gate_progress "FAIL: missing $DOC"; exit 1; }
grep -qF "§9.1" "$DOC" || grep -qF "9.1 Codegen" "$DOC" || {
  gate_progress "FAIL: doc missing §9.1"
  exit 1
}

# 名称|脚本|说明
DEBT_CASES=(
  "compound-assign|run-compound-assign.sh|复合赋值+if 第二处"
  "time-call-hoist|run-time.sh|CALL 返回值 hoist"
  "i64-ctfe|run-i64-ctfe-gate.sh|i64 比较/asm"
  "struct|run-struct.sh|struct -o"
  "result|run-result.sh|16B Result ABI"
)

STRICT="${SHUX_CODEGEN_DEBT_STRICT:-0}"
FAIL=0
WARN=0
gate_progress "§9.1: codegen semantic debt (STRICT=$STRICT, ${#DEBT_CASES[@]} cases)"

run_debt() {
  local id="$1" script="$2" note="$3"
  local path="tests/$script"
  if [ ! -f "$path" ]; then
    gate_progress "FAIL: missing $path ($id)"
    return 1
  fi
  chmod +x "$path"
  if SHUX_SKIP_SUBSCRIPT_MAKE=1 gate_progress_run "§9.1 $id ($note)" ./tests/"$script"; then
    return 0
  fi
  return 1
}

for row in "${DEBT_CASES[@]}"; do
  IFS='|' read -r id script note <<<"$row"
  if run_debt "$id" "$script" "$note"; then
    continue
  fi
  if [ "$STRICT" = "1" ]; then
    FAIL=$((FAIL + 1))
  else
    WARN=$((WARN + 1))
    gate_progress "WARN $id (§9.1 待修)"
  fi
done

if [ "$FAIL" -gt 0 ]; then
  gate_progress "codegen-semantic-debt gate FAIL: $FAIL case(s)"
  exit 1
fi
if [ "$WARN" -gt 0 ]; then
  gate_progress "codegen-semantic-debt gate OK with $WARN WARN (键 C 前须逐条修绿)"
  exit 0
fi
gate_progress "codegen-semantic-debt gate OK (all green)"
