#!/usr/bin/env bash
# boot-025-parser-gen12-consistency.sh — BOOT-025 gen1/gen2 三代一致性辅助
#
# 用法（source 后）：
#   boot025_gen12_linux_asm
#   boot025_emit_report status gen12_ok dogfood_ok skip

BOOT025_PREFIX="${SHUX_BOOT025_PREFIX:-shux: [SHUX_BOOT025]}"

# Linux 且存在 shux_asm + seed shux 则可跑 stage2 一致性。
boot025_gen12_linux_asm() {
  [ "$(uname -s 2>/dev/null)" = "Linux" ] || return 1
  [ -x "./compiler/shux_asm" ] || return 1
  [ -x "./compiler/shux" ] || [ -x "./compiler/shux-sx" ] || return 1
  return 0
}

# 输出结构化报告行。
boot025_emit_report() {
  local status="$1"
  local gen12_ok="$2"
  local dogfood_ok="$3"
  local skip="$4"
  echo "${BOOT025_PREFIX} status=${status} gen12_ok=${gen12_ok} dogfood_ok=${dogfood_ok} skip=${skip}"
}
