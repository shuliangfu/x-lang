#!/usr/bin/env bash
# std-json-serialize.sh — STD-035 manifest helpers.
#
# Usage (after source):
#   std_jsz_symbols_ok MOD_X JSON_X TSV
#   std_jsz_emit_report status run obs skip
# Honesty: run=/obs=/skip= (check retired to obs; prefer asm product -o hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_JSZ_PREFIX="${XLANG_STD_JSON_SERIALIZE_PREFIX:-xlang: [XLANG_STD_JSON_SERIALIZE]}"

# Validate manifest symbol/file/script rows; echo miss count; return 0 on success.
std_jsz_symbols_ok() {
  local json_x="$1"
  local json_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        case "$mod_path" in
          std/json/json.c|std/json/json_parse_glue.c|std/json/json.x) mod_path="$json_c" ;;
          *) mod_path="$json_x" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-json-serialize FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file)
        if [ ! -f "$anchor" ]; then
          echo "std-json-serialize FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ ! -f "$anchor" ]; then
          echo "std-json-serialize FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      anchor)
        # DOC keyword anchors are validated by the gate script, not here.
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report line (honesty: run=/obs=/skip=).
# Hard-green signal is product -o runnable; check residual = obs.
std_jsz_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_JSZ_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
