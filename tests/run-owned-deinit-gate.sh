#!/usr/bin/env bash
# MEM-B1：owned(Vec_u8) 块尾自动 emit vec_u8_deinit。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
SHUX="${SHUX:-./compiler/shux-c}"
SRC="tests/mem/owned_vec_u8.sx"
OUT="/tmp/shux_owned_vec_$$"
rm -f "$OUT"
if ! SHUX_KEEP_C=1 "$SHUX" "$SRC" -o "$OUT" >/tmp/shux_owned_run.log 2>&1; then
  echo "owned-deinit-gate FAIL: compile/run failed" >&2
  tail -8 /tmp/shux_owned_run.log 2>/dev/null || true
  exit 1
fi
gen="$(grep -oE '/tmp/shux_[A-Za-z0-9]+\.c' /tmp/shux_owned_run.log | tail -1)"
if [ -z "$gen" ] || [ ! -f "$gen" ]; then
  echo "owned-deinit-gate FAIL: SHUX_KEEP_C did not retain generated C" >&2
  exit 1
fi
if ! grep -qE 'heap_free_u8_c|std_vec_vec_u8_deinit' "$gen"; then
  echo "owned-deinit-gate FAIL: missing vec_u8_deinit in generated C" >&2
  rm -f "$gen"
  exit 1
fi
rm -f "$gen"
rc=0
"$OUT" >/dev/null 2>&1 || rc=$?
if [ "$rc" != "0" ]; then
  echo "owned-deinit-gate FAIL: run exit=$rc want 0" >&2
  exit 1
fi
echo "owned-deinit-gate OK (owned Vec_u8 block-end deinit emitted)"
