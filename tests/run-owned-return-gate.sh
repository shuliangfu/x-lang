#!/usr/bin/env bash
# MEM-B1：owned 早 return 路径 deinit（xlang_cleanup + heap_free）。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q xlang-c 2>/dev/null || make -C compiler xlang-c
XLANG="${XLANG:-./compiler/xlang-c}"
SRC="tests/mem/owned_return_early.x"
OUT="/tmp/xlang_owned_return_$$"
rm -f "$OUT"
if ! XLANG_KEEP_C=1 "$XLANG" "$SRC" -o "$OUT" >/tmp/xlang_owned_return_build.log 2>&1; then
  echo "owned-return-gate FAIL: compile $SRC" >&2
  tail -8 /tmp/xlang_owned_return_build.log 2>/dev/null || true
  exit 1
fi
gen="$(grep -oE '/tmp/xlang_[A-Za-z0-9]+\.c' /tmp/xlang_owned_return_build.log | tail -1)"
if [ -z "$gen" ] || [ ! -f "$gen" ]; then
  echo "owned-return-gate FAIL: missing generated C" >&2
  exit 1
fi
if ! grep -q 'xlang_cleanup' "$gen"; then
  echo "owned-return-gate FAIL: missing xlang_cleanup for early return owned deinit" >&2
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
