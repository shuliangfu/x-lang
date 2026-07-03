#!/usr/bin/env bash
# boot-027-shux-asm2-cross.sh — BOOT-027 C5 shux_asm2 跨平台波次辅助
#
# 用法（source 后）：
#   boot027_linux_asm2_candidate
#   boot027_parse_smoke_log LOG_FILE
#   boot027_emit_report status c5_ok c5_smoke skip

BOOT027_PREFIX="${SHUX_BOOT027_PREFIX:-shux: [SHUX_BOOT027]}"
_LIB_DIR="$(dirname "${BASH_SOURCE[0]:-$0}")"
# shellcheck source=tests/lib/ci-host.sh
. "$_LIB_DIR/ci-host.sh"

# 探测 Linux 上可烟测的 shux_asm2 候选路径（Docker portable 无 shux_asm 链则 SKIP）。
boot027_linux_asm2_candidate() {
  [ "$(uname -s 2>/dev/null)" = "Linux" ] || return 1
  if ci_is_docker && [ ! -x "./compiler/shux_asm" ]; then
    return 1
  fi
  local c
  for c in compiler/shux_asm2 compiler/shux_asm2_refreshed; do
    if [ -x "$c" ] && boot027_native_binary "$c"; then
      return 0
    fi
  done
  return 1
}

# 校验二进制与当前宿主 ISA 匹配。
boot027_native_binary() {
  local f="$1"
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

# 从烟测日志解析 PASS / SKIP。
# 返回 "c5_ok c5_smoke" 两个 0/1 字段（空格分隔）。
boot027_parse_smoke_log() {
  local log="$1"
  local ok=0
  local smoke=0
  if grep -qF 'shux-asm2-cross-smoke OK' "$log" 2>/dev/null; then
    smoke=1
    ok=1
  elif grep -qF 'shux-asm2-cross-smoke SKIP' "$log" 2>/dev/null; then
    smoke=1
  fi
  echo "$ok $smoke"
}

# 输出结构化报告行。
boot027_emit_report() {
  local status="$1"
  local c5_ok="$2"
  local c5_smoke="$3"
  local skip="$4"
  echo "${BOOT027_PREFIX} status=${status} c5_ok=${c5_ok} c5_smoke=${c5_smoke} skip=${skip}"
}
