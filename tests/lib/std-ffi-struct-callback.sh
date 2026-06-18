#!/usr/bin/env bash
# std-ffi-struct-callback.sh — STD-151 manifest 与烟测辅助

STD151_PREFIX="${SHU_STD151_FFI_STRUCT_CALLBACK_PREFIX:-shu: [SHU_STD151_FFI_STRUCT_CALLBACK]}"

std_ffi_struct_callback_symbols_ok() {
  local mod_su="$1"
  local ffi_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api|const)
        if ! grep -qE "(function ${anchor}\\(|const ${anchor}:)" "$mod_su" 2>/dev/null; then
          echo "std-ffi-struct-callback FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      struct)
        if ! grep -qE "struct ${anchor} " "$mod_su" 2>/dev/null; then
          echo "std-ffi-struct-callback FAIL: missing struct '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/ffi/ffi.c" ]; then path="$ffi_c"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-ffi-struct-callback FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      smoke|gate)
        if [ ! -f "$anchor" ]; then
          echo "std-ffi-struct-callback FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ ! -f "$anchor" ]; then
          echo "std-ffi-struct-callback FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF "$anchor" "analysis/std-ffi-struct-callback-v1.md" 2>/dev/null; then
          echo "std-ffi-struct-callback FAIL: missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_ffi_struct_callback_run_c_smoke() {
  local ffi_c="$1"
  local src="tests/std-ffi/struct_callback_ok.c"
  local out="/tmp/shu_ffi_struct_cb_c_$$"
  local ffi_o
  ffi_o="$(dirname "$ffi_c")/ffi.o"
  if [ ! -f "$ffi_o" ]; then
    echo "std-ffi-struct-callback FAIL: missing $ffi_o" >&2
    return 1
  fi
  if ! cc -std=c11 -O0 -o "$out" "$src" "$ffi_o" 2>/dev/null; then
    echo "std-ffi-struct-callback FAIL: compile $src" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-ffi-struct-callback FAIL: C smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

std_ffi_struct_callback_run_su_smoke() {
  local shu="$1"
  local src="$2"
  local ffi_o="$3"
  local exe="/tmp/shu_ffi_struct_cb_su_$$"
  if ! "$shu" -L . "$src" -o "$exe" "$ffi_o" >/dev/null 2>&1; then
    echo "std-ffi-struct-callback FAIL: compile $src" >&2
    "$shu" -L . "$src" -o "$exe" "$ffi_o" 2>&1 | tail -10 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-ffi-struct-callback FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_ffi_struct_callback_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local skip="$4"
  echo "${STD151_PREFIX} status=${status} c=${c_ok} su=${su_ok} skip=${skip}"
}
