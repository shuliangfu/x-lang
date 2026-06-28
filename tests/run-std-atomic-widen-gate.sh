#!/usr/bin/env bash
# STD-146：std.atomic 16/64 扩展门禁
#
# 用法：./tests/run-std-atomic-widen-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-atomic-widen-v1.md"
MANIFEST="tests/baseline/std-atomic-widen-manifest.tsv"
MOD_SX="std/atomic/mod.sx"
ATOMIC_RUNTIME="${SHUX_STD_ATOMIC_IMPL:-compiler/src/asm/runtime_atomic_glue.c}"
LIB="tests/lib/std-atomic-widen.sh"
SMOKE_SX="tests/atomic/widen_16_64.sx"

# shellcheck source=tests/lib/std-atomic-widen.sh
. "$LIB"

echo "=== STD-146: std.atomic widen manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SX" "$ATOMIC_RUNTIME" "$SMOKE_SX" std/atomic/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-atomic-widen gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-146 load compare_exchange fetch_sub; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-atomic-widen gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(std_atomic_widen_symbols_ok "$MOD_SX" "$ATOMIC_RUNTIME" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_atomic_widen_emit_report "fail" 0 0
  exit 1
fi
echo "std-atomic-widen registry OK"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/atomic/atomic.o
ensure_runtime_atomic_glue_o 2>/dev/null || true
ATOMIC_O="$(cd compiler && pwd)/../std/atomic/atomic.o"
ATOMIC_RT_O="$(cd compiler && pwd)/runtime_atomic_glue.o"

EXEC_OK=0
SKIP=0
SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  if ! "$SHUX_BIN" check -L . "$SMOKE_SX" >/dev/null 2>&1; then
    echo "std-atomic-widen gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SX" 2>&1 | tail -10 >&2 || true
    std_atomic_widen_emit_report "fail" 0 0
    exit 1
  fi
  if std_atomic_widen_run_smoke "$SHUX_BIN" "$SMOKE_SX" "$ATOMIC_O" "$ATOMIC_RT_O"; then
    EXEC_OK=1
  else
    std_atomic_widen_emit_report "fail" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_atomic_widen_emit_report "ok" "$EXEC_OK" "$SKIP"
echo "std-atomic-widen gate OK"
