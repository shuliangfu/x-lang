#!/usr/bin/env bash
# std-datetime-timezone.sh — STD-135 manifest 与烟测辅助（固定偏移时区）。
#
# 用法（source 后）：
#   std_datetime_timezone_symbols_ok MOD_X DT_X TSV
#   std_datetime_timezone_run_c_smoke DT_O TIME_O
#   std_datetime_timezone_emit_report status check_ok run_ok skip
# 2026-08-26: report check=/run=/skip= (honesty; prefer asm runnable hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

# shellcheck source=compiler-make.sh
. "$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/compiler-make.sh"
STD_DATETIME_TIMEZONE_PREFIX="${XLANG_STD135_DATETIME_TIMEZONE_PREFIX:-xlang: [XLANG_STD135_DATETIME_TIMEZONE]}"

# 校验 manifest；echo 缺失数。C smoke 符号在 datetime.x。
std_datetime_timezone_symbols_ok() {
  local mod_x="$1"
  local dt_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path _notes
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}" "$mod_x" 2>/dev/null; then
          echo "std-datetime-timezone FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      struct_tz)
        if ! grep -qE "struct ${anchor}" "$mod_x" 2>/dev/null; then
          echo "std-datetime-timezone FAIL: missing struct '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/datetime/datetime_glue.c|std/datetime/datetime.x) path="$dt_x" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-datetime-timezone FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|script|gate)
        if [ ! -f "$anchor" ]; then
          echo "std-datetime-timezone FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      anchor|section)
        # DOC keyword / ## 4. Gate anchors are validated by the gate script.
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Observational host-C archaeology smoke (link datetime.o + time.o).
# Not a hard-green signal; callers must treat failure as SKIP note.
std_datetime_timezone_run_c_smoke() {
  local dt_o="$1"
  local time_o="$2"
  local src="tests/std-datetime/timezone_smoke_ok.c"
  local out="/tmp/xlang_std_dt_tz_c_$$"
  if [ ! -f "$src" ]; then
    printf '%s\n' \
      '#include <stdint.h>' \
      'extern int32_t datetime_timezone_smoke_c(void);' \
      'int main(void) { return datetime_timezone_smoke_c() != 0; }' > "$src"
  fi
  xlang_compiler_make runtime_time_os.o >/dev/null 2>&1 || true
  # Observational only: silent link failure (gate prints SKIP note).
  if ! cc -std=c11 -O1 -o "$out" "$src" "$dt_o" "$time_o" compiler/runtime_time_os.o 2>/dev/null; then
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

# 输出结构化报告行（honesty: check=/run=/skip=）。
std_datetime_timezone_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_DATETIME_TIMEZONE_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
