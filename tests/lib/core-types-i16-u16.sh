#!/usr/bin/env bash
# core-types-i16-u16.sh — CORE-013 manifest helpers (honesty soft→硬绿).
#
# Usage (source):
#   core_types_i16_u16_symbols_ok TYPES_X TSV
#   core_types_i16_u16_emit_report status run obs skip
# PLATFORM: SHARED archaeology.

CORE_TYPES_I16_U16_PREFIX="${XLANG_CORE_TYPES_I16_U16_PREFIX:-xlang: [XLANG_CORE_TYPES_I16_U16]}"

# Validate manifest symbol anchors; echo miss count; return 0 on clean.
core_types_i16_u16_symbols_ok() {
  local types_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        local target="${mod_path:-$types_x}"
        if ! grep -qF "$anchor" "$target" 2>/dev/null; then
          echo "core-types-i16-u16 FAIL: missing '$anchor' in $target" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report: run=/obs=/skip= (honesty 2026-08-28).
core_types_i16_u16_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${CORE_TYPES_I16_U16_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
