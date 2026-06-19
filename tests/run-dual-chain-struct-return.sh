#!/usr/bin/env bash
# struct/packed/return 双链回归：同一用例 seed（shux）与 B-strict（shux_asm）均须通过。
# 用法：./tests/run-dual-chain-struct-return.sh
# 要求：make -C compiler bootstrap-driver-seed && make -C compiler bootstrap-driver-bstrict

set -e
cd "$(dirname "$0")/.."

export SHUX_SKIP_SUBSCRIPT_MAKE=1
ulimit -s 16384 2>/dev/null || true

SCRIPTS=(run-struct.sh run-return-value.sh run-return-expr.sh)

for chain in seed shux_asm; do
  if [ "$chain" = "seed" ]; then
    if [ ! -x ./compiler/shux ]; then
      echo "run-dual-chain-struct-return: ./compiler/shux missing (make -C compiler bootstrap-driver-seed)" >&2
      exit 127
    fi
    SHUX=./compiler/shux
    echo "run-dual-chain-struct-return: seed ($SHUX) ..."
  else
    if [ ! -x ./compiler/shux_asm ]; then
      echo "run-dual-chain-struct-return: ./compiler/shux_asm missing (make -C compiler bootstrap-driver-bstrict)" >&2
      exit 127
    fi
    SHUX=./compiler/shux_asm
    export SHUX_SKIP_PARSE_SMOKE=1
    echo "run-dual-chain-struct-return: shux_asm ($SHUX) ..."
  fi
  for script in "${SCRIPTS[@]}"; do
    SHUX="$SHUX" ./tests/"$script"
  done
done

echo "dual-chain struct/packed/return OK (seed + shux_asm)"
