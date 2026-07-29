#!/usr/bin/env bash
# check_pipeline_gen_expr_i64_abi.sh — P0-4 Expr.int_val int64_t ABI guard (11.0.3 · wave725)
#
# Authority (G.7):
#   Single body for check-pipeline-gen-expr-i64-abi. Makefile thin leaf and
#   bootstrap-pipeline / glue-types prereqs all call this script — no dual
#   copy of restore/fail logic in Makefile recipes.
#
# Contract:
#   - pipeline_gen.c must exist and be non-empty (or restore from product pin seed)
#   - struct ast_Expr must carry int64_t int_val (not int32_t; P0-4 / i64-ctfe)
#   - Product pin seed: seeds/pipeline_gen.linux.x86_64.c (host-portable C)
#
# Usage (compiler directory):
#   ./scripts/check_pipeline_gen_expr_i64_abi.sh
#
# PLATFORM: SHARED — seed is portable generated C; same guard on Darwin/Linux/Windows.
# Wave: 725 §5b #1.

set -euo pipefail
cd "$(dirname "$0")/.."

SEED="seeds/pipeline_gen.linux.x86_64.c"
GEN="pipeline_gen.c"
TAG="check-pipeline-gen-expr-i64-abi"

seed_ok() {
  [ -f "$SEED" ]
}

restore_seed() {
  cp -f "$SEED" "$GEN"
}

if [ ! -s "$GEN" ]; then
  if seed_ok; then
    restore_seed
    echo "${TAG}: restored empty pipeline_gen.c from seed" >&2
  else
    echo "${TAG}: FAIL missing pipeline_gen.c" >&2
    exit 1
  fi
fi

# Same pattern as pre-wave725 Makefile: single-line struct field scan.
# Stale workspace pipeline_gen.c with int32_t int_val is the P0-4 L4 failure mode.
if ! grep -q 'struct ast_Expr {.*int64_t int_val' "$GEN" 2>/dev/null; then
  if seed_ok; then
    restore_seed
    echo "${TAG}: restored seed (Expr.int_val must be int64_t; P0-4 / i64-ctfe)" >&2
  else
    echo "${TAG}: FAIL Expr.int_val is not int64_t and no seed" >&2
    exit 1
  fi
fi

exit 0
