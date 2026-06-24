#!/usr/bin/env bash
# STD-148：std.hash 默认策略门禁
#
# 用法：./tests/run-std-hash-default-strategy-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-hash-default-strategy-v1.md"
MANIFEST="tests/baseline/std-hash-default-strategy-manifest.tsv"
VECTORS="tests/baseline/std-hash-default-strategy.tsv"
MOD_SX="std/hash/mod.sx"
HASH_SX="std/hash/hash.sx"
LIB="tests/lib/std-hash-default-strategy.sh"
SMOKE_SX="tests/std-hash/default_strategy.sx"
SMOKE_C="tests/std-hash/default_strategy_ok.c"

# shellcheck source=tests/lib/std-hash-default-strategy.sh
. "$LIB"

echo "=== STD-148: hash default strategy manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SX" "$HASH_SX" "$SMOKE_SX" "$SMOKE_C" std/hash/README.md; do
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

sym_miss="$(std_hash_default_strategy_symbols_ok "$MOD_SX" "$HASH_SX" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_hash_default_strategy_emit_report "fail" 0 0 0
  exit 1
fi

if ! std_hash_default_strategy_vectors_ok "$VECTORS" 3; then
  std_hash_default_strategy_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-hash-default-strategy registry OK"

C_OK=0
SX_OK=0
SKIP=0
SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi
if [ -z "$SHUX_BIN" ] && [ -x ./compiler/shux ]; then SHUX_BIN=./compiler/shux; fi

if [ -n "$SHUX_BIN" ]; then
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/hash/hash.o
  HASH_O="$(cd compiler && pwd)/../std/hash/hash.o"
  if std_hash_default_strategy_run_c_smoke "$HASH_SX"; then
    C_OK=1
  else
    std_hash_default_strategy_emit_report "fail" 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$SMOKE_SX" >/dev/null 2>&1; then
    echo "std-hash-default-strategy gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SX" 2>&1 | tail -10 >&2 || true
    std_hash_default_strategy_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_hash_default_strategy_run_sx_smoke "$SHUX_BIN" "$SMOKE_SX" "$HASH_O"; then
    SX_OK=1
  else
    std_hash_default_strategy_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  echo "std-hash-default-strategy gate SKIP c/sx smoke (no native shux-c)" >&2
  SKIP=1
fi

std_hash_default_strategy_emit_report "ok" "$C_OK" "$SX_OK" "$SKIP"
echo "std-hash-default-strategy gate OK"
