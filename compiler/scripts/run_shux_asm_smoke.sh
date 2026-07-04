#!/bin/sh
# run_shux_asm_smoke.sh — shux_asm 烟囱测试（不覆盖 ./shux）
# 用法：cd compiler && ./scripts/run_shux_asm_smoke.sh
# 要求：./shux_asm 已由 build_shux_asm.sh 产出。
# Darwin：gen_driver/experimental bootstrap 的 shux_asm 用户态 -o 默认 asm 链 Mach-O 不完整会 SIGILL；
#         compile+run 走 -backend c；完整 shux_asm gate 由 native linux job 覆盖。

set -e
cd "$(dirname "$0")/.."

# main.x EMIT_HEAVY + asm pipeline 深递归；默认 8MB 栈会导致 compile/SIGSEGV（与 build_shux_asm ulimit 对齐）。
ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || ulimit -s hard 2>/dev/null || true

if [ ! -x ./shux_asm ]; then
  echo "run_shux_asm_smoke: ./shux_asm missing (run SHUX=./shux ./scripts/build_shux_asm.sh first)"
  exit 1
fi

RV="../tests/return-value/main.x"
if [ ! -f "$RV" ]; then
  echo "run_shux_asm_smoke: $RV missing"
  exit 1
fi

# 烟测 compile+run 后端：Linux x86_64 默认 asm；Darwin / Linux ARM64 用 c（asm 链 EM:62 或 Mach-O 不完整）。
SMOKE_RUN_BACKEND="${SHUX_ASM_SMOKE_BACKEND:-}"
if [ -z "$SMOKE_RUN_BACKEND" ]; then
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-*|Linux-aarch64|Linux-arm64)
      SMOKE_RUN_BACKEND="c"
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

echo "run_shux_asm_smoke: compile+run return-value (expect exit 42, backend=${SMOKE_RUN_BACKEND}) ..."
OUT="/tmp/shux_asm_rv_out"
rm -f "$OUT" "$OUT.c" "$OUT.o"
set +e
# shellcheck disable=SC2086
./shux_asm $SMOKE_BACKEND_ARGS "$RV" -o "$OUT"
RC=$?
set -e
if [ "$RC" -ne 0 ]; then
  echo "run_shux_asm_smoke: compile failed (rc=$RC)"
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
    echo "run_shux_asm_smoke: no executable from -o $OUT"
    exit 1
  fi
else
  echo "run_shux_asm_smoke: -o produced neither binary nor .c"
  exit 1
fi
if [ "$RC" -ne 42 ]; then
  echo "run_shux_asm_smoke: FAIL (exit $RC, expected 42)"
  exit 1
fi

echo "run_shux_asm_smoke: OK"

# B-strict 用户 import 子集（-o 链 exe；比 bootstrap 全量 gate 少 option 等待 struct 按值对齐）
ASM_GATE="../tests/run-shux-asm-gate.sh"
if [ -f "$ASM_GATE" ] && [ -z "${SHUX_ASM_SMOKE_SKIP_GATE:-}" ]; then
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-*)
      echo "run_shux_asm_smoke: skip shux_asm gate on Darwin (asm -o __TEXT N/A; linux job covers full gate)"
      ;;
    Linux-aarch64|Linux-arm64)
      echo "run_shux_asm_smoke: skip shux_asm gate on Linux ARM64 (refresh shux_asm asm stub; x86_64 covers)"
      ;;
    *)
      echo "run_shux_asm_smoke: shux_asm gate (hello/import + while/typeck) ..."
      (cd .. && SHUX=./compiler/shux_asm ./tests/run-shux-asm-gate.sh)
      ;;
  esac
fi

echo "run_shux_asm_smoke: all smoke passed"
