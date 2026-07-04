#!/usr/bin/env bash
# STD-148：std.hash 默认策略门禁
#
# 用法：./tests/run-std-hash-default-strategy-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-hash-default-strategy-v1.md"
MANIFEST="tests/baseline/std-hash-default-strategy-manifest.tsv"
VECTORS="tests/baseline/std-hash-default-strategy.tsv"
MOD_X="std/hash/mod.x"
HASH_X="std/hash/hash.x"
LIB="tests/lib/std-hash-default-strategy.sh"
SMOKE_X="tests/std-hash/default_strategy.x"
SMOKE_C="tests/std-hash/default_strategy_ok.c"

# shellcheck source=tests/lib/std-hash-default-strategy.sh
. "$LIB"

echo "=== STD-148: hash default strategy manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$HASH_X" "$SMOKE_X" "$SMOKE_C" std/hash/README.md; do
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

sym_miss="$(std_hash_default_strategy_symbols_ok "$MOD_X" "$HASH_X" "$MANIFEST" || true)"
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
X_OK=0
SKIP=0
SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi
if [ -z "$SHUX_BIN" ] && [ -x ./compiler/shux ]; then SHUX_BIN=./compiler/shux; fi

if [ -n "$SHUX_BIN" ]; then
  make -C compiler -q shux-c 2>/dev/null || SHUX_LEGACY_C_FRONTEND=1 make -C compiler shux-c 2>/dev/null || true
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/hash/hash.o
  HASH_O="$(cd compiler && pwd)/../std/hash/hash.o"
  if std_hash_default_strategy_run_c_smoke "$HASH_X"; then
    C_OK=1
  else
    std_hash_default_strategy_emit_report "fail" 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    echo "std-hash-default-strategy gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_X" 2>&1 | tail -10 >&2 || true
    std_hash_default_strategy_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_hash_default_strategy_run_x_smoke "$SHUX_BIN" "$SMOKE_X" "$HASH_O"; then
    X_OK=1
  else
    std_hash_default_strategy_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  echo "std-hash-default-strategy gate SKIP c/x smoke (no native shux-c)" >&2
  SKIP=1
fi

std_hash_default_strategy_emit_report "ok" "$C_OK" "$X_OK" "$SKIP"
echo "std-hash-default-strategy gate OK"
