#!/usr/bin/env bash
# std-csv-stream.sh — STD-128 stream reader/writer helpers.
#
# Usage (after source):
#   std_csv_stream_symbols_ok MOD_X CSV_X TSV
#   std_csv_stream_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash.

STD_CSV_STREAM_PREFIX="${XLANG_STD_CSV_STREAM_PREFIX:-xlang: [XLANG_STD_CSV_STREAM]}"

# Validate manifest api/symbol/file anchors. Echo miss count; return 0 when miss=0.
std_csv_stream_symbols_ok() {
  local mod_x="$1"
  local csv_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-csv-stream FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/csv/csv.c|std/csv/csv.x) path="$csv_x" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-csv-stream FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-csv-stream FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report line (honesty: run=/obs=/skip=; retired c=/x=).
std_csv_stream_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_CSV_STREAM_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
