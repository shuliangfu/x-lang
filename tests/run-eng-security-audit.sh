#!/usr/bin/env bash
# ENG-007：安全扫描与依赖审计 runner
#
# 用法：
#   ./tests/run-eng-security-audit.sh
#   SHU_SEC_AUDIT_PROBE=1 ./tests/run-eng-security-audit.sh
set -e
cd "$(dirname "$0")/.."

INVENTORY="${SHU_SEC_INVENTORY:-tests/templates/eng-security-audit-inventory.txt}"

# shellcheck source=tests/lib/eng-security-audit.sh
. tests/lib/eng-security-audit.sh

echo "=== ENG-007: security audit periodic scan ==="

INV_STATUS="fail"
NPM_STATUS="skip"
SECRET_STATUS="fail"
ROWS=0
FAIL=0

if ROWS="$(eng_sec_inventory_scan "$INVENTORY")"; then
  INV_STATUS="ok"
else
  FAIL=$((FAIL + 1))
  ROWS=0
fi

if eng_sec_secret_probe; then
  SECRET_STATUS="ok"
else
  SECRET_STATUS="fail"
  FAIL=$((FAIL + 1))
fi

npm_ec=0
eng_sec_npm_audit || npm_ec=$?
case "$npm_ec" in
  0) NPM_STATUS="ok" ;;
  2) NPM_STATUS="skip" ;;
  *) NPM_STATUS="fail"; FAIL=$((FAIL + 1)) ;;
esac

if [ "$FAIL" -gt 0 ]; then
  eng_sec_emit_report "fail" "$INV_STATUS" "$NPM_STATUS" "$SECRET_STATUS" "$ROWS"
  echo "eng-security-audit FAIL" >&2
  exit 1
fi

eng_sec_emit_report "ok" "$INV_STATUS" "$NPM_STATUS" "$SECRET_STATUS" "$ROWS"
echo "eng-security-audit OK"
