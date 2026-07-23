#!/usr/bin/env bash
# STD-SOCKETIO-001 cluster ring live：SIOA 快照跨节点 ring 同步烟测（无 Redis）
#
# 启用：XLANG_SOCKETIO_CLUSTER_RING=1 ./tests/run-std-socketio-cluster-ring-live.sh
set -e
cd "$(dirname "$0")/.."

LIVE_X="tests/socketio/cluster_ring.x"

if [ "${XLANG_SOCKETIO_CLUSTER_RING:-0}" != "1" ]; then
  echo "std-socketio cluster ring live SKIP (set XLANG_SOCKETIO_CLUSTER_RING=1 to enable)"
  exit 0
fi

stdlib_cm_native_xlang() {
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

XLANG_BIN=""
if XLANG_BIN="$(stdlib_cm_native_xlang ./compiler/xlang-c && echo ./compiler/xlang-c || true)"; then
  :
elif XLANG_BIN="$(stdlib_cm_native_xlang ./compiler/xlang && echo ./compiler/xlang || true)"; then
  :
else
  echo "std-socketio cluster ring live SKIP (no native xlang)" >&2
  exit 0
fi

if [ ! -f "$LIVE_X" ]; then
  echo "std-socketio cluster ring live FAIL: missing $LIVE_X" >&2
  exit 1
fi

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/socketio/socketio.o
make -C compiler -q xlang-c 2>/dev/null || make -C compiler xlang-c 2>/dev/null || true

echo "=== STD-SOCKETIO-001: cluster ring SIOA sync live ==="
if ! "$XLANG_BIN" check -L . "$LIVE_X" >/dev/null 2>&1; then
  echo "std-socketio cluster ring live FAIL: typeck" >&2
  exit 1
fi

exe="/tmp/xlang_std_socketio_cluster_ring_$$"
if ! "$XLANG_BIN" -L . "$LIVE_X" -o "$exe" 2>/tmp/xlang_cluster_ring_link_$$.log; then
  echo "std-socketio cluster ring live FAIL: link" >&2
  tail -8 /tmp/xlang_cluster_ring_link_$$.log >&2 || true
  exit 1
fi

if ! "$exe"; then
  echo "std-socketio cluster ring live FAIL: run exit=$?" >&2
  exit 1
fi

echo "std-socketio cluster ring live OK"
