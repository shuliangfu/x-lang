#!/usr/bin/env bash
# std-dynlib-last-error.sh — STD-096 manifest helpers (last_os_error).
#
# Usage (after source):
#   std_dynlib_last_error_symbols_ok MOD_X DYNLIB_X TSV [DOC]
#   std_dynlib_last_error_run_c_smoke
#   std_dynlib_last_error_emit_report status check_ok run_ok skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_DYNLIB_LAST_ERROR_PREFIX="${XLANG_STD096_DYNLIB_ERR_PREFIX:-xlang: [XLANG_STD096_DYNLIB_ERR]}"

# Validate manifest api/symbol/file/smoke/script/section anchors.
# Echo miss count; return 0 when miss=0.
# Optional DOC overrides archive path for section checks (default archived RFC).
std_dynlib_last_error_symbols_ok() {
  local mod_x="$1"
  local dynlib_x="$2"
  local tsv="$3"
  local doc="${4:-analysis/archive/std/std-dynlib-last-error-v1.md}"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-dynlib-last-error FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/dynlib/dynlib.x|std/dynlib/dynlib.c) path="$dynlib_x" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-dynlib-last-error FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-dynlib-last-error FAIL: missing '$anchor'" >&2
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
          echo "std-dynlib-last-error FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF -- "$anchor" "$doc" 2>/dev/null; then
          echo "std-dynlib-last-error FAIL: doc missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      cross_ref)
        # Cross-ref anchors are documentary; require non-empty anchor only.
        if [ -z "${anchor:-}" ]; then
          echo "std-dynlib-last-error FAIL: empty cross_ref" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Observational C smoke: last_error_smoke.c + dynlib.o + runtime_dynlib_os.o.
# Not hard green — dynlib.o may pull process argv symbols on some hosts.
# PLATFORM: SHARED archaeology — product honesty is last_error.x via asm.
std_dynlib_last_error_run_c_smoke() {
  local src="tests/dynlib/last_error_smoke.c"
  local out="/tmp/xlang_std096_dynlib_err_c_$$"
  local dyn_o="std/dynlib/dynlib.o"
  local rt_o="compiler/runtime_dynlib_os.o"
  local ld_extra=""
  if [ ! -f "$dyn_o" ] || [ ! -f "$rt_o" ]; then
    echo "std-dynlib-last-error FAIL: missing $dyn_o or $rt_o" >&2
    return 1
  fi
  case "$(uname -s)" in
    Linux*) ld_extra="-ldl" ;;
  esac
  if ! cc -Wall -Wextra -o "$out" "$src" "$dyn_o" "$rt_o" $ld_extra 2>/dev/null; then
    echo "std-dynlib-last-error FAIL: compile C smoke" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-dynlib-last-error FAIL: C smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (check observational; run hard; skip only when no binary path).
std_dynlib_last_error_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_DYNLIB_LAST_ERROR_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
