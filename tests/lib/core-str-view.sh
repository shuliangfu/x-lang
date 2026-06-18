#!/usr/bin/env bash
# core-str-view.sh — CORE-007：BytesView manifest 辅助
#
# 用法（source 后）：
#   core_str_symbols_ok STR_SU TSV
#   core_str_emit_report status check_ok run_ok skip

CORE_STR_PREFIX="${SHU_CORE_STR_VIEW_PREFIX:-shu: [SHU_CORE_STR_VIEW]}"

# 校验 manifest 中 symbol 锚点；echo 缺失数，成功返回 0。
core_str_symbols_ok() {
  local str_su="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor
  while IFS=$'\t' read -r item_id kind anchor _mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        if ! grep -qF "$anchor" "$str_su" 2>/dev/null; then
          echo "core-str-view FAIL: missing '$anchor' in $str_su" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
core_str_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${CORE_STR_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
