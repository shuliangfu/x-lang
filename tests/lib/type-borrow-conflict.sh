#!/usr/bin/env bash
# type-borrow-conflict.sh — TYPE-003 借用冲突诊断共享辅助

# 判断本机能否直接执行给定 shux 二进制。
type_borrow_native_shu() {
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

# 解析用例源路径（slice_lifetime / linear / borrow 子目录）。
type_borrow_case_path() {
  local file="$1"
  if [ -f "tests/typeck/borrow/${file}" ]; then
    echo "tests/typeck/borrow/${file}"
  elif [ -f "tests/typeck/slice_lifetime/${file}" ]; then
    echo "tests/typeck/slice_lifetime/${file}"
  elif [ -f "tests/typeck/linear/${file}" ]; then
    echo "tests/typeck/linear/${file}"
  else
    return 1
  fi
}
