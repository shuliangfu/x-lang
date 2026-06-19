#!/usr/bin/env bash
# STD-144：std.mem 安全边界封装门禁
#
# 用法：./tests/run-std-mem-safe-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-mem-safe-v1.md"
MANIFEST="tests/baseline/std-mem-safe-manifest.tsv"
MOD_SU="std/mem/mod.sx"
LIB="tests/lib/std-mem-safe.sh"
SMOKE_SU="tests/mem/mem_safe_boundary.sx"

# shellcheck source=tests/lib/std-mem-safe.sh
. "$LIB"

echo "=== STD-144: std.mem safe boundary manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$SMOKE_SU" std/mem/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-mem-safe gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-144 copy_bounded compare_bounded buffer_from; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-mem-safe gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "copy_bounded" std/mem/README.md 2>/dev/null; then
  echo "std-mem-safe gate FAIL: README missing copy_bounded" >&2
  exit 1
fi

sym_miss="$(std_mem_safe_symbols_ok "$MOD_SU" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_mem_safe_emit_report "fail" 0 0
  exit 1
fi
echo "std-mem-safe registry OK"

SU_OK=0
SKIP=0
SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  if ! "$SHUX_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-mem-safe gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_mem_safe_emit_report "fail" 0 0
    exit 1
  fi
  if std_mem_safe_run_smoke "$SHUX_BIN" "$SMOKE_SU"; then
    SU_OK=1
  else
    std_mem_safe_emit_report "fail" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_mem_safe_emit_report "ok" "$SU_OK" "$SKIP"
echo "std-mem-safe gate OK"
