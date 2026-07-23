#!/usr/bin/env bash
# G-02f-329：product hybrid 下 parser thin rest 业务 T 符号须为 0（P20 foundation 里程碑哨兵）。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CDIR="$ROOT/compiler"
cd "$CDIR"

CC="${CC:-cc}"
BASE_CFLAGS="-Wall -Wextra -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm"
ALL_PTHIN="
  -DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE
  -DXLANG_PTHIN_LEX_SKIP_FROM_X -DXLANG_PTHIN_LET_ALIAS_FROM_X -DXLANG_PTHIN_TYPE_REF_FROM_X
  -DXLANG_PTHIN_EXPR_PRIMARY_FROM_X -DXLANG_PTHIN_EXPR_UNARY_FROM_X -DXLANG_PTHIN_EXPR_BINOP_FROM_X
  -DXLANG_PTHIN_EXPR_AS_SUFFIX_FROM_X -DXLANG_PTHIN_EXPR_TERNARY_FROM_X
  -DXLANG_PTHIN_CTRL_FROM_X -DXLANG_PTHIN_FN_BLOCK_FROM_X -DXLANG_PTHIN_SIMD_FROM_X
  -DXLANG_PTHIN_STRETCH_FROM_X -DXLANG_PTHIN_GLUE_FROM_X -DXLANG_PTHIN_IMPORTS_FROM_X
  -DXLANG_PTHIN_SKIP_TL_FROM_X -DXLANG_PTHIN_TRY_SKIP_ALLOW_FROM_X -DXLANG_PTHIN_SKIP_IF_FROM_X
  -DXLANG_PTHIN_LIBRARY_FROM_X -DXLANG_PTHIN_DIAG_PIPELINE_FROM_X -DXLANG_PTHIN_DIAG_LATE_FROM_X
  -DXLANG_PTHIN_BODY_TL_FROM_X -DXLANG_PTHIN_HELPERS_FROM_X -DXLANG_PTHIN_FOUNDATION_FROM_X
"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# shellcheck disable=SC2086
$CC $BASE_CFLAGS $ALL_PTHIN -c -o "$TMP/rest.o" seeds/parser_asm_thin_c.from_x.c
T_COUNT=$(nm -gU "$TMP/rest.o" 2>/dev/null | awk '$2=="T" {c++} END{print c+0}')

if [ "$T_COUNT" != "0" ]; then
  echo "FAIL: product hybrid parser thin rest has $T_COUNT global T symbol(s); expected 0 (G-02f-329)" >&2
  nm -gU "$TMP/rest.o" | awk '$2=="T"{print}' >&2 || true
  exit 1
fi

echo "OK: product hybrid parser thin rest T=0 (G-02f-329 gate)"
exit 0
