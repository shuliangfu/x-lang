#!/usr/bin/env bash
# std-simd-prod.sh — STD-061 production bench helpers.
#
# Usage (after source):
#   std_simd_prod_run_smoke XLANG_BIN X [TAG]
#   std_simd_prod_emit_report status run obs skip [ratio]
# Honesty: run=/obs=/skip= (check/perf = obs; product r04 -o hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_SIMD_PROD_PREFIX="${XLANG_STD061_PREFIX:-xlang: [XLANG_STD061_SIMD_PROD]}"

# Compile and run product bench .x via XLANG_BIN -L . -o; expect exit 0.
# Refuse soft RUN_XLANG remap / soft auto-make (gate pins XLANG_LINK_XLANG).
# PLATFORM: SHARED archaeology — product honesty path; SIMD needs asm backend.
std_simd_prod_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-r04}"
  local exe="/tmp/xlang_std_simd_prod_${tag}_$$"
  local log="/tmp/xlang_std_simd_prod_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-simd-prod FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-simd-prod FAIL: compile $src" >&2
    tail -n 12 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-simd-prod FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=).
# Hard-green signal is product -o bench/r04_simd_shuffle_select.x; check/perf = obs.
std_simd_prod_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  local ratio="${5:-}"
  if [ -n "$ratio" ]; then
    echo "${STD_SIMD_PROD_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip} ratio=${ratio}"
  else
    echo "${STD_SIMD_PROD_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
  fi
}
