#!/usr/bin/env bash
# boot-018-parser-std-decouple.sh — BOOT-018：parser/std 双轨解耦校验辅助
#
# 用法（source 后）：
#   boot018_mega7_stub_count MATRIX
#   boot018_portable_allows_skip PORTABLE_SUITE
#   boot018_eng_parser_not_hard ENG_MATRIX
#   boot018_emit_report status mega7_stub std_independent parser_portable

BOOT018_PREFIX="${SHU_BOOT018_PREFIX:-shu: [SHU_BOOT018]}"

# 统计 comp-parser-mega7-matrix 中 kind=mega7 且 status=stub 的行数。
boot018_mega7_stub_count() {
  local matrix="$1"
  local n=0
  while IFS=$'\t' read -r item_id kind _phase status _rest; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    if [ "$kind" = "mega7" ] && [ "$status" = "stub" ]; then
      n=$((n + 1))
    fi
  done < "$matrix"
  echo "$n"
}

# portable-suite 对 COMP-001 须允许 SKIP hooks。
boot018_portable_allows_skip() {
  local ps="$1"
  if grep -qE "comp-parser-mega7 gate OK\|comp-parser-mega7 gate SKIP hooks" "$ps" 2>/dev/null; then
    return 0
  fi
  echo "boot-018 FAIL: portable-suite missing COMP-001 OK|SKIP pattern" >&2
  return 1
}

# eng-quality 矩阵不得将 comp-parser-mega7 标为 Q + ci_hard=yes。
boot018_eng_parser_not_hard() {
  local eng="$1"
  if awk -F'\t' '$1=="comp_parser_mega7" && $3=="yes" { found=1 } END { exit !found }' "$eng" 2>/dev/null; then
    echo "boot-018 FAIL: comp_parser_mega7 must not be ci_hard=yes" >&2
    return 1
  fi
  return 0
}

# std 轨门禁脚本须存在。
boot018_std_gate_exists() {
  local script="$1"
  [ -f "$script" ]
}

# 输出结构化报告行。
boot018_emit_report() {
  local status="$1"
  local mega7_stub="$2"
  local std_independent="$3"
  local parser_portable="$4"
  echo "${BOOT018_PREFIX} status=${status} mega7_stub=${mega7_stub} std_independent=${std_independent} parser_portable=${parser_portable}"
}
