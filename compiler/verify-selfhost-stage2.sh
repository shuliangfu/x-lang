#!/bin/sh
# verify-selfhost-stage2.sh — 用 shux-x 编译自身，验证 Stage2 X（完全自举 = D+E+F，见 SELFHOST.md）
set -e
cd "$(dirname "$0")"

# Step 0：重链 shux-x；若无 driver_x.o 等则先 bootstrap-driver-seed
echo ""
echo "── Step 0: 确保 shux-x ──"
if [ ! -x ./shux-x ]; then
  if ! ${MAKE:-make} shux-x; then
    echo "  make shux-x 失败，执行 bootstrap-driver-seed …"
    ${MAKE:-make} bootstrap-driver-seed
  fi
fi

echo "============================================"
echo " Shux Stage2 X 验证 (Stage 2)"
echo " 种子: GEN=shux-x 生成 _gen2.c（-x -E -E-extern），链接 shux-x2；对比两代编译 hello 的退出码"
echo "============================================"

# GEN 使用 shux-x：-x -E 经 driver_run_x_emit_c_extern_via_cparser 与 C 路径 -E-extern 对齐（parse/typeck/codegen）。
X=./shux-x
GEN=$X

# ── Step 1: 生成所有 _gen2.c ──
echo ""
echo "── Step 1: 生成 _gen2.c (GEN=$GEN) ──"
echo "  token..."
$GEN -x -E -L src/lexer -E-extern src/lexer/token.x > token_gen2.c
echo "  ast..."
$GEN -x -E -E-extern src/ast/ast.x > ast_gen2.c
echo "  lexer..."
$GEN -x -E -L src/lexer -E-extern src/lexer/lexer.x > lexer_gen2.c
echo "  parser..."
$GEN -x -E -L .. -L src -L src/lexer -L src/ast -E-extern src/parser/parser.x > parser_gen2.c
echo "  typeck..."
$GEN -x -E -L .. -L src -L src/lexer -L src/ast -E-extern src/typeck/typeck.x > typeck_gen2.c
echo "  codegen..."
$GEN -x -E -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -E-extern src/codegen/codegen.x > codegen_gen2.c
echo "  preprocess..."
$GEN -x -E -L src/lexer -E-extern src/preprocess/preprocess.x > preprocess_gen2.c
echo "  pipeline..."
$GEN -x -E -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/asm -E-extern src/pipeline/pipeline.x > pipeline_gen2.c
echo "  driver (main.x)..."
$GEN -x -E -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -E-extern src/main.x > driver_gen2.c

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
# pipeline 须 #include pipeline_glue.c（ast_pool / preprocess_if_stack / platform 符号）；与 ast_x2 重复项改链 seed 的 ast_x.o。
perl scripts/hoist_pipeline_prototypes.pl pipeline_gen2.c 2>/dev/null || true
perl scripts/fix_slim_arena_gen_c.pl pipeline_gen2.c 2>/dev/null || true
perl -i -ne 'print unless /^extern.*parser_parse_into_buf/' pipeline_gen2.c 2>/dev/null || true
perl -i -0777 -pe 's/(struct parser_ParseIntoResult \{ int32_t ok; int32_t main_idx; \};\n)/$1extern struct parser_ParseIntoResult parser_parse_into_buf(struct ast_ASTArena *, struct ast_Module *, uint8_t *, int32_t);\n/s unless /parser_parse_into_buf\(struct ast_ASTArena \*, struct ast_Module \*, uint8_t \*, int32_t\)/' pipeline_gen2.c 2>/dev/null || true

