#!/usr/bin/env bash
# comp-riscv64.sh — COMP-012 riscv64 回归共享辅助
#
# native xlang 探测、.s 文本检查、ELF .o 校验、可选 riscv ld。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
RISCV_TARGET="${XLANG_RISCV_TARGET:-riscv64}"

# 本机可执行 xlang。
comp_riscv64_native_xlang() {
  local f="${1:-./compiler/xlang}"
  [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

# 探测 xlang 是否支持 -backend asm -target riscv64（C-only seed 返回 not available）。
comp_riscv64_asm_capable() {
  local xlang="$1"
  local sample="${2:-$ROOT/tests/asm/riscv64_min.x}"
  local err=""
  [ -x "$xlang" ] && [ -f "$sample" ] || return 1
  err="$("$xlang" -backend asm -target "$RISCV_TARGET" "$sample" 2>&1 >/dev/null || true)"
  if echo "$err" | grep -qi 'not available'; then
    return 1
  fi
  if "$xlang" -backend asm -target "$RISCV_TARGET" "$sample" >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

# 选择首个 native 且 asm-capable 的 xlang；无则返回 1。
comp_riscv64_pick_xlang() {
  local cand
  for cand in ./compiler/xlang_asm ./compiler/xlang_asm.strict ./compiler/xlang_asm.experimental \
              ./compiler/xlang ./compiler/xlang-c; do
    if comp_riscv64_native_xlang "$cand" && comp_riscv64_asm_capable "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
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
  local xlang="$1"
  local x="$2"
  local out
  out="$(mktemp /tmp/xlang_riscv_asm.XXXXXX)"
  if ! "$xlang" -backend asm -target "$RISCV_TARGET" "$x" >"$out" 2>/dev/null; then
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
  local xlang="$1"
  local x="$2"
  local out="$3"
  rm -f "$out" 2>/dev/null || true
  if ! "$xlang" -backend asm -target "$RISCV_TARGET" -o "$out" "$x" 2>/dev/null; then
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
