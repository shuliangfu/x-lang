#!/usr/bin/env bash
# MEM-C1：with_arena 内 vec_u8_push 单态化为 push_arena（heap_arena64_alloc_c 直调）。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
SHUX="${SHUX:-./compiler/shux-c}"
SRC="tests/mem/with_arena_vec_push.x"
OUT="/tmp/shux_vec_push_arena_$$"
rm -f "$OUT"
if ! SHUX_KEEP_C=1 "$SHUX" "$SRC" -o "$OUT" >/tmp/shux_vec_push_arena_run.log 2>&1; then
  echo "vec-push-arena-gate FAIL: compile/run failed" >&2
  tail -8 /tmp/shux_vec_push_arena_run.log 2>/dev/null || true
  exit 1
fi
gen="$(grep -oE '/tmp/shux_[A-Za-z0-9]+\.c' /tmp/shux_vec_push_arena_run.log | tail -1)"
if [ -z "$gen" ] || [ ! -f "$gen" ]; then
  echo "vec-push-arena-gate FAIL: SHUX_KEEP_C did not retain generated C" >&2
  exit 1
fi
if ! grep -q 'std_vec_vec_u8_push_arena' "$gen"; then
  echo "vec-push-arena-gate FAIL: push_arena call not found" >&2
  rm -f "$gen"
  exit 1
fi
if ! grep -q 'heap_arena64_alloc_c' "$gen"; then
  echo "vec-push-arena-gate FAIL: heap_arena64_alloc_c not in push_arena path" >&2
  rm -f "$gen"
  exit 1
fi
rm -f "$gen"
rc=0
"$OUT" >/dev/null 2>&1 || rc=$?
if [ "$rc" != "0" ]; then
  echo "vec-push-arena-gate FAIL: exit=$rc want 0" >&2
  exit 1
fi
echo "vec-push-arena-gate OK (with_arena vec push_arena monomorphization)"
