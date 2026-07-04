#!/usr/bin/env bash
# std-http-chunked.sh — STD-033 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_http_chunked_symbols_ok MOD_X CHUNKED_INC HTTP_C TSV
#   std_http_chunked_emit_report status chunked_ok keepalive_ok typeck_ok skip

STD_HTTP_CHUNKED_PREFIX="${SHUX_STD_HTTP_CHUNKED_PREFIX:-shux: [SHUX_STD_HTTP_CHUNKED]}"

# 校验 manifest；echo 缺失数。
std_http_chunked_symbols_ok() {
  local mod_x="$1"
  local chunked_inc="$2"
  local http_c="$3"
  local tsv="$4"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-http-chunked FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local target="${mod_path:-$chunked_inc}"
        if ! grep -qF "$anchor" "$target" 2>/dev/null; then
          echo "std-http-chunked FAIL: missing '$anchor' in $target" >&2
          miss=$((miss + 1))
        fi
        ;;
      cross_ref)
        if [ ! -f "$mod_path" ]; then
          echo "std-http-chunked FAIL: missing $mod_path" >&2
          miss=$((miss + 1))
        elif ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-http-chunked FAIL: $mod_path missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|bench)
        if [ ! -f "$anchor" ]; then
          echo "std-http-chunked FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
std_http_chunked_emit_report() {
  local status="$1"
  local chunked_ok="$2"
  local keepalive_ok="$3"
  local typeck_ok="$4"
  local skip="$5"
  echo "${STD_HTTP_CHUNKED_PREFIX} status=${status} chunked=${chunked_ok} keepalive=${keepalive_ok} typeck=${typeck_ok} skip=${skip}"
}
