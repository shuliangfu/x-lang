#!/usr/bin/env bash
# comp-isel.sh — COMP-006 指令选择共享辅助

# 判断本机能否执行 asm 后端二进制。
comp_isel_native_shu() {
  local f="${1:-./compiler/shux_asm}"
  [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

# 解析 isel bench 的 .sx 路径（tests/asm 或 tests/bench）。
comp_isel_bench_path() {
  local file="$1"
  if [ -f "tests/asm/${file}" ]; then
    echo "tests/asm/${file}"
  elif [ -f "tests/bench/${file}" ]; then
    echo "tests/bench/${file}"
  else
    return 1
  fi
}
