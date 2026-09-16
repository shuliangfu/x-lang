#!/usr/bin/env bash
# std-json-typed-decode.sh — STD-116 typed decode helpers.
#
# Usage (after source):
#   std_json_typed_symbols_ok MOD_X JSON_X TSV
#   std_json_typed_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash.

STD_JSON_TYPED_PREFIX="${XLANG_STD116_JSON_TYPED_PREFIX:-xlang: [XLANG_STD116_JSON_TYPED]}"

# Validate manifest api/symbol/file anchors. Echo miss count; return 0 when miss=0.
std_json_typed_symbols_ok() {
  local mod_x="$1"
  local json_x="$2"
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
          std/json/json.c|std/json/json_parse_glue.c|std/json/json.x) path="$json_x" ;;
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

# Structured report line (honesty: run=/obs=/skip=; retired c=/x=).
std_json_typed_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_JSON_TYPED_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
