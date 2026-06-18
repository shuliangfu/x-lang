#!/usr/bin/env bash
# boot-023-mega7-full-emit.sh — BOOT-023 7/7 全量 emit 波次辅助
#
# 用法（source 后）：
#   boot023_mega7_linux_asm
#   boot023_count_emit LOG_FILE
#   boot023_emit_report status promote_emit emit_full skip

BOOT023_PREFIX="${SHU_BOOT023_PREFIX:-shu: [SHU_BOOT023]}"

# Linux 且存在 experimental shu_asm 则可跑全量 emit wave。
boot023_mega7_linux_asm() {
  [ "$(uname -s 2>/dev/null)" = "Linux" ] || return 1
  [ -x "./compiler/shu_asm" ] || [ -x "./compiler/shu_asm.experimental" ] || return 1
  return 0
}

# 从 emit wave 日志统计 status=emit 条数。
boot023_count_emit() {
  local log="$1"
  grep -cE 'status=emit' "$log" 2>/dev/null || echo 0
}

# 输出结构化报告行（emit_full 与 promote_emit 同值，强调 7/7）。
boot023_emit_report() {
  local status="$1"
  local promote_emit="$2"
  local emit_full="$3"
  local skip="$4"
  echo "${BOOT023_PREFIX} status=${status} promote_emit=${promote_emit} emit_full=${emit_full} skip=${skip}"
}
