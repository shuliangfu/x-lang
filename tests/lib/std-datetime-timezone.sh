#!/usr/bin/env bash
# std-datetime-timezone.sh — STD-135 manifest 与烟测辅助

STD_DATETIME_TIMEZONE_PREFIX="${SHUX_STD135_DATETIME_TIMEZONE_PREFIX:-shux: [SHUX_STD135_DATETIME_TIMEZONE]}"

# 校验 manifest 条目；echo 缺失数。
std_datetime_timezone_symbols_ok() {
  local mod_su="$1"
  local dt_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path _notes
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}" "$mod_su" 2>/dev/null; then
          echo "std-datetime-timezone FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      struct_tz)
        if ! grep -qE "struct ${anchor}" "$mod_su" 2>/dev/null; then
          echo "std-datetime-timezone FAIL: missing struct '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/datetime/datetime.c) path="$dt_c" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-datetime-timezone FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-datetime-timezone FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 .sx 烟测。
std_datetime_timezone_run_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_dt_tz_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-datetime-timezone FAIL: compile $src" >&2
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

# 链接 datetime.o + time.o 运行 C 金样。
std_datetime_timezone_run_c_smoke() {
  local dt_o="$1"
  local time_o="$2"
  local src="tests/std-datetime/timezone_smoke_ok.c"
  local out="/tmp/shux_std_dt_tz_c_$$"
  if [ ! -f "$src" ]; then
    printf '%s\n' \
      '#include <stdint.h>' \
      'extern int32_t datetime_timezone_smoke_c(void);' \
      'int main(void) { return datetime_timezone_smoke_c() != 0; }' > "$src"
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$dt_o" "$time_o" 2>/dev/null; then
    echo "std-datetime-timezone FAIL: link C smoke" >&2
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
std_datetime_timezone_emit_report() {
  echo "${STD_DATETIME_TIMEZONE_PREFIX} status=$1 c=$2 su=$3 skip=$4"
}
