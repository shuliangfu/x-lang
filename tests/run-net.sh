#!/usr/bin/env bash
# 测试 std.net 占位：Ipv4Addr、TcpStream、TcpListener、connect、listen、accept；UDP 切片化 udp_recv_many_buf/udp_send_many_buf
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
ensure_std_c_o ../std/net/net.o
# ws.inc.c 内 shu_ws_fill_random16 依赖 random_fill_bytes_c
ensure_std_c_o ../std/random/random.o
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
SHUX=${SHUX:-./compiler/shux}
LINK_SHUX="${SHUX_LINK_SHUX:-${RUN_SHUX:-$SHUX}}"

$LINK_SHUX -L . tests/net/main.sx -o /tmp/shux_net 2>&1
exitcode=0; /tmp/shux_net >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0, got $exitcode"; exit 1; }

$LINK_SHUX -L . tests/net/udp_batch_buf.sx -o /tmp/shux_net_udp 2>&1
exitcode=0; /tmp/shux_net_udp >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (udp_recv_many_buf/udp_send_many_buf), got $exitcode"; exit 1; }

echo "net test OK"
