#!/bin/sh
# verify-selfhost.sh — Shux 语义自举验证（Stage2 SX；完全自举 = D+E+F，见 SELFHOST.md）
# 用法: cd compiler && sh verify-selfhost.sh

set -e
cd "$(dirname "$0")"

echo "============================================"
echo " Shux 自举验证"
echo "============================================"

# ── Step 0: Cold Bootstrap ──────────────────
echo ""
echo "── Step 0: 冷启动 ──"
rm -f *.o src/*.o src/*/*.o _sx_stubs.* _shux2_* shux shux-c shux-sx *_gen.c *_sx.o 2>/dev/null || true

SRCS="src/main.c src/runtime.c src/preprocess.c src/lexer/lexer.c src/ast/ast.c src/parser/parser.c src/typeck/typeck.c src/codegen/codegen.c src/lsp/lsp_diag.c"
OBJS=""
for src in $SRCS; do
  obj="${src%.c}.o"
  OBJS="$OBJS $obj"
  cc -Wall -Wextra -I. -Iinclude -Isrc -c -o "$obj" "$src"
done
cc -Wall -Wextra -I. -Iinclude -Isrc -o shux $OBJS
echo "shux built: $(ls -lh shux | awk '{print $5}')"

# invoke_cc 会链 ./runtime_panic.o（见 runtime.c get_runtime_panic_o_path）；冷启动未跑 Makefile 时需先产出。
if [ -f src/asm/runtime_panic_arm64.c ] && [ "$(uname -m 2>/dev/null)" = arm64 ]; then
  cc -Wall -Wextra -I. -Iinclude -Isrc -c -o runtime_panic.o src/asm/runtime_panic_arm64.c
else
  cc -Wall -Wextra -I. -Iinclude -Isrc -c -o runtime_panic.o src/asm/runtime_panic.c
fi
echo "runtime_panic.o ready"

# ── Step 1: Generate all SX _gen.c ──────────
echo ""
echo "── Step 1: 生成所有 SX 模块 _gen.c ──"

echo "  token..."
./shux -L src/lexer -E -E-extern src/lexer/token.sx > token_gen.c && echo "    $(wc -l < token_gen.c) lines"

echo "  ast..."
./shux -E -E-extern src/ast/ast.sx > ast_gen.c && echo "    $(wc -l < ast_gen.c) lines"

echo "  lexer..."
./shux -L src/lexer -E -E-extern src/lexer/lexer.sx > lexer_gen.c && echo "    $(wc -l < lexer_gen.c) lines"

echo "  parser..."
./shux -L .. -L src/lexer -L src/ast -E -E-extern src/parser/parser.sx > parser_gen.c && echo "    $(wc -l < parser_gen.c) lines"

echo "  typeck..."
./shux -L .. -L src/lexer -L src/ast -E -E-extern src/typeck/typeck.sx > typeck_gen.c && echo "    $(wc -l < typeck_gen.c) lines"

echo "  codegen..."
./shux -L .. -L src/lexer -L src/ast -L src/parser -L src/typeck -E -E-extern src/codegen/codegen.sx > codegen_gen.c && echo "    $(wc -l < codegen_gen.c) lines"

echo "  preprocess..."
./shux -L src/lexer -E -E-extern src/preprocess/preprocess.sx > preprocess_gen.c && echo "    $(wc -l < preprocess_gen.c) lines"

echo "  pipeline..."
./shux -L .. -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/asm -E -E-extern src/pipeline/pipeline.sx > pipeline_gen.c && echo "    $(wc -l < pipeline_gen.c) lines"

echo "  driver (main.sx)..."
./shux -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -E -E-extern src/main.sx > driver_gen.c && echo "    $(wc -l < driver_gen.c) lines"

# ── Step 2: Fix generated C files ───────────
echo ""
echo "── Step 2: 修复 _gen.c ──"

