#!/usr/bin/env bash
# std-http-https.sh — STD-HTTP-HTTPS manifest 与烟测辅助

STD_HTTP_HTTPS_PREFIX="${SHUX_STD_HTTP_HTTPS_PREFIX:-shux: [SHUX_STD_HTTP_HTTPS]}"

std_http_https_symbols_ok() {
  local mod_x="$1"
  local http_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null || miss=$((miss + 1))
        ;;
      symbol)
        case "$mod_path" in
          compiler/src/asm/http/runtime_http_glue.c) mod_path="$http_c" ;;
        esac
        grep -qF "$anchor" "$mod_path" 2>/dev/null || miss=$((miss + 1))
        ;;
      file|smoke)
        [ -f "$anchor" ] || miss=$((miss + 1))
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_http_https_run_x_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_http_https_$$"
  "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1 || return 1
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  [ "$ec" -eq 0 ]
}

std_http_https_run_c_smoke() {
  local http_o="$1"
  local net_o="$2"
  local ldflags="$3"
  local out="/tmp/shux_std_http_https_c_$$"
  # shellcheck disable=SC2086
  cc -std=c11 -O1 -o "$out" tests/http/https_smoke_ok.c "$http_o" "$net_o" $ldflags 2>/dev/null || return 1
  set +e
  SHUX_HTTPS_SMOKE_PORT="${SHUX_HTTPS_SMOKE_PORT:-}" "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

std_http_https_emit_report() {
  echo "${STD_HTTP_HTTPS_PREFIX} status=$1 c=$2 x=$3 skip=$4 openssl=$5"
}
