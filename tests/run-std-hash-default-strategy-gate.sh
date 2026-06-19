#!/usr/bin/env bash
# STD-148：std.hash 默认策略门禁
#
# 用法：./tests/run-std-hash-default-strategy-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-hash-default-strategy-v1.md"
MANIFEST="tests/baseline/std-hash-default-strategy-manifest.tsv"
VECTORS="tests/baseline/std-hash-default-strategy.tsv"
MOD_SU="std/hash/mod.sx"
HASH_C="std/hash/hash.c"
LIB="tests/lib/std-hash-default-strategy.sh"
SMOKE_SU="tests/std-hash/default_strategy.sx"
SMOKE_C="tests/std-hash/default_strategy_ok.c"

# shellcheck source=tests/lib/std-hash-default-strategy.sh
. "$LIB"

echo "=== STD-148: hash default strategy manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$HASH_C" "$SMOKE_SU" "$SMOKE_C" std/hash/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-hash-default-strategy gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-148 recommend_hasher_map SHUX_HASH_ALGO HASHER_XXHASH; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-hash-default-strategy gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "recommend_hasher_fast" std/hash/README.md 2>/dev/null; then
  echo "std-hash-default-strategy gate FAIL: README missing recommend_hasher_fast" >&2
  exit 1
fi

sym_miss="$(std_hash_default_strategy_symbols_ok "$MOD_SU" "$HASH_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_hash_default_strategy_emit_report "fail" 0 0 0
  exit 1
fi

if ! std_hash_default_strategy_vectors_ok "$VECTORS" 3; then
  std_hash_default_strategy_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-hash-default-strategy registry OK"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/hash/hash.o
HASH_O="$(cd compiler && pwd)/../std/hash/hash.o"

C_OK=0
if std_hash_default_strategy_run_c_smoke "$HASH_C"; then
  C_OK=1
else
  std_hash_default_strategy_emit_report "fail" 0 0 0
  exit 1
fi

SU_OK=0
SKIP=0
SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  if ! "$SHUX_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-hash-default-strategy gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_hash_default_strategy_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_hash_default_strategy_run_sx_smoke "$SHUX_BIN" "$SMOKE_SU" "$HASH_O"; then
    SU_OK=1
  else
    std_hash_default_strategy_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_hash_default_strategy_emit_report "ok" "$C_OK" "$SU_OK" "$SKIP"
echo "std-hash-default-strategy gate OK"
