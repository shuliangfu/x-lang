#!/usr/bin/env bash
# F-04 v10：std.net DNS/ALPN 去 C 门禁（dns.sx + alpn.sx，net.c 无 resolve/alpn）。
#
# 用法：./tests/run-f04-std-net-dns-alpn-gate.sh
# 环境：SHUX_F04_NET_DNS_ALPN_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F04_NET_DNS_ALPN_FAIL:-0}
DOC="analysis/phase-f-f04-v10.md"
ALPN_SX="std/net/alpn.sx"
DNS_SX="std/net/dns.sx"
NET_C="std/net/net.c"

die() {
  echo "f04-net-dns-alpn gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-04 v10: std.net DNS/ALPN remove from net.c ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v10' "$DOC" || die "doc missing F-04 v10 marker"
[ -f "$ALPN_SX" ] || die "missing alpn.sx"
[ -f "$DNS_SX" ] || die "missing dns.sx"
grep -q 'net_tls_alpn_h2_http1_wire_c' "$ALPN_SX" || die "alpn.sx missing alpn wire"
grep -q 'net_resolve_ipv4_ex_c' "$DNS_SX" || die "dns.sx missing resolve_ex"
grep -q 'net_resolve_ipv6_ex_c' "$DNS_SX" || die "dns.sx missing resolve_ipv6"
if grep -q 'net_resolve_ipv4_ex_c' "$NET_C" 2>/dev/null; then
  die "net.c still defines net_resolve_ipv4_ex_c"
fi
if grep -q 'net_tls_alpn_h2_http1_wire_c' "$NET_C" 2>/dev/null; then
  die "net.c still defines net_tls_alpn_h2_http1_wire_c"
fi
grep -q 'alpn.sx' compiler/Makefile || die "Makefile missing alpn.sx build"
grep -q 'dns.sx' compiler/Makefile || die "Makefile missing dns.sx build"

MANIFEST="tests/baseline/f04-std-net-dns-alpn.tsv"
if [ -f "$MANIFEST" ]; then
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        [ -f "$mod_path" ] || die "missing $mod_path"
        grep -qF "$anchor" "$mod_path" || die "manifest missing '$anchor' in $mod_path"
        ;;
      file)
        [ -f "$anchor" ] || die "missing file $anchor"
        ;;
      absent)
        if grep -qF "$anchor" "$NET_C" 2>/dev/null; then
          die "net.c still contains absent symbol $anchor"
        fi
        ;;
    esac
  done < "$MANIFEST"
fi

if [ -f tests/run-std-net-dns-gate.sh ]; then
  echo "=== F-04 v10: delegate run-std-net-dns-gate ==="
  chmod +x tests/run-std-net-dns-gate.sh
  if ! SHUX_STD_NET_DNS_FAIL="$FAIL" tests/run-std-net-dns-gate.sh; then
    die "std-net-dns sub-gate failed"
  fi
fi

echo "f04 std.net dns/alpn gate OK (F-04 v10)"
