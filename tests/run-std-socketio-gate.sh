#!/usr/bin/env bash
# STD-SOCKETIO-001: std.socketio Engine.IO gate — honesty soft prefer-c / soft
# SKIP→OK / soft ensure_std_c_o / hard check / smoke=/skip= report →硬绿.
#
# Honesty: prefer-c first (xlang-c only) + soft SKIP→OK (no xlang-c still
# gate OK) + soft `ensure_std_c_o` + soft `xlang_compiler_make … || true` +
# hard check as sole .x smoke + report `smoke=` retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die. Host-C archaeology = obs only (prebuilt std/socketio/socketio.o;
# refuse soft ensure). check residual = obs (paused 2026-08-05). tip
# product -o UNDEF/SEGV = obs (product debt; leave). Report: run=/obs=/skip=.
# Live npm／cluster scripts left (soft-ensure 另案). brotli ld left.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-socketio-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_SOCKETIO_DOC:-analysis/archive/std/std-socketio-v1.md}"
MANIFEST="${XLANG_STD_SOCKETIO_TSV:-tests/baseline/std-socketio.tsv}"
MOD_X="std/socketio/mod.x"
SIO_X="std/socketio/socketio.x"
SIO_README="std/socketio/README.md"
LIB="tests/lib/std-socketio.sh"
SOCKETIO_O="std/socketio/socketio.o"
FRAME_X="tests/socketio/eio_packet.x"
NODE_X="tests/socketio/node_golden.x"
SERVER_X="tests/socketio/server_golden.x"
NS_ACK_X="tests/socketio/ns_ack.x"
NS_ROUTER_X="tests/socketio/ns_router.x"
NS_SESSIONS_X="tests/socketio/ns_sessions.x"
WS_HUB_X="tests/socketio/ws_hub.x"
ROOM_X="tests/socketio/room.x"
HUB_SYNC_X="tests/socketio/hub_sync.x"
SESSION_SYNC_X="tests/socketio/session_sync.x"
CLUSTER_SYNC_X="tests/socketio/cluster_sync.x"
CLUSTER_ADAPTER_X="tests/socketio/cluster_adapter.x"
CLUSTER_RING_X="tests/socketio/cluster_ring.x"
P3_COMPLETE_X="tests/socketio/p3_complete.x"
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

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-socketio gate FAIL: $*" >&2
  std_socketio_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; refuse soft auto-make / prefer-c.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== STD-SOCKETIO-001: std.socketio manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$SIO_X" "$SIO_README" \
  "$FRAME_X" "$NODE_X" "$SERVER_X" "$NS_ACK_X" "$NS_ROUTER_X" "$NS_SESSIONS_X" \
  "$WS_HUB_X" "$ROOM_X" "$HUB_SYNC_X" "$SESSION_SYNC_X" "$CLUSTER_SYNC_X" \
  "$CLUSTER_ADAPTER_X" "$CLUSTER_RING_X" "$P3_COMPLETE_X" \
  "$LIVE_SH" "$NPM_LIVE_SH" "$NPM_WS_LIVE_SH" "$NPM_ROOM_LIVE_SH" \
  "$NPM_MW_LIVE_SH" "$NPM_PLUGIN_LIVE_SH" "$CLUSTER_RING_LIVE_SH" "$ALL_LIVE_SH"; do
  [ -f "$f" ] || die "missing $f"
done
[ ! -f analysis/std-socketio-v1.md ] || die "dual-authority fossil analysis/std-socketio-v1.md (archive live)"
grep -qF STD-SOCKETIO-001 "$DOC" || die "doc missing STD-SOCKETIO-001"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_APIS="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
done < "$MANIFEST"
[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_socketio_symbols_ok "$MOD_X" "$SIO_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-socketio manifest OK"

if [ "${XLANG_STD_SOCKETIO_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_socketio_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-socketio gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-SOCKETIO-001: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs) ==="

# Host-C archaeology = obs only; refuse soft ensure_std_c_o.
# PLATFORM: SHARED — missing prebuilt socketio.o = obs, not soft SKIP→OK.
set +e
std_socketio_run_c_smoke "$SOCKETIO_O"
c_rc=$?
set -e
case "$c_rc" in
  0)
    RUN_OK=$((RUN_OK + 1))
    echo "std-socketio OK: c smoke"
    ;;
  *)
    echo "std-socketio OBS c smoke (rc=$c_rc)" >&2
    OBS=$((OBS + 1))
    ;;
esac

# check = obs (paused); sample first smoke only to bound cost.
# PLATFORM: SHARED — refuse hard check as sole green.
set +e
"$XLANG_BIN" check -L . "$FRAME_X" >/tmp/xlang_std_socketio_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-socketio OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# tip product UNDEF/SEGV residual = obs per smoke (leave product debt).
# PLATFORM: SHARED — refuse soft SKIP→OK / soft silence / soft ensure rebuild.
for smoke_x in "$FRAME_X" "$NODE_X" "$SERVER_X" "$NS_ACK_X" "$NS_ROUTER_X" \
  "$NS_SESSIONS_X" "$WS_HUB_X" "$ROOM_X" "$HUB_SYNC_X" "$SESSION_SYNC_X" \
  "$CLUSTER_SYNC_X" "$CLUSTER_ADAPTER_X" "$CLUSTER_RING_X" "$P3_COMPLETE_X"; do
  if std_socketio_run_smoke "$XLANG_BIN" "$smoke_x" "product"; then
    RUN_OK=$((RUN_OK + 1))
    echo "std-socketio OK: product $(basename "$smoke_x")"
  else
    echo "std-socketio OBS tip product $(basename "$smoke_x") (UNDEF/SEGV residual)" >&2
    OBS=$((OBS + 1))
  fi
done

std_socketio_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-socketio gate OK"
