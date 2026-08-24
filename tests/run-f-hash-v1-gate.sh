#!/usr/bin/env bash
# F-hash v1：std.hash 去 C（hash.c → hash.x；v2 后逻辑全在 hash.x）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_HASH_V1_FAIL:-0}
DOC="analysis/archive/phase/phase-f-hash-v1.md"
MANIFEST="tests/baseline/f-hash-v1-closure.tsv"
die() { echo "f-hash-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-hash v1: hash.c → hash.x + glue ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-hash v1' "$DOC" || die "doc marker"
[ -f std/hash/hash.x ] || die "missing hash.x"
[ ! -f std/hash/hash.c ] || die "hash.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/hash/hash.o >/dev/null 2>&1 || die "ensure hash.o failed (xlang_compiler_make)"
else
  echo "f-hash-v1 SKIP hash.o build (no xlang-c)" >&2
fi
for sub in run-std-hash-hasher-trait-gate.sh run-std-hash-xxhash-gate.sh \
  run-std-hash-default-strategy-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-hash-v1 gate OK"