# ── Step 3: 编译 _x2.o ──
CFLAGS="-fno-stack-protector -Wall -Wextra -I. -Iinclude -Isrc -w"
echo ""
echo "── Step 3: 编译 _x2.o ──"
cc $CFLAGS -c token_gen2.c    -o token_x2.o
cc $CFLAGS -c ast_gen2.c      -o ast_x2.o
cc $CFLAGS -c lexer_gen2.c    -o lexer_x2.o
cc $CFLAGS -include ast.h -c parser_gen2.c -o parser_x2.o
cc $CFLAGS -c typeck_gen2.c   -o typeck_x2.o
cc $CFLAGS -c codegen_gen2.c  -o codegen_x2.o
cc $CFLAGS -c preprocess_gen2.c -o preprocess_x2.o
cc $CFLAGS -c pipeline_gen2.c -o pipeline_x2.o
STAGE2_X_TMP_DIR="${TMPDIR:-/tmp}/shux-stage2-x"
mkdir -p "$STAGE2_X_TMP_DIR"
PIPELINE_X2_ALL="$STAGE2_X_TMP_DIR/pipeline_x2.syms"
PIPELINE_X2_OMIT="$STAGE2_X_TMP_DIR/pipeline_x2.omit"
PIPELINE_X2_KEEP="$STAGE2_X_TMP_DIR/pipeline_x2.keep"
PIPELINE_X2_FILTERED="$STAGE2_X_TMP_DIR/pipeline_x2_filtered.o"
cat >"$PIPELINE_X2_OMIT" <<'EOF'
typeck_check_expr_call
typeck_check_expr_deref
typeck_check_expr_method_call
codegen_try_emit_slice_init_from_array_var
backend_ctx_push_loop_labels
backend_ctx_pop_loop_labels
backend_try_fold_count_up_while_elf
EOF
nm pipeline_x2.o 2>/dev/null | awk '/ [TDS] / { s=$3; sub(/^_/, "", s); print s }' | sort -u >"$PIPELINE_X2_ALL"
grep -vxF -f "$PIPELINE_X2_OMIT" "$PIPELINE_X2_ALL" | sed 's/^/_/' >"$PIPELINE_X2_KEEP"
ld -r -exported_symbols_list "$PIPELINE_X2_KEEP" -o "$PIPELINE_X2_FILTERED" pipeline_x2.o

echo ""
echo "── 编译 C 侧与 seed 桥（与 bootstrap-driver-seed 同拓扑）──"
${MAKE:-make} -q build-seed-asm-host 2>/dev/null || ${MAKE:-make} build-seed-asm-host
cc $CFLAGS -c src/ast_pool_l5_bridge.c -o src/ast_pool_l5_bridge.o
cc $CFLAGS -DX_VERIFY_STAGE2 -c src/x_seed_bridge.c -o src/x_seed_bridge_stage2.o
cc $CFLAGS -c typeck_x_link_alias.c -o typeck_x_link_alias.o
cc $CFLAGS -c codegen_x_link_alias.c -o codegen_x_link_alias.o
cc $CFLAGS -c lexer_x_link_alias.c -o lexer_x_link_alias.o 2>/dev/null || true
# runtime_driver（与 shux-x 相同宏，供 driver_run_compiler_full_x）
cc $CFLAGS -DSHUX_USE_X_DRIVER -DSHUX_USE_X_PIPELINE -DSHUX_USE_X_TYPECK -DSHUX_USE_X_CODEGEN -DSHUX_USE_X_PREPROCESS \
  -c src/runtime.c -o runtime_driver2.o
# Stage2 链接仍需沿用 driver 专用 C 对象；不要依赖工作区里偶然残留的 .o。
${MAKE:-make} src/main_driver.o src/driver/fmt_check_cmd_driver.o >/dev/null

# ── Step 4: 链接 shux-x2（*_x2.o 替代 parser_x/typeck_x/codegen_x/pipeline_x；其余与 bootstrap-driver-seed 同拓扑）──
echo ""
echo "── Step 4: 链接 shux-x2 ──"
${MAKE:-make} bootstrap-driver-seed >/dev/null
for _o in driver_x.o driver_compile_x.o driver_fmt_x.o driver_check_x.o driver_test_x.o \
  driver_build_x.o driver_run_x.o driver_emit_x.o preprocess_x.o lsp_x.o lsp_diag_x.o lsp_io_x.o lsp_io_std_heap_x.o \
  pipeline_bootstrap_orchestration.o src/async/async_liveness.o src/async/async_cps_codegen.o; do
  if [ ! -f "$_o" ]; then ${MAKE:-make} shux-x bootstrap-driver-seed 2>/dev/null || ${MAKE:-make} shux-x; break; fi
