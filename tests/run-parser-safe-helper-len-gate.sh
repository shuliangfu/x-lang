#!/usr/bin/env bash
# Parser EMIT_HEAVY safe_helper / thin_delegate x_len honesty gate.
#
# Historical body grepped deleted compiler/ast_pool.c (PARSER_SAFE_EQ /
# k_asm_parser_thin_delegate). After wave309 leave the script silent-SKIP'd
# forever (= fake green). Live authority is the thin-delegate audit already
# retargeted in wave966:
#   compiler/scripts/audit_parser_thin_delegate.py
#   → runtime_pipeline_abi.x asm_parser_func_is_thin_delegate /
#     asm_parser_m8_tail_thin_delegate_c_name
#
# Usage: ./tests/run-parser-safe-helper-len-gate.sh
# PLATFORM: SHARED archaeology honesty (invoked by run-parser-second-pass-gate).
set -e
cd "$(dirname "$0")/.."

AUDIT="compiler/scripts/audit_parser_thin_delegate.py"
if [ ! -f "$AUDIT" ]; then
  echo "parser-safe-helper-len-gate FAIL: missing live audit $AUDIT" >&2
  exit 1
fi

# Honesty: deleted mega shell must stay deleted.
if [ -f compiler/ast_pool.c ]; then
  echo "parser-safe-helper-len-gate FAIL: compiler/ast_pool.c resurrected (wave309 left)" >&2
  exit 1
fi

echo "=== parser-safe-helper-len: live thin-delegate audit ==="
python3 "$AUDIT"
echo "parser-safe-helper-len-gate OK"
