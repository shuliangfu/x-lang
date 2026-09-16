#!/usr/bin/env bash
# core-slice-api.sh — CORE-004 slice API manifest helpers.
# Honesty: emit_report uses run=/obs=/skip= (soft SKIP→OK / soft auto-make retired).
#
# Usage (after source):
#   core_slice_symbols_ok SLICE_X TSV
#   core_slice_emit_report status run_ok obs skip

CORE_SLICE_PREFIX="${XLANG_CORE_SLICE_PREFIX:-xlang: [XLANG_CORE_SLICE_API]}"

# 校验 manifest 中 symbol 锚点；echo 缺失数，成功返回 0。
core_slice_symbols_ok() {
  local slice_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        if ! grep -qF "$anchor" "$slice_x" 2>/dev/null; then
          echo "core-slice-api FAIL: missing '$anchor' in $slice_x" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report: run= hard product; obs= check residual; skip= platform N/A.
core_slice_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${CORE_SLICE_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
