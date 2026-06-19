#!/usr/bin/env bash
# STD-SOCKETIO-001：std.socketio Engine.IO 包编解码门禁（P3 可选）
#
# 用法：./tests/run-std-socketio-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_SOCKETIO_DOC:-analysis/std-socketio-v1.md}"
MANIFEST="${SHUX_STD_SOCKETIO_TSV:-tests/baseline/std-socketio.tsv}"
MOD_SU="std/socketio/mod.sx"
SIO_C="std/socketio/socketio.c"
SIO_README="std/socketio/README.md"
LIB="tests/lib/std-socketio.sh"
FRAME_SU="tests/socketio/eio_packet.sx"
NODE_SU="tests/socketio/node_golden.sx"
SERVER_SU="tests/socketio/server_golden.sx"
NS_ACK_SU="tests/socketio/ns_ack.sx"
NS_ROUTER_SU="tests/socketio/ns_router.sx"
NS_SESSIONS_SU="tests/socketio/ns_sessions.sx"
WS_HUB_SU="tests/socketio/ws_hub.sx"
ROOM_SU="tests/socketio/room.sx"
HUB_SYNC_SU="tests/socketio/hub_sync.sx"
SESSION_SYNC_SU="tests/socketio/session_sync.sx"
CLUSTER_SYNC_SU="tests/socketio/cluster_sync.sx"
CLUSTER_ADAPTER_SU="tests/socketio/cluster_adapter.sx"
CLUSTER_RING_SU="tests/socketio/cluster_ring.sx"
P3_COMPLETE_SU="tests/socketio/p3_complete.sx"
LIVE_SH="tests/run-std-socketio-live.sh"
MIN_APIS=48
NPM_LIVE_SH="tests/run-std-socketio-npm-live.sh"
NPM_WS_LIVE_SH="tests/run-std-socketio-npm-ws-live.sh"
NPM_ROOM_LIVE_SH="tests/run-std-socketio-npm-room-live.sh"
NPM_MW_LIVE_SH="tests/run-std-socketio-npm-mw-live.sh"
NPM_PLUGIN_LIVE_SH="tests/run-std-socketio-npm-plugin-live.sh"
CLUSTER_RING_LIVE_SH="tests/run-std-socketio-cluster-ring-live.sh"
ALL_LIVE_SH="tests/run-std-socketio-all-live.sh"

# shellcheck source=tests/lib/std-socketio.sh
. "$LIB"

echo "=== STD-SOCKETIO-001: std.socketio manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$SIO_README" "$SIO_C" "$FRAME_SU" "$NODE_SU" "$SERVER_SU" "$NS_ACK_SU" "$NS_ROUTER_SU" "$NS_SESSIONS_SU" "$WS_HUB_SU" "$ROOM_SU" "$HUB_SYNC_SU" "$SESSION_SYNC_SU" "$CLUSTER_SYNC_SU" "$CLUSTER_ADAPTER_SU" "$CLUSTER_RING_SU" "$P3_COMPLETE_SU" "$LIVE_SH" "$NPM_LIVE_SH" "$NPM_WS_LIVE_SH" "$NPM_ROOM_LIVE_SH" "$NPM_MW_LIVE_SH" "$NPM_PLUGIN_LIVE_SH" "$CLUSTER_RING_LIVE_SH" "$ALL_LIVE_SH"; do
  if [ ! -f "$f" ]; then
    echo "std-socketio gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-SOCKETIO-001 Engine.IO eio_encode_packet sio_encode_event socketio; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-socketio gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_APIS="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api) API_N=$((API_N + 1)) ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-socketio gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-socketio gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_socketio_symbols_ok "$MOD_SU" "$SIO_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_socketio_emit_report fail 0 1
  echo "std-socketio gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-socketio manifest OK"

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

SMOKE_OK=0
SKIP=1
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
else
  SHUX_BIN=""
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-SOCKETIO-001: typeck + smoke (SHUX=$SHUX_BIN) ==="
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/socketio/socketio.o
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  for smoke_su in "$FRAME_SU" "$NODE_SU" "$SERVER_SU" "$NS_ACK_SU" "$NS_ROUTER_SU" "$NS_SESSIONS_SU" "$WS_HUB_SU" "$ROOM_SU" "$HUB_SYNC_SU" "$SESSION_SYNC_SU" "$CLUSTER_SYNC_SU" "$CLUSTER_ADAPTER_SU" "$CLUSTER_RING_SU" "$P3_COMPLETE_SU"; do
    if ! "$SHUX_BIN" check -L . "$smoke_su" >/dev/null 2>&1; then
      echo "std-socketio gate FAIL: typeck $smoke_su" >&2
      "$SHUX_BIN" check -L . "$smoke_su" 2>&1 | tail -10 >&2 || true
      std_socketio_emit_report fail 0 1
      exit 1
    fi
    exe="/tmp/shux_std_socketio_smoke_$$"
    set +e
    link_log=$("$SHUX_BIN" -L . "$smoke_su" -o "$exe" 2>&1)
    link_ec=$?
    set -e
    if [ "$link_ec" -eq 0 ]; then
      set +e
      "$exe" >/dev/null 2>&1
      run_ec=$?
      set -e
      rm -f "$exe"
      if [ "$run_ec" -ne 0 ]; then
        echo "std-socketio gate FAIL: run $smoke_su exit=$run_ec" >&2
        std_socketio_emit_report fail 0 0
        exit 1
      fi
    else
      echo "std-socketio gate FAIL: link $smoke_su" >&2
      echo "$link_log" | tail -8 >&2 || true
      std_socketio_emit_report fail 0 0
      exit 1
    fi
  done
  SMOKE_OK=1
  SKIP=0
else
  echo "std-socketio gate SKIP smoke (no native shux-c)" >&2
fi

std_socketio_emit_report ok "$SMOKE_OK" "$SKIP"
echo "std-socketio gate OK"
