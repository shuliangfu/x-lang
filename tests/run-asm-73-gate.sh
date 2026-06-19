#!/usr/bin/env bash
# asm 计算：8× binop + vector-var + call-inline（与 run-pre-push-p0 / bstrict-ci 一致）。
# 用法：SHUX=./compiler/shux_asm ./tests/run-asm-73-gate.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/ensure-compiler-seed.sh
source "$(dirname "$0")/lib/ensure-compiler-seed.sh"
export SHUX="${SHUX:-./compiler/shux_asm}"
if [ ! -x "$SHUX" ]; then
  echo "run-asm-73-gate: missing $SHUX" >&2
  exit 1
fi

scripts=(
  run-asm-binop-var.sh
  run-asm-binop-block-var.sh
  run-asm-binop-stack-spill.sh
  run-asm-binop-cfg-merge.sh
  run-asm-binop-field-index.sh
  run-asm-binop-nested-var.sh
  run-asm-binop-index-lit.sh
  run-asm-binop-div-index.sh
  run-asm-vector-var.sh
  run-asm-call-inline.sh
)

for s in "${scripts[@]}"; do
  echo "=== asm compute: $s ==="
  SHUX="$SHUX" "./tests/$s"
done

echo "asm compute gate OK (${#scripts[@]} scripts: 8× binop + vector-var + call-inline)"
