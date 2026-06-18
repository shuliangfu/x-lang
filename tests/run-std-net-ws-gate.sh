#!/usr/bin/env bash
# STD-031：std.net WebSocket 客户端草案门禁
#
# 用法：./tests/run-std-net-ws-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD_NET_WS_DOC:-analysis/std-net-ws-v1.md}"
MANIFEST="${SHU_STD_NET_WS_TSV:-tests/baseline/std-net-ws.tsv}"
NET_SU="std/net/mod.su"
WS_INC="std/net/ws.inc.c"
NET_C="std/net/net.c"
LIB="tests/lib/std-net-ws.sh"
FRAME_SU="tests/net/ws_frame.su"
MIN_APIS=5

# shellcheck source=tests/lib/std-net-ws.sh
. "$LIB"

echo "=== STD-031: net WebSocket manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$NET_SU" "$WS_INC" "$NET_C" "$FRAME_SU"; do
  if [ ! -f "$f" ]; then
    echo "std-net-ws gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-031 WebSocket ws_compute_accept Upgrade websocket; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-net-ws gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'ws.inc.c' "$NET_C" 2>/dev/null; then
  echo "std-net-ws gate FAIL: net.c missing ws.inc.c include" >&2
  exit 1
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api) API_N=$((API_N + 1)) ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-net-ws gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-net-ws gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_net_ws_symbols_ok "$NET_SU" "$WS_INC" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_net_ws_emit_report "fail" 0 0 0 1
  echo "std-net-ws gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-net-ws manifest OK"

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

ACCEPT_OK=0
FRAME_OK=0
TYPECK_OK=0
SKIP=1
if SHU_BIN="$(stdlib_cm_native_shu ./compiler/shu-c && echo ./compiler/shu-c || true)"; then
  :
elif SHU_BIN="$(stdlib_cm_native_shu ./compiler/shu && echo ./compiler/shu || true)"; then
  :
else
  SHU_BIN=""
fi

if [ -n "$SHU_BIN" ]; then
  echo "=== STD-031: typeck + frame smoke (SHU=$SHU_BIN) ==="
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/net/net.o
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c 2>/dev/null || true
  if ! "$SHU_BIN" check -L . "$FRAME_SU" >/dev/null 2>&1; then
    echo "std-net-ws gate FAIL: typeck $FRAME_SU" >&2
    "$SHU_BIN" check -L . "$FRAME_SU" 2>&1 | tail -10 >&2 || true
    std_net_ws_emit_report "fail" 0 0 0 0
    exit 1
  fi
  TYPECK_OK=1
  exe="/tmp/shu_std_net_ws_frame_$$"
  set +e
  link_log=$("$SHU_BIN" -L . "$FRAME_SU" -o "$exe" 2>&1)
  link_ec=$?
  set -e
  if [ "$link_ec" -eq 0 ]; then
    set +e
    "$exe" >/dev/null 2>&1
    run_ec=$?
    set -e
    rm -f "$exe"
    if [ "$run_ec" -eq 0 ]; then
      ACCEPT_OK=1
      FRAME_OK=1
      SKIP=0
    else
      echo "std-net-ws gate FAIL: run exit=$run_ec" >&2
      std_net_ws_emit_report "fail" 0 0 "$TYPECK_OK" 0
      exit 1
    fi
  elif echo "$link_log" | grep -qF "library 'zstd' not found"; then
    echo "std-net-ws gate SKIP runnable link (typeck passed)" >&2
    ACCEPT_OK=0
    FRAME_OK=0
    SKIP=1
  else
    echo "std-net-ws gate FAIL: link $FRAME_SU" >&2
    echo "$link_log" | tail -8 >&2 || true
    std_net_ws_emit_report "fail" 0 0 "$TYPECK_OK" 0
    exit 1
  fi
else
  echo "std-net-ws gate SKIP smoke (no native shu-c)" >&2
fi

std_net_ws_emit_report "ok" "$ACCEPT_OK" "$FRAME_OK" "$TYPECK_OK" "$SKIP"
echo "std-net-ws gate OK"
