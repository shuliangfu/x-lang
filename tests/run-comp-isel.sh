#!/usr/bin/env bash
# COMP-006：指令选择 asm 烟测
#
# 用法：./tests/run-comp-isel.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/comp-isel.sh
. tests/lib/comp-isel.sh

SHU_BIN="${SHU:-}"
for cand in ./compiler/shu_asm ./compiler/shu; do
  if comp_isel_native_shu "$cand"; then
    SHU_BIN="$cand"
    break
  fi
done

if [ -z "$SHU_BIN" ]; then
  echo "comp-isel SKIP (no native shu_asm, host=$(uname -s)/$(uname -m 2>/dev/null))"
  echo "comp-isel OK"
  exit 0
fi

make -C compiler -q 2>/dev/null || make -C compiler

echo "=== COMP-006: isel smoke (SHU=$SHU_BIN) ==="
chmod +x tests/run-asm-binop-var.sh tests/run-asm-binop-index-lit.sh \
  tests/run-asm-binop-field-index.sh tests/run-asm-binop-nested-var.sh \
  tests/run-asm-binop-div-index.sh
SHU="$SHU_BIN" ./tests/run-asm-binop-var.sh
echo "comp-isel OK var_fast"

SHU="$SHU_BIN" ./tests/run-asm-binop-index-lit.sh
echo "comp-isel OK index_lit"

# COMP-014 P0 抽样烟测（field / nested / div-index）
SHU="$SHU_BIN" ./tests/run-asm-binop-field-index.sh
echo "comp-isel OK field_index_p0"

SHU="$SHU_BIN" ./tests/run-asm-binop-nested-var.sh
echo "comp-isel OK nested_var_p0"

SHU="$SHU_BIN" ./tests/run-asm-binop-div-index.sh
echo "comp-isel OK div_index_p0"

echo "comp-isel OK"
