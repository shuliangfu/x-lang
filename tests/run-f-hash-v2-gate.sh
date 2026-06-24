#!/usr/bin/env bash
# F-hash v2：std.hash 逻辑全量 .sx（删除 hash_glue.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_HASH_V2_FAIL:-0}
DOC="analysis/phase-f-hash-v2.md"
MANIFEST="tests/baseline/f-hash-v2-closure.tsv"
die() { echo "f-hash-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-hash v2: SipHash/xxHash/FNV → hash.sx (zero glue) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-hash v2' "$DOC" || die "doc marker"
[ -f std/hash/hash.sx ] || die "missing hash.sx"
[ ! -f std/hash/hash_glue.c ] || die "hash_glue.c should be deleted"
[ ! -f std/hash/hash.c ] || die "hash.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'hash_sip_new_c' std/hash/hash.sx || die "hash.sx missing sip new"
grep -q 'hash_xxhash64_bytes_c' std/hash/hash.sx || die "hash.sx missing xxhash"
grep -q 'hash_hasher_switch_smoke_c' std/hash/hash.sx || die "hash.sx missing smoke"
grep -q 'hash_f_hash_v2_marker_c' std/hash/hash.sx || die "hash.sx missing v2 marker"
grep -q 'F-hash v2' compiler/Makefile || die "Makefile missing F-hash v2 note"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/hash/hash.o >/dev/null 2>&1 || die "make hash.o failed"
else
  echo "f-hash-v2 SKIP hash.o build (no shux-c)" >&2
fi
for sub in run-std-hash-hasher-trait-gate.sh run-std-hash-xxhash-gate.sh \
  run-std-hash-default-strategy-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-hash-v2 gate OK"
