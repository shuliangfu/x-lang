#!/usr/bin/env bash
# 键 C P0 总门禁 — 自举前必须清单 §十二 P0 七项
#
# 汇总 V6 / C6 / §9.1 / spill / V4V5 / S7 / L9；输出分项 PASS/WARN/SKIP/FAIL。
# 键 C 闭合须七项全 PASS（WARN 仅 staging，不算闭合）。
#
# 用法：./tests/run-bootstrap-keyc-p0-gate.sh
# 环境：SHUX_KEYC_P0_ALLOW_WARN=1 — 有 WARN 仍 exit 0（CI 渐进）
set -euo pipefail
cd "$(dirname "$0")/.."

DOC="analysis/自举前必须清单.md"
[ -f "$DOC" ] || { echo "keyc-p0 gate FAIL: missing $DOC" >&2; exit 1; }

# id|gate脚本|必绿(1=strict)
P0_GATES=(
  "P0#1-V6|run-bootstrap-fresh-seed-gate.sh|1"
  "P0#2-C6|run-bootstrap-c6-asm-o-gate.sh|0"
  "P0#3-9.1|run-codegen-semantic-debt-gate.sh|0"
  "P0#4-spill|run-comp-regalloc-result-spill-gate.sh|0"
  "P0#5-anti-collapse|run-bootstrap-anti-collapse-gate.sh|0"
  "P0#6-S7|run-bootstrap-std-harddeps-gate.sh|1"
  "P0#7-L9|run-memory-contract-arena-align-gate.sh|0"
)

PASS=0
WARN=0
SKIP=0
FAIL=0

run_p0_gate() {
  local id="$1" script="$2" strict="$3"
  local path="tests/$script"
  local log="/tmp/shux_keyc_${id//[^a-zA-Z0-9]/_}.log"
  echo ""
  echo "======== $id ($script) ========"
  # V4/V5：无 gen1/gen2 产物时 anti-collapse 由 gold 覆盖，此处 SKIP。
  if [ "$script" = "run-bootstrap-anti-collapse-gate.sh" ]; then
    if [ ! -f compiler/shux_asm_stage1 ] || [ ! -f compiler/shux_asm2 ]; then
      echo "keyc-p0: $id SKIP (no stage1/2; V4/V5 见 bootstrap-gold)"
      SKIP=$((SKIP + 1))
      return
    fi
  fi
  if [ ! -f "$path" ]; then
    echo "keyc-p0 FAIL: missing $path" >&2
    FAIL=$((FAIL + 1))
    return
  fi
  chmod +x "$path"
  set +e
  ./tests/"$script" >"$log" 2>&1
  local ec=$?
  set -e
  tail -6 "$log" 2>/dev/null || cat "$log"
  if [ "$ec" -eq 0 ]; then
    if grep -qiE 'WARN|typeck-only|manifest-only|待 C6|待修' "$log"; then
      echo "keyc-p0: $id WARN"
      WARN=$((WARN + 1))
    else
      echo "keyc-p0: $id PASS"
      PASS=$((PASS + 1))
    fi
    return
  fi
  if grep -qiE 'SKIP|skip' "$log"; then
    echo "keyc-p0: $id SKIP"
    SKIP=$((SKIP + 1))
    if [ "$strict" = "1" ]; then
      FAIL=$((FAIL + 1))
    fi
    return
  fi
  echo "keyc-p0: $id FAIL (ec=$ec)" >&2
  FAIL=$((FAIL + 1))
}

# P0#5 由 run_p0_gate 内按 stage1/2 是否存在决定 SKIP
for row in "${P0_GATES[@]}"; do
  IFS='|' read -r id script strict <<<"$row"
  run_p0_gate "$id" "$script" "$strict"
done

echo ""
echo "======== 键 C P0 汇总 ========"
echo "PASS=$PASS WARN=$WARN SKIP=$SKIP FAIL=$FAIL"

if [ "$FAIL" -gt 0 ]; then
  echo "keyc-p0 gate FAIL ($FAIL item(s))" >&2
  exit 1
fi
if [ "$WARN" -gt 0 ] || [ "$SKIP" -gt 0 ]; then
  if [ "${SHUX_KEYC_P0_ALLOW_WARN:-0}" = "1" ]; then
    echo "keyc-p0 gate OK with WARN/SKIP (SHUX_KEYC_P0_ALLOW_WARN=1; 键 C 未闭合)"
    exit 0
  fi
  echo "keyc-p0 gate INCOMPLETE: 键 C 须 PASS=7；当前 WARN=$WARN SKIP=$SKIP" >&2
  exit 1
fi
echo "keyc-p0 gate OK (键 C P0 七项全绿)"
