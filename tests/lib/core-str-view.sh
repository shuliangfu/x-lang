#!/usr/bin/env bash
# core-str-view.sh — CORE-007 BytesView manifest helpers.
# Honesty: emit_report uses run=/obs=/skip= (soft SKIP→OK / soft auto-make retired).
#
# Usage (after source):
#   core_str_symbols_ok STR_X TSV
#   core_str_emit_report status run_ok obs skip

CORE_STR_PREFIX="${XLANG_CORE_STR_VIEW_PREFIX:-xlang: [XLANG_CORE_STR_VIEW]}"

# 校验 manifest 中 symbol 锚点；echo 缺失数，成功返回 0。
core_str_symbols_ok() {
  local str_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor
  while IFS=$'\t' read -r item_id kind anchor _mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        if ! grep -qF "$anchor" "$str_x" 2>/dev/null; then
          echo "core-str-view FAIL: missing '$anchor' in $str_x" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report: run= hard product (smoke+cookbook); obs= check; skip= N/A.
core_str_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${CORE_STR_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
