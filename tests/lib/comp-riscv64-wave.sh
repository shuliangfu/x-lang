#!/usr/bin/env bash
# comp-riscv64-wave.sh — COMP-016 riscv64 wave 回归辅助
#
# 用法（source 后）：
#   comp_riscv64_wave_count MATRIX
#   comp_riscv64_wave_run_case SHU_BIN SAMPLE
#   comp_riscv64_wave_emit_report status wave_ok wave_skip skip

COMP016_PREFIX="${SHU_COMP016_PREFIX:-shu: [SHU_COMP016_RISCV_WAVE]}"

# 统计矩阵中 policy=wave 的 case 数。
comp_riscv64_wave_count() {
  local matrix="$1"
  local n=0
  local case_id _sample _check _expect policy
  while IFS=$'\t' read -r case_id _sample _check _expect policy _notes; do
    [ -z "${case_id:-}" ] && continue
    case "$case_id" in \#*|min_*) continue ;; esac
    [ "${policy:-}" = "wave" ] && n=$((n + 1))
  done < "$matrix"
  echo "$n"
}

# 对单样例跑 riscv64 asm_text 烟测。
comp_riscv64_wave_run_case() {
  local shu="$1"
  local sample="$2"
  local path
  # shellcheck source=tests/lib/comp-riscv64.sh
  . tests/lib/comp-riscv64.sh
  path="$(comp_riscv64_sample_path "$sample")" || return 1
  comp_riscv64_check_asm_text "$shu" "$path"
}

# 输出结构化报告行。
comp_riscv64_wave_emit_report() {
  local status="$1"
  local wave_ok="$2"
  local wave_skip="$3"
  local skip="$4"
  echo "${COMP016_PREFIX} status=${status} wave_ok=${wave_ok} wave_skip=${wave_skip} skip=${skip}"
}
