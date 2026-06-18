#!/usr/bin/env bash
# std-time-format-timezone.sh — STD-137 manifest 与烟测辅助

STD_TIME_FORMAT_TZ_PREFIX="${SHU_STD137_TIME_FORMAT_TZ_PREFIX:-shu: [SHU_STD137_TIME_FORMAT_TZ]}"

std_time_format_tz_symbols_ok() {
  local mod_su="$1"
  local time_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path _notes
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}" "$mod_su" 2>/dev/null; then
          echo "std-time-format-tz FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in std/time/time.c) path="$time_c" ;; esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-time-format-tz FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-time-format-tz FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_time_format_tz_run_smoke() {
  local shu="$1"
  local src="$2"
  local exe="/tmp/shu_std_time_ftz_$$"
  if ! "$shu" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-time-format-tz FAIL: compile $src" >&2
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

std_time_format_tz_run_c_smoke() {
  local time_o="$1"
  local dt_o="$2"
  local src="tests/time/format_timezone_smoke_ok.c"
  local out="/tmp/shu_std_time_ftz_c_$$"
  if [ ! -f "$src" ]; then
    printf '%s\n' \
      '#include <stdint.h>' \
      'extern int32_t time_format_timezone_smoke_c(void);' \
      'int main(void) { return time_format_timezone_smoke_c() != 0; }' > "$src"
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$time_o" "$dt_o" 2>/dev/null; then
    echo "std-time-format-tz FAIL: link C smoke" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

std_time_format_tz_emit_report() {
  echo "${STD_TIME_FORMAT_TZ_PREFIX} status=$1 c=$2 su=$3 skip=$4"
}
