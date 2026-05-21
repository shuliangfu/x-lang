#!/bin/sh
# verify-selfhost-stage2.sh — 用 shu-su 编译自身，验证完全自举
set -e
cd "$(dirname "$0")"

# Step 0：重链 shu-su；若无 driver_su.o 等则先 bootstrap-driver-seed
echo ""
echo "── Step 0: 确保 shu-su ──"
if ! ${MAKE:-make} shu-su; then
  echo "  make shu-su 失败，执行 bootstrap-driver-seed …"
  ${MAKE:-make} bootstrap-driver-seed
fi

echo "============================================"
echo " Shulang 完全自举验证 (Stage 2)"
echo " 种子: GEN=shu-su 生成 _gen2.c（-su -E -E-extern），SU 链出 shu-su2；对比 SU 与 SU2 编译 hello 的退出码"
echo "============================================"

# GEN 使用 shu-su：-su -E 经 driver_run_su_emit_c_extern_via_cparser 与 C 路径 -E-extern 对齐（parse/typeck/codegen）。
SU=./shu-su
GEN=$SU

# ── Step 1: 生成所有 _gen2.c ──
echo ""
echo "── Step 1: 生成 _gen2.c (GEN=$GEN) ──"
echo "  token..."
$GEN -su -E -L src/lexer -E-extern src/lexer/token.su > token_gen2.c
echo "  ast..."
$GEN -su -E -E-extern src/ast/ast.su > ast_gen2.c
echo "  lexer..."
$GEN -su -E -L src/lexer -E-extern src/lexer/lexer.su > lexer_gen2.c
echo "  parser..."
$GEN -su -E -L .. -L src/lexer -L src/ast -E-extern src/parser/parser.su > parser_gen2.c
echo "  typeck..."
$GEN -su -E -L .. -L src/lexer -L src/ast -E-extern src/typeck/typeck.su > typeck_gen2.c
echo "  codegen..."
$GEN -su -E -L .. -L src/lexer -L src/ast -L src/parser -L src/typeck -E-extern src/codegen/codegen.su > codegen_gen2.c
echo "  preprocess..."
$GEN -su -E -L src/lexer -E-extern src/preprocess/preprocess.su > preprocess_gen2.c
echo "  pipeline..."
$GEN -su -E -L .. -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/asm -E-extern src/pipeline/pipeline.su > pipeline_gen2.c
echo "  driver (main.su)..."
$GEN -su -E -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -E-extern src/main.su > driver_gen2.c

# ── Step 2: 去重结构体 ──
echo ""
echo "── Step 2: 修复 pipeline_gen2.c / 去重 slice 结构体 ──"
for f in parser_gen2.c typeck_gen2.c codegen_gen2.c pipeline_gen2.c driver_gen2.c preprocess_gen2.c; do
  perl -i -ne 'print unless /^struct shulang_slice_uint8_t/ && $seen++' "$f" 2>/dev/null || true
done
for f in ast_gen2.c parser_gen2.c typeck_gen2.c codegen_gen2.c pipeline_gen2.c driver_gen2.c; do
  perl scripts/fix_slim_arena_gen_c.pl "$f" 2>/dev/null || true
done
perl scripts/hoist_pipeline_prototypes.pl pipeline_gen2.c 2>/dev/null || true
perl scripts/fix_slim_arena_gen_c.pl pipeline_gen2.c 2>/dev/null || true
perl -i -ne 'print unless /^extern.*parser_parse_into_buf/' pipeline_gen2.c 2>/dev/null || true
perl -i -pe 's/^(static inline void shulang_panic_.*__attribute__)/extern struct parser_ParseIntoResult parser_parse_into_buf(struct ast_ASTArena *, struct ast_Module *, uint8_t *, int32_t);\n\n$1/' pipeline_gen2.c

