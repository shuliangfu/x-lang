#!/bin/sh
# run_shu_asm_smoke.sh — shu_asm 烟囱测试（不覆盖 ./shu）
# 用法：cd compiler && ./scripts/run_shu_asm_smoke.sh
# 要求：./shu_asm 已由 build_shu_asm.sh 产出。
# Darwin：gen_driver/experimental bootstrap 的 shu_asm 用户态 -o 默认 asm 链 Mach-O 不完整会 SIGILL；
#         compile+run 走 -backend c，另做 asm 仅编译检查（与 S2 EMIT_HEAVY 仅 Linux x86_64 实跑对齐）。

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

# 烟测 compile+run 后端：Linux 默认 asm；Darwin 用 c（可 SHU_ASM_SMOKE_BACKEND=asm|c 覆盖）。
SMOKE_RUN_BACKEND="${SHU_ASM_SMOKE_BACKEND:-}"
DARWIN_ASM_COMPILE_CHECK=0
if [ -z "$SMOKE_RUN_BACKEND" ]; then
  case "$(uname -s 2>/dev/null)" in
    Darwin)
      SMOKE_RUN_BACKEND="c"
      DARWIN_ASM_COMPILE_CHECK=1
      ;;
    *)
      SMOKE_RUN_BACKEND="asm"
      ;;
  esac
fi

SMOKE_BACKEND_ARGS=""
if [ "$SMOKE_RUN_BACKEND" = "c" ]; then
  SMOKE_BACKEND_ARGS="-backend c"
elif [ "$SMOKE_RUN_BACKEND" = "asm" ]; then
  SMOKE_BACKEND_ARGS="-backend asm"
fi

echo "run_shu_asm_smoke: compile+run return-value (expect exit 42, backend=${SMOKE_RUN_BACKEND}) ..."
OUT="/tmp/shu_asm_rv_out"
rm -f "$OUT" "$OUT.c" "$OUT.o"
set +e
# shellcheck disable=SC2086
./shu_asm $SMOKE_BACKEND_ARGS "$RV" -o "$OUT"
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

# Darwin：额外验证 asm 路径能编译（不执行，避免 SIGILL）。
if [ "$DARWIN_ASM_COMPILE_CHECK" = 1 ]; then
  ASM_OUT="/tmp/shu_asm_rv_asm_out"
  rm -f "$ASM_OUT" "$ASM_OUT.c" "$ASM_OUT.o"
  echo "run_shu_asm_smoke: Darwin asm compile-only (no run; Mach-O user exe N/A on gen_driver hybrid) ..."
  if ! ./shu_asm -backend asm "$RV" -o "$ASM_OUT"; then
    echo "run_shu_asm_smoke: Darwin asm compile failed"
    exit 1
  fi
  echo "run_shu_asm_smoke: Darwin asm compile OK"
fi

echo "run_shu_asm_smoke: OK"

# B-strict 用户 import 子集（-o 链 exe；比 bootstrap 全量 gate 少 option 等待 struct 按值对齐）
ASM_GATE="../tests/run-shu-asm-gate.sh"
if [ -f "$ASM_GATE" ] && [ -z "${SHU_ASM_SMOKE_SKIP_GATE:-}" ]; then
  echo "run_shu_asm_smoke: shu_asm gate (hello/import + while/typeck) ..."
  (cd .. && SHU=./compiler/shu_asm ./tests/run-shu-asm-gate.sh)
fi

echo "run_shu_asm_smoke: all smoke passed"
