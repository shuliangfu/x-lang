#!/usr/bin/env bash
# F-url v1：std.url 去 C（url.c → url.sx + url_glue.c inet 胶层）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_URL_V1_FAIL:-0}
DOC="analysis/phase-f-url-v1.md"
MANIFEST="tests/baseline/f-url-v1-closure.tsv"
die() { echo "f-url-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-url v1: url.c → url.sx + glue ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-url v1' "$DOC" || die "doc marker"
[ -f std/url/url.sx ] || die "missing url.sx"
[ ! -f std/url/url_glue.c ] || die "url_glue.c should be deleted (F-ZC)"
[ ! -f std/url/url.c ] || die "url.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'url.sx' compiler/Makefile || die "Makefile missing url.sx"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/url/url.o >/dev/null 2>&1 || die "make url.o failed"
else
  echo "f-url-v1 SKIP url.o build (no shux-c)" >&2
fi
for sub in run-std-url-gate.sh run-std-url-ipv6-host-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-url-v1 gate OK"
