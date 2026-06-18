#!/usr/bin/env bash
# COMP-005：寄存器分配策略轻量烟测
#
# 用法：./tests/run-comp-regalloc.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/comp-regalloc.sh
. tests/lib/comp-regalloc.sh

SHU_ASM="${SHU:-./compiler/shu_asm}"
if ! comp_regalloc_native_shu_asm "$SHU_ASM"; then
  echo "comp-regalloc SKIP (no native shu_asm, host=$(uname -s)/$(uname -m 2>/dev/null))"
  echo "comp-regalloc OK"
  exit 0
fi

echo "=== COMP-005: regalloc smoke (SHU=$SHU_ASM) ==="
chmod +x tests/run-asm-binop-var.sh tests/run-asm-binop-block-var.sh
SHU="$SHU_ASM" ./tests/run-asm-binop-var.sh
echo "comp-regalloc OK var_fast"

if comp_regalloc_disasm_host; then
  SHU="$SHU_ASM" ./tests/run-asm-binop-block-var.sh
  echo "comp-regalloc OK block_var"
else
  echo "comp-regalloc SKIP block_var disasm (non-arm64 host)"
fi

echo "comp-regalloc OK"
