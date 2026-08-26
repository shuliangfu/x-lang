#!/usr/bin/env bash
# F-04 v3: std.net WebSocket remove ws.inc.c (ws_codec/ws_io.x).
#
# Usage: ./tests/run-f04-std-net-ws-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f04-std-net-ws-gate.sh
# 2026-08-26: Honesty — hard-fail static TSV + inventory (no soft die→exit0).
# Soft XLANG_F04_NET_WS_FAIL retired. Prefer asm; pin XLANG_LINK_XLANG.
# STD-031 run-std-net-ws-gate observational (still prefers xlang-c check;
# check gate paused → CHK002 must not soft-fail this archaeology gate).
# Report static=/inventory=/ws=/skip=. Gate was portable-false-green (DOC
# top-level after archive; soft FAIL exit0; Makefile fossil greps).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_F04_NET_WS_DOC:-analysis/archive/phase/phase-f-f04-v3.md}"
WS_CODEC="std/net/ws_codec.x"
WS_IO="std/net/ws_io.x"
WS_MOD="std/websocket/mod.x"
MANIFEST="tests/baseline/f04-std-net-ws.tsv"
ENSURE="compiler/scripts/ensure_host_cc_seed_o.sh"
MK_STD="compiler/mk/std_and_panic_objs.mk"
PREFIX="xlang: [XLANG_F04_NET_WS]"

resolve_shu() {
  local cand abs
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$(pwd)/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

die() {
  echo "f04-net-ws gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} inventory=${INVENTORY_OK:-0} ws=${WS_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
INVENTORY_OK=0
WS_OK=0
SKIP=1

echo "=== F-04 v3: std.net ws remove ws.inc.c (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
grep -q 'F-04 v3' "$DOC" || die "doc missing F-04 v3 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-f-f04-v3.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$ENSURE" ] || die "missing ensure_host_cc_seed_o.sh"
[ -f "$MK_STD" ] || die "missing std_and_panic_objs.mk"
[ -f "$WS_CODEC" ] || die "missing ws_codec.x"
[ -f "$WS_IO" ] || die "missing ws_io.x"
[ ! -f std/net/ws.inc.c ] || die "ws.inc.c should be deleted"
[ ! -f std/net/net.c ] || die "std/net/net.c must stay deleted"
grep -q 'net_ws_compute_accept_c' "$WS_CODEC" || die "ws_codec missing accept"
grep -q 'net_ws_connect_c' "$WS_IO" || die "ws_io missing connect"
grep -q 'import("std.net.ws_codec")' "$WS_MOD" || die "websocket mod missing ws_codec import"
grep -q 'import("std.net.ws_io")' "$WS_MOD" || die "websocket mod missing ws_io import"
grep -q 'ws_compute_accept' "$WS_MOD" || die "websocket mod missing ws_compute_accept"
grep -q '../std/net/net.o' "$MK_STD" || die "mk missing net.o"

while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in
    \#*) continue ;;
  esac
  case "$kind" in
    symbol)
      target="$WS_CODEC"
      case "$mod_path" in
        std/net/ws_io.x) target="$WS_IO" ;;
        std/websocket/mod.x) target="$WS_MOD" ;;
      esac
      grep -qF "$anchor" "$target" || die "manifest missing '$anchor' in $target"
      ;;
    absent)
      [ ! -f "$anchor" ] || die "manifest absent file still exists: $anchor"
      ;;
    *)
      die "manifest unknown kind '$kind' for $item_id"
      ;;
  esac
done < "$MANIFEST"
echo "f04-net-ws manifest OK"
STATIC_OK=1

if [ ! -f tests/run-std-c-inventory-gate.sh ]; then
  die "missing tests/run-std-c-inventory-gate.sh"
fi
echo "=== F-04 v3: delegate run-std-c-inventory-gate (F-01; hard) ==="
chmod +x tests/run-std-c-inventory-gate.sh
if ! XLANG_STD_C_INVENTORY_FAIL=1 tests/run-std-c-inventory-gate.sh; then
  die "std-c-inventory sub-gate failed"
fi
INVENTORY_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1

# STD-031 product dogfood is observational (check gate paused; gate still
# prefers xlang-c and hard-exits on CHK002). Archaeology = static + inventory.
# PLATFORM: SHARED archaeology.
echo "=== F-04 v3: run-std-net-ws-gate (observational) ==="
set +e
if [ -f tests/run-std-net-ws-gate.sh ]; then
  chmod +x tests/run-std-net-ws-gate.sh
  if tests/run-std-net-ws-gate.sh; then
    WS_OK=1
  else
    echo "f04-net-ws: std-net-ws observational fail (not soft FAIL)" >&2
    WS_OK=0
  fi
else
  echo "f04-net-ws: std-net-ws observational skip (missing gate)" >&2
  WS_OK=0
fi
set -e
SKIP=0

echo "${PREFIX} status=ok static=${STATIC_OK} inventory=${INVENTORY_OK} ws=${WS_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f04 std.net ws gate OK (F-04 v3; honesty)"
