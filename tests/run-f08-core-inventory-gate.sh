#!/usr/bin/env bash
# F-08: core/ handwritten C inventory (G-01 closed: zero core .c).
#
# Usage: ./tests/run-f08-core-inventory-gate.sh
# 2026-08-26: Honesty — hard-fail archive DOC + zero-core + F-01 inventory
# (no soft die→exit0). Soft XLANG_F08_CORE_INVENTORY_FAIL retired. DOC live
# face = analysis/archive/phase/ (refuse top-level resurrect). compiler/Makefile
# deleted — refuse resurrect (use ./xbuild). Report
# doc=/manifest=/core_zero=/inventory=/skip=. Gate was portable-false-green
# (soft FAIL exit0 while static zero-core already green).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_F08_DOC:-analysis/archive/phase/phase-f-f08-v1.md}"
MANIFEST="tests/baseline/f08-core-inventory.tsv"
PREFIX="xlang: [XLANG_F08_CORE]"

die() {
  echo "f08-core-inventory gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK:-0} manifest=${MANIFEST_OK:-0} core_zero=${CORE_ZERO_OK:-0} inventory=${INVENTORY_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

DOC_OK=0
MANIFEST_OK=0
CORE_ZERO_OK=0
INVENTORY_OK=0
SKIP=1

echo "=== F-08: core/ handwritten C inventory (honesty; G-01 zero .c) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-08 v1' "$DOC" || die "doc missing F-08 v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-f-f08-v1.md ]; then
  die "top-level F-08 DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
DOC_OK=1

CORE_N=0
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    gate_ref)
      [ -f "$anchor" ] || die "missing gate_ref $anchor ($item_id)"
      ;;
  esac
  case "$kind" in
    file)
      case "$anchor" in core/*/*.c) CORE_N=$((CORE_N + 1)) ;; esac
      ;;
  esac
done < "$MANIFEST"
MANIFEST_OK=1

ACTUAL="$(find core -name '*.c' 2>/dev/null | wc -l | tr -d ' ')"
[ "$ACTUAL" = "0" ] || die "expected 0 core .c files, found $ACTUAL"
[ "$CORE_N" = "0" ] || die "manifest core .c count $CORE_N != 0 (G-01: core 零 C)"
CORE_ZERO_OK=1

chmod +x tests/run-std-c-inventory-gate.sh
# Hard-delegate; soft XLANG_STD_C_INVENTORY_FAIL retired (honesty).
# PLATFORM: SHARED archaeology.
if ! tests/run-std-c-inventory-gate.sh; then
  die "std-c-inventory failed"
fi
INVENTORY_OK=1
SKIP=0

echo "f08-core-inventory gate OK (core .c=$ACTUAL)"
echo "${PREFIX} status=ok doc=${DOC_OK} manifest=${MANIFEST_OK} core_zero=${CORE_ZERO_OK} inventory=${INVENTORY_OK} skip=${SKIP} host=$(ci_host_summary)"
