#!/usr/bin/env bash
# F-url v2：std.url 逻辑下沉（parse/build/query/resolve → url.x；F-ZC 纯 .x 无 inet glue）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_URL_V2_FAIL:-0}
DOC="analysis/phase-f-url-v2.md"
MANIFEST="tests/baseline/f-url-v2-closure.tsv"
die() { echo "f-url-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-url v2: URL logic → url.x (F-ZC zero C) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-url v2' "$DOC" || die "doc marker"
[ -f std/url/url.x ] || die "missing url.x"
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
grep -q 'url_parse_c' std/url/url.x || die "url.x missing parse"
grep -q 'url_resolve_c' std/url/url.x || die "url.x missing resolve"
grep -q 'url_smoke_c' std/url/url.x || die "url.x missing smoke"
grep -q 'url_f_url_v2_marker_c' std/url/url.x || die "url.x missing v2 marker"
grep -q 'url_f_zero_c_marker_c' std/url/url.x || die "url.x missing zero-c marker"
grep -q 'url_inet_pton6_c' std/url/url.x || die "url.x missing inet_pton"
grep -q 'inet_ntop' std/url/url.x || die "url.x missing inet_ntop extern"
grep -q 'url.x' compiler/Makefile || die "Makefile missing url.x"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/url/url.o >/dev/null 2>&1 || die "make url.o failed"
else
  echo "f-url-v2 SKIP url.o build (no shux-c)" >&2
fi
for sub in run-std-url-gate.sh run-std-url-ipv6-host-gate.sh; do
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-url-v2 gate OK"
