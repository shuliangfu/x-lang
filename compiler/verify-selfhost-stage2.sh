#!/bin/sh
# verify-selfhost-stage2.sh — 用 shux-sx 编译自身，验证 Stage2 SX（完全自举 = D+E+F，见 SELFHOST.md）
set -e
cd "$(dirname "$0")"

# Step 0：重链 shux-sx；若无 driver_sx.o 等则先 bootstrap-driver-seed
echo ""
echo "── Step 0: 确保 shux-sx ──"
if [ ! -x ./shux-sx ]; then
  if ! ${MAKE:-make} shux-sx; then
    echo "  make shux-sx 失败，执行 bootstrap-driver-seed …"
    ${MAKE:-make} bootstrap-driver-seed
  fi
fi

echo "============================================"
echo " Shux Stage2 SX 验证 (Stage 2)"
echo " 种子: GEN=shux-sx 生成 _gen2.c（-sx -E -E-extern），链接 shux-sx2；对比两代编译 hello 的退出码"
echo "============================================"

# GEN 使用 shux-sx：-sx -E 经 driver_run_sx_emit_c_extern_via_cparser 与 C 路径 -E-extern 对齐（parse/typeck/codegen）。
SX=./shux-sx
GEN=$SX

# ── Step 1: 生成所有 _gen2.c ──
echo ""
echo "── Step 1: 生成 _gen2.c (GEN=$GEN) ──"
echo "  token..."
$GEN -sx -E -L src/lexer -E-extern src/lexer/token.sx > token_gen2.c
echo "  ast..."
$GEN -sx -E -E-extern src/ast/ast.sx > ast_gen2.c
echo "  lexer..."
$GEN -sx -E -L src/lexer -E-extern src/lexer/lexer.sx > lexer_gen2.c
echo "  parser..."
$GEN -sx -E -L .. -L src/lexer -L src/ast -E-extern src/parser/parser.sx > parser_gen2.c
echo "  typeck..."
$GEN -sx -E -L .. -L src/lexer -L src/ast -E-extern src/typeck/typeck.sx > typeck_gen2.c
echo "  codegen..."
$GEN -sx -E -L .. -L src/lexer -L src/ast -L src/parser -L src/typeck -E-extern src/codegen/codegen.sx > codegen_gen2.c
echo "  preprocess..."
$GEN -sx -E -L src/lexer -E-extern src/preprocess/preprocess.sx > preprocess_gen2.c
echo "  pipeline..."
$GEN -sx -E -L .. -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/asm -E-extern src/pipeline/pipeline.sx > pipeline_gen2.c
echo "  driver (main.sx)..."
$GEN -sx -E -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -E-extern src/main.sx > driver_gen2.c

# ── Step 2: 去重结构体 ──
echo ""
echo "── Step 2: 修复 pipeline_gen2.c / 去重 slice 结构体 ──"
for f in parser_gen2.c typeck_gen2.c codegen_gen2.c pipeline_gen2.c driver_gen2.c preprocess_gen2.c; do
  perl -i -ne 'print unless /^struct shux_slice_uint8_t/ && $seen++' "$f" 2>/dev/null || true
done
for f in ast_gen2.c lexer_gen2.c parser_gen2.c typeck_gen2.c codegen_gen2.c pipeline_gen2.c driver_gen2.c; do
  perl scripts/fix_slim_arena_gen_c.pl "$f" 2>/dev/null || true
