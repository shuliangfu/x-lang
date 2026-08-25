#!/usr/bin/env bash
# std-csv-row.sh — STD-036 manifest 与烟测辅助（F-csv v1：csv.x）
#
# 用法（source 后）：
#   std_csv_row_symbols_ok MOD_X CSV_X TSV
#   std_csv_row_emit_report status check_ok run_ok skip
# 2026-08-26: report check=/run=/skip= (honesty; prefer asm runnable hard).

STD_CSV_ROW_PREFIX="${XLANG_STD_CSV_ROW_PREFIX:-xlang: [XLANG_STD_CSV_ROW]}"

# 校验 manifest；C symbol 在 csv.x。
std_csv_row_symbols_ok() {
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
          echo "std-csv-row FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        case "$mod_path" in
          std/csv/csv.c|std/csv/csv.x) mod_path="$csv_x" ;;
          std/csv/mod.x) mod_path="$mod_x" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-csv-row FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|script)
        if [ ! -f "$anchor" ]; then
          echo "std-csv-row FAIL: missing '$anchor'" >&2
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

# 输出结构化报告行（honesty: check=/run=/skip=）。
std_csv_row_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_CSV_ROW_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
