#!/usr/bin/env bash
# std-simd-prod.sh — STD-061 生产级 bench 共享辅助
#
# 用法（source 后）：
#   std_simd_prod_native_asm SHUX_BIN
#   std_simd_prod_emit_report status bench_ok bench_skip skip ratio

STD_SIMD_PROD_PREFIX="${SHUX_STD061_PREFIX:-shux: [SHUX_STD061_SIMD_PROD]}"

# 判断本机 shux_asm 可执行 shuffle/select bench。
std_simd_prod_native_asm() {
  local f="${1:-./compiler/shux_asm}"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$f" in
    */shux-c|*/shux-sx*) return 1 ;;
  esac
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

# 输出结构化报告行（ratio 可为空）。
std_simd_prod_emit_report() {
  local status="$1"
  local bench_ok="$2"
  local bench_skip="$3"
  local skip="$4"
  local ratio="${5:-}"
  if [ -n "$ratio" ]; then
    echo "${STD_SIMD_PROD_PREFIX} status=${status} bench_ok=${bench_ok} bench_skip=${bench_skip} skip=${skip} ratio=${ratio}"
  else
    echo "${STD_SIMD_PROD_PREFIX} status=${status} bench_ok=${bench_ok} bench_skip=${bench_skip} skip=${skip}"
  fi
}