done
perl scripts/fix_parser_pool_access_gen_c.pl parser_gen2.c 2>/dev/null || true
perl scripts/fix_driver_gen_duplicate_main.pl driver_gen2.c 2>/dev/null || true
perl scripts/fix_pipeline_extern_gen_c.pl pipeline_gen2.c 2>/dev/null || true
# pipeline 须 #include pipeline_glue.c（ast_pool / preprocess_if_stack / platform 符号）；与 ast_sx2 重复项改链 seed 的 ast_sx.o。
perl scripts/hoist_pipeline_prototypes.pl pipeline_gen2.c 2>/dev/null || true
perl scripts/fix_slim_arena_gen_c.pl pipeline_gen2.c 2>/dev/null || true
perl -i -ne 'print unless /^extern.*parser_parse_into_buf/' pipeline_gen2.c 2>/dev/null || true
perl -i -0777 -pe 's/(struct parser_ParseIntoResult \{ int32_t ok; int32_t main_idx; \};\n)/$1extern struct parser_ParseIntoResult parser_parse_into_buf(struct ast_ASTArena *, struct ast_Module *, uint8_t *, int32_t);\n/s unless /parser_parse_into_buf\(struct ast_ASTArena \*, struct ast_Module \*, uint8_t \*, int32_t\)/' pipeline_gen2.c 2>/dev/null || true

# ── Step 3: 编译 _sx2.o ──
CFLAGS="-fno-stack-protector -Wall -Wextra -I. -Iinclude -Isrc -w"
echo ""
echo "── Step 3: 编译 _sx2.o ──"
cc $CFLAGS -c token_gen2.c    -o token_sx2.o
cc $CFLAGS -c ast_gen2.c      -o ast_sx2.o
cc $CFLAGS -c lexer_gen2.c    -o lexer_sx2.o
cc $CFLAGS -include ast.h -c parser_gen2.c -o parser_sx2.o
cc $CFLAGS -c typeck_gen2.c   -o typeck_sx2.o
cc $CFLAGS -c codegen_gen2.c  -o codegen_sx2.o
cc $CFLAGS -c preprocess_gen2.c -o preprocess_sx2.o
cc $CFLAGS -c pipeline_gen2.c -o pipeline_sx2.o

echo ""
echo "── 编译 C 侧与 seed 桥（与 bootstrap-driver-seed 同拓扑）──"
${MAKE:-make} -q build-seed-asm-host 2>/dev/null || ${MAKE:-make} build-seed-asm-host
cc $CFLAGS -c src/ast_pool_l5_bridge.c -o src/ast_pool_l5_bridge.o
cc $CFLAGS -DSX_VERIFY_STAGE2 -c src/sx_seed_bridge.c -o src/sx_seed_bridge_stage2.o
cc $CFLAGS -c typeck_sx_link_alias.c -o typeck_sx_link_alias.o
cc $CFLAGS -c codegen_sx_link_alias.c -o codegen_sx_link_alias.o
cc $CFLAGS -c lexer_sx_link_alias.c -o lexer_sx_link_alias.o 2>/dev/null || true
# runtime_driver（与 shux-sx 相同宏，供 driver_run_compiler_full_sx）
cc $CFLAGS -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -DSHUX_USE_SX_TYPECK -DSHUX_USE_SX_CODEGEN -DSHUX_USE_SX_PREPROCESS \
  -c src/runtime.c -o runtime_driver2.o

# ── Step 4: 链接 shux-sx2（*_sx2.o 替代 parser_sx/typeck_sx/codegen_sx/pipeline_sx；其余与 bootstrap-driver-seed 同拓扑）──
echo ""
echo "── Step 4: 链接 shux-sx2 ──"
for _o in driver_sx.o driver_compile_sx.o driver_fmt_sx.o driver_check_sx.o driver_test_sx.o \
  driver_build_sx.o driver_run_sx.o driver_emit_sx.o preprocess_sx.o lsp_sx.o lsp_diag_sx.o lsp_io_sx.o lsp_io_std_heap_sx.o \
  pipeline_bootstrap_orchestration.o src/async/async_liveness.o src/async/async_cps_codegen.o; do
  if [ ! -f "$_o" ]; then ${MAKE:-make} shux-sx bootstrap-driver-seed 2>/dev/null || ${MAKE:-make} shux-sx; break; fi
