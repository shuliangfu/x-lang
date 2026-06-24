#!/usr/bin/env bash
# std-net-ws.sh — STD-031：WebSocket manifest 与烟测辅助
#
# 用法（source 后）：
#   std_net_ws_symbols_ok MOD_SX WS_INC TSV
#   std_net_ws_emit_report status accept_ok frame_ok typeck_ok skip

STD_NET_WS_PREFIX="${SHUX_STD_NET_WS_PREFIX:-shux: [SHUX_STD_NET_WS]}"

# 校验 manifest symbol/api/file；echo 缺失数。
std_net_ws_symbols_ok() {
  local mod_sx="$1"
  local ws_inc="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_sx" 2>/dev/null; then
          echo "std-net-ws FAIL: missing api '$anchor' in $mod_sx" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local target="${mod_path:-$ws_inc}"
        case "$mod_path" in
          std/net/ws_codec.sx|std/net/ws_io.sx) target="$mod_path" ;;
          std/net/ws.inc.c) target="std/net/ws_codec.sx" ;;
        esac
        if ! grep -qF "$anchor" "$target" 2>/dev/null; then
          echo "std-net-ws FAIL: missing '$anchor' in $target" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-net-ws FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
std_net_ws_emit_report() {
  local status="$1"
  local accept_ok="$2"
  local frame_ok="$3"
  local typeck_ok="$4"
  local skip="$5"
  echo "${STD_NET_WS_PREFIX} status=${status} accept=${accept_ok} frame=${frame_ok} typeck=${typeck_ok} skip=${skip}"
}
