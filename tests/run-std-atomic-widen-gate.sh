#!/usr/bin/env bash
# STD-146：std.atomic 16/64 扩展门禁
#
# 用法：./tests/run-std-atomic-widen-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-atomic-widen-v1.md"
MANIFEST="tests/baseline/std-atomic-widen-manifest.tsv"
MOD_SU="std/atomic/mod.su"
ATOMIC_C="std/atomic/atomic.c"
LIB="tests/lib/std-atomic-widen.sh"
SMOKE_SU="tests/atomic/widen_16_64.su"

# shellcheck source=tests/lib/std-atomic-widen.sh
. "$LIB"

echo "=== STD-146: std.atomic widen manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$ATOMIC_C" "$SMOKE_SU" std/atomic/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-atomic-widen gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-146 load_i16 compare_exchange_u64 fetch_sub_i64; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-atomic-widen gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(std_atomic_widen_symbols_ok "$MOD_SU" "$ATOMIC_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_atomic_widen_emit_report "fail" 0 0
  exit 1
fi
echo "std-atomic-widen registry OK"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/atomic/atomic.o
ATOMIC_O="$(cd compiler && pwd)/../std/atomic/atomic.o"

EXEC_OK=0
SKIP=0
SHU_BIN=""
if [ -x ./compiler/shu-c ]; then SHU_BIN=./compiler/shu-c; fi

if [ -n "$SHU_BIN" ]; then
  if ! "$SHU_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-atomic-widen gate FAIL: typeck" >&2
    "$SHU_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_atomic_widen_emit_report "fail" 0 0
    exit 1
  fi
  if std_atomic_widen_run_smoke "$SHU_BIN" "$SMOKE_SU" "$ATOMIC_O"; then
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
