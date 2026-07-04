#!/usr/bin/env bash
# MEM-C1 AL-06：slice + Allocator 双重逃逸 + AL-04 赋值逃逸 typeck 负例。
set -e
cd "$(dirname "$0")/.."
SHUX="${SHUX:-./compiler/shux-c}"
if [ ! -x "$SHUX" ]; then
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
  SHUX=./compiler/shux-c
fi

check_neg() {
  local src="$1"
  local msg="$2"
  local out
  out="$("$SHUX" check "$src" 2>&1)" || true
  if ! echo "$out" | grep -qF "$msg"; then
    echo "al06-gate FAIL: $src expected '$msg'" >&2
    echo "$out" >&2
    exit 1
  fi
  echo "al06-gate OK $src -> $msg"
}

check_neg tests/typeck/allocator_assign_escape.x "allocator region escape"
check_neg tests/typeck/dual_escape_with_arena_region.x "slice region escape"
echo "al06-gate OK (AL-04 assign + AL-06 dual escape)"
