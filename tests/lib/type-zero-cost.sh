#!/usr/bin/env bash
# type-zero-cost.sh — TYPE-005 零成本抽象共享辅助

# 判断本机能否直接执行给定 shux 二进制。
type_zero_cost_native_shu() {
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

# 解析 bench 矩阵中的 .sx 路径。
type_zero_cost_bench_sx() {
  local file="$1"
  if [ -f "tests/bench/${file}" ]; then
    echo "tests/bench/${file}"
  elif [ -f "tests/typeck/linear/${file}" ]; then
    echo "tests/typeck/linear/${file}"
  else
    return 1
  fi
}
