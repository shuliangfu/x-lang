#!/usr/bin/env bash
# STD-140：std.path 极端路径规范化门禁
#
# 用法：./tests/run-std-path-extreme-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-path-extreme-v1.md"
MANIFEST="tests/baseline/std-path-extreme-manifest.tsv"
VECTORS="tests/baseline/std-path-extreme.tsv"
MOD_SU="std/path/mod.su"
LIB="tests/lib/std-path-extreme.sh"
SMOKE_SU="tests/path/extreme_clean.su"
MIN_VECTORS=8

# shellcheck source=tests/lib/std-path-extreme.sh
. "$LIB"

echo "=== STD-140: std.path extreme manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$SMOKE_SU" std/path/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-path-extreme gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-140 path_clean path_resolve path_extension_and_stem foo//baz; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-path-extreme gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(std_path_extreme_symbols_ok "$MOD_SU" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_path_extreme_emit_report "fail" 0 0
  exit 1
fi

if ! std_path_extreme_vectors_ok "$VECTORS" "$MIN_VECTORS"; then
  std_path_extreme_emit_report "fail" 0 0
  exit 1
fi
echo "std-path-extreme registry OK"

SU_OK=0
SKIP=0
SHU_BIN=""
if [ -x ./compiler/shu-c ]; then SHU_BIN=./compiler/shu-c; fi

if [ -n "$SHU_BIN" ]; then
  if ! "$SHU_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-path-extreme gate FAIL: typeck" >&2
    "$SHU_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_path_extreme_emit_report "fail" 0 0
    exit 1
  fi
  if std_path_extreme_run_smoke "$SHU_BIN" "$SMOKE_SU"; then
    SU_OK=1
  else
    std_path_extreme_emit_report "fail" 0 0
    exit 1
  fi
else
  echo "std-path-extreme gate SKIP .su smoke (no shu)" >&2
  SKIP=1
fi

std_path_extreme_emit_report "ok" "$SU_OK" "$SKIP"
echo "std-path-extreme gate OK"
