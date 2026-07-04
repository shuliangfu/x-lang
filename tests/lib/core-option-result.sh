#!/usr/bin/env bash
# core-option-result.sh — CORE-002/003：Option/Result 类型族 manifest 辅助
#
# 用法（source 后）：
#   core_or_symbols_ok OPTION_X RESULT_X TSV
#   core_or_emit_report status option_ok result_ok skip

CORE_OR_PREFIX="${SHUX_CORE_OPTION_RESULT_PREFIX:-shux: [SHUX_CORE_OPTION_RESULT]}"

# 校验 manifest 中 symbol 锚点；echo 缺失数，成功返回 0。
core_or_symbols_ok() {
  local option_x="$1"
  local result_x="$2"
  local tsv="$3"
  local miss=0
  local sym mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        sym="$anchor"
        case "$mod_path" in
          core/result/mod.x) mod_path="$result_x" ;;
          *) mod_path="$option_x" ;;
        esac
        if [ "$sym" = "unwrap_or<T>" ]; then
          if ! grep -qF 'function unwrap_or<T>' "$option_x" 2>/dev/null; then
            echo "core-option-result FAIL: missing generic unwrap_or" >&2
            miss=$((miss + 1))
          fi
        elif ! grep -qF "$sym" "$mod_path" 2>/dev/null; then
          echo "core-option-result FAIL: missing '$sym' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
core_or_emit_report() {
  local status="$1"
  local option_ok="$2"
  local result_ok="$3"
  local skip="$4"
  echo "${CORE_OR_PREFIX} status=${status} option=${option_ok} result=${result_ok} skip=${skip}"
}
