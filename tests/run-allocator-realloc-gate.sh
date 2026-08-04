#!/usr/bin/env bash
# MEM-C1 AL-05：arena Allocator 上 allocator_realloc 须 typeck 拒错。
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c
XLANG="${XLANG:-./compiler/xlang-c}"
SRC="tests/typeck/allocator_realloc_arena.x"
if "$XLANG" "$SRC" -o /tmp/xlang_alloc_realloc_bad 2>/tmp/xlang_alloc_realloc.log; then
  echo "allocator-realloc-gate FAIL: expected typeck error for $SRC" >&2
  exit 1
fi
if ! grep -qi 'realloc' /tmp/xlang_alloc_realloc.log; then
  echo "allocator-realloc-gate FAIL: missing realloc diagnostic" >&2
  tail -6 /tmp/xlang_alloc_realloc.log 2>/dev/null || true
  exit 1
fi
echo "allocator-realloc-gate OK (arena realloc rejected)"
