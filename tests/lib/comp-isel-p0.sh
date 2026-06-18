#!/usr/bin/env bash
# comp-isel-p0.sh — COMP-014 isel P0 回归辅助
#
# 用法（source 后）：
#   comp_isel_p0_run_hook SHU script_name
#   comp_isel_p0_emit_report status p0_ok p0_skip skip

COMP_ISEL_P0_PREFIX="${SHU_COMP014_PREFIX:-shu: [SHU_COMP014_ISEL_P0]}"

# 执行 P0 hook 脚本；成功 0，失败 1。
comp_isel_p0_run_hook() {
  local shu="$1"
  local script="$2"
  local path="tests/$script"
  if [ ! -f "$path" ]; then
    echo "comp-isel-p0 FAIL: missing $path" >&2
    return 1
  fi
  chmod +x "$path" 2>/dev/null || true
  if ! SHU="$shu" "$path" >/dev/null 2>&1; then
    SHU="$shu" "$path" 2>&1 | tail -6 >&2 || true
    return 1
  fi
  return 0
}

# 输出结构化报告行。
comp_isel_p0_emit_report() {
  local status="$1"
  local p0_ok="$2"
  local p0_skip="$3"
  local skip="$4"
  echo "${COMP_ISEL_P0_PREFIX} status=${status} p0_ok=${p0_ok} p0_skip=${p0_skip} skip=${skip}"
}
