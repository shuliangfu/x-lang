#!/usr/bin/env bash
# std-time.sh — STD-005 manifest helpers (precision / timezone)
#
# Usage (after source):
#   std_time_api_count [manifest_tsv]
#   std_time_has_api MOD_X fn_name
#   std_time_run_smoke XLANG_BIN smoke_x tag
#   std_time_emit_report status check_ok main_ok precision_ok skip
# 2026-08-26: report check=/main=/precision=/skip= (honesty; prefer asm runnable hard).
# PLATFORM: SHARED archaeology.

STD_TIME_PREFIX="${XLANG_STD005_TIME_PREFIX:-xlang: [XLANG_STD005_TIME]}"

# Count api rows in manifest (comments excluded).
std_time_api_count() {
  local man="${1:-tests/baseline/std-time-manifest.tsv}"
  awk -F'\t' '$2=="api" && $1 !~ /^#/ { n++ } END { print n+0 }' "$man"
}

# Check that mod.x exports the named function.
std_time_has_api() {
  local mod="$1"
  local fn="$2"
  grep -qE "function ${fn}\\(" "$mod" 2>/dev/null
}

# Compile and run smoke .x; expect exit 0.
# Prefer RUN_XLANG (after gate pins XLANG_LINK_XLANG) so Darwin does not
# silently remap asm→c. Falls back to direct XLANG_BIN -L . -o.
# PLATFORM: SHARED archaeology — product honesty path.
std_time_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_time_${tag}_$$"
  local log="/tmp/xlang_std_time_build_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-time FAIL: missing $src" >&2
    return 1
  fi
  if [ -n "${RUN_XLANG:-}" ]; then
    if ! $RUN_XLANG build -L . "$src" -o "$exe" >"$log" 2>&1; then
      echo "std-time FAIL: compile $src" >&2
      tail -12 "$log" 2>/dev/null >&2 || true
      rm -f "$exe" "$log"
      return 1
    fi
  else
    if ! "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1; then
      echo "std-time FAIL: compile $src" >&2
      tail -12 "$log" 2>/dev/null >&2 || true
      rm -f "$exe" "$log"
      return 1
    fi
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-time FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: check=/main=/precision=/skip=).
std_time_emit_report() {
  local status="$1"
  local check_ok="$2"
  local main_ok="$3"
  local precision_ok="$4"
  local skip="$5"
  echo "${STD_TIME_PREFIX} status=${status} check=${check_ok} main=${main_ok} precision=${precision_ok} skip=${skip}"
}
