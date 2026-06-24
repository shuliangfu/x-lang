#!/usr/bin/env bash
# MEM-C1 AL-05：arena Allocator 上 allocator_realloc 须 typeck 拒错。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
SHUX="${SHUX:-./compiler/shux-c}"
SRC="tests/typeck/allocator_realloc_arena.sx"
if "$SHUX" "$SRC" -o /tmp/shux_alloc_realloc_bad 2>/tmp/shux_alloc_realloc.log; then
  echo "allocator-realloc-gate FAIL: expected typeck error for $SRC" >&2
  exit 1
fi
if ! grep -qi 'realloc' /tmp/shux_alloc_realloc.log; then
  echo "allocator-realloc-gate FAIL: missing realloc diagnostic" >&2
  tail -6 /tmp/shux_alloc_realloc.log 2>/dev/null || true
  exit 1
fi
echo "allocator-realloc-gate OK (arena realloc rejected)"
