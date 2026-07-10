#!/usr/bin/env bash
# F-04 v14：std.net accept workers 去 C；net.c 删除门禁。
#
# 用法：./tests/run-f04-std-net-slice-v14-gate.sh
# 环境：SHUX_F04_NET_SLICE_V14_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F04_NET_SLICE_V14_FAIL:-0}
DOC="analysis/phase-f-f04-v14.md"
NET_RUNTIME="compiler/src/asm/runtime_net_workers.inc"

die() {
  echo "f04-net-slice-v14 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-04 v14: std.net workers remove from net.c (delete net.c) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v14' "$DOC" || die "doc missing F-04 v14 marker"
[ ! -f std/net/net.c ] || die "std/net/net.c should be deleted"
[ -f std/net/workers.x ] || die "missing workers.x"
[ -f "$NET_RUNTIME" ] || die "missing runtime_net_workers.inc"
[ ! -f std/net/workers_glue.c ] || die "net_workers_glue.c should be deleted"
grep -q 'net_run_accept_workers_c' std/net/workers.x || die "workers.x missing API"
grep -q 'net_run_accept_workers_c_real' std/net/workers.x || die "workers.x missing _real alias"
grep -q 'shu_net_worker_accept_entry_ptr_c' "$NET_RUNTIME" || die "runtime missing entry ptr"
grep -q 'workers.x' compiler/Makefile || die "Makefile missing workers.x"
grep -q 'runtime_net_workers' compiler/Makefile || die "Makefile missing runtime_net_workers"
make -C compiler -q runtime_net_workers.o 2>/dev/null || make -C compiler runtime_net_workers.o >/dev/null 2>&1 || die "runtime_net_workers.o build failed"
if grep -q 'std/net/net\.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references std/net/net.c"
fi

if [ -f tests/run-f04-std-net-slice-v13b-gate.sh ]; then
  echo "=== F-04 v14: delegate v13b gate ==="
  chmod +x tests/run-f04-std-net-slice-v13b-gate.sh
  if ! SHUX_F04_NET_SLICE_V13B_FAIL="$FAIL" tests/run-f04-std-net-slice-v13b-gate.sh; then
    die "v13b sub-gate failed"
  fi
fi

echo "f04 std.net slice v14 gate OK (F-04 v14)"
