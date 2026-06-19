#!/usr/bin/env bash
# 测试 std.net 占位：Ipv4Addr、TcpStream、TcpListener、connect、listen、accept；UDP 切片化 udp_recv_many_buf/udp_send_many_buf
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}

$SHUX -L . tests/net/main.sx -o /tmp/shux_net 2>&1
exitcode=0; /tmp/shux_net >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0, got $exitcode"; exit 1; }

$SHUX -L . tests/net/udp_batch_buf.sx -o /tmp/shux_net_udp 2>&1
exitcode=0; /tmp/shux_net_udp >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (udp_recv_many_buf/udp_send_many_buf), got $exitcode"; exit 1; }

echo "net test OK"
