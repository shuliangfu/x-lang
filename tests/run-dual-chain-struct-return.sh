#!/usr/bin/env bash
# struct/packed/return 双链回归：同一用例 seed（shu）与 B-strict（shu_asm）均须通过。
# 用法：./tests/run-dual-chain-struct-return.sh
# 要求：make -C compiler bootstrap-driver-seed && make -C compiler bootstrap-driver-bstrict

set -e
cd "$(dirname "$0")/.."

export SHULANG_SKIP_SUBSCRIPT_MAKE=1
ulimit -s 16384 2>/dev/null || true

SCRIPTS=(run-struct.sh run-return-value.sh run-return-expr.sh)

for chain in seed shu_asm; do
  if [ "$chain" = "seed" ]; then
    if [ ! -x ./compiler/shu ]; then
      echo "run-dual-chain-struct-return: ./compiler/shu missing (make -C compiler bootstrap-driver-seed)" >&2
      exit 127
    fi
    SHU=./compiler/shu
    echo "run-dual-chain-struct-return: seed ($SHU) ..."
  else
    if [ ! -x ./compiler/shu_asm ]; then
      echo "run-dual-chain-struct-return: ./compiler/shu_asm missing (make -C compiler bootstrap-driver-bstrict)" >&2
      exit 127
    fi
    SHU=./compiler/shu_asm
    export SHU_SKIP_PARSE_SMOKE=1
    echo "run-dual-chain-struct-return: shu_asm ($SHU) ..."
  fi
  for script in "${SCRIPTS[@]}"; do
    SHU="$SHU" ./tests/"$script"
  done
done

echo "dual-chain struct/packed/return OK (seed + shu_asm)"
