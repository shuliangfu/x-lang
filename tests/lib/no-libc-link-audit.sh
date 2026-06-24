#!/usr/bin/env bash
# no-libc-link-audit.sh — 提取 runtime.c freestanding 链接块并审计（无 -lc）。
#
# 用法（source）：. tests/lib/no-libc-link-audit.sh
#   nolibc_audit_runtime_freestanding_block compiler/src/runtime_link_abi.c || exit 1

# 审计 runtime_link_abi.c 中 NL-05 BEGIN/END 块：须含 -nostdlib，不得含 -lc。
nolibc_audit_runtime_freestanding_block() {
  local rt="${1:-compiler/src/runtime_link_abi.c}"
  local block
  if [ ! -f "$rt" ]; then
    echo "nolibc-link-audit: missing $rt" >&2
    return 1
  fi
  block=$(awk '/F-no-libc NL-05 BEGIN/,/F-no-libc NL-05 END/' "$rt")
  if [ -z "$block" ]; then
    echo "nolibc-link-audit: NL-05 markers not found in $rt" >&2
    return 1
  fi
  if ! echo "$block" | grep -q '\-nostdlib'; then
    echo "nolibc-link-audit: freestanding block missing -nostdlib" >&2
    return 1
  fi
  if echo "$block" | grep -qE '[[:space:]]-lc([[:space:]]|$)|"-lc"'; then
    echo "nolibc-link-audit: freestanding block must not contain -lc" >&2
    return 1
  fi
  if ! echo "$block" | grep -q '\-\-gc-sections'; then
    echo "nolibc-link-audit: freestanding block missing --gc-sections" >&2
    return 1
  fi
  return 0
}

# 登记编译器 bootstrap 脚本中 -lc 命中数（track-only，不失败）。
nolibc_track_compiler_lc_mentions() {
  local n=0
  local f
  for f in compiler/scripts/build_shux_asm.sh compiler/src/runtime.c; do
    if [ -f "$f" ] && grep -qE '[[:space:]]-lc([[:space:]]|$)|"-lc"' "$f" 2>/dev/null; then
      n=$((n + 1))
    fi
  done
  echo "$n"
}
