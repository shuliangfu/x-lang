#!/usr/bin/env bash
# comp-riscv64.sh — COMP-012 riscv64 回归共享辅助
#
# native shux 探测、.s 文本检查、ELF .o 校验、可选 riscv ld。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RISCV_TARGET="${SHUX_RISCV_TARGET:-riscv64}"

# 本机可执行 shux。
comp_riscv64_native_shu() {
  local f="${1:-./compiler/shux}"
  [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

# 解析 tests/asm 下样例路径。
comp_riscv64_sample_path() {
  local name="$1"
  if [ -f "$ROOT/tests/asm/$name" ]; then
    echo "$ROOT/tests/asm/$name"
  else
    return 1
  fi
}

# 检查 riscv64 汇编文本输出（.text、main、ret）。
comp_riscv64_check_asm_text() {
  local shux="$1"
  local su="$2"
  local out
  out="$(mktemp /tmp/shux_riscv_asm.XXXXXX)"
  if ! "$shux" -backend asm -target "$RISCV_TARGET" "$su" >"$out" 2>/dev/null; then
    rm -f "$out"
    return 1
  fi
  if ! grep -q '\.text' "$out" || ! grep -q 'main' "$out" || ! grep -q 'ret' "$out"; then
    rm -f "$out"
    return 1
  fi
  rm -f "$out"
  return 0
}

# 生成 riscv64 ELF .o 并校验；Linux 上必须为 ELF relocatable。
comp_riscv64_emit_elf_o() {
  local shux="$1"
  local su="$2"
  local out="$3"
  rm -f "$out" 2>/dev/null || true
  if ! "$shux" -backend asm -target "$RISCV_TARGET" -o "$out" "$su" 2>/dev/null; then
    return 1
  fi
  [ -f "$out" ] && [ -s "$out" ] || return 1
  if command -v file >/dev/null 2>&1; then
    if file "$out" 2>/dev/null | grep -qiE 'ELF[[:space:]]*.*relocatable'; then
      return 0
    fi
    if [ "$(uname -s 2>/dev/null)" = "Linux" ]; then
      return 1
    fi
  fi
  return 0
}

# 尝试链接并运行，期望 exit 42。
comp_riscv64_try_link_run() {
  local o="$1"
  local bin="$2"
  local ld cmd got
  rm -f "$bin" 2>/dev/null || true
  for ld in riscv64-unknown-elf-ld riscv64-linux-gnu-ld ld.lld ld; do
    if command -v "$ld" >/dev/null 2>&1; then
      if "$ld" -e _main -o "$bin" "$o" 2>/dev/null; then
        got=0
        "$bin" 2>/dev/null || got=$?
        if [ "$got" -eq 42 ]; then
          echo "$ld"
          return 0
        fi
      fi
    fi
  done
  return 1
}
