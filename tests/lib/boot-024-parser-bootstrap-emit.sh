#!/usr/bin/env bash
# boot-024-parser-bootstrap-emit.sh — BOOT-024 C2 bootstrap emit 波次辅助
#
# 用法（source 后）：
#   boot024_parser_linux_shu
#   boot024_parse_bisect_minimal LOG_FILE
#   boot024_emit_report status bootstrap_minimal_ok bootstrap_full_emit skip

BOOT024_PREFIX="${SHUX_BOOT024_PREFIX:-shux: [SHUX_BOOT024]}"
_LIB_DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=tests/lib/comp-riscv64.sh
. "$_LIB_DIR/comp-riscv64.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$_LIB_DIR/ci-host.sh"

# Linux 且存在可用 shux/asm 链时可跑 bootstrap bisect。
# Docker portable（make all 仅 shux-c）无 shux_asm 时 SKIP。
boot024_parser_linux_shu() {
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
  comp_riscv64_native_shu "./compiler/shux"
}

# 从 bisect 日志解析 MINIMAL PASS 行。
boot024_parse_bisect_minimal() {
  local log="$1"
  grep -cE 'MINIMAL PASS' "$log" 2>/dev/null || echo 0
}

# 从 bisect 日志解析 FULL 意外成功（ec=0 且 emitted）。
boot024_parse_bisect_full_emit() {
  local log="$1"
  if grep -qE 'FULL PASS \(ec=0' "$log" 2>/dev/null; then
    echo 1
    return
  fi
  echo 0
}

# 输出结构化报告行。
boot024_emit_report() {
  local status="$1"
  local bootstrap_minimal_ok="$2"
  local bootstrap_full_emit="$3"
  local skip="$4"
  echo "${BOOT024_PREFIX} status=${status} bootstrap_minimal_ok=${bootstrap_minimal_ok} bootstrap_full_emit=${bootstrap_full_emit} skip=${skip}"
}
