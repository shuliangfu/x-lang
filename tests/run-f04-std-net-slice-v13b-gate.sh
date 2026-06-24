#!/usr/bin/env bash
# F-04 v13b：std.net UDP batch 去 C 门禁。
#
# 用法：./tests/run-f04-std-net-slice-v13b-gate.sh
# 环境：SHUX_F04_NET_SLICE_V13B_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F04_NET_SLICE_V13B_FAIL:-0}
DOC="analysis/phase-f-f04-v13b.md"
NET_C="std/net/net.c"
NET_RUNTIME="compiler/src/asm/runtime_net_udp_batch.c"

die() {
  echo "f04-net-slice-v13b gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-04 v13b: std.net UDP batch remove from net.c ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v13b' "$DOC" || die "doc missing F-04 v13b marker"
[ -f std/net/net_udp_batch.sx ] || die "missing net_udp_batch.sx"
[ -f "$NET_RUNTIME" ] || die "missing runtime_net_udp_batch.c"
[ ! -f std/net/net_udp_batch_glue.c ] || die "net_udp_batch_glue.c should be deleted"
grep -q 'net_udp_recv_many_c' std/net/net_udp_batch.sx || die "batch.sx missing recv_many"
grep -q 'net_udp_send_many_buf_c' std/net/net_udp_batch.sx || die "batch.sx missing send_many_buf"
grep -q 'shu_net_udp_recvmmsg2_c' "$NET_RUNTIME" || die "runtime missing recvmmsg2"
for sym in net_udp_recv_many_c net_udp_send_many_c net_udp_recv_many_buf_c net_udp_send_many_buf_c; do
  if [ -f "$NET_C" ] && grep -qE "^int ${sym}\\(" "$NET_C" 2>/dev/null; then
    die "net.c still defines $sym"
  fi
done
if [ -f "$NET_C" ] && grep -q 'shu_net_set_addr_port' "$NET_C" 2>/dev/null; then
  die "net.c still has UDP batch helpers"
fi
grep -q 'net_udp_batch.sx' compiler/Makefile || die "Makefile missing net_udp_batch.sx"
grep -q 'runtime_net_udp_batch' compiler/Makefile || die "Makefile missing runtime_net_udp_batch"
make -C compiler -q runtime_net_udp_batch.o 2>/dev/null || make -C compiler runtime_net_udp_batch.o >/dev/null 2>&1 || die "runtime_net_udp_batch.o build failed"

if [ -f tests/run-f04-std-net-slice-v13-gate.sh ]; then
  echo "=== F-04 v13b: delegate v13 gate ==="
  chmod +x tests/run-f04-std-net-slice-v13-gate.sh
  if ! SHUX_F04_NET_SLICE_V13_FAIL="$FAIL" tests/run-f04-std-net-slice-v13-gate.sh; then
    die "v13 sub-gate failed"
  fi
fi

echo "f04 std.net slice v13b gate OK (F-04 v13b)"
