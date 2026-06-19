#!/usr/bin/env bash
# boot-021-mega7-promote.sh — BOOT-021 B1–B7 晋升波次辅助
#
# 用法（source 后）：
#   boot021_mega7_linux_asm
#   boot021_parse_bisect_status LOG_FILE TARGET
#   boot021_emit_report status runnable_ok promote_emit skip

BOOT021_PREFIX="${SHUX_BOOT021_PREFIX:-shux: [SHUX_BOOT021]}"

# Linux 且存在 experimental shux_asm 则可跑 bisect wave。
boot021_mega7_linux_asm() {
  [ "$(uname -s 2>/dev/null)" = "Linux" ] || return 1
  [ -x "./compiler/shux_asm" ] || [ -x "./compiler/shux_asm.experimental" ] || return 1
  return 0
}

# 从 promote wave 日志解析单函数 status（stub/emit/fail）。
boot021_parse_bisect_status() {
  local log="$1"
  local target="$2"
  grep -E "^${target}[[:space:]]" "$log" 2>/dev/null | awk '{print $NF}' | sed 's/status=//' | head -1
}

# 输出结构化报告行。
boot021_emit_report() {
  local status="$1"
  local runnable_ok="$2"
  local promote_emit="$3"
  local skip="$4"
  echo "${BOOT021_PREFIX} status=${status} runnable_ok=${runnable_ok} promote_emit=${promote_emit} skip=${skip}"
}
