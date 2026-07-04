#!/usr/bin/env bash
# STD-134：std.url IPv6 bracket host 门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-url-ipv6-host-v1.md"
MANIFEST="tests/baseline/std-url-ipv6-host-manifest.tsv"
MOD_X="std/url/mod.x"
URL_X="std/url/url.x"
LIB="tests/lib/std-url-ipv6-host.sh"
SMOKE_X="tests/std-url/ipv6_host.x"
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$URL_X" "$SMOKE_X"; do
  [ -f "$f" ] || { echo "std-url-ipv6-host gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-134 "$DOC" || { echo "std-url-ipv6-host gate FAIL: doc" >&2; exit 1; }
sym_miss="$(std_url_ipv6_host_symbols_ok "$MOD_X" "$URL_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
. tests/lib/build-std-c-o.sh
C_OK=0
SKIP=0
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  ensure_std_c_o ../std/url/url.o
  URL_O="$(cd compiler && pwd)/../std/url/url.o"
  std_url_ipv6_host_run_c_smoke "$URL_O" && C_OK=1 || exit 1
else
  echo "std-url-ipv6-host gate SKIP c smoke (need shux-c)" >&2
  SKIP=1
fi
X_OK=0
SKIP=0
if [ -x ./compiler/shux-c ]; then
  ./compiler/shux-c check -L . "$SMOKE_X" >/dev/null
  std_url_ipv6_host_run_smoke ./compiler/shux-c "$SMOKE_X" && X_OK=1 || exit 1
else
  SKIP=1
fi
std_url_ipv6_host_emit_report ok "$C_OK" "$X_OK" "$SKIP"
echo "std-url-ipv6-host gate OK"