# ── Step 3: 编译 _su2.o ──
CFLAGS="-fno-stack-protector -Wall -Wextra -I. -Iinclude -Isrc -w"
echo ""
echo "── Step 3: 编译 _su2.o ──"
cc $CFLAGS -c token_gen2.c    -o token_su2.o
cc $CFLAGS -c ast_gen2.c      -o ast_su2.o
cc $CFLAGS -c lexer_gen2.c    -o lexer_su2.o
cc $CFLAGS -include ast.h -c parser_gen2.c -o parser_su2.o
cc $CFLAGS -c typeck_gen2.c   -o typeck_su2.o
cc $CFLAGS -c codegen_gen2.c  -o codegen_su2.o
cc $CFLAGS -c preprocess_gen2.c -o preprocess_su2.o
cc $CFLAGS -c pipeline_gen2.c -o pipeline_su2.o
cc $CFLAGS -c driver_gen2.c   -o driver_su2.o

echo ""
echo "── 编译 C 侧模块 ──"
cc $CFLAGS -DSHU_USE_SU_AST -c src/ast/ast.c -o ast_c2.o
cc $CFLAGS -c src/lexer/lexer.c -o lexer_c2.o
cc $CFLAGS -c src/parser/parser.c -o parser_c2.o
cc $CFLAGS -c src/typeck/typeck.c -o typeck_c2.o
cc $CFLAGS -c src/codegen/codegen.c -o codegen_c2.o
cc $CFLAGS -c src/lsp/lsp_diag.c -o lsp_diag_c2.o
cc $CFLAGS -c src/std_fs_shim.c -o std_fs_shim_c2.o

# 桩文件（asm_driver_*、std_heap、driver 子命令桩；lsp sizeof 见 lsp_diag_pipeline_sizes2.o）
cc $CFLAGS -c _su_stubs2.c -o _su_stubs2.o
cc $CFLAGS -c src/lsp/lsp_diag_pipeline_sizes.c -o lsp_diag_pipeline_sizes2.o

# runtime_driver
cc $CFLAGS -DSHU_USE_SU_DRIVER -DSHU_USE_SU_PIPELINE -DSHU_USE_SU_FRONTEND -DSHU_USE_SU_PREPROCESS -c src/runtime.c -o runtime_driver2.o
cc $CFLAGS -DSHU_USE_SU_PREPROCESS -c src/preprocess.c -o preprocess_fallback2.o
cc $CFLAGS -c src/main.c -o main2.o

# ── Step 4: 链接 shu-su2 ──
echo ""
echo "── Step 4: 链接 shu-su2 ──"
cc -fno-stack-protector -o shu-su2 \
  main2.o runtime_driver2.o preprocess_fallback2.o \
  lexer_c2.o ast_c2.o parser_c2.o typeck_c2.o codegen_c2.o lsp_diag_c2.o std_fs_shim_c2.o \
  token_su2.o ast_su2.o lexer_su2.o parser_su2.o typeck_su2.o codegen_su2.o preprocess_su2.o pipeline_su2.o driver_su2.o \
  lsp_diag_pipeline_sizes2.o _su_stubs2.o

echo "shu-su2 linked: $(ls -lh shu-su2 | awk '{print $5}')"

# ── Step 5: 功能对比 ──
echo ""
echo "── Step 5: 功能对比 ──"
echo 'function main(): i32 { return 42; }' > /tmp/selfhost_test.su

echo "shu-su 编译:"
$SU /tmp/selfhost_test.su -o /tmp/selfhost_a 2>&1 || true
chmod +x /tmp/selfhost_a 2>/dev/null || true
set +e
/tmp/selfhost_a >/dev/null 2>&1
r1=$?
set -e

echo "shu-su2 编译:"
./shu-su2 /tmp/selfhost_test.su -o /tmp/selfhost_b 2>&1 || true
chmod +x /tmp/selfhost_b 2>/dev/null || true
set +e
/tmp/selfhost_b >/dev/null 2>&1
r2=$?
set -e

echo ""
echo "shu-su  返回值: $r1"
echo "shu-su2 返回值: $r2"

if [ "$r1" = "42" ] && [ "$r2" = "42" ]; then
    echo ""
    echo "============================================"
    echo " ✓ 完全自举验证通过!"
    echo "   shu-su  ($(ls -lh shu-su  | awk '{print $5}'))"
    echo "   shu-su2 ($(ls -lh shu-su2 | awk '{print $5}'))"
    echo "   两代编译器行为一致 (exit 42)"
    echo "============================================"
else
    echo "✗ 自举验证失败! r1=$r1 r2=$r2"
    exit 1
fi
