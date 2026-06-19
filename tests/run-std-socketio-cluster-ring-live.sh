#!/usr/bin/env bash
# STD-SOCKETIO-001 cluster ring live：SIOA 快照跨节点 ring 同步烟测（无 Redis）
#
# 启用：SHUX_SOCKETIO_CLUSTER_RING=1 ./tests/run-std-socketio-cluster-ring-live.sh
set -e
cd "$(dirname "$0")/.."

LIVE_SU="tests/socketio/cluster_ring.sx"

if [ "${SHUX_SOCKETIO_CLUSTER_RING:-0}" != "1" ]; then
  echo "std-socketio cluster ring live SKIP (set SHUX_SOCKETIO_CLUSTER_RING=1 to enable)"
  exit 0
fi

stdlib_cm_native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

SHUX_BIN=""
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
else
  echo "std-socketio cluster ring live SKIP (no native shux)" >&2
  exit 0
fi

if [ ! -f "$LIVE_SU" ]; then
  echo "std-socketio cluster ring live FAIL: missing $LIVE_SU" >&2
  exit 1
fi

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/socketio/socketio.o
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true

echo "=== STD-SOCKETIO-001: cluster ring SIOA sync live ==="
if ! "$SHUX_BIN" check -L . "$LIVE_SU" >/dev/null 2>&1; then
  echo "std-socketio cluster ring live FAIL: typeck" >&2
  exit 1
fi

exe="/tmp/shux_std_socketio_cluster_ring_$$"
if ! "$SHUX_BIN" -L . "$LIVE_SU" -o "$exe" 2>/tmp/shux_cluster_ring_link_$$.log; then
  echo "std-socketio cluster ring live FAIL: link" >&2
  tail -8 /tmp/shux_cluster_ring_link_$$.log >&2 || true
  exit 1
fi

if ! "$exe"; then
  echo "std-socketio cluster ring live FAIL: run exit=$?" >&2
  exit 1
fi

echo "std-socketio cluster ring live OK"
