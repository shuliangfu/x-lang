#!/usr/bin/env bash
# comp-incr-compile-wave.sh — COMP-020 incr-compile wave tier 烟测扩面辅助
#
# 用法（source 后）：
#   comp_incr_wave_native_shu
#   comp_incr_wave_hook_runnable HOOK_SCRIPT
#   comp_incr_wave_emit_report status wave_ok wave_run wave_skip skip

COMP020_PREFIX="${SHUX_COMP020_PREFIX:-shux: [SHUX_COMP020_INCR_WAVE]}"

# 复用 COMP-007 native shux 探测。
comp_incr_wave_native_shu() {
  # shellcheck source=tests/lib/comp-incr-compile.sh
  . tests/lib/comp-incr-compile.sh
  local cand
  for cand in ./compiler/shux-c ./compiler/shux ./compiler/shux_asm; do
    if comp_incr_compile_native_shu "$cand"; then
      return 0
    fi
  done
  return 1
}

# 判断 wave hook 在本机是否应尝试 runnable。
comp_incr_wave_hook_runnable() {
  local hook="$1"
  case "$hook" in
    run-comp-incr-compile.sh|run-obs-compile-phase-timing-gate.sh)
      comp_incr_wave_native_shu
      ;;
    run-comp-incr-compile-gate.sh)
      return 0
      ;;
    *)
      return 0
      ;;
  esac
}

# 输出结构化报告行。
comp_incr_wave_emit_report() {
  local status="$1"
  local wave_ok="$2"
  local wave_run="$3"
  local wave_skip="$4"
  local skip="$5"
  echo "${COMP020_PREFIX} status=${status} wave_ok=${wave_ok} wave_run=${wave_run} wave_skip=${wave_skip} skip=${skip}"
}
