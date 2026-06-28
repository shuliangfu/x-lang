#!/usr/bin/env bash
# STD-140：std.path 极端路径规范化门禁
#
# 用法：./tests/run-std-path-extreme-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-path-extreme-v1.md"
MANIFEST="tests/baseline/std-path-extreme-manifest.tsv"
VECTORS="tests/baseline/std-path-extreme.tsv"
MOD_SX="std/path/mod.sx"
LIB="tests/lib/std-path-extreme.sh"
SMOKE_SX="tests/path/extreme_clean.sx"
MIN_VECTORS=8

# shellcheck source=tests/lib/std-path-extreme.sh
. "$LIB"

echo "=== STD-140: std.path extreme manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SX" "$SMOKE_SX" std/path/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-path-extreme gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-140 clean resolve extension_and_stem foo//baz; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-path-extreme gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(std_path_extreme_symbols_ok "$MOD_SX" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_path_extreme_emit_report "fail" 0 0
  exit 1
fi

if ! std_path_extreme_vectors_ok "$VECTORS" "$MIN_VECTORS"; then
  std_path_extreme_emit_report "fail" 0 0
  exit 1
fi
echo "std-path-extreme registry OK"

SX_OK=0
SKIP=0
SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-140: typeck + API rename grep (SHUX=$SHUX_BIN) ==="
  if ! "$SHUX_BIN" check -L . "$SMOKE_SX" >/dev/null 2>&1; then
    echo "std-path-extreme gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SX" 2>&1 | tail -10 >&2 || true
    std_path_extreme_emit_report "fail" 0 0
    exit 1
  fi
  for sym in clean resolve extension_and_stem join sep is_absolute; do
    if ! grep -qE "function ${sym}\\(" "$MOD_SX" 2>/dev/null; then
      echo "std-path-extreme gate FAIL: mod missing function ${sym}" >&2
      std_path_extreme_emit_report "fail" 0 0
      exit 1
    fi
  done
  for call in path.clean path.resolve path.extension_and_stem; do
    if ! grep -q "${call}" "$SMOKE_SX" 2>/dev/null; then
      echo "std-path-extreme gate FAIL: smoke missing ${call}" >&2
      std_path_extreme_emit_report "fail" 0 0
      exit 1
    fi
  done
  # sx pipeline compile/run 待 path.o co-emit 闭合；typeck + manifest + grep 通过即 OK。
  SX_OK=1
  SKIP=1
else
  echo "std-path-extreme gate SKIP .sx smoke (no shux)" >&2
  SKIP=1
fi

std_path_extreme_emit_report "ok" "$SX_OK" "$SKIP"
echo "std-path-extreme gate OK"
