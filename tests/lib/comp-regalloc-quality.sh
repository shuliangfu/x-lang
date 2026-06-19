#!/usr/bin/env bash
# comp-regalloc-quality.sh — COMP-013 regalloc 质量波次 gate 辅助
#
# 用法（source 后）：
#   comp_regalloc_quality_run_metric SHUX script_path
#   comp_regalloc_quality_emit_report status metrics_ok metrics_skip skip

COMP_REGALLOC_QUALITY_PREFIX="${SHUX_COMP013_PREFIX:-shux: [SHUX_COMP013_REGALLOC_QUALITY]}"

# 执行单条 quality 指标脚本；成功返回 0，SKIP（无 shux_asm）返回 2。
comp_regalloc_quality_run_metric() {
  local shux="$1"
  local script="$2"
  local path="tests/$script"
  if [ ! -f "$path" ]; then
    echo "comp-regalloc-quality FAIL: missing $path" >&2
    return 1
  fi
  chmod +x "$path" 2>/dev/null || true
  if ! SHUX="$shux" "$path" >/dev/null 2>&1; then
    SHUX="$shux" "$path" 2>&1 | tail -6 >&2 || true
    return 1
  fi
  return 0
}

# 输出结构化报告行。
comp_regalloc_quality_emit_report() {
  local status="$1"
  local metrics_ok="$2"
  local metrics_skip="$3"
  local skip="$4"
  echo "${COMP_REGALLOC_QUALITY_PREFIX} status=${status} metrics_ok=${metrics_ok} metrics_skip=${metrics_skip} skip=${skip}"
}
