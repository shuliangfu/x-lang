#!/usr/bin/env bash
# std-ffi-struct-callback.sh — STD-151 FfiPoint/callback helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_ffi_struct_callback_symbols_ok MOD_X FFI_X FFI_GLUE TSV
#   std_ffi_struct_callback_run_c_smoke FFI_IMPL   # prebuilt ffi.o only
#   std_ffi_struct_callback_run_x_smoke XLANG_BIN SRC FFI_O
#   std_ffi_struct_callback_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / soft ensure; report run=/obs=/skip=.
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD151_PREFIX="${XLANG_STD151_FFI_STRUCT_CALLBACK_PREFIX:-xlang: [XLANG_STD151_FFI_STRUCT_CALLBACK]}"

# Validate manifest; echo miss count; return 0 iff miss==0.
std_ffi_struct_callback_symbols_ok() {
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
        if ! grep -qE "(function ${anchor}\\(|const ${anchor}:)" "$mod_x" 2>/dev/null; then
          echo "std-ffi-struct-callback FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      struct)
        if ! grep -qE "struct ${anchor} " "$mod_x" 2>/dev/null; then
          echo "std-ffi-struct-callback FAIL: missing struct '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/ffi/ffi.c|std/ffi/ffi.x|std/ffi/ffi_cb_glue.c) path="$ffi_x" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-ffi-struct-callback FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      smoke|gate|file)
        if [ ! -f "$anchor" ]; then
          echo "std-ffi-struct-callback FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ -n "$anchor" ] && [ -f "$anchor" ]; then
          :
        elif [ -n "$mod_path" ] && [ -f "$mod_path" ]; then
          :
        else
          echo "std-ffi-struct-callback FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        local doc="${XLANG_STD_FFI_STRUCT_CALLBACK_DOC:-analysis/archive/std/std-ffi-struct-callback-v1.md}"
        if [ ! -f "$doc" ] || ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-ffi-struct-callback FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Host-C archaeology: prebuilt std/ffi/ffi.o only.
# Refuse soft ensure_std_c_o / soft auto-make.
# Returns 0 green, 1 link/run fail, 2 missing prebuilt.
# PLATFORM: SHARED — do not toggle set -e (leaks make return 1 kill the gate).
std_ffi_struct_callback_run_c_smoke() {
  local ffi_impl="$1"
  local src="tests/std-ffi/struct_callback_ok.c"
  local out="/tmp/xlang_ffi_struct_cb_c_$$"
  local ffi_o
  ffi_o="$(dirname "$ffi_impl")/ffi.o"
  if [ ! -f "$ffi_o" ]; then
    echo "std-ffi-struct-callback OBS c smoke (missing prebuilt $ffi_o; refuse soft ensure)" >&2
    return 2
  fi
  if [ ! -f "$src" ]; then
    echo "std-ffi-struct-callback OBS c smoke (missing $src)" >&2
    return 2
  fi
  if ! cc -std=c11 -O0 -o "$out" "$src" "$ffi_o" 2>/tmp/std_ffi_struct_cb_c_$$.log; then
    echo "std-ffi-struct-callback OBS c smoke link (refuse soft ensure)" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-ffi-struct-callback OBS c smoke run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Product tip -o smoke (optional prebuilt ffi.o link arg).
# Caller decides hard vs obs (tip UNDEF/SEGV = obs leave).
# PLATFORM: SHARED archaeology — product honesty path.
# Do not restore set -e between steps: return 1 must not trip the gate's set +e window.
std_ffi_struct_callback_run_x_smoke() {
  local xlang="$1"
  local src="$2"
  local ffi_o="$3"
  local exe="/tmp/xlang_ffi_struct_cb_x_$$"
  local log="/tmp/xlang_ffi_struct_cb_x_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-ffi-struct-callback FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  set +e
  if [ -n "$ffi_o" ] && [ -f "$ffi_o" ]; then
    "$xlang" -L . "$src" -o "$exe" "$ffi_o" >"$log" 2>&1
  else
    "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  fi
  local o_ec=$?
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-ffi-struct-callback OBS tip product -o (ec=$o_ec)" >&2
    tail -n 8 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  "$exe" >/dev/null 2>&1
  local ec=$?
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-ffi-struct-callback OBS tip run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; retired c=/x=).
std_ffi_struct_callback_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD151_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
