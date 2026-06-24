#!/usr/bin/env bash
# F-08 v1：core/ 手写 C 存量确认（4 文件 + mod.sx + 专 gate）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F08_CORE_INVENTORY_FAIL:-0}
DOC="analysis/phase-f-f08-v1.md"
MANIFEST="tests/baseline/f08-core-inventory.tsv"
die() { echo "f08-core-inventory gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }

echo "=== F-08 v1: core/ handwritten C inventory ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-08 v1' "$DOC" || die "doc marker"
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
ACTUAL="$(find core -name '*.c' 2>/dev/null | wc -l | tr -d ' ')"
[ "$ACTUAL" = "0" ] || die "expected 0 core .c files, found $ACTUAL"
[ "$CORE_N" = "0" ] || die "manifest core .c count $CORE_N != 0 (G-01: core 零 C)"
chmod +x tests/run-std-c-inventory-gate.sh
tests/run-std-c-inventory-gate.sh || die "std-c-inventory failed"
echo "f08-core-inventory gate OK (core .c=$ACTUAL)"
