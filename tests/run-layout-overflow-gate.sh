#!/usr/bin/env bash
# P1-4：布局算术溢出检查门禁 — manifest + repr(C) 布局烟测回归。
#
# 用法：./tests/run-layout-overflow-gate.sh
set -e
cd "$(dirname "$0")/.."

HEADER="compiler/include/shux_layout_arith.h"
TYPECK="compiler/src/typeck/typeck.c"
MANIFEST="tests/baseline/layout-overflow.tsv"

echo "=== P1-4: layout overflow manifest ==="
for f in "$HEADER" "$TYPECK" "$MANIFEST"; do
  if [ ! -f "$f" ]; then
    echo "layout-overflow gate FAIL: missing $f" >&2
    exit 1
  fi
done
if ! grep -qF "shux_layout_iadd_overflow" "$HEADER" 2>/dev/null; then
  echo "layout-overflow gate FAIL: header missing shux_layout_iadd_overflow" >&2
  exit 1
fi
if ! grep -qF "layout_offset_add" "$TYPECK" 2>/dev/null; then
  echo "layout-overflow gate FAIL: typeck missing layout_offset_add" >&2
  exit 1
fi
echo "layout-overflow manifest OK"

chmod +x tests/run-repr-c-layout-gate.sh
SHUX="${SHUX:-./compiler/shux-c}"
if [ ! -x "$SHUX" ]; then
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
  SHUX=./compiler/shux-c
fi
SHUX_REPR_C_LAYOUT_FAIL=1 SHUX="$SHUX" ./tests/run-repr-c-layout-gate.sh

echo "layout-overflow gate OK"
