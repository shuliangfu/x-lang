#!/usr/bin/env bash
# std-ffi-cstring-lifecycle.sh — STD-055 manifest helpers (ffi CString lifecycle).
#
# Usage (after source):
#   std_ffi_cstring_symbols_ok MOD_X FFI_X FFI_GLUE TSV
#   std_ffi_cstring_run_c_smoke FFI_IMPL   # existing .o only; no soft rebuild
#   std_ffi_cstring_emit_report status run obs skip
# Honesty: run=/obs=/skip= (check/host-C = obs; product -o + SAFE-004 folded into run).
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

# Host-C archaeology: cstring_lifecycle_ok.c + existing ffi.o.
# Refuse soft ensure_std_c_o / soft auto-make of missing .o (obs path only).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
std_ffi_cstring_run_c_smoke() {
  local ffi_impl="$1"
  local src="tests/std-ffi/cstring_lifecycle_ok.c"
  local out="/tmp/xlang_std_ffi_cstr_c_$$"
  local ffi_o
  ffi_o="$(dirname "$ffi_impl")/ffi.o"
  if [ ! -f "$ffi_o" ]; then
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$ffi_o" 2>/dev/null; then
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
# Hard-green signals are product -o + SAFE-004 (both folded into run=);
# check/host-C = obs. Legacy safe004= column retired into run=.
std_ffi_cstring_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_FFI_CSTRING_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
