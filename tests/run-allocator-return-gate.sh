#!/usr/bin/env bash
# MEM-C1 AL-04：with_arena 内 return Allocator 须 typeck 拒错。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
SHUX="${SHUX:-./compiler/shux-c}"
SRC="tests/typeck/allocator_return_escape.x"
if "$SHUX" "$SRC" -o /tmp/shux_alloc_return_bad 2>/tmp/shux_alloc_return.log; then
  echo "allocator-return-gate FAIL: expected typeck error for $SRC" >&2
  exit 1
fi
if ! grep -qi 'allocator region escape' /tmp/shux_alloc_return.log; then
  echo "allocator-return-gate FAIL: missing region escape diagnostic" >&2
  tail -6 /tmp/shux_alloc_return.log 2>/dev/null || true
  exit 1
fi
echo "allocator-return-gate OK (return Allocator from with_arena rejected)"
