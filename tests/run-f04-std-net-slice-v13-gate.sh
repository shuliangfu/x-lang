#!/usr/bin/env bash
# F-04 v13：std.net IPv4 TCP 核心去 C 门禁。
#
# 用法：./tests/run-f04-std-net-slice-v13-gate.sh
# 环境：SHUX_F04_NET_SLICE_V13_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F04_NET_SLICE_V13_FAIL:-0}
DOC="analysis/phase-f-f04-v13.md"
NET_C="std/net/net.c"

die() {
  echo "f04-net-slice-v13 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-04 v13: std.net TCP core remove from net.c ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v13' "$DOC" || die "doc missing F-04 v13 marker"
[ -f std/net/tcp.x ] || die "missing tcp.x"
grep -q 'net_tcp_connect_c' std/net/tcp.x || die "net_tcp missing connect"
grep -q 'net_tcp_listen_c' std/net/tcp.x || die "net_tcp missing listen"
grep -q 'net_accept_c' std/net/tcp.x || die "net_tcp missing accept"
grep -q 'net_accept_many_c' std/net/tcp.x || die "net_tcp missing accept_many"
grep -q 'net_connect_many_c' std/net/tcp.x || die "net_tcp missing connect_many"
for sym in net_tcp_connect_c net_tcp_connect_blocking_c net_tcp_listen_c net_accept_c net_accept_many_c net_connect_many_c; do
  if [ -f "$NET_C" ] && grep -qE "^int32_t ${sym}\\(|^int ${sym}\\(" "$NET_C" 2>/dev/null; then
    die "net.c still defines $sym"
  fi
done
if [ -f "$NET_C" ]; then
  grep -q 'tcp.x' "$NET_C" || die "net.c should reference tcp.x"
  grep -q 'extern int net_accept_many_c' "$NET_C" || die "net.c workers should extern net_accept_many_c"
  grep -q 'extern int32_t net_close_socket_c' "$NET_C" || die "net.c workers should extern net_close_socket_c"
fi
if [ -f std/net/workers.x ]; then
  grep -q 'net_run_accept_workers_c' std/net/workers.x || die "workers.x missing run_accept_workers"
fi
if grep -q 'net_close_socket_c_real' "$NET_C" 2>/dev/null; then
  die "net.c still references net_close_socket_c_real"
fi
grep -q 'tcp.x' compiler/Makefile || die "Makefile missing tcp.x"

if [ -f tests/run-f04-std-net-slice-v12-gate.sh ]; then
  echo "=== F-04 v13: delegate v12 gate ==="
  chmod +x tests/run-f04-std-net-slice-v12-gate.sh
  if ! SHUX_F04_NET_SLICE_V12_FAIL="$FAIL" tests/run-f04-std-net-slice-v12-gate.sh; then
    die "v12 sub-gate failed"
  fi
fi

echo "f04 std.net slice v13 gate OK (F-04 v13)"
