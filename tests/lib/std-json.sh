#!/usr/bin/env bash
# std-json.sh — STD-008: std.json zero-copy manifest helpers.
#
# Usage (after source):
#   std_json_api_count [manifest_tsv]
#   std_json_has_api MOD_X fn_name
#   std_json_has_c_impl JSON_X sym_name
#   std_json_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_JSON_PREFIX="${XLANG_STD_JSON_PREFIX:-xlang: [XLANG_STD_JSON]}"

# Count api rows in the manifest TSV.
std_json_api_count() {
  local man="${1:-tests/baseline/std-json-manifest.tsv}"
  awk -F'\t' '$2=="api" && $1 !~ /^#/ { n++ } END { print n+0 }' "$man"
}

# True if mod.x exports function fn_name(.
std_json_has_api() {
  local mod="$1"
  local fn="$2"
  grep -qE "function ${fn}\\(" "$mod" 2>/dev/null
}

# True if json.x (or legacy .c) defines sym_name(.
std_json_has_c_impl() {
  local cfile="$1"
  local sym="$2"
  grep -qF "${sym}(" "$cfile" 2>/dev/null
}

# Structured report line (honesty: run=/obs=/skip=).
# Hard-green signal is main product -o; zc / check residuals = obs
# (Darwin arm64 needs_copy residual on zc_parse_string_view).
std_json_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_JSON_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
