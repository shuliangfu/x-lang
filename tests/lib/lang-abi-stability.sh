#!/usr/bin/env bash
# lang-abi-stability.sh — LANG-005 ABI 稳定承诺共享辅助

# 判断本机能否直接执行给定 shu 二进制。
lang_abi_native_shu() {
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

# 统计 manifest 中 layer_* 行数。
lang_abi_layer_count() {
  local man="${1:-tests/baseline/lang-abi-stability.tsv}"
  awk -F'\t' '$2=="layers" && $1 ~ /^layer_/ { n++ } END { print n+0 }' "$man"
}
