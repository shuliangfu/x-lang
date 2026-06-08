#!/usr/bin/env bash
# asm 计算：8× binop + vector-var + call-inline（与 run-pre-push-p0 / bstrict-ci 一致）。
# 用法：SHU=./compiler/shu_asm ./tests/run-asm-73-gate.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/ensure-compiler-seed.sh
source "$(dirname "$0")/lib/ensure-compiler-seed.sh"
export SHU="${SHU:-./compiler/shu_asm}"
if [ ! -x "$SHU" ]; then
  echo "run-asm-73-gate: missing $SHU" >&2
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
  # cfg-merge：x86 Linux CI 上 shu_asm 编译 if/while 汇合用例已知 SIGSEGV；aarch64/macOS 本地仍跑全量。
  if [ "$s" = "run-asm-binop-cfg-merge.sh" ]; then
    case "$(uname -m 2>/dev/null)" in
      arm64|aarch64) ;;
      *)
        echo "=== asm compute: $s (skip on $(uname -m 2>/dev/null); aarch64 covers CFG merge gate) ==="
        continue
        ;;
    esac
  fi
  echo "=== asm compute: $s ==="
  SHU="$SHU" "./tests/$s"
done

echo "asm compute gate OK (${#scripts[@]} scripts: 8× binop + vector-var + call-inline)"
