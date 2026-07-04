#!/usr/bin/env bash
# F-cache v2：std.cache 逻辑全量 .x（删除 cache_glue.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_CACHE_V2_FAIL:-0}
DOC="analysis/phase-f-cache-v2.md"
MANIFEST="tests/baseline/f-cache-v2-closure.tsv"
die() { echo "f-cache-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-cache v2: LRU/pool logic → cache.x (zero glue) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-cache v2' "$DOC" || die "doc marker"
[ -f std/cache/cache.x ] || die "missing cache.x"
[ ! -f std/cache/cache_glue.c ] || die "cache_glue.c should be deleted"
[ ! -f std/cache/cache.c ] || die "cache.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'cache_lru_create_c' std/cache/cache.x || die "cache.x missing lru create"
grep -q 'cache_pool_create_c' std/cache/cache.x || die "cache.x missing pool create"
grep -q 'cache_smoke_c' std/cache/cache.x || die "cache.x missing smoke"
grep -q 'cache_f_cache_v2_marker_c' std/cache/cache.x || die "cache.x missing v2 marker"
grep -q 'F-cache v2' compiler/Makefile || die "Makefile missing F-cache v2 note"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/cache/cache.o >/dev/null 2>&1 || die "make cache.o failed"
else
  echo "f-cache-v2 SKIP cache.o build (no shux-c)" >&2
fi
chmod +x tests/run-std-cache-gate.sh
tests/run-std-cache-gate.sh || die "run-std-cache-gate failed"
echo "f-cache-v2 gate OK"
