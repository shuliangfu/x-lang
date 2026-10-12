#!/usr/bin/env bash
# PLATFORM: SHARED — leftover scan for PREFIX asm_asm_codegen_ast.
# w1533 (5.11): seeds/asm_experimental_symbol_bridge.from_x.c is deleted.
# The product bridge is pure asm of src/asm/asm_experimental_symbol_bridge.x
# (g05). This probe does not host-cc a seed and does not link a C bridge.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
if [ -f "$ROOT/compiler/seeds/asm_experimental_symbol_bridge.from_x.c" ]; then
  echo "FAIL: C seed came back (w1533)" >&2
  exit 1
fi
if [ ! -f "$ROOT/compiler/src/asm/asm_experimental_symbol_bridge.x" ]; then
  echo "FAIL: product bridge .x missing" >&2
  exit 1
fi

# Same-class PREFIX -1 leftovers. A STRONG PREFIX asm_asm_codegen_ast -1
# is a multiply_defined first-wins override of user_asm_seed_bridge.
leftover_re='^(XLANG_WEAK[[:space:]]+)?int(32_t)?[[:space:]]+asm_asm_codegen_ast[[:space:]]*\('
leftover_n=0
for src in \
  "$ROOT/compiler/seeds/runtime_driver_strict_glue_stubs.from_x.c" \
  "$ROOT/compiler/seeds/x_stubs.from_x.c" \
  "$ROOT/compiler/verify-selfhost.sh"
do
  if grep -nE "$leftover_re" "$src"; then
    echo "FAIL: $src still defines PREFIX asm_asm_codegen_ast" >&2
    leftover_n=$((leftover_n + 1))
  fi
done
if [ "$leftover_n" -ne 0 ]; then
  exit 1
fi
echo "bridge_asm_codegen_ast probe OK leftover_prefix=0"
