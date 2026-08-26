#!/usr/bin/env bash
# std-json.sh — STD-008 shared: std.json API + smoke helpers
#
# Usage (after source):
#   std_json_api_count [manifest_tsv]
#   std_json_has_api MOD_X fn_name
#   std_json_has_c_impl JSON_X sym_name
#   std_json_run_smoke XLANG_BIN smoke_x tag
#   std_json_emit_report status check_ok main_ok zc_ok skip
# 2026-08-26: report check=/main=/zc=/skip= (honesty; prefer asm; main hard).
# PLATFORM: SHARED archaeology.

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

# Compile and run smoke .x; expect exit code 0.
std_json_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_json_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-json FAIL: missing $src" >&2
    return 1
  fi
  if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    "$xlang" -L . "$src" -o "$exe" 2>&1 | tail -8 >&2 || true
    rm -f "$exe"
    return 1
  fi
  local ec=0
  "$exe" >/dev/null 2>&1 || ec=$?
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-json FAIL: $tag exit=$ec ($src)" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: check=/main=/zc=/skip=).
# Hard-green signal is main=; zc is observational (Darwin needs_copy residual).
std_json_emit_report() {
  local status="$1"
  local check_ok="$2"
  local main_ok="$3"
  local zc_ok="$4"
  local skip="$5"
  echo "${STD_JSON_PREFIX} status=${status} check=${check_ok} main=${main_ok} zc=${zc_ok} skip=${skip}"
}
