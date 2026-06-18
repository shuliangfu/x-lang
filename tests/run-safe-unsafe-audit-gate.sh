#!/usr/bin/env bash
# SAFE-003：unsafe 审计 ledger 门禁
#
# 验证 SAFE-002 清单中每条 tier-u / tier-e 在 safe-unsafe-audit.tsv 有完整审计记录。
# 用法：./tests/run-safe-unsafe-audit-gate.sh
set -e
cd "$(dirname "$0")/.."

API_TSV="${SHU_SAFE_UNSAFE_API_TSV:-tests/baseline/safe-unsafe-api.tsv}"
EXT_TSV="${SHU_SAFE_UNSAFE_EXTERN_TSV:-tests/baseline/safe-unsafe-extern.tsv}"
AUDIT_TSV="${SHU_SAFE_UNSAFE_AUDIT_TSV:-tests/baseline/safe-unsafe-audit.tsv}"

echo "=== SAFE-003: unsafe audit manifest ==="
for f in \
  analysis/safe-unsafe-audit-v1.md \
  analysis/safe-unsafe-api-v1.md \
  "$AUDIT_TSV" \
  tests/templates/safe-unsafe-audit-entry.txt; do
  if [ ! -f "$f" ]; then
    echo "safe-unsafe-audit gate FAIL: missing $f" >&2
    exit 1
  fi
done
echo "safe-unsafe-audit manifest OK"

# 读取 audit ledger 到关联数组（bash 3.2+ 兼容：用临时文件）
AUDIT_KEYS="$(mktemp /tmp/shu_audit_keys.XXXXXX)"
AUDIT_ORPHAN="$(mktemp /tmp/shu_audit_orphan.XXXXXX)"
: > "$AUDIT_KEYS"
: > "$AUDIT_ORPHAN"

audit_lookup() {
  local scope="$1" sym="$2"
  awk -F'\t' -v s="$scope" -v n="$sym" \
    '$0 !~ /^#/ && $1==s && $2==n {print; found=1; exit} END{exit !found}' \
    "$AUDIT_TSV"
}

audit_validate_row() {
  local scope="$1" sym="$2" owner="$3" rationale="$4" reviewer="$5" adate="$6"
  if [ -z "$owner" ] || [ -z "$rationale" ] || [ -z "$reviewer" ] || [ -z "$adate" ]; then
    echo "safe-unsafe-audit FAIL: empty field for ${scope}:${sym}" >&2
    return 1
  fi
  if ! printf '%s' "$adate" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
    echo "safe-unsafe-audit FAIL: bad audit_date for ${scope}:${sym}: $adate" >&2
    return 1
  fi
  return 0
}

FAILS=0
echo "=== SAFE-003: audit ledger field check ==="
while IFS=$'\t' read -r scope sym owner rationale reviewer adate; do
  [ -z "${scope:-}" ] && continue
  case "$scope" in \#*) continue ;; esac
  echo "${scope}:${sym}" >> "$AUDIT_ORPHAN"
  if ! audit_validate_row "$scope" "$sym" "$owner" "$rationale" "$reviewer" "$adate"; then
    FAILS=$((FAILS + 1))
  fi
done < "$AUDIT_TSV"
AUDIT_N="$(grep -cv '^#' "$AUDIT_TSV" 2>/dev/null || echo 0)"
echo "safe-unsafe-audit ledger rows: ${AUDIT_N}"

echo "=== SAFE-003: tier-u coverage (SAFE-002 API) ==="
U_MISS=0
U_N=0
while IFS=$'\t' read -r sym kind mod mode src; do
  [ -z "${sym:-}" ] && continue
  case "$sym" in \#*) continue ;; esac
  U_N=$((U_N + 1))
  row="$(audit_lookup tier-u "$sym" || true)"
  if [ -z "$row" ]; then
    echo "safe-unsafe-audit FAIL: missing tier-u audit for $sym" >&2
    U_MISS=$((U_MISS + 1))
    FAILS=$((FAILS + 1))
    continue
  fi
  echo "tier-u:${sym}" >> "$AUDIT_KEYS"
done < "$API_TSV"
if [ "$U_MISS" -gt 0 ]; then
  echo "safe-unsafe-audit tier-u missing: ${U_MISS}/${U_N}" >&2
else
  echo "safe-unsafe-audit tier-u OK (${U_N}/${U_N})"
fi

echo "=== SAFE-003: tier-e coverage (SAFE-002 extern) ==="
E_MISS=0
E_N=0
while IFS=$'\t' read -r src en; do
  [ -z "${src:-}" ] && continue
  case "$src" in \#*) continue ;; esac
  E_N=$((E_N + 1))
  row="$(audit_lookup tier-e "$en" || true)"
  if [ -z "$row" ]; then
    echo "safe-unsafe-audit FAIL: missing tier-e audit for $en" >&2
    E_MISS=$((E_MISS + 1))
    FAILS=$((FAILS + 1))
    continue
  fi
  echo "tier-e:${en}" >> "$AUDIT_KEYS"
done < "$EXT_TSV"
if [ "$E_MISS" -gt 0 ]; then
  echo "safe-unsafe-audit tier-e missing: ${E_MISS}/${E_N}" >&2
else
  echo "safe-unsafe-audit tier-e OK (${E_N}/${E_N})"
fi

echo "=== SAFE-003: orphan audit rows ==="
ORPHAN=0
while IFS=$'\t' read -r scope sym _rest; do
  [ -z "${scope:-}" ] && continue
  case "$scope" in \#*) continue ;; esac
  key="${scope}:${sym}"
  if ! grep -qxF "$key" "$AUDIT_KEYS" 2>/dev/null; then
    echo "safe-unsafe-audit FAIL: orphan audit row $key (not in SAFE-002 lists)" >&2
    ORPHAN=$((ORPHAN + 1))
    FAILS=$((FAILS + 1))
  fi
done < "$AUDIT_TSV"
if [ "$ORPHAN" -eq 0 ]; then
  echo "safe-unsafe-audit no orphans OK"
fi

rm -f "$AUDIT_KEYS" "$AUDIT_ORPHAN"

if [ "$FAILS" -gt 0 ]; then
  echo "safe-unsafe-audit gate FAIL: ${FAILS} issue(s)" >&2
  exit 1
fi

echo "=== SAFE-003: SAFE-002 inventory hook ==="
chmod +x tests/run-safe-unsafe-api-gate.sh
./tests/run-safe-unsafe-api-gate.sh

echo "safe-unsafe-audit gate OK"
