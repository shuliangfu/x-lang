#!/bin/bash
set -e
cd "$(dirname "$0")"
CFLAGS="-Wall -Wextra -I. -Iinclude -Isrc"
CFLAGS_DRIVER="$CFLAGS -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -DSHUX_USE_SX_FRONTEND -DSHUX_USE_SX_PREPROCESS"

echo "=== 0. Bootstrap ==="
SRCS="src/main.c src/runtime.c src/preprocess.c src/lexer/lexer.c src/ast/ast.c src/parser/parser.c src/typeck/typeck.c src/codegen/codegen.c src/lsp/lsp_diag.c"
OBJS=""
for src in $SRCS; do
  obj="${src%.c}.o"
  OBJS="$OBJS $obj"
  cc $CFLAGS -c -o "$obj" "$src"
done
cc $CFLAGS -o shux $OBJS
cc $CFLAGS -o shux-c $OBJS

echo "=== 1. Relink shux with fixed runtime ==="
cc $CFLAGS -c src/runtime.c -o src/runtime.o
cc $CFLAGS -o shux src/main.o src/runtime.o src/preprocess.o src/lexer/lexer.o src/ast/ast.o src/parser/parser.o src/typeck/typeck.o src/codegen/codegen.o src/lsp/lsp_diag.o

echo "=== 2. Generate all _gen.c ==="
./shux -L .. -L src/lexer -L src/ast -E -E-extern src/parser/parser.sx > parser_gen.c
./shux -L .. -L src/lexer -L src/ast -E -E-extern src/typeck/typeck.sx > typeck_gen.c
./shux -L .. -L src/lexer -L src/ast -L src/parser -L src/typeck -E -E-extern src/codegen/codegen.sx > codegen_gen.c
./shux -E -E-extern src/ast/ast.sx > ast_gen.c
./shux -L src/lexer -E -E-extern src/lexer/token.sx > token_gen.c
./shux -L src/lexer -E -E-extern src/lexer/lexer.sx > lexer_gen.c
./shux -L src/lexer -E -E-extern src/preprocess/preprocess.sx > preprocess_gen.c
./shux -L .. -L . -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/asm -L src/preprocess -E -E-extern src/pipeline/pipeline.sx > pipeline_gen.c
./shux -L .. -L . -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess src/main.sx -E -E-extern > driver_gen.c

echo "=== 3. Fix generated C ==="
sed -i '' '52d' parser_gen.c 2>/dev/null || true
sed -i '' '/^extern void lexer_lexer_next_into/a\
extern void ast_expr_init_match_enum(struct ast_Expr * e);
' parser_gen.c

sed -i '' '74d' pipeline_gen.c 2>/dev/null || true
sed -i '' '73a\
extern struct parser_ParseIntoResult parser_parse_into_buf(struct ast_ASTArena * arena, struct ast_Module * module, uint8_t * data, int32_t len);
' pipeline_gen.c

echo "=== 4. Compile all _sx.o ==="
for f in parser typeck codegen ast token lexer preprocess pipeline driver; do
  cc $CFLAGS -c ${f}_gen.c -o ${f}_sx.o
done

echo "=== 5. Compile support files ==="
cc $CFLAGS_DRIVER -c src/runtime.c -o runtime_driver.o
cc $CFLAGS -DSHUX_USE_SX_PREPROCESS -c src/preprocess.c -o preprocess_fallback.o
cc $CFLAGS -c src/std_fs_shim.c -o std_fs_shim.o
cc $CFLAGS -c src/asm/runtime_panic.c -o runtime_panic.o
cc $CFLAGS -c shu_sx_stubs.c -o shu_sx_stubs.o

echo "=== 6. Compile C fallback object files ==="
cc $CFLAGS -c src/lexer/lexer.c -o src/lexer/lexer.o
cc $CFLAGS -c src/ast/ast.c -o src/ast/ast.o
cc $CFLAGS -c src/parser/parser.c -o src/parser/parser.o
cc $CFLAGS -c src/typeck/typeck.c -o src/typeck/typeck.o
cc $CFLAGS -c src/codegen/codegen.c -o src/codegen/codegen.o
cc $CFLAGS -c src/lsp/lsp_diag.c -o src/lsp/lsp_diag.o

echo "=== 7. Link shux_sx ==="
cc $CFLAGS_DRIVER -o shux_sx \
  src/main.o runtime_driver.o preprocess_fallback.o \
  preprocess_sx.o std_fs_shim.o \
  ast_sx.o token_sx.o lexer_sx.o parser_sx.o typeck_sx.o codegen_sx.o \
  driver_sx.o pipeline_sx.o runtime_panic.o \
  src/lexer/lexer.o src/ast/ast.o src/parser/parser.o \
  src/typeck/typeck.o src/codegen/codegen.o src/lsp/lsp_diag.o \
  shu_sx_stubs.o

echo "=== 8. Quick smoke test ==="
./shux_sx -sx -E ../tests/sx-pipeline/hello.sx 2>&1 || true
echo "shux_sx built successfully: $(ls -lh shux_sx | awk '{print $5}')"
echo "Ready for full test suite."
