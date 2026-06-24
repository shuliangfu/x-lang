#!/usr/bin/env bash
# F-04 v12：std.net socket/UDP 基础去 C 门禁。
#
# 用法：./tests/run-f04-std-net-slice-v12-gate.sh
# 环境：SHUX_F04_NET_SLICE_V12_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F04_NET_SLICE_V12_FAIL:-0}
DOC="analysis/phase-f-f04-v12.md"
NET_C="std/net/net.c"

die() {
  echo "f04-net-slice-v12 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-04 v12: std.net sock/udp basic remove from net.c ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v12' "$DOC" || die "doc missing F-04 v12 marker"
[ -f std/net/net_sock.sx ] || die "missing net_sock.sx"
[ -f std/net/net_udp.sx ] || die "missing net_udp.sx"
grep -q 'net_close_socket_c' std/net/net_sock.sx || die "net_sock missing close"
grep -q 'net_set_blocking_c' std/net/net_sock.sx || die "net_sock missing set_blocking"
grep -q 'net_udp_bind_c' std/net/net_udp.sx || die "net_udp missing bind"
grep -q 'net_udp_recv_from_c' std/net/net_udp.sx || die "net_udp missing recv_from"
for sym in net_close_socket_c net_set_blocking_c net_udp_bind_c; do
  if [ -f "$NET_C" ] && grep -qE "^int32_t ${sym}\\(|^int ${sym}\\(" "$NET_C" 2>/dev/null; then
    die "net.c still defines $sym"
  fi
done
if [ -f "$NET_C" ] && grep -qE "^int32_t net_udp_send_to_c\\(" "$NET_C" 2>/dev/null; then
  die "net.c still defines net_udp_send_to_c"
fi
if [ -f std/net/net_udp_batch.sx ]; then
  grep -q 'net_udp_recv_from_c' std/net/net_udp_batch.sx || die "net_udp_batch should use net_udp_recv_from_c"
else
  grep -q 'net_udp_recv_from_c' "$NET_C" || die "net.c batch should extern net_udp_recv_from_c"
fi
grep -q 'net_sock.sx' compiler/Makefile || die "Makefile missing net_sock.sx"
grep -q 'net_udp.sx' compiler/Makefile || die "Makefile missing net_udp.sx"

if [ -f tests/run-f04-std-net-slice-v11-gate.sh ]; then
  echo "=== F-04 v12: delegate v11 gate ==="
  chmod +x tests/run-f04-std-net-slice-v11-gate.sh
  if ! SHUX_F04_NET_SLICE_V11_FAIL="$FAIL" tests/run-f04-std-net-slice-v11-gate.sh; then
    die "v11 sub-gate failed"
  fi
fi

echo "f04 std.net slice v12 gate OK (F-04 v12)"
