#!/usr/bin/env bash
# placeholder-inventory.sh — placeholder() 清单扫描辅助
#
# 用法（source 后）：
#   placeholder_count_repo
#   placeholder_emit_report status count max

PH_INV_PREFIX="${SHU_PLACEHOLDER_INV_PREFIX:-shu: [SHU_PLACEHOLDER_INV]}"

# 统计仓库内 function placeholder() 定义数（不含 bad_path_placeholder 等）。
placeholder_count_repo() {
  local n
  n="$(grep -rE '^function placeholder\(\)' core std 2>/dev/null \
    | grep -v compiler/asm_libroot \
    | wc -l \
    | tr -d ' ')"
  echo "${n:-0}"
}

# 输出结构化报告行。
placeholder_emit_report() {
  local status="$1"
  local count="$2"
  local max="$3"
  echo "${PH_INV_PREFIX} status=${status} count=${count} max=${max}"
}
