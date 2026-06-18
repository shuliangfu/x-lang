#!/usr/bin/env bash
# std-csv-stream.sh — STD-128 manifest 与烟测辅助

STD_CSV_STREAM_PREFIX="${SHU_STD128_CSV_STREAM_PREFIX:-shu: [SHU_STD128_CSV_STREAM]}"

# 校验 manifest 条目。
std_csv_stream_symbols_ok() {
  local mod_su="$1"
  local csv_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}" "$mod_su" 2>/dev/null; then
          echo "std-csv-stream FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/csv/csv.c) path="$csv_c" ;;
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

# 编译并运行 .su 烟测。
std_csv_stream_run_smoke() {
  local shu="$1"
  local src="$2"
  local exe="/tmp/shu_std_csv_stream_$$"
  if ! "$shu" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-csv-stream FAIL: compile $src" >&2
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  [ "$ec" -eq 0 ]
}

# 链接 csv.o 运行 C smoke。
std_csv_stream_run_c_smoke() {
  local csv_o="$1"
  local src="tests/csv/stream_smoke_ok.c"
  local out="/tmp/shu_std_csv_stream_c_$$"
  if [ ! -f "$src" ]; then
    printf '%s\n' \
      '#include <stdint.h>' \
      'extern int32_t csv_stream_smoke_c(void);' \
      'int main(void) { return csv_stream_smoke_c() != 0; }' > "$src"
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$csv_o" 2>/dev/null; then
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

# 输出 gate 报告。
std_csv_stream_emit_report() {
  echo "${STD_CSV_STREAM_PREFIX} status=$1 c=$2 su=$3 skip=$4"
}
