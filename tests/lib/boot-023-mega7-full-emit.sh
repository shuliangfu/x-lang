#!/usr/bin/env bash
# boot-023-mega7-full-emit.sh — BOOT-023 7/7 全量 emit 波次辅助
#
# 用法（source 后）：
#   boot023_mega7_linux_asm
#   boot023_count_emit LOG_FILE
#   boot023_emit_report status promote_emit emit_full skip

BOOT023_PREFIX="${SHUX_BOOT023_PREFIX:-shux: [SHUX_BOOT023]}"
_LIB_DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=tests/lib/comp-riscv64.sh
. "$_LIB_DIR/comp-riscv64.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$_LIB_DIR/ci-host.sh"

# Linux 且存在本机构建 shux_asm 链时可跑全量 emit wave（Docker portable 无 shux_asm 则 SKIP）。
boot023_mega7_linux_asm() {
  [ "$(uname -s 2>/dev/null)" = "Linux" ] || return 1
  if ci_is_docker && [ ! -x "./compiler/shux_asm" ]; then
    return 1
  fi
  local cand
  for cand in ./compiler/shux_asm ./compiler/shux_asm.experimental; do
    if comp_riscv64_native_shu "$cand"; then
      return 0
    fi
  done
  return 1
}

# 从 emit wave 日志统计 status=emit 条数。
boot023_count_emit() {
  local log="$1"
  grep -cE 'status=emit' "$log" 2>/dev/null || echo 0
}

# 输出结构化报告行（emit_full 与 promote_emit 同值，强调 7/7）。
boot023_emit_report() {
  local status="$1"
  local promote_emit="$2"
  local emit_full="$3"
  local skip="$4"
  echo "${BOOT023_PREFIX} status=${status} promote_emit=${promote_emit} emit_full=${emit_full} skip=${skip}"
}
