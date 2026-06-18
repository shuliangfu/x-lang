#!/usr/bin/env bash
# comp-incr-compile-prod.sh — COMP-021 incr-compile prod tier 烟测辅助
#
# 用法（source 后）：
#   comp_incr_prod_native_shu
#   comp_incr_prod_hook_runnable HOOK_SCRIPT
#   comp_incr_prod_emit_report status prod_ok prod_run prod_skip skip

COMP021_PREFIX="${SHU_COMP021_PREFIX:-shu: [SHU_COMP021_INCR_PROD]}"

# 复用 COMP-020 native shu 探测。
comp_incr_prod_native_shu() {
  # shellcheck source=tests/lib/comp-incr-compile-wave.sh
  . tests/lib/comp-incr-compile-wave.sh
  comp_incr_wave_native_shu
}

# 判断 prod hook 在本机是否应尝试 runnable。
comp_incr_prod_hook_runnable() {
  local hook="$1"
  case "$hook" in
    run-comp-incr-compile.sh|run-obs-compile-phase-timing-gate.sh)
      comp_incr_prod_native_shu
      ;;
    run-comp-incr-compile-gate.sh|run-comp-incr-compile-wave-gate.sh)
      return 0
      ;;
    *)
      return 0
      ;;
  esac
}

# 输出结构化报告行。
comp_incr_prod_emit_report() {
  local status="$1"
  local prod_ok="$2"
  local prod_run="$3"
  local prod_skip="$4"
  local skip="$5"
  echo "${COMP021_PREFIX} status=${status} prod_ok=${prod_ok} prod_run=${prod_run} prod_skip=${prod_skip} skip=${skip}"
}
