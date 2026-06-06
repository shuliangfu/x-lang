#!/usr/bin/env bash
# DOD 门禁共用：判断 shu/shu_asm 是否为本机可 exec 的二进制。
# 用法：source tests/lib/dod-native-exe.sh && dod_native_exe "$path"

# 判断编译器/可执行文件是否与本机 OS/架构匹配；无 file(1) 时 Linux/Darwin 回落为可 exec 即通过。
dod_native_exe() {
  local f="$1"
  local os arch
  [ -n "$f" ] && [ -x "$f" ] || return 1
  os="$(uname -s 2>/dev/null || echo unknown)"
  arch="$(uname -m 2>/dev/null || echo unknown)"
  if ! command -v file >/dev/null 2>&1; then
    case "$os" in
      Linux|Darwin) return 0 ;;
      *) return 0 ;;
    esac
  fi
  case "${os}-${arch}" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}
