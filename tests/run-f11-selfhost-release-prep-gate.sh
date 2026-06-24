#!/usr/bin/env bash
# F-11 v1：完全自举发布 checklist（文档 + 子 gate 委托；不要求已打 tag）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F11_SELFHOST_RELEASE_PREP_FAIL:-0}
DOC="analysis/phase-f-f11-v1.md"
MANIFEST="tests/baseline/f11-selfhost-release-prep.tsv"
die() { echo "f11-selfhost-release-prep gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }

echo "=== F-11 v1: selfhost release prep checklist ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-11 v1' "$DOC" || die "doc marker"
grep -q 'vX.Y.Z-selfhost' "$DOC" || die "doc missing tag format"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    gate_ref) [ -f "$anchor" ] || die "missing gate_ref $anchor ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'D+E+F' compiler/docs/SELFHOST.md || die "SELFHOST missing D+E+F"
grep -q '完全自举' compiler/docs/SELFHOST.md || die "SELFHOST missing 完全自举"

for sub in run-d03-stage2-hash-gate.sh run-d05-single-shux-release-gate.sh \
  run-f-std-de-c-batch-gate.sh; do
  [ -f "tests/$sub" ] || die "missing tests/$sub"
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done

if [ -f tests/run-e-soft-retire-gate.sh ]; then
  chmod +x tests/run-e-soft-retire-gate.sh
  tests/run-e-soft-retire-gate.sh || die "e-soft-retire failed"
fi

if [ -f tests/run-d04-stage2-portable-diff-gate.sh ]; then
  chmod +x tests/run-d04-stage2-portable-diff-gate.sh
  tests/run-d04-stage2-portable-diff-gate.sh || die "d04 failed"
fi

echo "f11-selfhost-release-prep gate OK (checklist green; tag on release)"
