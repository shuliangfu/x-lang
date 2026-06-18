#!/usr/bin/env bash
# boot-028-shu-asm2-ci-matrix.sh — BOOT-028 C6 shu_asm2 CI 矩阵辅助
#
# 用法（source 后）：
#   boot028_current_platform
#   boot028_row_policy LINUX_P MACOS_P WIN_P
#   boot028_parse_smoke_log LOG_FILE
#   boot028_emit_report status c6_matrix_ok c6_smoke skip

# shellcheck source=tests/lib/boot-027-shu-asm2-cross.sh
_BOOT028_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$_BOOT028_LIB_DIR/boot-027-shu-asm2-cross.sh"

BOOT028_PREFIX="${SHU_BOOT028_PREFIX:-shu: [SHU_BOOT028]}"

# 返回当前 CI 平台标签：linux / macos / windows / unknown。
boot028_current_platform() {
  # shellcheck source=tests/lib/ci-host.sh
  . "$_BOOT028_LIB_DIR/ci-host.sh"
  if ci_is_linux; then
    echo linux
  elif ci_is_darwin; then
    echo macos
  elif ci_is_windows_msys; then
    echo windows
  else
    echo unknown
  fi
}

# 按宿主 OS 解析矩阵行策略（linux/macos/windows 列）。
boot028_row_policy() {
  local linux_p="$1"
  local macos_p="$2"
  local win_p="$3"
  case "$(boot028_current_platform)" in
    linux) echo "$linux_p" ;;
    macos) echo "$macos_p" ;;
    windows) echo "$win_p" ;;
    *) echo skip ;;
  esac
}

# 从烟测日志解析 c6_smoke（0/1）。
boot028_parse_smoke_log() {
  local log="$1"
  if grep -qE 'shu-asm2-cross-smoke OK|shu-asm2-cross-smoke SKIP' "$log" 2>/dev/null; then
    echo 1
  else
    echo 0
  fi
}

# 输出结构化报告行。
boot028_emit_report() {
  local status="$1"
  local c6_matrix_ok="$2"
  local c6_smoke="$3"
  local skip="$4"
  echo "${BOOT028_PREFIX} status=${status} c6_matrix_ok=${c6_matrix_ok} c6_smoke=${c6_smoke} skip=${skip}"
}