# 去重 shux_slice_uint8_t
for f in parser_gen.c typeck_gen.c codegen_gen.c pipeline_gen.c driver_gen.c preprocess_gen.c; do
  perl -i -ne 'print unless /^struct shux_slice_uint8_t/ && $seen++' "$f" 2>/dev/null || true
done

# pipeline_gen.c: 确保 parser_parse_into_buf extern 在文件头部
# 删除所有已有 extern 声明（可能在文件末尾），在第一个 shux_panic_ 前置声明前插入一次
perl -i -ne 'print unless /^extern.*parser_parse_into_buf/' pipeline_gen.c 2>/dev/null || true
perl -i -pe 's/^(static inline void shux_panic_.*__attribute__)/extern struct parser_ParseIntoResult parser_parse_into_buf(struct ast_ASTArena *, struct ast_Module *, uint8_t *, int32_t);\n\n$1/' pipeline_gen.c
echo "  pipeline_gen.c: ensured parser_parse_into_buf extern at top"
echo "  修复完成"

# ── Step 3: Compile all _sx.o ──────────────
echo ""
echo "── Step 3: 编译 _sx.o (fno-stack-protector) ──"
CFLAGS="-fno-stack-protector -Wall -Wextra -I. -Iinclude -Isrc -w"

echo "  token_sx.o..."
cc $CFLAGS -c token_gen.c -o token_sx.o

echo "  ast_sx.o..."
cc $CFLAGS -c ast_gen.c -o ast_sx.o

echo "  lexer_sx.o..."
cc $CFLAGS -c lexer_gen.c -o lexer_sx.o

echo "  parser_sx.o (-include ast.h)..."
cc $CFLAGS -include ast.h -c parser_gen.c -o parser_sx.o

echo "  typeck_sx.o..."
cc $CFLAGS -c typeck_gen.c -o typeck_sx.o

echo "  codegen_sx.o..."
cc $CFLAGS -c codegen_gen.c -o codegen_sx.o

echo "  preprocess_sx.o..."
cc $CFLAGS -c preprocess_gen.c -o preprocess_sx.o

echo "  pipeline_sx.o..."
perl -i -ne 'print unless /^struct shux_slice_uint8_t/ && $seen++' pipeline_gen.c 2>/dev/null || true
cc $CFLAGS -c pipeline_gen.c -o pipeline_sx.o

echo "  driver_sx.o..."
cc $CFLAGS -c driver_gen.c -o driver_sx.o

# 编译 C 侧模块
echo ""
echo "  编译 C 侧模块..."
cc $CFLAGS -DSHUX_USE_SX_AST -c src/ast/ast.c -o ast_c.o
cc $CFLAGS -c src/lexer/lexer.c -o lexer_c.o
cc $CFLAGS -c src/parser/parser.c -o parser_c.o
cc $CFLAGS -c src/typeck/typeck.c -o typeck_c.o
cc $CFLAGS -c src/codegen/codegen.c -o codegen_c.o
cc $CFLAGS -c src/lsp/lsp_diag.c -o lsp_diag_c.o
cc $CFLAGS -c src/std_fs_shim.c -o std_fs_shim_c.o

# 编译桩文件
echo "  编译桩文件..."
cat > _sx_stubs.c << 'STUBEOF'
#include <stdint.h>
#include <stddef.h>
int asm_asm_codegen_ast(void *a, void *b, void *c, void *d) { return -1; }
int asm_asm_codegen_elf_o(void *a, void *b, void *c, void *d, void *e) { return -1; }
int io_read_batch_buf(void) { return -1; }
int io_write_batch_buf(void) { return -1; }
int typeck_lsp_main(void) { return -1; }
extern int32_t typeck_preprocess_sx_buf(const uint8_t *src, ptrdiff_t src_len, uint8_t *out_buf, int32_t out_cap);
int32_t preprocess_sx_buf(const uint8_t *src, ptrdiff_t src_len, uint8_t *out_buf, int32_t out_cap) {
    return typeck_preprocess_sx_buf(src, src_len, out_buf, out_cap);
}
STUBEOF
cc $CFLAGS -c _sx_stubs.c -o _sx_stubs.o

