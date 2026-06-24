#!/usr/bin/env bash
# MEM-B1：owned 早 return 路径 deinit（shux_cleanup + heap_free）。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
SHUX="${SHUX:-./compiler/shux-c}"
SRC="tests/mem/owned_return_early.sx"
OUT="/tmp/shux_owned_return_$$"
rm -f "$OUT"
if ! SHUX_KEEP_C=1 "$SHUX" "$SRC" -o "$OUT" >/tmp/shux_owned_return_build.log 2>&1; then
  echo "owned-return-gate FAIL: compile $SRC" >&2
  tail -8 /tmp/shux_owned_return_build.log 2>/dev/null || true
  exit 1
fi
gen="$(grep -oE '/tmp/shux_[A-Za-z0-9]+\.c' /tmp/shux_owned_return_build.log | tail -1)"
if [ -z "$gen" ] || [ ! -f "$gen" ]; then
  echo "owned-return-gate FAIL: missing generated C" >&2
  exit 1
fi
if ! grep -q 'shux_cleanup' "$gen"; then
  echo "owned-return-gate FAIL: missing shux_cleanup for early return owned deinit" >&2
  rm -f "$gen"
  exit 1
fi
if ! grep -qE 'heap_free_u8_c|\.ptr = 0' "$gen"; then
  echo "owned-return-gate FAIL: missing owned Vec_u8 deinit in generated C" >&2
  rm -f "$gen"
  exit 1
fi
rm -f "$gen"
rc=0
"$OUT" >/dev/null 2>&1 || rc=$?
if [ "$rc" != "0" ]; then
  echo "owned-return-gate FAIL: run exit=$rc want 0" >&2
  exit 1
fi
echo "owned-return-gate OK (owned early-return cleanup path)"
