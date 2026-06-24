#!/usr/bin/env bash
# MEM-AUTO-005：Allocator 域逃逸 — scope_allocator 块外须 typeck 拒错。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
SHUX="${SHUX:-./compiler/shux-c}"
SRC="tests/typeck/allocator_escape.sx"
if "$SHUX" "$SRC" -o /tmp/shux_alloc_escape_bad 2>/tmp/shux_alloc_escape.log; then
  echo "allocator-escape-gate FAIL: expected typeck error for $SRC" >&2
  exit 1
fi
if ! grep -qi 'scope_allocator' /tmp/shux_alloc_escape.log; then
  echo "allocator-escape-gate FAIL: missing scope_allocator diagnostic" >&2
  tail -6 /tmp/shux_alloc_escape.log 2>/dev/null || true
  exit 1
fi
echo "allocator-escape-gate OK (scope_allocator outside with_arena rejected)"
