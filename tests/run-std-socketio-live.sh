#!/usr/bin/env bash
# STD-SOCKETIO-001 live：Engine.IO polling 握手（mock HTTP 服务；可选 Node）
#
# 默认 SKIP；启用：SHUX_SOCKETIO_LIVE=1 ./tests/run-std-socketio-live.sh
set -e
cd "$(dirname "$0")/.."

LIVE_SX="tests/socketio/live_handshake.sx"
MOCK_JS="tests/socketio/mock_eio_polling_server.js"
PORT="${SHUX_SOCKETIO_LIVE_PORT:-13001}"

if [ "${SHUX_SOCKETIO_LIVE:-0}" != "1" ]; then
  echo "std-socketio live SKIP (set SHUX_SOCKETIO_LIVE=1 to enable)"
  exit 0
fi

if ! command -v node >/dev/null 2>&1; then
  echo "std-socketio live SKIP (node not found)" >&2
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
  echo "std-socketio live SKIP (no native shux)" >&2
  exit 0
fi

for f in "$LIVE_SX" "$MOCK_JS"; do
  if [ ! -f "$f" ]; then
    echo "std-socketio live FAIL: missing $f" >&2
    exit 1
  fi
done

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/socketio/socketio.o
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true

MOCK_PID=""
cleanup() {
  if [ -n "$MOCK_PID" ]; then
    kill "$MOCK_PID" 2>/dev/null || true
    wait "$MOCK_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

node "$MOCK_JS" "$PORT" >/tmp/shux_socketio_mock_$$.log 2>&1 &
MOCK_PID=$!
sleep 0.5

echo "=== STD-SOCKETIO-001: live polling handshake (port=$PORT) ==="
if ! "$SHUX_BIN" check -L . "$LIVE_SX" >/dev/null 2>&1; then
  echo "std-socketio live FAIL: typeck $LIVE_SX" >&2
  exit 1
fi

exe="/tmp/shux_std_socketio_live_$$"
if ! "$SHUX_BIN" -L . "$LIVE_SX" -o "$exe" 2>/tmp/shux_socketio_live_link_$$.log; then
  echo "std-socketio live FAIL: link" >&2
  tail -8 /tmp/shux_socketio_live_link_$$.log >&2 || true
  exit 1
fi

if ! "$exe"; then
  echo "std-socketio live FAIL: run exit=$?" >&2
  exit 1
fi

echo "std-socketio live OK"
