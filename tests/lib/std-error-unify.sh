#!/usr/bin/env bash
# std-error-unify.sh — STD-011：错误码统一 manifest 辅助
#
# Usage (source then):
#   std_error_unify_manifest_ok ERR_MOD MATRIX → echo miss count; exit status 0 iff miss=0
#   std_error_unify_emit_report status check_ok run_ok skip
# PLATFORM: SHARED archaeology.

STD_ERROR_UNIFY_PREFIX="${XLANG_STD_ERROR_UNIFY_PREFIX:-xlang: [XLANG_STD_ERROR_UNIFY]}"

# Validate module matrix + global/sidecar/symbol rows against std/error and module sources.
# Echoes the miss count on stdout; returns 0 when miss=0.
std_error_unify_manifest_ok() {
  local err_mod="$1"
  local matrix="$2"
  local miss=0
  local mod_n=0
  local min_mod=6
  local module_id exc_layer base_fn sidecar_fn src tier notes

  while IFS=$'\t' read -r c1 c2 _rest; do
    case "$c1" in min_modules) min_mod="$c2" ;; esac
  done < "$matrix"

  while IFS=$'\t' read -r module_id exc_layer base_fn sidecar_fn src tier notes; do
    [ -z "${module_id:-}" ] && continue
    case "$module_id" in \#*|min_modules|global_codes|sidecar_*|symbol_*|smoke_case) continue ;; esac
    mod_n=$((mod_n + 1))
    if [ ! -f "$src" ]; then
      echo "std-error-unify FAIL: missing src $src ($module_id)" >&2
      miss=$((miss + 1))
      continue
    fi
    if [ -n "$base_fn" ] && [ "$base_fn" != "-" ]; then
      if ! grep -qE "function ${base_fn}\\(" "$err_mod" 2>/dev/null; then
        echo "std-error-unify FAIL: missing ${base_fn} in $err_mod ($module_id)" >&2
        miss=$((miss + 1))
      fi
    fi
    if [ -n "$sidecar_fn" ] && [ "$sidecar_fn" != "-" ]; then
      if ! grep -qE "function ${sidecar_fn}\\(" "$src" 2>/dev/null; then
        echo "std-error-unify FAIL: missing sidecar ${sidecar_fn} in $src" >&2
        miss=$((miss + 1))
      fi
    fi
  done < "$matrix"

  while IFS=$'\t' read -r module_id exc_layer base_fn sidecar_fn src tier notes; do
    [ -z "${module_id:-}" ] && continue
    case "$module_id" in
      global_codes)
        if ! grep -qE "function ${base_fn}\\(" "$err_mod" 2>/dev/null; then
          echo "std-error-unify FAIL: missing global ${base_fn}" >&2
          miss=$((miss + 1))
        fi
        ;;
      sidecar_fs)
        if [ ! -f "$src" ] || ! grep -qE "function last_error|fs_last_error" "$src" 2>/dev/null; then
          echo "std-error-unify FAIL: fs sidecar" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol_*)
        if ! grep -qE "function ${base_fn}\\(" "$err_mod" 2>/dev/null; then
          echo "std-error-unify FAIL: missing symbol ${base_fn}" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$matrix"

  if [ "$mod_n" -lt "$min_mod" ]; then
    echo "std-error-unify FAIL: modules=${mod_n} < min ${min_mod}" >&2
    miss=$((miss + 1))
  fi
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Emit structured report line (check observational; run= is hard-green signal).
std_error_unify_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_ERROR_UNIFY_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
