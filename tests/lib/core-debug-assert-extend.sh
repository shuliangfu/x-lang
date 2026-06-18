#!/usr/bin/env bash
# core-debug-assert-extend.sh — CORE-012：断言类型扩展 manifest 辅助
#
# 用法（source 后）：
#   core_debug_assert_extend_symbols_ok DEBUG_SU TSV
#   core_debug_assert_extend_emit_report status check_ok skip

CORE_DEBUG_ASSERT_EXTEND_PREFIX="${SHU_CORE_DEBUG_ASSERT_EXTEND_PREFIX:-shu: [SHU_CORE_DEBUG_ASSERT_EXTEND]}"

# 校验 manifest 中 symbol 锚点；echo 缺失数，成功返回 0。
core_debug_assert_extend_symbols_ok() {
  local debug_su="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        local target="${mod_path:-$debug_su}"
        if ! grep -qF "$anchor" "$target" 2>/dev/null; then
          echo "core-debug-assert-extend FAIL: missing '$anchor' in $target" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
core_debug_assert_extend_emit_report() {
  local status="$1"
  local check_ok="$2"
  local skip="$3"
  echo "${CORE_DEBUG_ASSERT_EXTEND_PREFIX} status=${status} check=${check_ok} skip=${skip}"
}
