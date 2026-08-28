#!/usr/bin/env bash
# std-dynlib-last-error.sh — STD-096 manifest helpers (last_os_error).
#
# Usage (after source):
#   std_dynlib_last_error_symbols_ok MOD_X DYNLIB_X TSV [DOC]
#   std_dynlib_last_error_run_c_smoke   # existing .o only; no soft rebuild
#   std_dynlib_last_error_emit_report status run obs skip
# Honesty: run=/obs=/skip= (check/host-C = obs; prefer asm product -o hard).
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

# Host-C archaeology: last_error_smoke.c + existing dynlib.o + runtime_dynlib_os.o.
# Refuse soft ensure_std_c_o / soft auto-make of missing .o (obs path only).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
std_dynlib_last_error_run_c_smoke() {
  local src="tests/dynlib/last_error_smoke.c"
  local out="/tmp/xlang_std096_dynlib_err_c_$$"
  local dyn_o="std/dynlib/dynlib.o"
  local rt_o="compiler/runtime_dynlib_os.o"
  local ld_extra=""
  if [ ! -f "$dyn_o" ] || [ ! -f "$rt_o" ]; then
    return 1
  fi
  case "$(uname -s)" in
    Linux*) ld_extra="-ldl" ;;
  esac
  # PLATFORM: LINUX — -ldl for dlopen family; MACOS has dl* in libSystem.
  if ! cc -Wall -Wextra -o "$out" "$src" "$dyn_o" "$rt_o" $ld_extra 2>/dev/null; then
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
# Hard-green signal is product -o last_error.x; check/host-C = obs.
std_dynlib_last_error_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_DYNLIB_LAST_ERROR_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
