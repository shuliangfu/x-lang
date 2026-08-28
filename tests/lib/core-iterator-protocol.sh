#!/usr/bin/env bash
# core-iterator-protocol.sh — CORE-006 iterator protocol manifest helpers.
# Honesty: emit_report uses run=/obs=/skip= (soft SKIP→OK / soft auto-make retired).
#
# Usage (after source):
#   core_iter_symbols_ok ITER_X TSV
#   core_iter_emit_report status run_ok obs skip

CORE_ITER_PREFIX="${XLANG_CORE_ITERATOR_PREFIX:-xlang: [XLANG_CORE_ITERATOR]}"

# 校验 manifest 中 symbol 锚点；echo 缺失数，成功返回 0。
core_iter_symbols_ok() {
  local iter_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor
  while IFS=$'\t' read -r item_id kind anchor _mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        if ! grep -qF "$anchor" "$iter_x" 2>/dev/null; then
          echo "core-iterator-protocol FAIL: missing '$anchor' in $iter_x" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report: run= hard product (smoke+cookbook); obs= check; skip= N/A.
core_iter_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${CORE_ITER_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
