#!/usr/bin/env bash
# core-fmt-widths.sh — CORE-010 manifest helpers (honesty soft→硬绿).
#
# Usage (source):
#   core_fmt_widths_symbols_ok FMT_X TSV
#   core_fmt_widths_emit_report status run obs skip
# PLATFORM: SHARED archaeology.

CORE_FMT_WIDTHS_PREFIX="${XLANG_CORE_FMT_WIDTHS_PREFIX:-xlang: [XLANG_CORE_FMT_WIDTHS]}"

# Validate manifest symbol anchors; echo miss count; return 0 on clean.
core_fmt_widths_symbols_ok() {
  local fmt_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor
  while IFS=$'\t' read -r item_id kind anchor _mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        if ! grep -qF "$anchor" "$fmt_x" 2>/dev/null; then
          echo "core-fmt-widths FAIL: missing '$anchor' in $fmt_x" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report: run=/obs=/skip= (honesty 2026-08-28).
core_fmt_widths_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${CORE_FMT_WIDTHS_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
