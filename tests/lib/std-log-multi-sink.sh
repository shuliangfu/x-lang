#!/usr/bin/env bash
# std-log-multi-sink.sh — STD-053 manifest + host-C archaeology helpers.
#
# Usage (after source):
#   std_log_multi_sink_symbols_ok MOD_X LOG_X LOG_GLUE TSV
#   std_log_multi_sink_run_c_smoke   # existing .o only; no soft rebuild
#   std_log_multi_sink_emit_report status run obs skip
# Honesty: run=/obs=/skip= (check/host-C = obs; prefer asm product -o hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_LOG_MULTI_SINK_PREFIX="${XLANG_STD_LOG_MULTI_SINK_PREFIX:-xlang: [XLANG_STD_LOG_MULTI_SINK]}"

# Walk manifest TSV; validate api/const/symbol/file/smoke. Echo miss count.
std_log_multi_sink_symbols_ok() {
  local mod_x="$1"
  local log_x="$2"
  local log_glue="$3"
  local tsv="$4"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-log-multi-sink FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      const)
        if ! grep -qE "const ${anchor}:" "$mod_x" 2>/dev/null; then
          echo "std-log-multi-sink FAIL: missing const '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/log/log.c|std/log/log.x) path="$log_x" ;;
          std/log/log_os_glue.c|compiler/seeds/runtime_log_os.from_x.c) path="$log_glue" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-log-multi-sink FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-log-multi-sink FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Host-C archaeology: multi_sink_ok.c + existing log.o + runtime_log_os.o.
# Refuse soft ensure_std_c_o / soft auto-make of missing .o (obs path only).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
std_log_multi_sink_run_c_smoke() {
  local src="tests/std-log/multi_sink_ok.c"
  local out="/tmp/xlang_std_log_multi_sink_$$"
  local log_o="std/log/log.o"
  local rt_o="compiler/runtime_log_os.o"
  if [ ! -f "$log_o" ] || [ ! -f "$rt_o" ]; then
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$log_o" "$rt_o" 2>/dev/null; then
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
# Hard-green signal is product -o level_filter; check/host-C = obs.
std_log_multi_sink_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_LOG_MULTI_SINK_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
