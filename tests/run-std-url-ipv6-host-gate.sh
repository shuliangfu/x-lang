#!/usr/bin/env bash
# STD-134：std.url IPv6 bracket host 门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-url-ipv6-host-v1.md"
MANIFEST="tests/baseline/std-url-ipv6-host-manifest.tsv"
MOD_SU="std/url/mod.su"
URL_C="std/url/url.c"
LIB="tests/lib/std-url-ipv6-host.sh"
SMOKE_SU="tests/std-url/ipv6_host.su"
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$URL_C" "$SMOKE_SU"; do
  [ -f "$f" ] || { echo "std-url-ipv6-host gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-134 "$DOC" || { echo "std-url-ipv6-host gate FAIL: doc" >&2; exit 1; }
sym_miss="$(std_url_ipv6_host_symbols_ok "$MOD_SU" "$URL_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/url/url.o
URL_O="$(cd compiler && pwd)/../std/url/url.o"
C_OK=0
std_url_ipv6_host_run_c_smoke "$URL_O" && C_OK=1 || exit 1
SU_OK=0
SKIP=0
if [ -x ./compiler/shu-c ]; then
  ./compiler/shu-c check -L . "$SMOKE_SU" >/dev/null
  std_url_ipv6_host_run_smoke ./compiler/shu-c "$SMOKE_SU" && SU_OK=1 || exit 1
else
  SKIP=1
fi
std_url_ipv6_host_emit_report ok "$C_OK" "$SU_OK" "$SKIP"
echo "std-url-ipv6-host gate OK"
