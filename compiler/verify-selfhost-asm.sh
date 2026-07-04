#!/bin/sh
# verify-selfhost-asm.sh — asm 构建质量与 shux_asm 烟囱测试（零 cc 路线验收辅助）
# 用法：cd compiler && ./verify-selfhost-asm.sh
# 要求：./shux 已存在（make bootstrap-driver-seed）；不替代 make bootstrap-verify（语义自举仍以 shux-x 为准）。

set -e
cd "$(dirname "$0")"

echo "============================================"
echo " Shux asm 自举质量验证"
echo "============================================"

if [ ! -x ./shux ]; then
  echo "verify-selfhost-asm: ./shux missing, run: make bootstrap-driver-seed"
  exit 1
fi

echo ""
echo "── Step 1: build_asm + __text 质量 ──"
SHUX=./shux SHUX_ASM_QUALITY_STRICT=1 ./scripts/build_shux_asm.sh || {
  echo "verify-selfhost-asm: build_shux_asm failed (strict __text)"
  exit 1
}

if [ ! -x ./shux_asm ]; then
  echo "verify-selfhost-asm: shux_asm not produced"
  exit 1
fi

echo ""
echo "── Step 2: shux_asm 编译 smoke（return-value）──"
RV=../tests/return-value/main.x
if [ -f "$RV" ]; then
  set +e
  ./shux_asm -backend asm -o /tmp/shux_asm_rv.o "$RV"
  RC=$?
  set -e
  if [ "$RC" -ne 0 ]; then
    echo "verify-selfhost-asm: shux_asm compile $RV failed (rc=$RC)"
    exit 1
  fi
  echo "verify-selfhost-asm: shux_asm smoke OK"
else
  echo "verify-selfhost-asm: skip smoke ($RV missing)"
fi

echo ""
echo "verify-selfhost-asm: PASS (asm quality + shux_asm smoke)"
echo "Note: full zero-cc (no cc -c pipeline_gen) needs SHUX_ASM_LINK_TOPOLOGY=full_asm and all __text non-empty."
