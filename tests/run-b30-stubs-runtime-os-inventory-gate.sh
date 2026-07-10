#!/usr/bin/env bash
# B-30：_stubs.c / runtime.c OS 调用盘点门禁（manifest + 关键符号存在）。
#
# 用法：./tests/run-b30-stubs-runtime-os-inventory-gate.sh
set -e
cd "$(dirname "$0")/.."

MANIFEST="tests/baseline/b30-os-inventory.tsv"
RT="compiler/seeds/runtime.from_x.c"
DOC="analysis/phase-b-completion-v1.md"

echo "=== B-30: stubs/runtime OS inventory ==="
for f in "$MANIFEST" "$RT" "$DOC" compiler/docs/完全去掉C与H-前置清单.md; do
  [ -f "$f" ] || { echo "b30 gate FAIL: missing $f" >&2; exit 1; }
done
grep -q 'read_file' "$RT" || { echo "b30 gate FAIL: runtime.c missing read_file" >&2; exit 1; }
grep -q 'write_file' "$RT" || { echo "b30 gate FAIL: runtime.c missing write_file" >&2; exit 1; }
grep -q 'generated_c_contains_any_substr' "$RT" || { echo "b30 gate FAIL: missing generated_c scan" >&2; exit 1; }
echo "b30 inventory OK"
