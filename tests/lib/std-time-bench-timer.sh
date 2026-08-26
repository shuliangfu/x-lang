#!/usr/bin/env bash
# std-time-bench-timer.sh — STD-133 manifest 与烟测辅助
# Honesty 2026-08-26: report check=/run=/skip=; TSV anchors = product short names.

STD_TIME_BENCH_TIMER_PREFIX="${XLANG_STD133_TIME_BENCH_TIMER_PREFIX:-xlang: [XLANG_STD133_TIME_BENCH_TIMER]}"

# Validate manifest entries against product mod.x; echo miss count.
# @param mod_x path to std/time/mod.x
# @param tsv path to baseline TSV
# @return 0 when miss==0
std_time_bench_timer_symbols_ok() {
  local mod_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path _notes
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}" "$mod_x" 2>/dev/null; then
          echo "std-time-bench-timer FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      struct|struct_timer)
        if ! grep -qE "struct ${anchor}" "$mod_x" 2>/dev/null; then
          echo "std-time-bench-timer FAIL: missing struct '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-time-bench-timer FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ ! -f "$mod_path" ] && [ ! -f "tests/$anchor" ] && [ ! -f "$anchor" ]; then
          : # gate path checked by gate itself
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run .x smoke (legacy helper; gate prefers RUN_XLANG build).
# @param xlang compiler binary
# @param src .x smoke path
# @return 0 on exit 0
std_time_bench_timer_run_smoke() {
  local xlang="$1"
  local src="$2"
  local exe="/tmp/xlang_std_time_bench_$$"
  if ! "$xlang" -L . "$src" -o "$exe" 2>&1; then
    echo "std-time-bench-timer FAIL: compile $src" >&2
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-time-bench-timer FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Emit structured report line (honesty: check=/run=/skip=).
# @param status ok|fail
# @param check_ok 0|1 observational xlang check
# @param run_ok 0|1 hard runnable exit0
# @param skip 0|1 residual skip bit (0 when runnable hard-green)
std_time_bench_timer_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_TIME_BENCH_TIMER_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
