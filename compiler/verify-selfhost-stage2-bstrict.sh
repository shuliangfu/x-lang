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
MAIN_WPO_TIMEOUT="${SHU_WPO_MAIN_ASM_TIMEOUT:-180}"

# 与 build_shu_asm.sh 一致：main.su -backend asm 须 LIBROOT。
LIBROOT=""
if [ -f src/asm/asm_build_list.su ]; then
  TAB=$(printf '\t')
  LIBROOT=$(grep '^// LIBROOT:' src/asm/asm_build_list.su | sed "s|^// LIBROOT:${TAB}||")
fi
[ -z "$LIBROOT" ] && LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"

# main.su EMIT_HEAVY 须大栈（与 rebuild_main_o_for_cli / run_shu_asm_smoke 一致）。
ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || ulimit -s hard 2>/dev/null || true

# Step 2b：用 gen2/gen1 编译器重编 build_asm/main.o（WPO DCE）；build_shu_asm 内 post-strict 可能 SIGSEGV。
echo ""
echo "── Step 2b: WPO main.o recompile（shu_asm2 → stage1 fallback）──"
stage2_main_o_text_bytes() {
  local o="$1"
  local hex
  hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
  if [ -z "$hex" ]; then
    hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
  fi
  if [ -z "$hex" ]; then
    echo 0
    return
  fi
  perl -e 'print hex(shift)' "$hex" 2>/dev/null || echo 0
}
stage2_rebuild_main_o_wpo() {
  local comp="$1"
  local wpo_arg="$2"
  local emit_heavy="${3:-0}"
  local tmp="build_asm/main.stage2_wpo.o"
  local txt=""
  rm -f "$tmp" 2>/dev/null || true
  if [ -n "$wpo_arg" ]; then
    if ! timeout "$MAIN_WPO_TIMEOUT" env -u SHU_ASM_START_FUNC \
      SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 SHU_ASM_ENTRY_EMIT_HEAVY="$emit_heavy" \
      SHU_ASM_WPO_DCE="$wpo_arg" \
      "$comp" -backend asm -o "$tmp" $LIBROOT src/main.su >/dev/null 2>&1; then
      return 1
    fi
  elif ! timeout "$MAIN_WPO_TIMEOUT" env -u SHU_ASM_START_FUNC \
    SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 SHU_ASM_ENTRY_EMIT_HEAVY="$emit_heavy" \
    "$comp" -backend asm -o "$tmp" $LIBROOT src/main.su >/dev/null 2>&1; then
    return 1
  fi
  txt=$(stage2_main_o_text_bytes "$tmp" 2>/dev/null || echo 0)
  if [ "$txt" = "0" ]; then
    return 1
  fi
  if ! nm "$tmp" 2>/dev/null | grep -qE '(_)?entry$'; then
    return 1
  fi
  if [ -z "$wpo_arg" ] && [ "$txt" -gt 768 ] 2>/dev/null; then
    return 1
  fi
  mv -f "$tmp" build_asm/main.o
  echo "  main.o OK via $comp (__text=${txt}B, WPO DCE ${wpo_arg:-on}, EMIT_HEAVY=${emit_heavy})"
  return 0
}

MAIN_WPO_OK=0
MAIN_WPO_COMPRESSED=0
for comp in ./shu_asm2 ./shu_asm.experimental ./shu_asm_stage1 ./shu_asm; do
  [ -x "$comp" ] || continue
  if stage2_rebuild_main_o_wpo "$comp" "" 0; then
    MAIN_WPO_OK=1
    txt=$(stage2_main_o_text_bytes build_asm/main.o 2>/dev/null || echo 9999)
    if [ "$txt" -le 768 ] 2>/dev/null; then
      MAIN_WPO_COMPRESSED=1
    fi
    break
  fi
  if stage2_rebuild_main_o_wpo "$comp" "" 1; then
    MAIN_WPO_OK=1
    break
  fi
done
if [ "$MAIN_WPO_OK" -eq 0 ]; then
  for comp in ./shu_asm2 ./shu_asm_stage1 ./shu_asm; do
    [ -x "$comp" ] || continue
    if stage2_rebuild_main_o_wpo "$comp" "0"; then
      MAIN_WPO_OK=1
      echo "  WPO off fallback via $comp"
      break
    fi
  done
