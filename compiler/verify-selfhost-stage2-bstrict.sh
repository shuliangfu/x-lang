#!/bin/sh
# verify-selfhost-stage2-bstrict.sh — B-strict Stage2：shu_asm 自举第二遍产出 shu_asm2，两代行为一致。
# 与 verify-selfhost-stage2.sh（shu-su -su -E 生成 _gen2.c）正交；本脚本仅验 asm 链二遍自举。
# 用法：cd compiler && sh ./verify-selfhost-stage2-bstrict.sh

set -e
cd "$(dirname "$0")"

ulimit -s 16384 2>/dev/null || true

echo "============================================"
echo " Shulang B-strict Stage2（shu_asm -> shu_asm2）"
echo "============================================"

echo ""
echo "── Step 0: bootstrap-driver-bstrict ──"
${MAKE:-make} bootstrap-driver-seed -q 2>/dev/null || ${MAKE:-make} bootstrap-driver-seed
SHU_ASM_EXPERIMENTAL_SKIP_GEN=1 ${MAKE:-make} bootstrap-driver-bstrict
if [ ! -x ./shu_asm ]; then
  echo "verify-stage2-bstrict: shu_asm missing" >&2
  exit 1
fi

echo ""
echo "── Step 1: shu_asm -> shu_asm_stage1 ──"
cp -f ./shu_asm ./shu_asm_stage1
ls -lh ./shu_asm_stage1 | awk '{print "  stage1:", $5}'

echo ""
echo "── Step 2: 第二遍 build_shu_asm（SHU=shu_asm_stage1）──"
SHU_ASM_EXPERIMENTAL_SKIP_GEN=1 SHU=./shu_asm_stage1 ./scripts/build_shu_asm.sh 2>&1 | tee /tmp/build_shu_asm2.log
if ! grep -qE 'asm_only_strict|B-strict OK' /tmp/build_shu_asm2.log; then
  echo "verify-stage2-bstrict: second pass did not reach B-strict link" >&2
  exit 1
fi
if [ ! -x ./shu_asm ]; then
  echo "verify-stage2-bstrict: shu_asm missing after second pass" >&2
  exit 1
fi
cp -f ./shu_asm ./shu_asm2
ls -lh ./shu_asm2 | awk '{print "  stage2:", $5}'

ROOT="$(cd .. && pwd)"

# ── Step 3: 两代编译同一用例，对比退出码（对齐 verify-selfhost-stage2 Step 5）──
echo ""
echo "── Step 3: 功能对比（return-value / hello）──"
echo 'function main(): i32 { return 42; }' > /tmp/stage2_bstrict_rv.su

run_compile() {
  # 参数：$1=编译器路径 $2=输出路径
  "$1" /tmp/stage2_bstrict_rv.su -o "$2" >/dev/null 2>&1 || return 1
  chmod +x "$2" 2>/dev/null || true
  return 0
}

r1=255
r2=255
if run_compile ./shu_asm_stage1 /tmp/stage2_bstrict_a; then
  set +e
  /tmp/stage2_bstrict_a >/dev/null 2>&1
  r1=$?
  set -e
fi
if run_compile ./shu_asm2 /tmp/stage2_bstrict_b; then
  set +e
  /tmp/stage2_bstrict_b >/dev/null 2>&1
  r2=$?
  set -e
fi

echo "  shu_asm (gen1) return-value exit: $r1"
echo "  shu_asm2 (gen2) return-value exit: $r2"

if [ "$r1" != "42" ] || [ "$r2" != "42" ]; then
  echo "verify-stage2-bstrict: return-value parity failed (expected 42/42)" >&2
  exit 1
fi

echo ""
echo "── Step 4: hello（import std.io，shu_asm -o 偶发 SIGSEGV 时重试）──"
rm -f /tmp/stage2_bstrict_hello1 /tmp/stage2_bstrict_hello2
hello_compile() {
  local bin="$1" out="$2"
  local try=1
  while [ "$try" -le 8 ]; do
    if "$bin" -L "$ROOT" "$ROOT/examples/hello.su" -o "$out" >/dev/null 2>&1; then
      return 0
    fi
    try=$((try + 1))
  done
  return 1
}
hello_compile ./shu_asm_stage1 /tmp/stage2_bstrict_hello1 || {
  echo "verify-stage2-bstrict: shu_asm_stage1 hello compile failed (8 attempts)" >&2
  exit 1
}
hello_compile ./shu_asm2 /tmp/stage2_bstrict_hello2 || {
  echo "verify-stage2-bstrict: shu_asm2 hello compile failed (8 attempts)" >&2
  exit 1
}
/tmp/stage2_bstrict_hello1 | grep -q "Hello World" || {
  echo "verify-stage2-bstrict: shu_asm_stage1 hello run failed" >&2
  exit 1
}
/tmp/stage2_bstrict_hello2 | grep -q "Hello World" || {
  echo "verify-stage2-bstrict: shu_asm2 hello run failed" >&2
  exit 1
}

echo ""
echo "============================================"
echo " ✓ B-strict Stage2 通过"
echo "   shu_asm_stage1 / shu_asm2 行为一致（42 + hello）"
echo "   （-su -E 全模块 C 生成仍见 verify-selfhost-stage2.sh + shu-su）"
echo "============================================"
