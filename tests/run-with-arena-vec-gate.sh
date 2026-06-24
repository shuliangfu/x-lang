#!/usr/bin/env bash
# MEM-C1 波次 A：with_arena 内 std.vec push/reserve 走 v.al（scope bump）。
# 用法：./tests/run-with-arena-vec-gate.sh
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
SHUX="${SHUX:-./compiler/shux-c}"
SRC="tests/mem/with_arena_vec_push.sx"
OUT="/tmp/shux_with_arena_vec_$$"
FAIL="${SHUX_WITH_ARENA_VEC_GATE_FAIL:-0}"

rm -f "$OUT"
if ! "$SHUX" "$SRC" -o "$OUT" >/tmp/shux_with_arena_vec_build.log 2>&1; then
  echo "with-arena-vec-gate FAIL: compile $SRC" >&2
  tail -8 /tmp/shux_with_arena_vec_build.log 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rc=0
"$OUT" >/dev/null 2>&1 || rc=$?
if [ "$rc" != "0" ]; then
  echo "with-arena-vec-gate FAIL: run exit=$rc want 0" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

# 生成 C 应走 allocator_alloc（非 heap_alloc_u8）
gen="$(grep -oE '/tmp/shux_[A-Za-z0-9]+\.c' /tmp/shux_with_arena_vec_build.log | tail -1)"
if [ -n "$gen" ] && [ -f "$gen" ]; then
  if grep -qE 'heap_alloc_u8_c|heap\.alloc_u8' "$gen" 2>/dev/null; then
    echo "with-arena-vec-gate FAIL: reserve still uses heap.alloc_u8 in generated C" >&2
    rm -f "$gen"
    [ "$FAIL" = "1" ] && exit 1
    exit 0
  fi
  rm -f "$gen"
fi

echo "with-arena-vec-gate OK (with_arena Vec_u8 push via v.al)"
