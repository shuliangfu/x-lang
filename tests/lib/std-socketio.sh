#!/usr/bin/env bash
# std-socketio.sh — STD-SOCKETIO-001 manifest 与烟测辅助

STD_SOCKETIO_PREFIX="${SHUX_STD_SOCKETIO_PREFIX:-shux: [SHUX_STD_SOCKETIO]}"

std_socketio_symbols_ok() {
  local mod_sx="$1"
  local c_src="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor
  while IFS=$'\t' read -r item_id kind anchor _rest; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        grep -qE "function ${anchor}\\(" "$mod_sx" 2>/dev/null || miss=$((miss + 1))
        ;;
      symbol)
        grep -qF "${anchor}" "$c_src" 2>/dev/null || miss=$((miss + 1))
        ;;
      smoke)
        [ -f "$anchor" ] || miss=$((miss + 1))
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_socketio_emit_report() {
  local status="$1"
  local smoke_ok="$2"
  local skip="$3"
  echo "${STD_SOCKETIO_PREFIX} status=${status} smoke=${smoke_ok} skip=${skip}"
}
