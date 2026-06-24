#!/usr/bin/env bash
# C-08 v1：runtime.c vs .sx driver 迁移盘点（manifest + 关键符号）。
#
# 用法：./tests/run-c08-runtime-inventory-gate.sh
set -e
cd "$(dirname "$0")/.."

MANIFEST="tests/baseline/c08-runtime-driver-inventory.tsv"
RT="compiler/src/runtime.c"

echo "=== C-08: runtime/driver inventory ==="
for f in "$MANIFEST" "$RT" analysis/phase-c-c08-v1.md; do
  [ -f "$f" ] || { echo "c08 inventory FAIL: missing $f" >&2; exit 1; }
done
grep -q 'SHUX_USE_SX_DRIVER' "$RT" || { echo "c08 inventory FAIL: runtime.c missing SHUX_USE_SX_DRIVER sections" >&2; exit 1; }
grep -q 'driver_run_compiler_full' "$RT" || { echo "c08 inventory FAIL: runtime.c missing driver_run_compiler_full" >&2; exit 1; }
grep -q 'function entry(' compiler/src/main.sx || { echo "c08 inventory FAIL: main.sx missing entry()" >&2; exit 1; }
echo "c08 runtime inventory OK"
