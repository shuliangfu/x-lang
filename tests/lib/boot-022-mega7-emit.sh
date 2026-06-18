#!/usr/bin/env bash
# boot-022-mega7-emit.sh — BOOT-022 emit 晋升波次辅助
#
# 用法（source 后）：
#   boot022_mega7_linux_asm
#   boot022_parse_emit_lead LOG_FILE
#   boot022_emit_report status promote_emit emit_lead skip

BOOT022_PREFIX="${SHU_BOOT022_PREFIX:-shu: [SHU_BOOT022]}"

# Linux 且存在 experimental shu_asm 则可跑 emit wave。
boot022_mega7_linux_asm() {
  [ "$(uname -s 2>/dev/null)" = "Linux" ] || return 1
  [ -x "./compiler/shu_asm" ] || [ -x "./compiler/shu_asm.experimental" ] || return 1
  return 0
}

# 从 emit wave 日志解析首个 status=emit 的函数名。
boot022_parse_emit_lead() {
  local log="$1"
  grep -E 'status=emit' "$log" 2>/dev/null | awk '{print $1}' | head -1
}

# 输出结构化报告行。
boot022_emit_report() {
  local status="$1"
  local promote_emit="$2"
  local emit_lead="$3"
  local skip="$4"
  echo "${BOOT022_PREFIX} status=${status} promote_emit=${promote_emit} emit_lead=${emit_lead} skip=${skip}"
}
