#!/usr/bin/env bash
# F-04 v3：std.net WebSocket 去 C 门禁（ws_codec/ws_io.sx + 无 ws.inc.c）。
#
# 用法：./tests/run-f04-std-net-ws-gate.sh
# 环境：SHUX_F04_NET_WS_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F04_NET_WS_FAIL:-0}
DOC="analysis/phase-f-f04-v3.md"
WS_CODEC="std/net/ws_codec.sx"
WS_IO="std/net/ws_io.sx"
WS_MOD="std/websocket/mod.sx"
MANIFEST="tests/baseline/f04-std-net-ws.tsv"

die() {
  echo "f04-net-ws gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-04 v3: std.net ws remove ws.inc.c ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v3' "$DOC" || die "doc missing F-04 v3 marker"
[ -f "$WS_CODEC" ] || die "missing ws_codec.sx"
[ -f "$WS_IO" ] || die "missing ws_io.sx"
[ ! -f std/net/ws.inc.c ] || die "ws.inc.c should be deleted"
grep -q 'net_ws_compute_accept_c' "$WS_CODEC" || die "ws_codec missing accept"
grep -q 'net_ws_connect_c' "$WS_IO" || die "ws_io missing connect"
grep -q 'import("std.net.ws_codec")' "$WS_MOD" || die "websocket mod missing ws_codec import"
grep -q 'import("std.net.ws_io")' "$WS_MOD" || die "websocket mod missing ws_io import"
if grep -q 'ws.inc.c' std/net/net.c 2>/dev/null; then
  die "net.c still includes ws.inc.c"
fi
if grep -q 'ws.inc.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references ws.inc.c"
fi

if [ -f "$MANIFEST" ]; then
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        target="$WS_CODEC"
        case "$mod_path" in
          std/net/ws_io.sx) target="$WS_IO" ;;
          std/websocket/mod.sx) target="$WS_MOD" ;;
        esac
        grep -qF "$anchor" "$target" || die "manifest missing '$anchor' in $target"
        ;;
      absent)
        [ ! -f "$anchor" ] || die "manifest absent file still exists: $anchor"
        ;;
    esac
  done < "$MANIFEST"
fi

if [ -f tests/run-std-net-ws-gate.sh ]; then
  echo "=== F-04 v3: delegate run-std-net-ws-gate.sh ==="
  chmod +x tests/run-std-net-ws-gate.sh
  if ! tests/run-std-net-ws-gate.sh; then
    die "std-net-ws sub-gate failed"
  fi
fi

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-04 v3: delegate run-std-c-inventory-gate (F-01) ==="
  chmod +x tests/run-std-c-inventory-gate.sh
  if ! SHUX_STD_C_INVENTORY_FAIL="$FAIL" tests/run-std-c-inventory-gate.sh; then
    die "std-c-inventory sub-gate failed"
  fi
fi

echo "f04 std.net ws gate OK (F-04 v3)"
