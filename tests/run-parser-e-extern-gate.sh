#!/usr/bin/env bash
# C-04 parser：parser.x -E-extern codegen TU 别名 + cc -c（无 fix_slim/fix_parser_pool perl 时亦须过）。
# 用法：./tests/run-parser-e-extern-gate.sh
# 环境：SHUX_PARSER_E_EXTERN_FAIL=1 失败时硬退出
# 注：fix_slim_arena 仍须 parser_gen.c 文件名（内部 TU 别名扫描）；gate 在临时目录生成该名。
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/compiler"

FAIL=${SHUX_PARSER_E_EXTERN_FAIL:-0}
SHUX="${SHUX:-./shux-c}"
DIRS="-L .. -L src/lexer -L src/ast"
GENDIR="/tmp/shux_parser_eextern_$$"
GEN="$GENDIR/parser_gen.c"
OBJ="$GENDIR/parser_gen.o"

PIPE_CFLAGS="-Wno-unused-variable -Wno-unused-parameter -Wno-unused-function -Wno-parentheses -Wno-sign-compare -Wno-ignored-qualifiers -Wno-unused-but-set-variable -Wno-type-limits"
if cc -v 2>&1 | grep -q clang; then
  PIPE_CFLAGS="$PIPE_CFLAGS -Wno-logical-op-parentheses -Wno-bitwise-op-parentheses -Wno-incompatible-pointer-types-discards-qualifiers"
fi

if [ ! -x "$SHUX" ]; then
  SHUX="./shux"
fi
if [ ! -x "$SHUX" ]; then
  echo "parser-e-extern-gate: SKIP (no shux/shux-c)"
  exit 0
fi

rm -rf "$GENDIR" 2>/dev/null || true
mkdir -p "$GENDIR"

GEN_OK=0
if [ -x "./shux-x" ] && ./shux-x -x -E $DIRS -E-extern src/parser/parser.x >"$GEN" 2>/tmp/shux_parser_e_extern_x.log \
  && grep -q 'lexer_advance_one' "$GEN"; then
  GEN_OK=1
fi
if [ "$GEN_OK" = "0" ]; then
  if ! "$SHUX" $DIRS src/parser/parser.x -E -E-extern >"$GEN" 2>/tmp/shux_parser_e_extern_gen.log; then
    echo "parser-e-extern-gate FAIL: parser -E-extern" >&2
    tail -n 10 /tmp/shux_parser_e_extern_gen.log 2>/dev/null || true
    rm -rf "$GENDIR" 2>/dev/null || true
    [ "$FAIL" = "1" ] && exit 1
    exit 0
  fi
fi

if ! grep -q 'C-04 -E-extern TU aliases' "$GEN"; then
  echo "parser-e-extern-gate FAIL: missing codegen TU aliases block" >&2
  rm -rf "$GENDIR" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
if ! grep -q '#define ast_arena_expr_set ast_ast_arena_expr_set' "$GEN"; then
  echo "parser-e-extern-gate FAIL: missing ast_arena TU alias" >&2
  rm -rf "$GENDIR" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
if ! grep -qE '#define lexer_init lexer_lexer_init' "$GEN"; then
  echo "parser-e-extern-gate FAIL: missing lexer_init TU alias" >&2
  rm -rf "$GENDIR" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if ! grep -q 'C-04 parser: ast_expr_init_match_enum after struct ast_Expr' "$GEN" 2>/dev/null; then
  echo "parser-e-extern-gate FAIL: missing C-04 parser pool marker (no perl fallback)" >&2
  rm -rf "$GENDIR" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if ! cc -I.. -I. -Iinclude -Isrc $PIPE_CFLAGS \
  -Dstd_io_driver_driver_read_ptr_len=shux_io_read_ptr_len \
  -Dstd_io_driver_driver_read_ptr=shux_io_read_ptr \
  -c "$GEN" -o "$OBJ" 2>/tmp/shux_parser_e_extern_cc.log; then
  echo "parser-e-extern-gate FAIL: cc -c parser_gen" >&2
  tail -n 15 /tmp/shux_parser_e_extern_cc.log 2>/dev/null || true
  rm -rf "$GENDIR" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rm -rf "$GENDIR" 2>/dev/null || true
echo "parser-e-extern-gate OK (parser -E-extern codegen TU aliases + cc -c)"
exit 0
