#!/usr/bin/env bash
# core-cmp-ordering.sh — CORE-005 manifest helpers (honesty soft→硬绿).
#
# Usage (source):
#   core_cmp_symbols_ok CMP_X TSV
#   core_cmp_emit_report status run obs skip
# PLATFORM: SHARED archaeology.

CORE_CMP_PREFIX="${XLANG_CORE_CMP_PREFIX:-xlang: [XLANG_CORE_CMP_ORDERING]}"

# Validate manifest symbol anchors; echo miss count; return 0 on clean.
core_cmp_symbols_ok() {
  local cmp_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor
  while IFS=$'\t' read -r item_id kind anchor _mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        if ! grep -qF "$anchor" "$cmp_x" 2>/dev/null; then
          echo "core-cmp-ordering FAIL: missing '$anchor' in $cmp_x" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report: run=/obs=/skip= (honesty 2026-08-28).
core_cmp_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${CORE_CMP_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
