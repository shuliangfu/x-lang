#!/usr/bin/env bash
# F-hash v1：std.hash 去 C（hash.c → hash.sx；v2 后逻辑全在 hash.sx）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_HASH_V1_FAIL:-0}
DOC="analysis/phase-f-hash-v1.md"
MANIFEST="tests/baseline/f-hash-v1-closure.tsv"
die() { echo "f-hash-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-hash v1: hash.c → hash.sx + glue ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-hash v1' "$DOC" || die "doc marker"
[ -f std/hash/hash.sx ] || die "missing hash.sx"
[ ! -f std/hash/hash.c ] || die "hash.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'hash.sx' compiler/Makefile || die "Makefile missing hash.sx"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/hash/hash.o >/dev/null 2>&1 || die "make hash.o failed"
else
  echo "f-hash-v1 SKIP hash.o build (no shux-c)" >&2
fi
for sub in run-std-hash-hasher-trait-gate.sh run-std-hash-xxhash-gate.sh \
  run-std-hash-default-strategy-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-hash-v1 gate OK"
