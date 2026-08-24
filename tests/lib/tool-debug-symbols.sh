#!/usr/bin/env bash
# tool-debug-symbols.sh — TOOL-005 共享：调试符号检查辅助
#
# 用法（source 后）：
#   tool_dbg_exe_has_sym EXE SYM
#   tool_dbg_exe_not_stripped EXE
#   tool_dbg_rule_count [manifest_tsv]

# 检查可执行文件符号表是否含 SYM（兼容 Mach-O 前导 _）。
tool_dbg_exe_has_sym() {
  local exe="$1"
  local sym="$2"
  local bare="${sym#_}"
  if nm "$exe" 2>/dev/null | awk -v w="$bare" '{
    s = $3; sub(/^_/, "", s); if (s == w) found = 1
  } END { exit !found }'; then
    return 0
  fi
  echo "tool-debug-symbols FAIL: missing symbol ${sym} in $exe" >&2
  return 1
}

# 检查可执行文件未被 strip（调试构建期望）。
# Linux ELF：file(1) 输出含 "not stripped"。
# macOS Mach-O：file(1) 不标注 stripped 状态，改查 LC_SYMTAB nsyms。
# With -dead_strip (release) tiny products collapse to nsyms≈3; -O 0 without
# dead_strip keeps ~100+ even without DWARF. Threshold 50 separates the two
# (was 300 — false-red on honest -O0 asm products). PLATFORM: DARWIN nsyms.
tool_dbg_exe_not_stripped() {
  local exe="$1"
  local info
  info=$(file "$exe" 2>/dev/null || true)
  if echo "$info" | grep -qi 'not stripped'; then
    return 0
  fi
  if echo "$info" | grep -qi 'Mach-O'; then
    if otool -l "$exe" 2>/dev/null | awk '/^[[:space:]]*nsyms[[:space:]]/ { if ($2 > 50) ok = 1 } END { exit !ok }'; then
      return 0
    fi
  fi
  echo "tool-debug-symbols FAIL: expected not stripped: $info" >&2
  return 1
}

# 统计 manifest rules 行数。
tool_dbg_rule_count() {
  local man="${1:-tests/baseline/tool-debug-symbols.tsv}"
  awk -F'\t' '$2=="rules" && $1 !~ /^#/ { n++ } END { print n+0 }' "$man"
}
