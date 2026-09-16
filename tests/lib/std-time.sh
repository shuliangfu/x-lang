#!/usr/bin/env bash
# std-time.sh — STD-005: precision / timezone manifest helpers.
#
# Usage (after source):
#   std_time_api_count [manifest_tsv]
#   std_time_has_api MOD_X fn_name
#   std_time_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

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

# Structured report line (honesty: run=/obs=/skip=; check residual = obs).
std_time_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_TIME_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
