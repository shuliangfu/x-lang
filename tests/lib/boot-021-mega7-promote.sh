#!/usr/bin/env bash
# boot-021-mega7-promote.sh — BOOT-021 B1–B7 晋升波次辅助
#
# 用法（source 后）：
#   boot021_mega7_linux_asm
#   boot021_parse_bisect_status LOG_FILE TARGET
#   boot021_emit_report status runnable_ok promote_emit skip

BOOT021_PREFIX="${SHUX_BOOT021_PREFIX:-shux: [SHUX_BOOT021]}"
_LIB_DIR="$(dirname "${BASH_SOURCE[0]:-$0}")"
# shellcheck source=tests/lib/comp-riscv64.sh
. "$_LIB_DIR/comp-riscv64.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$_LIB_DIR/ci-host.sh"

# Linux 且存在本机构建 shux_asm 链时可跑 bisect wave。
# Docker portable（make all 仅 shux-c）忽略 bind-mount 的 shux_asm.experimental 残留。
boot021_mega7_linux_asm() {
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

# 从 promote wave 日志解析单函数 status（stub/emit/fail）。
boot021_parse_bisect_status() {
  local log="$1"
  local target="$2"
  grep -E "^${target}[[:space:]]" "$log" 2>/dev/null | awk '{print $NF}' | sed 's/status=//' | head -1
}

# 输出结构化报告行。
boot021_emit_report() {
  local status="$1"
  local runnable_ok="$2"
  local promote_emit="$3"
  local skip="$4"
  echo "${BOOT021_PREFIX} status=${status} runnable_ok=${runnable_ok} promote_emit=${promote_emit} skip=${skip}"
}
