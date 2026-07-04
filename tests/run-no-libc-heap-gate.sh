#!/usr/bin/env bash
# NL-03：Linux freestanding mmap bump 堆烟测（零 libc，无 heap.c/malloc）。
#
# 用法：./tests/run-no-libc-heap-gate.sh
# 环境：
#   SHUX_NOLIBC_HEAP_FAIL=1  — 失败时硬退出
#   SHUX=./compiler/shux      — freestanding 编译器
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_NOLIBC_HEAP_FAIL:-0}
X="tests/sys/linux_heap_mmap_smoke.x"
OUT="/tmp/shux_nolibc_heap.$$.out"
PAGE_MMAP="std/heap/page_mmap.x"

die() {
  echo "nolibc-heap gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== NL-03: freestanding mmap heap (zero libc) ==="
[ -f "$X" ] || die "missing $X"
[ -f "$PAGE_MMAP" ] || die "missing $PAGE_MMAP"
grep -q 'page_mmap_heap_init' "$PAGE_MMAP" || die "page_mmap.x missing init"

if [ "$(uname -s 2>/dev/null)" != "Linux" ] || [ "$(uname -m 2>/dev/null)" != "x86_64" ]; then
  echo "nolibc-heap gate: N/A (Linux x86_64 freestanding only; manifest OK)"
  exit 0
fi

SHUX="${SHUX:-./compiler/shux}"
if [ ! -x "$SHUX" ] && [ -x ./compiler/shux_asm ]; then
  SHUX=./compiler/shux_asm
fi
if [ ! -x "$SHUX" ]; then
  echo "nolibc-heap gate: SKIP (no shux/shux_asm)"
  exit 0
fi

rm -f "$OUT" 2>/dev/null || true
if ! "$SHUX" -freestanding -backend asm -o "$OUT" "$X" 2>/tmp/shux_nolibc_heap.log; then
  tail -n 12 /tmp/shux_nolibc_heap.log 2>/dev/null || true
  die "compile $X failed"
fi
[ -x "$OUT" ] || die "no executable $OUT"

# 不得动态依赖 libc.so
if command -v ldd >/dev/null 2>&1; then
  if ldd "$OUT" 2>&1 | grep -qi 'libc\.so'; then
    ldd "$OUT" 2>&1 || true
    die "$OUT linked against libc.so"
  fi
fi

rc=0
OUT_TXT=$("$OUT" 2>/dev/null) || rc=$?
rm -f "$OUT" 2>/dev/null || true
if [ "$rc" -ne 0 ]; then
  die "expected exit 0, got $rc"
fi
if [ "$OUT_TXT" != "ABC" ]; then
  die "stdout expected ABC, got '$OUT_TXT'"
fi

echo "nolibc-heap gate OK (mmap bump alloc + write, no libc.so)"
