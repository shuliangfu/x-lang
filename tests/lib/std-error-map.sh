#!/usr/bin/env bash
# std-error-map.sh — STD-020: error code map / last_error manifest helpers.
#
# Usage (after source):
#   std_error_map_manifest_ok ERR_MOD TSV
#   std_error_map_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_ERROR_MAP_PREFIX="${XLANG_STD_ERROR_MAP_PREFIX:-xlang: [XLANG_STD_ERROR_MAP]}"

# Validate manifest: lookup symbols, module src, sidecar fns. Echo miss count.
std_error_map_manifest_ok() {
  local err_mod="$1"
  local tsv="$2"
  local miss=0
  local mod_n=0
  local min_mod=8
  local item_id kind anchor mod_path src _notes
  while IFS=$'\t' read -r item_id kind anchor mod_path src _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in
      \#*) continue ;;
      min_modules)
        if [ -n "${anchor:-}" ]; then
          min_mod="$anchor"
        fi
        continue
        ;;
    esac
    case "$kind" in
      symbol)
        if ! grep -qE "function ${anchor}\\(" "$err_mod" 2>/dev/null; then
          echo "std-error-map FAIL: missing symbol ${anchor} in $err_mod" >&2
          miss=$((miss + 1))
        fi
        ;;
      module)
        mod_n=$((mod_n + 1))
        if [ ! -f "$src" ]; then
          echo "std-error-map FAIL: missing module src $src ($anchor)" >&2
          miss=$((miss + 1))
        fi
        if [ "$mod_path" != "-" ] && ! grep -qE "function ${mod_path}\\(" "$err_mod" 2>/dev/null; then
          echo "std-error-map FAIL: missing base ${mod_path} for $anchor" >&2
          miss=$((miss + 1))
        fi
        ;;
      sidecar)
        if [ ! -f "$src" ]; then
          echo "std-error-map FAIL: missing sidecar src $src" >&2
          miss=$((miss + 1))
        elif ! grep -qE "function ${anchor}\\(" "$src" 2>/dev/null; then
          echo "std-error-map FAIL: missing sidecar ${anchor} in $src" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  if [ "$mod_n" -lt "$min_mod" ]; then
    echo "std-error-map FAIL: modules=${mod_n} < min ${min_mod}" >&2
    miss=$((miss + 1))
  fi
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report line (honesty: run=/obs=/skip=; check residual = obs).
std_error_map_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_ERROR_MAP_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
