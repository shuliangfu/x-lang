#!/bin/sh
# bootstrap.sh — Shux 冷启动引导脚本
#
# 从零构建，仅需 C 编译器（cc），不依赖 Makefile 或已有 shux。
# 产出 compiler/shux、compiler/shux-c、compiler/build_tool。
# 执行一次后，日常构建只需 cd compiler && ./build_tool。
#
# 用法：cd compiler && sh bootstrap.sh

set -e

echo "=== Shux Cold Bootstrap ==="

SRCS="src/main.c src/runtime.c src/preprocess.c src/lexer/lexer.c src/ast/ast.c src/parser/parser.c src/typeck/typeck.c src/codegen/codegen.c src/lsp/lsp_codegen_extern.c src/lsp/lsp_diag.c src/lsp/lsp_diag_pipeline_sizes.c"
OBJS=""

echo "[1/4] compiling C sources..."
for src in $SRCS; do
  obj="${src%.c}.o"
  OBJS="$OBJS $obj"
  echo "  cc -c $src"
  cc -Wall -Wextra -I. -Iinclude -Isrc -c -o "$obj" "$src"
done

echo "[2/4] linking shux..."
cc -Wall -Wextra -I. -Iinclude -Isrc -o shux $OBJS

echo "[3/4] linking shux-c (pure C, no SU pipeline)..."
cc -Wall -Wextra -I. -Iinclude -Isrc -o shux-c $OBJS

# 与 Makefile build-tool 一致：用 shux-c（此处与 shux 二进制相同）跑 -E，不依赖带 .sx driver 的 shux。
echo "[4/4] generating build_tool from build.sx..."
./shux-c ../build.sx -E > build_gen.c
cc -Wall -Wextra -I. -Iinclude -Isrc -c build_gen.c -o build_tool.o
cc -Wall -Wextra -I. -Iinclude -Isrc -c src/build_runtime.c -o build_runtime.o
cc -Wall -Wextra -o build_tool build_tool.o build_runtime.o

echo ""
echo "=== Bootstrap Complete ==="
echo "  compiler/shux          — Shux compiler"
echo "  compiler/shux-c        — Pure C Shux compiler"
echo "  compiler/build_tool   — Build tool (../build.sx config + build_runtime.c)"
echo ""
echo "Daily (C intermediate):  cd compiler && ./build_tool ./shux"
echo "Prefer machine code:     cd compiler && ./build_tool ./shux asm   # -> shux_asm"
echo "Tests (example):         cd .. && SHUX=./compiler/shux ./tests/run-all.sh"
