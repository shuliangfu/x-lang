#!/usr/bin/env bash
# std-ffi-cstring-lifecycle.sh — STD-055 manifest 与烟测辅助

STD_FFI_CSTRING_PREFIX="${SHUX_STD_FFI_CSTRING_PREFIX:-shux: [SHUX_STD_FFI_CSTRING]}"

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

std_ffi_cstring_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shux_std_ffi_cstr_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-ffi-cstring FAIL: compile $src" >&2
    "$shux" -L . "$src" 2>&1 | tail -10 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-ffi-cstring FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_ffi_cstring_run_c_smoke() {
  local ffi_impl="$1"
  local src="tests/std-ffi/cstring_lifecycle_ok.c"
  local out="/tmp/shux_std_ffi_cstr_c_$$"
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

std_ffi_cstring_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local safe_ok="$4"
  local skip="$5"
  echo "${STD_FFI_CSTRING_PREFIX} status=${status} c_smoke=${c_ok} x=${su_ok} safe004=${safe_ok} skip=${skip}"
}