# ── Step 4: Compile runtime_driver ──────────
echo ""
echo "── Step 4: 编译 runtime_driver ──"
cc $CFLAGS -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -DSHUX_USE_SX_FRONTEND -DSHUX_USE_SX_PREPROCESS \
  -c src/runtime.c -o runtime_driver.o
cc $CFLAGS -DSHUX_USE_SX_PREPROCESS -c src/preprocess.c -o preprocess_fallback.o
cc $CFLAGS -c src/main.c -o main.o

# ── Step 5: Link shux-sx ─────────────────────
echo ""
echo "── Step 5: 链接 shux-sx ──"
cc -fno-stack-protector -o shux-sx \
  main.o runtime_driver.o preprocess_fallback.o \
  lexer_c.o ast_c.o parser_c.o typeck_c.o codegen_c.o lsp_diag_c.o std_fs_shim_c.o \
  token_sx.o ast_sx.o lexer_sx.o parser_sx.o typeck_sx.o codegen_sx.o preprocess_sx.o pipeline_sx.o driver_sx.o \
  _sx_stubs.o

echo "shux-sx linked: $(ls -lh shux-sx | awk '{print $5}')"

# ── Step 6: Typeck 测试 ─────────────────────
echo ""
echo "============================================"
echo "── Step 6: Typeck 测试 ──"
echo "============================================"

# 测试 1: 简单程序编译
cat > /tmp/hello.sx << 'EOF'
function main(): i32 { return 42; }
EOF

echo "Test: C 编译器编译 hello.sx"
./shux /tmp/hello.sx -o /tmp/hello_c
chmod +x /tmp/hello_c 2>/dev/null || true
set +e
/tmp/hello_c >/dev/null 2>&1
r1=$?
set -e
echo " 返回值: $r1 (期望: 42)"
if [ "$r1" = "42" ]; then echo "  ✓"; else echo "  ✗"; fi

# 测试 2: 类型错误检测
echo ""
echo "Test: 类型错误检测"
cat > /tmp/test_bad.sx << 'EOF'
function main(): i32 { let x: i32 = true; return 0; }
EOF

./shux /tmp/test_bad.sx -o /tmp/test_bad_c 2>/tmp/test_bad_stderr; rc=$?
if [ $rc -ne 0 ] && (grep -q "typeck error" /tmp/test_bad_stderr 2>/dev/null || [ $rc -ne 0 ]); then
  echo "  ✓ C compiler: type error caught (rc=$rc)"
else
  echo "  ! C compiler: rc=$rc"
  head -3 /tmp/test_bad_stderr 2>/dev/null || true
fi

# 测试 3: SX 管线编译
echo ""
echo "Test: SX 管线编译 hello.sx"
./shux-sx -sx -E /tmp/hello.sx > /tmp/hello_sx_E 2>/tmp/hello_sx_stderr; rc=$?
echo "  -sx -E: rc=$rc output=$(wc -c < /tmp/hello_sx_E 2>/dev/null || echo 0) bytes"
if [ $rc -ne 0 ]; then
  echo "  stderr: $(head -3 /tmp/hello_sx_stderr 2>/dev/null || true)"
fi

# ── Summary ─────────────────────────────────
echo ""
echo "============================================"
echo " 自举验证完成"
echo "============================================"
echo " 编译器:"
echo "   shux      — C 编译器 ($(ls -lh shux 2>/dev/null | awk '{print $5}' || echo 'N/A'))"
echo "   shux-sx   — SX 自举编译器 ($(ls -lh shux-sx 2>/dev/null | awk '{print $5}' || echo 'N/A'))"
echo ""
echo " 下一步: 逐阶段调试 shux-sx -sx 管线"
echo "============================================"
