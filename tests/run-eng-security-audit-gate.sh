#!/usr/bin/env bash
# ENG-007：安全扫描与依赖审计 manifest 门禁
#
# 用法：./tests/run-eng-security-audit-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_SEC_DOC:-analysis/eng-security-audit-v1.md}"
MANIFEST="${SHU_SEC_MANIFEST:-tests/baseline/eng-security-audit.tsv}"
INVENTORY="tests/templates/eng-security-audit-inventory.txt"
LIB="tests/lib/eng-security-audit.sh"
RUNNER="tests/run-eng-security-audit.sh"
MIN_TRACKS=4
PREFIX="shu: [SHU_SECURITY_AUDIT]"

# shellcheck source=tests/lib/eng-security-audit.sh
. tests/lib/eng-security-audit.sh

echo "=== ENG-007: security audit manifest ==="
for f in "$DOC" "$MANIFEST" "$INVENTORY" "$LIB" "$RUNNER"; do
  if [ ! -f "$f" ]; then
    echo "eng-security-audit gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in runnable report SHU_SECURITY_AUDIT T1-deps-inventory periodic audit; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "eng-security-audit gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_tracks) MIN_TRACKS="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
TRACK_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$item_id" in
    read_path|tracks|inventory|report|schedule)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "eng-security-audit FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    track_*)
      TRACK_N=$((TRACK_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "eng-security-audit FAIL: doc missing track $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    inventory_file)
      if [ ! -f "$src" ]; then
        echo "eng-security-audit FAIL: missing $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "eng-security-audit FAIL: doc missing inventory ref" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    lib|runner|gate)
      if [ ! -f "$src" ]; then
        echo "eng-security-audit FAIL: missing $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "eng-security-audit FAIL: doc missing ref $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    workflow)
      if [ ! -f "$src" ]; then
        echo "eng-security-audit FAIL: missing workflow $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "eng-security-audit FAIL: doc missing workflow $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_*)
      if [ ! -f "$anchor" ]; then
        echo "eng-security-audit FAIL: missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$TRACK_N" -lt "$MIN_TRACKS" ]; then
  echo "eng-security-audit gate FAIL: tracks=${TRACK_N} < min ${MIN_TRACKS}" >&2
  exit 1
fi
if ! grep -qF 'eng_sec_emit_report' "$RUNNER" 2>/dev/null; then
  echo "eng-security-audit gate FAIL: runner must emit report" >&2
  MISS=$((MISS + 1))
fi
if [ "$MISS" -gt 0 ]; then
  echo "eng-security-audit gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "eng-security-audit manifest OK (tracks=${TRACK_N})"

echo "=== ENG-007: inventory + secret smoke ==="
if ! ROWS="$(eng_sec_inventory_scan "$INVENTORY")"; then
  echo "eng-security-audit gate FAIL: inventory scan" >&2
  exit 1
fi
if ! eng_sec_secret_probe; then
  echo "eng-security-audit gate FAIL: secret probe" >&2
  exit 1
fi
echo "eng-security-audit inventory OK (rows=${ROWS})"

echo "=== ENG-007: runnable report ==="
chmod +x "$RUNNER" "$LIB"
if ! ./"$RUNNER" 2>&1 | tee /tmp/eng_security_audit_smoke.log; then
  echo "eng-security-audit gate FAIL: runner" >&2
  exit 1
fi
grep -qF "$PREFIX" /tmp/eng_security_audit_smoke.log || {
  echo "eng-security-audit gate FAIL: missing report prefix" >&2
  exit 1
}
grep -q 'eng-security-audit OK' /tmp/eng_security_audit_smoke.log || {
  echo "eng-security-audit gate FAIL: runner did not OK" >&2
  exit 1
}
echo "eng-security-audit gate OK"
