#!/usr/bin/env bash
# struct/packed/return 双链回归：同一用例 seed（xlang）与 B-strict（xlang_asm）均须通过。
# 用法：./tests/run-dual-chain-struct-return.sh
# 要求：make -C compiler bootstrap-driver-seed && make -C compiler bootstrap-driver-bstrict

set -e
cd "$(dirname "$0")/.."

export XLANG_SKIP_SUBSCRIPT_MAKE=1
ulimit -s 16384 2>/dev/null || true

SCRIPTS=(run-struct.sh run-return-value.sh run-return-expr.sh)

for chain in seed xlang_asm; do
  if [ "$chain" = "seed" ]; then
    if [ ! -x ./compiler/xlang ]; then
      echo "run-dual-chain-struct-return: ./compiler/xlang missing (make -C compiler bootstrap-driver-seed)" >&2
      exit 127
    fi
    XLANG=./compiler/xlang
    echo "run-dual-chain-struct-return: seed ($XLANG) ..."
  else
    if [ ! -x ./compiler/xlang_asm ]; then
      echo "run-dual-chain-struct-return: ./compiler/xlang_asm missing (make -C compiler bootstrap-driver-bstrict)" >&2
      exit 127
    fi
    XLANG=./compiler/xlang_asm
    export XLANG_SKIP_PARSE_SMOKE=1
    echo "run-dual-chain-struct-return: xlang_asm ($XLANG) ..."
  fi
  for script in "${SCRIPTS[@]}"; do
    XLANG="$XLANG" ./tests/"$script"
  done
done

echo "dual-chain struct/packed/return OK (seed + xlang_asm)"
