#!/usr/bin/env bash
# std-time-format-timezone.sh — STD-137 manifest 与烟测辅助

STD_TIME_FORMAT_TZ_PREFIX="${XLANG_STD137_TIME_FORMAT_TZ_PREFIX:-xlang: [XLANG_STD137_TIME_FORMAT_TZ]}"

std_time_format_tz_symbols_ok() {
  local mod_x="$1"
  local time_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path _notes
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}" "$mod_x" 2>/dev/null; then
          echo "std-time-format-tz FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/time/time.c|std/time/time.x) path="$time_c" ;;
          std/time/time_os_glue.c|compiler/seeds/runtime_time_os.from_x.c) path="${time_runtime:-compiler/seeds/runtime_time_os.from_x.c}" ;;
        esac
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
  local xlang="$1"
  local src="$2"
  local exe="/tmp/xlang_std_time_ftz_$$"
  if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
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
  local out="/tmp/xlang_std_time_ftz_c_$$"
  if [ ! -f "$src" ]; then
    printf '%s\n' \
      '#include <stdint.h>' \
      'extern int32_t time_format_timezone_smoke_c(void);' \
      'int main(void) { return time_format_timezone_smoke_c() != 0; }' > "$src"
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$time_o" "$dt_o" compiler/runtime_time_os.o 2>/dev/null; then
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

# Emit structured report line (honesty: check=/run=/skip=).
# @param status ok|fail
# @param check_ok 0|1 observational xlang check
# @param run_ok 0|1 hard runnable exit0
# @param skip 0|1 residual skip bit (0 when runnable hard-green)
std_time_format_tz_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_TIME_FORMAT_TZ_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
