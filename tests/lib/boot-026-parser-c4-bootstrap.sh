#!/usr/bin/env bash
# boot-026-parser-c4-bootstrap.sh — BOOT-026 C4 SU bootstrap 波次辅助
#
# 用法（source 后）：
#   boot026_parser_linux_shu
#   boot026_parse_su_emit_log LOG_FILE
#   boot026_emit_report status c4_minimal_ok c4_su_probe skip

BOOT026_PREFIX="${SHU_BOOT026_PREFIX:-shu: [SHU_BOOT026]}"

# Linux 且存在 compiler/shu seed 则可跑 SU bootstrap 波次。
boot026_parser_linux_shu() {
  [ "$(uname -s 2>/dev/null)" = "Linux" ] || return 1
  [ -x "./compiler/shu" ] || return 1
  return 0
}

# 从 SU emit 日志解析 MINIMAL OK / PASS。
# 返回 "minimal_ok su_probe" 两个 0/1 字段（空格分隔）。
boot026_parse_su_emit_log() {
  local log="$1"
  local minimal=0
  local probe=0
  if grep -qE 'parser-parse-bootstrap-su-emit-gate PASS' "$log" 2>/dev/null; then
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
  local c4_su_probe="$3"
  local skip="$4"
  echo "${BOOT026_PREFIX} status=${status} c4_minimal_ok=${c4_minimal_ok} c4_su_probe=${c4_su_probe} skip=${skip}"
}