done
cc -fno-stack-protector -Wall -Wextra -I. -Iinclude -Isrc -w \
  -DSHUX_USE_X_DRIVER -DSHUX_USE_X_PIPELINE -DSHUX_USE_X_TYPECK -DSHUX_USE_X_CODEGEN \
  -Wl,-multiply_defined,suppress -e _start -nostartfiles \
  -o shux-x2 \
  src/asm/crt0_arm64.o src/runtime_abi.o src/runtime_io_abi.o src/runtime_proc_abi.o src/runtime_link_abi.o \
  src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/runtime_pipeline_abi.o runtime_driver2.o \
  src/driver/fmt_check_cmd_driver.o src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o \
  src/asm/bootstrap_seed_io_stubs.o src/lexer/lexer.o src/ast/ast_seed.o \
  src/async/async_liveness.o src/async/async_cps_codegen.o \
  src/runtime_c_import.o src/codegen/codegen_pipeline_stubs.o src/lexer/cfg_eval.o \
  src/typeck/typeck_f64_bits.o typeck_c_module_stubs.o src/runtime_pipeline_abi_shux_c_stubs.o \
  src/lsp/lsp_heap_bootstrap.o src/x_seed_bridge_stage2.o src/seed_link_compat.o src/std_fs_shim.o src/std_sys_shim.o \
  src/ast_pool_l5_bridge.o \
  token_x2.o ast_x2.o lexer_x2.o parser_x2.o typeck_x2.o codegen_x2.o preprocess_x2.o "$PIPELINE_X2_FILTERED" \
  lexer_x_link_alias.o typeck_x_link_alias.o codegen_x_link_alias.o \
  driver_x.o pipeline_bootstrap_orchestration.o \
  driver_fmt_x.o driver_check_x.o driver_test_x.o driver_compile_x.o driver_build_x.o driver_run_x.o driver_emit_x.o \
  _stubs_driver.o src/lsp/lsp_codegen_extern.o src/lsp/lsp_diag_stubs_no_c.o src/lsp/lsp_diag_pipeline_sizes_nostub.o \
  src/lsp/lsp_diag_pipeline_ctx.o src/lsp/lsp_state.o lsp_x.o lsp_diag_x.o src/lsp/lsp_diag_x_alias.o \
  lsp_io_x.o lsp_io_std_heap_x.o build_asm/seed_host/asm_backend_partial.o \
  build_asm/seed_host/asm_full_link_stubs.o build_asm/bootstrap_seed_user_asm_seed_bridge_filtered.o \
  build_asm/bootstrap_seed_asm_backend_compat_stubs_filtered.o build_asm/bootstrap_seed_backend_x86_64_enc_c_filtered.o \
  src/asm/backend_enc_dispatch.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o \
  src/asm/backend_call_dispatch.o parser_asm_thin_glue.o parser_asm_link_alias.o \
  src/asm/parser_asm_parse_expr_link.o build_asm/pipeline_glue_strict_minimal.o

echo "shux-x2 linked: $(ls -lh shux-x2 | awk '{print $5}')"

# ── Step 5: 功能对比 ──
echo ""
echo "── Step 5: 功能对比 ──"
echo 'function main(): i32 { return 42; }' > /tmp/selfhost_test.x
# 与 verify-selfhost-stage2-bstrict 对齐：Darwin/ARM64 等平台 asm -o 尚不稳定时，用 -backend c 验证行为 parity。
GEN_FLAGS="-L .."
STAGE2_X_COMPILE_BACKEND=""
case "$(uname -s)-$(uname -m 2>/dev/null)" in
  Darwin-*|Linux-aarch64|Linux-arm64)
    STAGE2_X_COMPILE_BACKEND="-backend c"
    echo "verify-stage2: use -backend c for Step 5 on $(uname -s)/$(uname -m 2>/dev/null)"
    ;;
esac
REF=$X

echo "参照编译 ($REF):"
# shellcheck disable=SC2086
$REF $STAGE2_X_COMPILE_BACKEND $GEN_FLAGS /tmp/selfhost_test.x -o /tmp/selfhost_a 2>&1 || true
if [ ! -x /tmp/selfhost_a ] && [ -x ./shux-c ]; then
  echo "  (shux-x -o 未产出，非 x86_64 等环境改 shux-c 作参照)"
  REF=./shux-c
  # shellcheck disable=SC2086
  $REF $STAGE2_X_COMPILE_BACKEND $GEN_FLAGS /tmp/selfhost_test.x -o /tmp/selfhost_a 2>&1 || true
fi
chmod +x /tmp/selfhost_a 2>/dev/null || true
set +e
/tmp/selfhost_a >/dev/null 2>&1
r1=$?
set -e

echo "shux-x2 编译:"
# shellcheck disable=SC2086
./shux-x2 $STAGE2_X_COMPILE_BACKEND $GEN_FLAGS /tmp/selfhost_test.x -o /tmp/selfhost_b 2>&1 || true
chmod +x /tmp/selfhost_b 2>/dev/null || true
set +e
/tmp/selfhost_b >/dev/null 2>&1
r2=$?
set -e

echo ""
echo "参照 ($REF) 返回值: $r1"
echo "shux-x2 返回值: $r2"

if [ "$r1" = "42" ] && [ "$r2" = "42" ]; then
    echo ""
    echo "============================================"
    echo " ✓ Stage2 X 验证通过!"
    echo "   shux-x  ($(ls -lh shux-x  | awk '{print $5}'))"
    echo "   shux-x2 ($(ls -lh shux-x2 | awk '{print $5}'))"
    echo "   两代编译器行为一致 (exit 42)"
    echo "============================================"
else
    echo "✗ 自举验证失败! r1=$r1 r2=$r2"
    exit 1
fi
