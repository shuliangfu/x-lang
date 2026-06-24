#!/usr/bin/env bash
# F-cache v1：std.cache 去 C（cache.c → cache.sx；v2 后逻辑全在 cache.sx）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_CACHE_V1_FAIL:-0}
DOC="analysis/phase-f-cache-v1.md"
MANIFEST="tests/baseline/f-cache-v1-closure.tsv"
die() { echo "f-cache-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-cache v1: cache.c → cache.sx + glue ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-cache v1' "$DOC" || die "doc marker"
[ -f std/cache/cache.sx ] || die "missing cache.sx"
[ ! -f std/cache/cache.c ] || die "cache.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'cache.sx' compiler/Makefile || die "Makefile missing cache.sx"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/cache/cache.o >/dev/null 2>&1 || die "make cache.o failed"
else
  echo "f-cache-v1 SKIP cache.o build (no shux-c)" >&2
fi
chmod +x tests/run-std-cache-gate.sh
tests/run-std-cache-gate.sh || die "run-std-cache-gate failed"
echo "f-cache-v1 gate OK"
