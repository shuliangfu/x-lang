#!/usr/bin/env bash
# STD-092：std.net ↔ std.context connect/accept/read/write 联动门禁
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

MOD_X="std/net/mod.x"
SMOKE="tests/net/context_connect.x"
PREFIX="shux: [SHUX_STD092_NET_CTX]"

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

echo "=== STD-092: net-context manifest ==="
for f in "$MOD_X" "$SMOKE"; do
  if [ ! -f "$f" ]; then
    echo "net-context gate FAIL: missing $f" >&2
    exit 1
  fi
done
for sym in connect_ctx_fd accept_ctx_fd connect_ipv6_ctx_fd read_ctx write_ctx; do
  if ! grep -qE "function ${sym}\\(" "$MOD_X" 2>/dev/null; then
    echo "net-context gate FAIL: missing api $sym" >&2
    exit 1
  fi
done
if ! grep -qF 'function net_err_timeout()' std/error/mod.x 2>/dev/null; then
  echo "net-context gate FAIL: missing net_err_timeout in std.error" >&2
  exit 1
fi
if ! grep -qF 'function net_err_cancelled()' std/error/mod.x 2>/dev/null; then
  echo "net-context gate FAIL: missing net_err_cancelled in std.error" >&2
  exit 1
fi
echo "net-context manifest OK"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/context/context.o
ensure_std_c_o ../std/time/time.o
ensure_std_c_o ../std/net/net.o

SHUX_BIN=""
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
fi

X_OK=0
SKIP=0
if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-092: smoke (SHUX=$SHUX_BIN) ==="
  if ! "$SHUX_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    echo "net-context gate FAIL: typeck $SMOKE" >&2
    exit 1
  fi
  exe="/tmp/shux_std092_net_ctx_$$"
  if ! "$SHUX_BIN" -L . "$SMOKE" -o "$exe" >/dev/null 2>&1; then
    echo "net-context gate FAIL: compile $SMOKE" >&2
    exit 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "net-context gate FAIL: run exit=$ec" >&2
    exit 1
  fi
  X_OK=1
else
  echo "net-context gate SKIP .x (no native shux)" >&2
  SKIP=1
fi

echo "${PREFIX} status=ok x=${X_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "std-net-context gate OK"
