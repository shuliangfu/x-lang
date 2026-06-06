#!/usr/bin/env bash
# wpo-main-disasm.sh — WPO-S2：跨平台提取 _main 反汇编并检测 call/bl 模式（otool / objdump）。
# 用法：source tests/lib/wpo-main-disasm.sh
#   wpo_main_asm /path/to/binary
#   wpo_main_calls_pat /path/to/binary 'scale|lane0'

# 返回可执行文件 _main 反汇编文本（macOS otool / Linux objdump --disassemble）。
wpo_main_asm() {
  local exe="$1"
  local out=""
  if [ ! -f "$exe" ]; then
    return 1
  fi
  if command -v otool >/dev/null 2>&1; then
    out=$(otool -tv "$exe" 2>/dev/null | sed -n '/^_main:/,/^_[a-zA-Z]/p' || true)
    if [ -n "$out" ]; then
      printf '%s\n' "$out"
      return 0
    fi
  fi
  if command -v objdump >/dev/null 2>&1; then
    local sym
    # Linux ELF 入口常为 main；macOS Mach-O 为 _main。
    for sym in _main main; do
      out=$(objdump -d --disassemble="$sym" "$exe" 2>/dev/null | sed -n "/<${sym}>:/,\$p" | sed '/^$/q' || true)
      if [ -n "$out" ] && printf '%s\n' "$out" | grep -q "<${sym}>:"; then
        printf '%s\n' "$out"
        return 0
      fi
    done
    # 旧 objdump 无 --disassemble：回退 sed 区间。
    for sym in _main main; do
      out=$(objdump -d "$exe" 2>/dev/null | sed -n "/<${sym}>:/,/^$/p" || true)
      if [ -n "$out" ]; then
        printf '%s\n' "$out"
        return 0
      fi
    done
  fi
  return 1
}

# _main 内是否存在匹配 pat 的 call/bl（pat 为 ERE，不含边界）。
wpo_main_calls_pat() {
  local exe="$1"
  local pat="$2"
  local asm
  asm=$(wpo_main_asm "$exe") || return 1
  # macOS: bl _scale；Linux x86_64/aarch64: call ... scale
  printf '%s\n' "$asm" | grep -E '(^[[:space:]]*bl[[:space:]]|call[[:space:]]|callq[[:space:]]|bl[[:space:]]+)' | grep -qE "$pat"
}

# _main 内是否不含匹配 pat 的 call/bl（fold 烟测：泛型 callee 应被消除）。
wpo_main_no_calls_pat() {
  local exe="$1"
  local pat="$2"
  if wpo_main_calls_pat "$exe" "$pat"; then
    return 1
  fi
  return 0
}
