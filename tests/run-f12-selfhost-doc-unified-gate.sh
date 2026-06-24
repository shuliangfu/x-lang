#!/usr/bin/env bash
# F-12 v1：README + SELFHOST 完全自举口径统一（D+E+F；Stage2 非终局）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F12_SELFHOST_DOC_UNIFIED_FAIL:-0}
DOC="analysis/phase-f-f12-v1.md"
MANIFEST="tests/baseline/f12-selfhost-doc-unified.tsv"
die() { echo "f12-selfhost-doc-unified gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }

echo "=== F-12 v1: selfhost doc unified (D+E+F) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-12 v1' "$DOC" || die "doc marker"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile|script) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    gate_ref) [ -f "$anchor" ] || die "missing gate_ref $anchor ($item_id)" ;;
  esac
done < "$MANIFEST"

for kw in 'D+E+F' '完全自举' '黄金自举' '阶段 D'; do
  grep -qF "$kw" compiler/docs/SELFHOST.md || die "SELFHOST missing '$kw'"
done
grep -qF 'SELFHOST.md' README.md || die "README missing SELFHOST link"
grep -qE 'Stage2|语义自举' README.md || die "README missing Stage2/semantic selfhost row"
grep -qF '阶段 F' README.md || die "README missing 阶段 F"
grep -qF 'D+E+F' README.md || die "README missing D+E+F"

if grep -q 'Shux 完全自举验证' compiler/verify-selfhost.sh 2>/dev/null; then
  die "verify-selfhost.sh still claims 完全自举 in title"
fi
if grep -qE '^echo " Shux 完全自举' compiler/verify-selfhost-stage2.sh 2>/dev/null; then
  die "verify-selfhost-stage2.sh banner still claims bare 完全自举"
fi
if grep -q '✓ 完全自举验证通过' compiler/verify-selfhost-stage2.sh 2>/dev/null; then
  die "verify-selfhost-stage2.sh success message still claims 完全自举"
fi

chmod +x tests/run-d06-selfhost-doc-gate.sh
tests/run-d06-selfhost-doc-gate.sh || die "d06 doc gate failed"

echo "f12-selfhost-doc-unified gate OK"
