#!/usr/bin/env bash
# core-types-i16-u16.sh — CORE-013：i16/u16 宽度 manifest 辅助
#
# 用法（source 后）：
#   core_types_i16_u16_symbols_ok TYPES_X TSV
#   core_types_i16_u16_emit_report status check_ok skip

CORE_TYPES_I16_U16_PREFIX="${SHUX_CORE_TYPES_I16_U16_PREFIX:-shux: [SHUX_CORE_TYPES_I16_U16]}"

# 校验 manifest 中 symbol 锚点；echo 缺失数，成功返回 0。
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

# 输出结构化报告行。
core_types_i16_u16_emit_report() {
  local status="$1"
  local check_ok="$2"
  local skip="$3"
  echo "${CORE_TYPES_I16_U16_PREFIX} status=${status} check=${check_ok} skip=${skip}"
}
