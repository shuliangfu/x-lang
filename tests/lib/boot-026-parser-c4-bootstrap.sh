#!/usr/bin/env bash
# boot-026-parser-c4-bootstrap.sh — BOOT-026 C4 SX bootstrap 波次辅助
#
# 用法（source 后）：
#   boot026_parser_linux_shu
#   boot026_parse_sx_emit_log LOG_FILE
#   boot026_emit_report status c4_minimal_ok c4_sx_probe skip

BOOT026_PREFIX="${SHUX_BOOT026_PREFIX:-shux: [SHUX_BOOT026]}"
_LIB_DIR="$(dirname "${BASH_SOURCE[0]:-$0}")"
# shellcheck source=tests/lib/comp-riscv64.sh
. "$_LIB_DIR/comp-riscv64.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$_LIB_DIR/ci-host.sh"

# Linux 且存在可用 shux/asm 链时可跑 SX bootstrap 波次（Docker portable 无 shux_asm 则 SKIP）。
boot026_parser_linux_shu() {
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

# 从 SX emit 日志解析 MINIMAL OK / PASS。
# 返回 "minimal_ok su_probe" 两个 0/1 字段（空格分隔）。
boot026_parse_sx_emit_log() {
  local log="$1"
  local minimal=0
  local probe=0
  if grep -qE 'parser-parse-bootstrap-sx-emit-gate PASS' "$log" 2>/dev/null; then
    probe=1
    if grep -qF 'MINIMAL OK' "$log" 2>/dev/null; then
      minimal=1
    fi
  fi
  echo "$minimal $probe"
}

# 输出结构化报告行。
boot026_emit_report() {
  local status="$1"
  local c4_minimal_ok="$2"
  local c4_sx_probe="$3"
  local skip="$4"
  echo "${BOOT026_PREFIX} status=${status} c4_minimal_ok=${c4_minimal_ok} c4_sx_probe=${c4_sx_probe} skip=${skip}"
}
