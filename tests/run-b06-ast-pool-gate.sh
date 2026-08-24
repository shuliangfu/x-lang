#!/usr/bin/env bash
# B-06: AST Arena / pool-limit boundary gate.
#
# wave309: compiler/ast_pool.c left — do NOT hard-require the deleted mega shell
# (sit-red forever / dual-authority if resurrected). Live pool/arena authority:
#   compiler/src/runtime_pipeline_abi.x  (ast_pool_* freestanding APIs,
#   pipe_en_max_variants, grow pools)
# plus parser.x call sites and tests/run-pool-limits.sh behavioral matrix.
#
# Usage: ./tests/run-b06-ast-pool-gate.sh
# PLATFORM: SHARED archaeology honesty (bootstrap-bstrict-ci still invokes).
set -e
cd "$(dirname "$0")/.."

echo "=== B-06: pool limits / live arena authority ==="
LIVE_ABI="compiler/src/runtime_pipeline_abi.x"
for f in "$LIVE_ABI" tests/run-pool-limits.sh; do
  [ -f "$f" ] || { echo "b06 gate FAIL: missing $f" >&2; exit 1; }
done

# Live freestanding pool API must remain callable from parser (G.7).
grep -q 'ast_pool_' compiler/src/parser/parser.x || {
  echo "b06 gate FAIL: parser.x missing ast_pool_* refs (live freestanding pool API)" >&2
  exit 1
}

# Cap authority lives in runtime_pipeline_abi (historical MODULE_ENUM_MAX twin).
grep -q 'pipe_en_max_variants' "$LIVE_ABI" || {
  echo "b06 gate FAIL: $LIVE_ABI missing pipe_en_max_variants" >&2
  exit 1
}

# Honesty: deleted mega shell must stay deleted (no resurrected fossil).
if [ -f compiler/ast_pool.c ]; then
  echo "b06 gate FAIL: compiler/ast_pool.c resurrected (wave309 left; dual authority)" >&2
  exit 1
fi

chmod +x tests/run-pool-limits.sh
XLANG="${XLANG:-./compiler/xlang-c}"
[ -x "$XLANG" ] || XLANG=./compiler/xlang
if [ -x "$XLANG" ] && "$XLANG" --version >/dev/null 2>&1; then
  XLANG="$XLANG" bash tests/run-pool-limits.sh
else
  echo "b06 gate SKIP pool-limits (no runnable xlang on this host)"
fi
echo "b06 ast-pool gate OK"
