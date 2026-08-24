#!/usr/bin/env bash
# F-cache v1：std.cache 去 C（cache.c → cache.x；v2 后逻辑全在 cache.x）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_CACHE_V1_FAIL:-0}
DOC="analysis/archive/phase/phase-f-cache-v1.md"
MANIFEST="tests/baseline/f-cache-v1-closure.tsv"
die() { echo "f-cache-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-cache v1: cache.c → cache.x + glue ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-cache v1' "$DOC" || die "doc marker"
[ -f std/cache/cache.x ] || die "missing cache.x"
[ ! -f std/cache/cache.c ] || die "cache.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/cache/cache.o >/dev/null 2>&1 || die "ensure cache.o failed (xlang_compiler_make)"
else
  echo "f-cache-v1 SKIP cache.o build (no xlang-c)" >&2
fi
chmod +x tests/run-std-cache-gate.sh
tests/run-std-cache-gate.sh || die "run-std-cache-gate failed"
echo "f-cache-v1 gate OK"
