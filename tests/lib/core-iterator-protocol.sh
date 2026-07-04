#!/usr/bin/env bash
# core-iterator-protocol.sh — CORE-006：iterator next 协议 manifest 辅助
#
# 用法（source 后）：
#   core_iter_symbols_ok ITER_X TSV
#   core_iter_emit_report status check_ok run_ok cookbook_ok skip

CORE_ITER_PREFIX="${SHUX_CORE_ITERATOR_PREFIX:-shux: [SHUX_CORE_ITERATOR]}"

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

# 输出结构化报告行。
core_iter_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local cookbook_ok="$4"
  local skip="$5"
  echo "${CORE_ITER_PREFIX} status=${status} check=${check_ok} run=${run_ok} cookbook=${cookbook_ok} skip=${skip}"
}
