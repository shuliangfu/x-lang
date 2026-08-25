#!/usr/bin/env bash
# std-ffi-cstring-lifecycle.sh — STD-055 manifest helpers (ffi CString lifecycle).
#
# Usage (after source):
#   std_ffi_cstring_symbols_ok MOD_X FFI_X FFI_GLUE TSV
#   std_ffi_cstring_run_c_smoke FFI_IMPL
#   std_ffi_cstring_emit_report status check_ok run_ok safe_ok skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_FFI_CSTRING_PREFIX="${XLANG_STD_FFI_CSTRING_PREFIX:-xlang: [XLANG_STD_FFI_CSTRING]}"

# Validate manifest api/const/symbol/file/smoke/cross_ref anchors.
# Echo miss count; return 0 when miss=0.
std_ffi_cstring_symbols_ok() {
  local mod_x="$1"
  local ffi_x="$2"
  local ffi_glue="$3"
  local tsv="$4"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api|const)
        if [ "$kind" = "api" ]; then
          if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
            echo "std-ffi-cstring FAIL: missing api '$anchor'" >&2
            miss=$((miss + 1))
          fi
        else
          if ! grep -qE "const ${anchor}:" "$mod_x" 2>/dev/null; then
            echo "std-ffi-cstring FAIL: missing const '$anchor'" >&2
            miss=$((miss + 1))
          fi
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/ffi/ffi.c|std/ffi/ffi.x|std/ffi/ffi_cb_glue.c) path="$ffi_x" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-ffi-cstring FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-ffi-cstring FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      cross_ref)
        if [ ! -f "$anchor" ]; then
          echo "std-ffi-cstring FAIL: missing cross_ref '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Host-C archaeology smoke (observational only; not hard green).
std_ffi_cstring_run_c_smoke() {
  local ffi_impl="$1"
  local src="tests/std-ffi/cstring_lifecycle_ok.c"
  local out="/tmp/xlang_std_ffi_cstr_c_$$"
  local ffi_o
  ffi_o="$(dirname "$ffi_impl")/ffi.o"
  if [ ! -f "$ffi_o" ]; then
    echo "std-ffi-cstring FAIL: missing $ffi_o" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$ffi_o" 2>/dev/null; then
    echo "std-ffi-cstring FAIL: compile $src" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-ffi-cstring FAIL: c smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (check observational; run+safe004 hard; skip only when no binary).
std_ffi_cstring_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local safe_ok="$4"
  local skip="$5"
  echo "${STD_FFI_CSTRING_PREFIX} status=${status} check=${check_ok} run=${run_ok} safe004=${safe_ok} skip=${skip}"
}
