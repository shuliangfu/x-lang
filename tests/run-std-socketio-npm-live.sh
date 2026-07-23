#!/usr/bin/env bash
# STD-SOCKETIO-001 npm live：真实 socket.io polling 握手（可选）
#
# 启用：XLANG_SOCKETIO_NPM=1 ./tests/run-std-socketio-npm-live.sh
set -e
cd "$(dirname "$0")/.."

NPM_DIR="tests/socketio/npm_live"
LIVE_X="tests/socketio/npm_live_handshake.x"
PORT="${XLANG_SOCKETIO_NPM_PORT:-13002}"

if [ "${XLANG_SOCKETIO_NPM:-0}" != "1" ]; then
  echo "std-socketio npm live SKIP (set XLANG_SOCKETIO_NPM=1 to enable)"
  exit 0
fi

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  echo "std-socketio npm live SKIP (node/npm not found)" >&2
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
  echo "std-socketio npm live SKIP (no native xlang)" >&2
  exit 0
fi

for f in "$LIVE_X" "$NPM_DIR/package.json" "$NPM_DIR/server.mjs"; do
  if [ ! -f "$f" ]; then
    echo "std-socketio npm live FAIL: missing $f" >&2
    exit 1
  fi
done

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/socketio/socketio.o
make -C compiler -q xlang-c 2>/dev/null || make -C compiler xlang-c 2>/dev/null || true

echo "=== STD-SOCKETIO-001: npm install socket.io ==="
if ! (cd "$NPM_DIR" && npm install --no-audit --no-fund >/tmp/xlang_socketio_npm_install_$$.log 2>&1); then
  echo "std-socketio npm live FAIL: npm install" >&2
  tail -15 /tmp/xlang_socketio_npm_install_$$.log >&2 || true
  exit 1
fi

SVR_PID=""
cleanup() {
  if [ -n "$SVR_PID" ]; then
    kill "$SVR_PID" 2>/dev/null || true
    wait "$SVR_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

PORT="$PORT" node "$NPM_DIR/server.mjs" >/tmp/xlang_socketio_npm_svr_$$.log 2>&1 &
SVR_PID=$!
sleep 1.5

echo "=== STD-SOCKETIO-001: npm live polling handshake (port=$PORT) ==="
if ! "$XLANG_BIN" check -L . "$LIVE_X" >/dev/null 2>&1; then
  echo "std-socketio npm live FAIL: typeck" >&2
  exit 1
fi

exe="/tmp/xlang_std_socketio_npm_$$"
if ! "$XLANG_BIN" -L . "$LIVE_X" -o "$exe" 2>/tmp/xlang_socketio_npm_link_$$.log; then
  echo "std-socketio npm live FAIL: link" >&2
  tail -8 /tmp/xlang_socketio_npm_link_$$.log >&2 || true
  exit 1
fi

if ! "$exe"; then
  echo "std-socketio npm live FAIL: run exit=$?" >&2
  tail -5 /tmp/xlang_socketio_npm_svr_$$.log >&2 || true
  exit 1
fi

echo "std-socketio npm live OK"
