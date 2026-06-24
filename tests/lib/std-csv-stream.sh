#!/usr/bin/env bash
# std-csv-stream.sh — STD-128 manifest 与烟测辅助（F-csv v1：csv.sx）

STD_CSV_STREAM_PREFIX="${SHUX_STD_CSV_STREAM_PREFIX:-shux: [SHUX_STD_CSV_STREAM]}"

std_csv_stream_symbols_ok() {
  local mod_sx="$1"
  local csv_sx="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_sx" 2>/dev/null; then
          echo "std-csv-stream FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/csv/csv.c|std/csv/csv.sx) path="$csv_sx" ;;
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

std_csv_stream_run_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_csv_stream_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-csv-stream FAIL: compile $src" >&2
    "$shux" -L . "$src" 2>&1 | tail -10 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-csv-stream FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# C 烟测：直接调用 csv_stream_smoke_c（需 sync.o 来自 csv.o）。
std_csv_stream_run_c_smoke() {
  local csv_o="$1"
  local src="tests/csv/stream_smoke_ok.c"
  local out="/tmp/shux_std_csv_stream_c_$$"
  if [ ! -f "$csv_o" ]; then
    echo "std-csv-stream FAIL: missing $csv_o" >&2
    return 1
  fi
  if [ ! -f "$src" ]; then
    echo "std-csv-stream SKIP c smoke (no $src)" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$csv_o" 2>/dev/null; then
    echo "std-csv-stream FAIL: compile C smoke" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-csv-stream FAIL: C smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

std_csv_stream_emit_report() {
  echo "${STD_CSV_STREAM_PREFIX} status=$1 c=$2 sx=$3 skip=$4"
}
