#!/usr/bin/env bash
# comp-wpo.sh — COMP-004 WPO 共享辅助

# 判断本机能否直接执行给定 shu/shu-c 二进制。
comp_wpo_native_exe() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 0 ;;
  esac
}

# 统计 manifest 中 stage_* 行数。
comp_wpo_stage_count() {
  local man="${1:-tests/baseline/comp-wpo.tsv}"
  awk -F'\t' '$2=="stages" && $1 ~ /^stage_/ { n++ } END { print n+0 }' "$man"
}
