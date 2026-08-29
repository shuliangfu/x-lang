#!/usr/bin/env bash
# SAFE-003: unsafe audit ledger — leftover dual-authority DOC →硬绿.
#
# Honesty: leftover top-level `analysis/safe-unsafe-audit-v1.md` /
# `analysis/safe-unsafe-api-v1.md` (identical copies of archive/safe;
# false dual authority) retired. Live = analysis/archive/safe/. Refuse
# top-level resurrect. Nested run-safe-unsafe-api-gate.sh leftover
# "accept top-level until SAFE soft knife" retired in the same wave.
# Ledger coverage + nested SAFE-002 inventory remain hard. No XLANG
# face (G.7: do not fork a resolver). Report: run=/obs=/skip=.
# Keep `safe-unsafe-audit gate OK`.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-safe-unsafe-audit-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

DOC="${XLANG_SAFE_UNSAFE_AUDIT_DOC:-analysis/archive/safe/safe-unsafe-audit-v1.md}"
API_DOC="${XLANG_SAFE_UNSAFE_API_DOC:-analysis/archive/safe/safe-unsafe-api-v1.md}"
API_TSV="${XLANG_SAFE_UNSAFE_API_TSV:-tests/baseline/safe-unsafe-api.tsv}"
EXT_TSV="${XLANG_SAFE_UNSAFE_EXTERN_TSV:-tests/baseline/safe-unsafe-extern.tsv}"
AUDIT_TSV="${XLANG_SAFE_UNSAFE_AUDIT_TSV:-tests/baseline/safe-unsafe-audit.tsv}"
PREFIX="xlang: [XLANG_SAFE_AUDIT]"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "safe-unsafe-audit gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

echo "=== SAFE-003: unsafe audit manifest (archive DOC; refuse leftover dual-authority) ==="
if [ -f analysis/safe-unsafe-audit-v1.md ]; then
  die "dual-authority fossil analysis/safe-unsafe-audit-v1.md (archive live)"
fi
if [ -f analysis/safe-unsafe-api-v1.md ]; then
  die "dual-authority fossil analysis/safe-unsafe-api-v1.md (archive live)"
fi
for f in \
  "$DOC" \
  "$API_DOC" \
  "$AUDIT_TSV" \
  "$API_TSV" \
  "$EXT_TSV" \
  tests/templates/safe-unsafe-audit-entry.txt; do
  [ -f "$f" ] || die "missing $f"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
echo "safe-unsafe-audit manifest OK"

# 读取 audit ledger 到关联数组（bash 3.2+ 兼容：用临时文件）
AUDIT_KEYS="$(mktemp /tmp/xlang_audit_keys.XXXXXX)"
AUDIT_ORPHAN="$(mktemp /tmp/xlang_audit_orphan.XXXXXX)"
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
  die "${FAILS} issue(s) (refuse leftover dual-authority DOC / leftover SKIP→OK)"
fi

echo "=== SAFE-003: SAFE-002 inventory hook (refuse leftover accept top-level) ==="
chmod +x tests/run-safe-unsafe-api-gate.sh
# Nested SAFE-002 leftover "accept top-level until SAFE soft knife" retired
# in this wave. Ledger coverage stays hard; no XLANG face on this host.
./tests/run-safe-unsafe-api-gate.sh || die "nested SAFE-002 failed (refuse leftover dual-authority DOC / leftover SKIP→OK)"
RUN_OK=$((RUN_OK + 1))

echo "safe-unsafe-audit gate OK"
ok_report
exit 0
