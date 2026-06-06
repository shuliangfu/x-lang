#!/bin/sh
# run_shu_asm_smoke.sh — shu_asm 烟囱测试（不覆盖 ./shu）
# 用法：cd compiler && ./scripts/run_shu_asm_smoke.sh
# 要求：./shu_asm 已由 build_shu_asm.sh 产出。

set -e
cd "$(dirname "$0")/.."

# main.su EMIT_HEAVY + asm pipeline 深递归；默认 8MB 栈会导致 compile/SIGSEGV（与 build_shu_asm ulimit 对齐）。
ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || ulimit -s hard 2>/dev/null || true

if [ ! -x ./shu_asm ]; then
  echo "run_shu_asm_smoke: ./shu_asm missing (run SHU=./shu ./scripts/build_shu_asm.sh first)"
  exit 1
fi

RV="../tests/return-value/main.su"
if [ ! -f "$RV" ]; then
  echo "run_shu_asm_smoke: $RV missing"
  exit 1
fi

echo "run_shu_asm_smoke: compile+run return-value (expect exit 42) ..."
OUT="/tmp/shu_asm_rv_out"
rm -f "$OUT" "$OUT.c" "$OUT.o"
set +e
./shu_asm "$RV" -o "$OUT"
RC=$?
set -e
if [ "$RC" -ne 0 ]; then
  echo "run_shu_asm_smoke: compile failed (rc=$RC)"
  exit 1
fi
if [ -x "$OUT" ]; then
  set +e
  "$OUT"
  RC=$?
  set -e
elif [ -f "${OUT}.c" ]; then
  cc -std=gnu11 -o "$OUT" "${OUT}.c" 2>/dev/null || cc -std=gnu11 -o "$OUT" "$OUT" 2>/dev/null || true
  if [ -x "$OUT" ]; then
    set +e
    "$OUT"
    RC=$?
    set -e
  else
    echo "run_shu_asm_smoke: no executable from -o $OUT"
    exit 1
  fi
else
  echo "run_shu_asm_smoke: -o produced neither binary nor .c"
  exit 1
fi
if [ "$RC" -ne 42 ]; then
  echo "run_shu_asm_smoke: FAIL (exit $RC, expected 42)"
  exit 1
fi
echo "run_shu_asm_smoke: OK"

# B-strict 用户 import 子集（-o 链 exe；比 bootstrap 全量 gate 少 option 等待 struct 按值对齐）
ASM_GATE="../tests/run-shu-asm-gate.sh"
if [ -f "$ASM_GATE" ] && [ -z "${SHU_ASM_SMOKE_SKIP_GATE:-}" ]; then
  echo "run_shu_asm_smoke: shu_asm gate (hello/import + while/typeck) ..."
  (cd .. && SHU=./compiler/shu_asm ./tests/run-shu-asm-gate.sh)
fi

echo "run_shu_asm_smoke: all smoke passed"
