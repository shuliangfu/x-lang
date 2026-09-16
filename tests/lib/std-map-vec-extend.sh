#!/usr/bin/env bash
# std-map-vec-extend.sh — STD-013/014 manifest helpers (honesty soft→硬绿).
#
# Usage (source):
#   std_mve_symbols_ok MAP_X VEC_X HEAP_X TSV
#   std_mve_emit_report status run obs skip
# PLATFORM: SHARED archaeology.

STD_MVE_PREFIX="${XLANG_STD_MAP_VEC_EXTEND_PREFIX:-xlang: [XLANG_STD_MAP_VEC_EXTEND]}"

# Validate manifest symbol anchors; echo miss count; return 0 on clean.
std_mve_symbols_ok() {
  local map_x="$1"
  local vec_x="$2"
  local heap_x="$3"
  local tsv="$4"
  local miss=0
  local mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        case "$mod_path" in
          std/vec/mod.x) mod_path="$vec_x" ;;
          std/heap/mod.x) mod_path="$heap_x" ;;
          *) mod_path="$map_x" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-map-vec-extend FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report: run=/obs=/skip= (honesty 2026-08-28).
std_mve_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_MVE_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
