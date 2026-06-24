#!/usr/bin/env bash
# B-06：AST Arena / ast_pool 边界 — run-pool-limits + ast_pool 符号存在。
#
# 用法：./tests/run-b06-ast-pool-gate.sh
set -e
cd "$(dirname "$0")/.."

echo "=== B-06: ast_pool / pool limits ==="
for f in compiler/ast_pool.c tests/run-pool-limits.sh; do
  [ -f "$f" ] || { echo "b06 gate FAIL: missing $f" >&2; exit 1; }
done
grep -q 'ast_pool' compiler/src/parser/parser.sx || grep -q 'ast_pool' compiler/src/pipeline/pipeline.sx || {
  echo "b06 gate FAIL: .sx pipeline missing ast_pool ref" >&2
  exit 1
}
chmod +x tests/run-pool-limits.sh
SHUX="${SHUX:-./compiler/shux-c}"
[ -x "$SHUX" ] || SHUX=./compiler/shux
if [ -x "$SHUX" ] && "$SHUX" --version >/dev/null 2>&1; then
  SHUX="$SHUX" tests/run-pool-limits.sh
else
  echo "b06 gate SKIP pool-limits (no runnable shux on this host)"
fi
echo "b06 ast-pool gate OK"
