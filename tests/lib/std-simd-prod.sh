#!/usr/bin/env bash
# std-simd-prod.sh — STD-061 生产级 bench 共享辅助
#
# 用法（source 后）：
#   std_simd_prod_native_asm XLANG_BIN
#   std_simd_prod_emit_report status check_ok bench_ok bench_skip skip [ratio]
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_SIMD_PROD_PREFIX="${XLANG_STD061_PREFIX:-xlang: [XLANG_STD061_SIMD_PROD]}"

# 判断本机 xlang_asm 可执行 shuffle/select bench。
std_simd_prod_native_asm() {
  local f="${1:-./compiler/xlang_asm}"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$f" in
    */xlang-c|*/xlang-x*) return 1 ;;
  esac
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

# Structured report: check observational; bench hard-green when ratio ok;
# bench_skip/skip mark honest perf soft residual (not fossil DOC false-red).
std_simd_prod_emit_report() {
  local status="$1"
  local check_ok="$2"
  local bench_ok="$3"
  local bench_skip="$4"
  local skip="$5"
  local ratio="${6:-}"
  if [ -n "$ratio" ]; then
    echo "${STD_SIMD_PROD_PREFIX} status=${status} check=${check_ok} bench=${bench_ok} skip=${skip} ratio=${ratio}"
  else
    echo "${STD_SIMD_PROD_PREFIX} status=${status} check=${check_ok} bench=${bench_ok} skip=${skip}"
  fi
}
