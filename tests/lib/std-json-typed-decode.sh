#!/usr/bin/env bash
# std-json-typed-decode.sh — STD-116 manifest 与烟测辅助

STD_JSON_TYPED_PREFIX="${SHUX_STD116_JSON_TYPED_PREFIX:-shux: [SHUX_STD116_JSON_TYPED]}"

std_json_typed_symbols_ok() {
  local mod_x="$1"
  local json_c="$2"
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
        local path="$mod_path"
        case "$path" in
          std/json/json.c|std/json/json_parse_glue.c|std/json/json.x) path="$json_c" ;;
        esac
        grep -qF "$anchor" "$path" 2>/dev/null || miss=$((miss + 1))
        ;;
      file|smoke|vectors)
        [ -f "$anchor" ] || miss=$((miss + 1))
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_json_typed_run_x_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_json_typed_$$"
  "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1 || return 1
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  [ "$ec" -eq 0 ]
}

std_json_typed_run_c_smoke() {
  local json_o="$1"
  local out="/tmp/shux_std_json_typed_c_$$"
  cc -std=c11 -O1 -o "$out" tests/json/typed_decode_smoke_ok.c "$json_o" 2>/dev/null || return 1
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

std_json_typed_emit_report() {
  echo "${STD_JSON_TYPED_PREFIX} status=$1 c=$2 x=$3 skip=$4"
}
