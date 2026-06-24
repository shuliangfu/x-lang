#!/usr/bin/env sh
# gen_bootstrap_gens.sh — 用 LEGACY C 前端 shux-c 生成 bootstrap 所需的 *_gen.c（G-06 冷启动）
#
# 用法（compiler 目录）：
#   SHUX_LEGACY_C_FRONTEND=1 ./scripts/gen_bootstrap_gens.sh
#
# 说明：预编译 seed 对 pipeline/asm 等大模块 -E 会挂死；LEGACY shux-c 走 C 前端 -E 路径。
# ast.sx / pipeline.sx 须保留仓库内已 pin 的 ast_gen2.c / pipeline_gen.c。

set -e
cd "$(dirname "$0")/.."

echo "gen_bootstrap_gens: build LEGACY shux-c ..."
SHUX_LEGACY_C_FRONTEND=1 make shux-c

SHUX=./shux-c
LIB_ASM="-L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/asm -L src/preprocess -L src/pipeline -L src/codegen"
LSP_DIRS="-L .. -L src/lsp -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess"
MAIN_DIRS="-L .. -L src -L src/lsp -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess"
DRIVER_DIRS="-L .. -L src -L src/lexer -L src/ast"

gen_one() {
  _out="$1"
  _force="${2:-0}"
  shift 2
  if [ "$_force" != "1" ] && [ -s "$_out" ]; then
    echo "gen_bootstrap_gens: pinned $_out ($(wc -c < "$_out" | tr -d ' ') bytes)"
    return 0
  fi
  echo "gen_bootstrap_gens: $_out ..."
  if "$SHUX" "$@" > "$_out" && [ -s "$_out" ]; then
    case "$_out" in
      typeck_gen.c|codegen_gen.c|parser_gen.c)
        perl scripts/fix_slim_arena_gen_c.pl "$_out" 2>/dev/null || true
        ;;
    esac
    echo "  OK $(wc -c < "$_out" | tr -d ' ') bytes"
    return 0
  fi
  echo "  WARN $_out failed" >&2
  [ -s "$_out" ] && return 0
  return 1
}

if [ ! -s ast_gen2.c ]; then
  echo "gen_bootstrap_gens: need non-empty ast_gen2.c" >&2
  exit 1
fi
echo "gen_bootstrap_gens: pinned ast_gen2.c ($(wc -c < ast_gen2.c | tr -d ' ') bytes)"

if [ ! -s pipeline_gen.c ]; then
  gen_one pipeline_gen.c 1 $LIB_ASM -E -E-extern src/pipeline/pipeline.sx
else
  echo "gen_bootstrap_gens: pinned pipeline_gen.c ($(wc -c < pipeline_gen.c | tr -d ' ') bytes)"
fi

gen_one typeck_gen.c 1 -L .. -L src -L src/lexer -L src/ast -L src/parser src/typeck/typeck.sx -E-extern || true
gen_one codegen_gen.c 1 -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck src/codegen/codegen.sx -E-extern || true
gen_one parser_gen.c 1 -L .. -L src/lexer -L src/ast -E -E-extern src/parser/parser.sx || true
gen_one lexer_gen.c 1 -L src/lexer -E -E-extern src/lexer/lexer.sx || true
gen_one driver_gen.c 1 $MAIN_DIRS -E -E-extern src/main.sx || true
gen_one preprocess_gen.c 1 -L src/preprocess -E -E-extern src/preprocess/preprocess.sx || true
gen_one lsp_io_gen.c 1 $LSP_DIRS -E -E-extern src/lsp/lsp_io.sx || true
gen_one lsp_gen.c 1 $LSP_DIRS -E -E-extern src/lsp/lsp.sx || true
gen_one lsp_diag_gen.c 1 $LSP_DIRS -E -E-extern src/lsp/lsp_diag.sx || true
gen_one lsp_io_std_heap_gen.c 1 $LSP_DIRS -E -E-extern src/lsp/lsp_io_std_heap.sx || true
for sub in fmt check test compile build run emit; do
  gen_one "driver_${sub}_gen.c" 1 $DRIVER_DIRS -E -E-extern "src/driver/${sub}.sx" || true
done

for req in typeck_gen.c codegen_gen.c parser_gen.c lexer_gen.c driver_gen.c preprocess_gen.c; do
  if [ ! -s "$req" ]; then
    echo "gen_bootstrap_gens: missing required $req" >&2
    exit 1
  fi
done

echo "gen_bootstrap_gens: build-seed-asm-host (asm.sx -E via LEGACY shux-c) ..."
SHUX_E=./shux-c ./scripts/build_seed_asm_host.sh

echo "gen_bootstrap_gens OK"