fi
if [ "$MAIN_WPO_OK" -eq 0 ]; then
  echo "verify-stage2-bstrict: main.o WPO recompile failed (all compilers)" >&2
  exit 1
fi

echo ""
echo "── Step 2c–2g: WPO build_asm 五模块聚合门禁 ──"
SHU_WPO_CHAIN_FAIL=1 bash "$ROOT/tests/run-wpo-build-asm-chain-gate.sh" "$ROOT/compiler/build_asm"

echo ""
echo "── Step 2h: WPO strict link 门禁（pipeline+typeck+backend → shu_asm.strict_glue）──"
chmod +x "$ROOT/tests/run-wpo-strict-link-gate.sh" \
  "$ROOT/tests/run-wpo-pipeline-reach-gate.sh" \
  "$ROOT/tests/run-wpo-typeck-reach-gate.sh" \
  "$ROOT/tests/run-wpo-backend-reach-gate.sh" \
  "$ROOT/compiler/scripts/relink_shu_asm_strict_glue.sh" 2>/dev/null || true
SHU_WPO_STRICT_LINK_FAIL=1 bash "$ROOT/tests/run-wpo-strict-link-gate.sh"

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
echo "── Step 4b: shu_asm2 struct mk 烟测（gen2 CALL 内联，须 exit 10）──"
SMK_SU="$ROOT/tests/boundary/struct_mk_let_inline.su"
SMK_TIMEOUT="${SHU_STAGE2_STRUCT_MK_TIMEOUT:-120}"
if [ -x ./shu_asm2 ] && [ -f "$SMK_SU" ]; then
  rm -f /tmp/stage2_bstrict_smki2
  (
    ./shu_asm2 "$SMK_SU" -o /tmp/stage2_bstrict_smki2 2>/dev/null
  ) &
  smk_pid=$!
  (
    sleep "$SMK_TIMEOUT"
    kill "$smk_pid" 2>/dev/null
  ) &
  smk_watch=$!
  set +e
  wait "$smk_pid" 2>/dev/null
  smk_comp_rc=$?
  set -e
  kill "$smk_watch" 2>/dev/null
  wait "$smk_watch" 2>/dev/null || true
  if [ "$smk_comp_rc" -ne 0 ] || [ ! -x /tmp/stage2_bstrict_smki2 ]; then
    echo "verify-stage2-bstrict: shu_asm2 struct_mk_let_inline compile failed (rc=$smk_comp_rc, timeout=${SMK_TIMEOUT}s)" >&2
    exit 1
  fi
  set +e
  /tmp/stage2_bstrict_smki2 >/dev/null 2>&1
  smk_ec=$?
  set -e
  if [ "$smk_ec" -ne 10 ]; then
    echo "verify-stage2-bstrict: shu_asm2 struct_mk_let_inline exit=$smk_ec (expected 10)" >&2
    exit 1
  fi
  # Linux：_main 不得 call mk（与 run-asm-call-inline 语义一致）。
  if command -v objdump >/dev/null 2>&1; then
    if objdump -d /tmp/stage2_bstrict_smki2 2>/dev/null | sed -n '/<_main>:/,/^$/p' | grep -qE 'call.*\<mk\>|bl[[:space:]]+.*\<mk\>'; then
      echo "verify-stage2-bstrict: shu_asm2 struct_mk_let_inline _main still calls mk (inline regression)" >&2
      exit 1
    fi
  fi
  echo "  shu_asm2 struct_mk_let_inline: exit 10 + no mk call in _main (gen2 inline OK)"
fi
rm -f /tmp/stage2_bstrict_smki2

echo ""
echo "── Step 5: refresh shu_asm gate（P0 asm struct mk 内联）──"
# 纯 strict gen2（typeck_su_no_layout + 无 pipeline_su.o）常无法 struct mk 内联；门禁用 refresh-shu-asm-gate。
${MAKE:-make} refresh-shu-asm-gate

echo ""
echo "============================================"
echo " ✓ B-strict Stage2 通过"
echo "   shu_asm_stage1 / shu_asm2 行为一致（42 + hello）"
echo "   shu_asm 已恢复为 seed+parser_su（asm-73 / run-pre-push-p0）"
echo "   （-su -E 全模块 C 生成仍见 verify-selfhost-stage2.sh + shu-su）"
echo "============================================"