done
cc -fno-stack-protector -Wall -Wextra -I. -Iinclude -Isrc -w \
  -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -DSHUX_USE_SX_TYPECK -DSHUX_USE_SX_CODEGEN \
  -o shux-sx2 \
  src/main_driver.o runtime_driver2.o src/driver/fmt_check_cmd_driver.o src/driver/target_cpu.o \
  src/asm/simd_enc.o src/asm/simd_loop.o src/preprocess_for_driver.o \
  src/lexer/lexer.o src/ast/ast_seed.o src/parser/parser.o src/typeck/typeck.o src/codegen/codegen.o \
  src/async/async_liveness.o src/async/async_cps_codegen.o \
  src/sx_seed_bridge_stage2.o src/std_fs_shim.o src/ast_pool_l5_bridge.o \
  token_sx2.o ast_sx2.o lexer_sx2.o parser_sx2.o typeck_sx2.o codegen_sx2.o preprocess_sx2.o pipeline_sx2.o \
  lexer_sx_link_alias.o typeck_sx_link_alias.o codegen_sx_link_alias.o \
  pipeline_bootstrap_orchestration.o \
  driver_sx.o \
  driver_fmt_sx.o driver_check_sx.o driver_test_sx.o driver_compile_sx.o driver_build_sx.o driver_run_sx.o driver_emit_sx.o \
  src/lsp/lsp_codegen_extern.o src/lsp/lsp_diag.o src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o \
  src/lsp/lsp_diag_sx_alias.o src/lsp/lsp_state.o \
  lsp_sx.o lsp_diag_sx.o lsp_io_sx.o lsp_io_std_heap_sx.o \
  _stubs_driver.o \
  build_asm/seed_host/asm_backend_partial.o src/asm/user_asm_seed_bridge.o src/asm/asm_backend_compat_stubs.o \
  src/asm/backend_enc_dispatch.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o \
  src/asm/backend_call_dispatch.o src/asm/pipeline_abi_f32_xmm.o parser_asm_thin_glue.o parser_asm_link_alias.o

echo "shux-sx2 linked: $(ls -lh shux-sx2 | awk '{print $5}')"

# ── Step 5: 功能对比 ──
echo ""
echo "── Step 5: 功能对比 ──"
echo 'function main(): i32 { return 42; }' > /tmp/selfhost_test.sx
# 与 run-hello 一致：-L .. 链 std；非 x86_64 上 shux-sx -o 可能失败，参照改 shux-c。
GEN_FLAGS="-L .."
REF=$SX

echo "参照编译 ($REF):"
$REF $GEN_FLAGS /tmp/selfhost_test.sx -o /tmp/selfhost_a 2>&1 || true
if [ ! -x /tmp/selfhost_a ] && [ -x ./shux-c ]; then
  echo "  (shux-sx -o 未产出，非 x86_64 等环境改 shux-c 作参照)"
  REF=./shux-c
  $REF $GEN_FLAGS /tmp/selfhost_test.sx -o /tmp/selfhost_a 2>&1 || true
fi
chmod +x /tmp/selfhost_a 2>/dev/null || true
set +e
/tmp/selfhost_a >/dev/null 2>&1
r1=$?
set -e

echo "shux-sx2 编译:"
./shux-sx2 $GEN_FLAGS /tmp/selfhost_test.sx -o /tmp/selfhost_b 2>&1 || true
chmod +x /tmp/selfhost_b 2>/dev/null || true
set +e
/tmp/selfhost_b >/dev/null 2>&1
r2=$?
set -e

echo ""
echo "参照 ($REF) 返回值: $r1"
echo "shux-sx2 返回值: $r2"

if [ "$r1" = "42" ] && [ "$r2" = "42" ]; then
    echo ""
    echo "============================================"
    echo " ✓ Stage2 SX 验证通过!"
    echo "   shux-sx  ($(ls -lh shux-sx  | awk '{print $5}'))"
    echo "   shux-sx2 ($(ls -lh shux-sx2 | awk '{print $5}'))"
    echo "   两代编译器行为一致 (exit 42)"
    echo "============================================"
else
    echo "✗ 自举验证失败! r1=$r1 r2=$r2"
    exit 1
fi
