#!/usr/bin/env bash
# comp-wpo-global.sh — COMP-019 WPO global tier 全局开启烟测辅助
#
# 用法（source 后）：
#   comp_wpo_global_linux_asm
#   comp_wpo_global_hook_runnable HOOK_SCRIPT
#   comp_wpo_global_emit_report status global_ok global_skip skip

COMP019_PREFIX="${SHUX_COMP019_PREFIX:-shux: [SHUX_COMP019_WPO_GLOBAL]}"

# Linux 且存在 shux_asm 则可跑 stretch / strict_glue / .o 代理类 hook。
comp_wpo_global_linux_asm() {
  [ "$(uname -s 2>/dev/null)" = "Linux" ] || return 1
  [ -x "./compiler/shux_asm" ] || [ -x "./compiler/shux_asm.experimental" ] || return 1
  return 0
}

# 判断 global hook 在本机是否应尝试 runnable。
comp_wpo_global_hook_runnable() {
  local hook="$1"
  case "$hook" in
    run-wpo-typeck-o-gate.sh)
      [ -f "./compiler/build_asm/typeck_wpo.o" ] && return 0
      comp_wpo_global_linux_asm
      ;;
    run-wpo-pipeline-o-gate.sh)
      [ -f "./compiler/build_asm/pipeline_wpo.o" ] && return 0
      comp_wpo_global_linux_asm
      ;;
    run-wpo-strict-glue-text-gate.sh|run-wpo-stretch-gate.sh|run-pipeline-wpo-optin-smoke.sh)
      comp_wpo_global_linux_asm
      ;;
    *)
      return 0
      ;;
  esac
}

# 输出结构化报告行。
comp_wpo_global_emit_report() {
  local status="$1"
  local global_ok="$2"
  local global_skip="$3"
  local skip="$4"
  echo "${COMP019_PREFIX} status=${status} global_ok=${global_ok} global_skip=${global_skip} skip=${skip}"
}
