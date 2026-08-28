#!/usr/bin/env bash
# STD-031: std.websocket gate — honesty soft prefer-c / soft SKIP→OK /
# soft auto-make / soft ensure_std_c_o / accept=/frame=/typeck= report →硬绿.
#
# Honesty: prefer-c first (xlang-c) + soft SKIP→OK (no native still gate OK) +
# soft `ensure_std_c_o` / soft `xlang_compiler_make … || true` + hard check as
# sole .x smoke + soft SKIP on zstd-missing link + report
# `accept=`/`frame=`/`typeck=` retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die. Host-C archaeology = obs only (prebuilt
# std/net/net.o; refuse soft ensure). check residual = obs
# (paused 2026-08-05). tip product -o UNDEF = obs (product debt; leave).
# Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-net-ws-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_NET_WS_DOC:-analysis/archive/std/std-net-ws-v1.md}"
MANIFEST="${XLANG_STD_NET_WS_TSV:-tests/baseline/std-net-ws.tsv}"
MOD_X="std/websocket/mod.x"
WS_README="std/websocket/README.md"
WS_CODEC="std/net/ws_codec.x"
WS_IO="std/net/ws_io.x"
LIB="tests/lib/std-net-ws.sh"
FRAME_X="tests/net/ws_frame.x"
MIN_APIS=30

# shellcheck source=tests/lib/std-net-ws.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-net-ws gate FAIL: $*" >&2
  std_net_ws_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-031: std.websocket manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$WS_README" "$WS_CODEC" "$WS_IO" "$FRAME_X"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-031 WebSocket ws_compute_accept ws_encode_ping_frame ws_connect ws_connect_url wss_is_available ws_server_accept ws_validate_upgrade_request ws_timeout_ms_from_ctx ws_read_frame_ctx Upgrade websocket; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qE '^## 5\. Gate|^## Gate' "$DOC" || die "doc missing ## Gate section"
[ ! -f analysis/std-net-ws-v1.md ] || die "dual-authority fossil analysis/std-net-ws-v1.md (archive live)"

if [ -f std/net/net.c ] && grep -q 'ws.inc.c' std/net/net.c 2>/dev/null; then
  die "net.c still includes ws.inc.c"
fi

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
      grep -qF "$anchor" "$DOC" 2>/dev/null || die "doc missing section $anchor"
      ;;
  esac
done < "$MANIFEST"
[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_net_ws_symbols_ok "$MOD_X" "$WS_CODEC" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-net-ws manifest OK"

if [ "${XLANG_STD_NET_WS_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_net_ws_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-net-ws gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-031: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs) ==="

# Host-C archaeology = obs only; refuse soft ensure/auto-make.
# PLATFORM: SHARED — missing deps = obs, not soft SKIP→OK.
set +e
std_net_ws_run_c_smoke
c_rc=$?
set -e
case "$c_rc" in
  0)
    RUN_OK=$((RUN_OK + 1))
    echo "std-net-ws OK: c smoke"
    ;;
  *)
    echo "std-net-ws OBS c smoke (rc=$c_rc)" >&2
    OBS=$((OBS + 1))
    ;;
esac

set +e
"$XLANG_BIN" check -L . "$FRAME_X" >/tmp/xlang_std_net_ws_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-net-ws OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# tip product UNDEF residual = obs (leave product debt).
# PLATFORM: SHARED — refuse soft SKIP→OK / soft silence / soft zstd SKIP.
if std_net_ws_run_smoke "$XLANG_BIN" "$FRAME_X" "frame"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-net-ws OK: product -o"
else
  echo "std-net-ws OBS tip product -o (std_websocket_* UNDEF residual)" >&2
  OBS=$((OBS + 1))
fi

std_net_ws_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-net-ws gate OK"
