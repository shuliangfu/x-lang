#!/usr/bin/env bash
# std-csv-row.sh — STD-036 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_csv_row_symbols_ok CSV_SU CSV_C TSV
#   std_csv_row_run_smoke SHU_BIN SU TAG
#   std_csv_row_emit_report status rt_ok main_ok skip

STD_CSV_ROW_PREFIX="${SHU_STD_CSV_ROW_PREFIX:-shu: [SHU_STD_CSV_ROW]}"

# 校验 manifest symbol/file；echo 缺失数，成功返回 0。
std_csv_row_symbols_ok() {
  local csv_su="$1"
  local csv_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        case "$mod_path" in
          std/csv/csv.c) mod_path="$csv_c" ;;
          *) mod_path="$csv_su" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-csv-row FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file)
        if [ ! -f "$anchor" ]; then
          echo "std-csv-row FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行烟测 .su（须已 ensure csv.o）。
std_csv_row_run_smoke() {
  local shu="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shu_std_csv_row_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-csv-row FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shu" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-csv-row FAIL: compile $src" >&2
    "$shu" -L . "$src" 2>&1 | tail -8 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-csv-row FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行。
std_csv_row_emit_report() {
  local status="$1"
  local rt_ok="$2"
  local main_ok="$3"
  local skip="$4"
  echo "${STD_CSV_ROW_PREFIX} status=${status} rt=${rt_ok} main=${main_ok} skip=${skip}"
}
