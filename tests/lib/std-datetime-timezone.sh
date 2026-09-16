#!/usr/bin/env bash
# std-datetime-timezone.sh — STD-135 manifest helpers (fixed-offset timezone).
#
# Usage (after source):
#   std_datetime_timezone_symbols_ok MOD_X DT_X TSV
#   std_datetime_timezone_run_c_smoke   # existing .o only; no soft rebuild
#   std_datetime_timezone_emit_report status run obs skip
# Honesty: run=/obs=/skip= (check/host-C = obs; prefer asm product -o hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_DATETIME_TIMEZONE_PREFIX="${XLANG_STD135_DATETIME_TIMEZONE_PREFIX:-xlang: [XLANG_STD135_DATETIME_TIMEZONE]}"

# Validate manifest; echo miss count; return 0 when miss=0.
# C smoke symbol lives in datetime.x.
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

# Host-C archaeology: timezone_smoke_ok.c + existing datetime.o/time.o/runtime_time_os.o.
# Refuse soft ensure_std_c_o / soft auto-make of missing .o (obs path only).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
std_datetime_timezone_run_c_smoke() {
  local dt_o="std/datetime/datetime.o"
  local time_o="std/time/time.o"
  local rt_o="compiler/runtime_time_os.o"
  local src="tests/std-datetime/timezone_smoke_ok.c"
  local out="/tmp/xlang_std_dt_tz_c_$$"
  if [ ! -f "$dt_o" ] || [ ! -f "$time_o" ] || [ ! -f "$rt_o" ]; then
    return 1
  fi
  if ! nm "$dt_o" 2>/dev/null | grep -qF 'datetime_timezone_smoke_c'; then
    return 1
  fi
  if [ ! -f "$src" ]; then
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$dt_o" "$time_o" "$rt_o" 2>/dev/null; then
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

# Structured report line (honesty: run=/obs=/skip=).
# Hard-green signal is product -o timezone.x; check/host-C = obs.
std_datetime_timezone_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_DATETIME_TIMEZONE_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
