#!/usr/bin/env bash
# F-04 v11：std.net 地址/IPv6/io batch 去 C 门禁。
#
# 用法：./tests/run-f04-std-net-slice-v11-gate.sh
# 环境：SHUX_F04_NET_SLICE_V11_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F04_NET_SLICE_V11_FAIL:-0}
DOC="analysis/phase-f-f04-v11.md"
NET_C="std/net/net.c"

die() {
  echo "f04-net-slice-v11 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-04 v11: std.net addr/ipv6/io_batch remove from net.c ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v11' "$DOC" || die "doc missing F-04 v11 marker"
for x in net_addr net_ipv6 net_io_batch; do
  [ -f "std/net/${x}.x" ] || die "missing ${x}.x"
done
grep -q 'net_tcp_local_addr_c' std/net/addr.x || die "net_addr missing local"
grep -q 'net_tcp_connect_ipv6_c' std/net/ipv6.x || die "net_ipv6 missing connect"
grep -q 'net_stream_read_batch_provided_c' std/net/io_batch.x || die "net_io_batch missing provided"
for sym in net_tcp_local_addr_c net_tcp_peer_addr_c net_tcp_connect_ipv6_c net_tcp_listen_ipv6_c \
  net_stream_write_batch_c net_stream_read_batch_c net_stream_read_batch_provided_c; do
  if [ -f "$NET_C" ] && grep -q "$sym" "$NET_C" 2>/dev/null; then
    die "net.c still defines $sym"
  fi
done
grep -q 'io_batch.x' compiler/Makefile || die "Makefile missing io_batch.x"

if [ -f tests/run-f04-std-net-dns-alpn-gate.sh ]; then
  echo "=== F-04 v11: delegate f04 dns/alpn gate ==="
  chmod +x tests/run-f04-std-net-dns-alpn-gate.sh
  if ! SHUX_F04_NET_DNS_ALPN_FAIL="$FAIL" tests/run-f04-std-net-dns-alpn-gate.sh; then
    die "dns/alpn sub-gate failed"
  fi
fi

if [ -f tests/run-std-net-dns-gate.sh ]; then
  echo "=== F-04 v11: delegate std-net-dns gate ==="
  chmod +x tests/run-std-net-dns-gate.sh
  if ! SHUX_STD_NET_DNS_FAIL="$FAIL" tests/run-std-net-dns-gate.sh; then
    die "std-net-dns sub-gate failed"
  fi
fi

echo "f04 std.net slice v11 gate OK (F-04 v11)"
