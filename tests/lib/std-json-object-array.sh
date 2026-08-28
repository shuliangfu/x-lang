#!/usr/bin/env bash
# std-json-object-array.sh — json-object-array (cursor/parse) manifest helpers.
#
# Usage (after source):
#   std_joa_symbols_ok MOD_X JSON_X TSV
#   std_joa_emit_report status run obs skip
# Honesty: run=/obs=/skip= (check retired to obs; prefer asm product -o hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_JOA_PREFIX="${XLANG_STD_JSON_OBJECT_ARRAY_PREFIX:-xlang: [XLANG_STD_JSON_OBJECT_ARRAY]}"

# Validate manifest symbol/file/smoke rows; echo miss count; return 0 on success.
std_joa_symbols_ok() {
  local mod_x="$1"
  local json_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        case "$mod_path" in
          std/json/json.c|std/json/json_parse_glue.c|std/json/json.x) mod_path="$json_x" ;;
          std/json/mod.x) mod_path="$mod_x" ;;
          *) mod_path="${mod_path:-$mod_x}" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-json-object-array FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-json-object-array FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ ! -f "$anchor" ]; then
          echo "std-json-object-array FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      anchor|section)
        # DOC keyword / section anchors are validated by the gate script.
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report line (honesty: run=/obs=/skip=).
# Hard-green signal is product -o (object_array_parse); check residual = obs.
# Legacy oa= renamed to run= for the honesty contract.
std_joa_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_JOA_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
