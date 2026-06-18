#!/usr/bin/env bash
# comp-wpo-default.sh — COMP-017 WPO default tier 扩面辅助
#
# 用法（source 后）：
#   comp_wpo_default_linux_asm
#   comp_wpo_default_hook_runnable HOOK_SCRIPT
#   comp_wpo_default_emit_report status default_ok default_skip skip

COMP017_PREFIX="${SHU_COMP017_PREFIX:-shu: [SHU_COMP017_WPO_DEFAULT]}"

# Linux 且存在 shu_asm 则可跑 full-chain / .o 代理类 hook。
comp_wpo_default_linux_asm() {
  [ "$(uname -s 2>/dev/null)" = "Linux" ] || return 1
  [ -x "./compiler/shu_asm" ] || [ -x "./compiler/shu_asm.experimental" ] || return 1
  return 0
}

# 判断 default hook 在本机是否应尝试 runnable。
comp_wpo_default_hook_runnable() {
  local hook="$1"
  case "$hook" in
    run-wpo-full-chain-gate.sh|run-wpo-backend-o-gate.sh|run-wpo-main-o-gate.sh|run-wpo-driver-o-gate.sh)
      comp_wpo_default_linux_asm
      ;;
    run-wpo-backend-reach-gate.sh)
      [ "$(uname -s 2>/dev/null)" = "Darwin" ] && return 1
      [ -f "./compiler/build_asm/backend_wpo.o" ] && return 0
      comp_wpo_default_linux_asm
      ;;
    *)
      return 0
      ;;
  esac
}

# 输出结构化报告行。
comp_wpo_default_emit_report() {
  local status="$1"
  local default_ok="$2"
  local default_skip="$3"
  local skip="$4"
  echo "${COMP017_PREFIX} status=${status} default_ok=${default_ok} default_skip=${default_skip} skip=${skip}"
}
