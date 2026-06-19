#!/usr/bin/env bash
# comp-wpo-prod.sh — COMP-015 WPO 生产波次辅助
#
# 用法（source 后）：
#   comp_wpo_prod_linux_asm
#   comp_wpo_prod_hook_runnable HOOK_SCRIPT
#   comp_wpo_prod_emit_report status prod_ok prod_skip skip

COMP015_PREFIX="${SHUX_COMP015_PREFIX:-shux: [SHUX_COMP015_WPO_PROD]}"

# Linux 且存在 shux_asm 则可跑 build_asm chain / strict link。
comp_wpo_prod_linux_asm() {
  [ "$(uname -s 2>/dev/null)" = "Linux" ] || return 1
  [ -x "./compiler/shux_asm" ] || [ -x "./compiler/shux_asm.experimental" ] || return 1
  return 0
}

# 判断 prod hook 在本机是否应尝试 runnable（非 Darwin N/A 类）。
comp_wpo_prod_hook_runnable() {
  local hook="$1"
  case "$hook" in
    run-wpo-build-asm-chain-gate.sh|run-wpo-strict-link-gate.sh)
      comp_wpo_prod_linux_asm
      ;;
    run-wpo-typeck-reach-gate.sh|run-wpo-pipeline-reach-gate.sh|run-wpo-backend-reach-gate.sh)
      [ "$(uname -s 2>/dev/null)" = "Darwin" ] && return 1
      return 0
      ;;
    *)
      return 0
      ;;
  esac
}

# 输出结构化报告行。
comp_wpo_prod_emit_report() {
  local status="$1"
  local prod_ok="$2"
  local prod_skip="$3"
  local skip="$4"
  echo "${COMP015_PREFIX} status=${status} prod_ok=${prod_ok} prod_skip=${prod_skip} skip=${skip}"
}
