#!/usr/bin/env bash
# boot-022-mega7-emit.sh — BOOT-022 emit 晋升波次辅助
#
# 用法（source 后）：
#   boot022_mega7_linux_asm
#   boot022_parse_emit_lead LOG_FILE
#   boot022_emit_report status promote_emit emit_lead skip

BOOT022_PREFIX="${SHUX_BOOT022_PREFIX:-shux: [SHUX_BOOT022]}"
_LIB_DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=tests/lib/comp-riscv64.sh
. "$_LIB_DIR/comp-riscv64.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$_LIB_DIR/ci-host.sh"

# Linux 且存在本机构建 shux_asm 链时可跑 emit wave（Docker portable 无 shux_asm 则 SKIP）。
boot022_mega7_linux_asm() {
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

# 从 emit wave 日志解析首个 status=emit 的函数名。
boot022_parse_emit_lead() {
  local log="$1"
  grep -E 'status=emit' "$log" 2>/dev/null | awk '{print $1}' | head -1
}

# 输出结构化报告行。
boot022_emit_report() {
  local status="$1"
  local promote_emit="$2"
  local emit_lead="$3"
  local skip="$4"
  echo "${BOOT022_PREFIX} status=${status} promote_emit=${promote_emit} emit_lead=${emit_lead} skip=${skip}"
}
