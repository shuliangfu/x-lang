#!/usr/bin/env bash
# STD-SOCKETIO-001 npm mw live：WS 直连 /chat → auth 中间件 → mw_ping/mw_pong（可选）
#
# 启用：SHUX_SOCKETIO_NPM_MW=1 ./tests/run-std-socketio-npm-mw-live.sh
set -e
cd "$(dirname "$0")/.."

NPM_DIR="tests/socketio/npm_live"
LIVE_X="tests/socketio/npm_live_mw.x"
PORT="${SHUX_SOCKETIO_NPM_MW_PORT:-13005}"

if [ "${SHUX_SOCKETIO_NPM_MW:-0}" != "1" ]; then
  echo "std-socketio npm mw live SKIP (set SHUX_SOCKETIO_NPM_MW=1 to enable)"
  exit 0
fi

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  echo "std-socketio npm mw live SKIP (node/npm not found)" >&2
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
  echo "std-socketio npm mw live SKIP (no native shux)" >&2
  exit 0
fi

for f in "$LIVE_X" "$NPM_DIR/package.json" "$NPM_DIR/server.mjs"; do
  if [ ! -f "$f" ]; then
    echo "std-socketio npm mw live FAIL: missing $f" >&2
    exit 1
  fi
done

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/socketio/socketio.o
ensure_std_c_o ../std/net/net.o
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true

echo "=== STD-SOCKETIO-001: npm install socket.io ==="
if ! (cd "$NPM_DIR" && npm install --no-audit --no-fund >/tmp/shux_socketio_npm_mw_install_$$.log 2>&1); then
  echo "std-socketio npm mw live FAIL: npm install" >&2
  tail -15 /tmp/shux_socketio_npm_mw_install_$$.log >&2 || true
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

PORT="$PORT" node "$NPM_DIR/server.mjs" >/tmp/shux_socketio_npm_mw_svr_$$.log 2>&1 &
SVR_PID=$!
sleep 1.5

echo "=== STD-SOCKETIO-001: npm mw live e2e (port=$PORT) ==="
if ! "$SHUX_BIN" check -L . "$LIVE_X" >/dev/null 2>&1; then
  echo "std-socketio npm mw live FAIL: typeck" >&2
  "$SHUX_BIN" check -L . "$LIVE_X" 2>&1 | tail -10 >&2 || true
  exit 1
fi

exe="/tmp/shux_std_socketio_npm_mw_$$"
if ! "$SHUX_BIN" -L . "$LIVE_X" -o "$exe" 2>/tmp/shux_socketio_npm_mw_link_$$.log; then
  echo "std-socketio npm mw live FAIL: link" >&2
  tail -8 /tmp/shux_socketio_npm_mw_link_$$.log >&2 || true
  exit 1
fi

set +e
"$exe"
run_ec=$?
set -e
if [ "$run_ec" -ne 0 ]; then
  echo "std-socketio npm mw live FAIL: run exit=$run_ec" >&2
  tail -8 /tmp/shux_socketio_npm_mw_svr_$$.log >&2 || true
  exit 1
fi

echo "std-socketio npm mw live OK"
