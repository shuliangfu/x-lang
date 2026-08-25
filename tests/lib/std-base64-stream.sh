#!/usr/bin/env bash
# std-base64-stream.sh — STD-109 manifest helpers (stream enc/dec).
#
# Usage (after source):
#   std_base64_stream_symbols_ok MOD_X B64_X TSV [DOC]
#   std_base64_stream_run_c_smoke B64_X
#   std_base64_stream_emit_report status check_ok run_ok skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_BASE64_STREAM_PREFIX="${XLANG_STD109_BASE64_STREAM_PREFIX:-xlang: [XLANG_STD109_BASE64_STREAM]}"

# Validate manifest api/symbol/file/smoke/script/section anchors.
# Echo miss count; return 0 when miss=0.
# Optional DOC overrides archive path for section checks (default archived RFC).
std_base64_stream_symbols_ok() {
  local mod_x="$1"
  local b64_x="$2"
  local tsv="$3"
  local doc="${4:-analysis/archive/std/std-base64-stream-v1.md}"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-base64-stream FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/base64/base64.c|std/base64/base64.x) path="$b64_x" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-base64-stream FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-base64-stream FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        # Prefer tests/… path in anchor (honesty); fall back to mod_path.
        local sp="$anchor"
        if [ ! -f "$sp" ] && [ -n "${mod_path:-}" ] && [ -f "$mod_path" ]; then
          sp="$mod_path"
        fi
        if [ ! -f "$sp" ]; then
          echo "std-base64-stream FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF -- "$anchor" "$doc" 2>/dev/null; then
          echo "std-base64-stream FAIL: doc missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Observational C smoke: stream_smoke_ok.c + base64.o (not hard green).
std_base64_stream_run_c_smoke() {
  local b64_c="$1"
  local src="tests/std-base64/stream_smoke_ok.c"
  local out="/tmp/xlang_std_base64_stream_c_$$"
  local b64_o
  b64_o="$(dirname "$b64_c")/base64.o"
  if [ ! -f "$b64_o" ]; then
    echo "std-base64-stream FAIL: missing $b64_o" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$b64_o" 2>/dev/null; then
    echo "std-base64-stream FAIL: compile C smoke" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-base64-stream FAIL: C smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (check observational; run hard; skip only when no binary path).
std_base64_stream_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_BASE64_STREAM_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
