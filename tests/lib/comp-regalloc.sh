#!/usr/bin/env bash
# comp-regalloc.sh — COMP-005 寄存器分配评估共享辅助

# 判断本机能否执行 shux_asm（asm 7.3 regalloc 路径）。
comp_regalloc_native_shux_asm() {
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

# arm64 反汇编质量门禁宿主。
comp_regalloc_disasm_host() {
  case "$(uname -m 2>/dev/null)" in
    arm64|aarch64) return 0 ;;
    *) return 1 ;;
  esac
}
