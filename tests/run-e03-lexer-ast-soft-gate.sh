#!/usr/bin/env bash
# E-03 v2 lexer/ast：lexer.c / ast_seed.o 软退役门禁（默认不链，文件保留）。
#
# 用法：./tests/run-e03-lexer-ast-soft-gate.sh
# 环境：
#   SHUX_E03_LEXER_AST_FAIL=1           — 失败时硬退出
#   SHUX_E03_LEXER_AST_MANIFEST_ONLY=1  — 仅 manifest
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_E03_LEXER_AST_FAIL:-0}
DOC="analysis/phase-e-e03-v2-lexer-ast.md"
MF="compiler/Makefile"
LEXER_C="compiler/src/lexer/lexer.c"
AST_C="compiler/src/ast/ast.c"

die() {
  echo "e03-lexer-ast gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== E-03 v2 lexer/ast: soft-retire (default no lexer.o / ast_seed.o) ==="
for f in "$DOC" "$MF" "$LEXER_C" "$AST_C"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-03 v2 lexer/ast' "$DOC" || die "doc missing E-03 v2 lexer/ast marker"
grep -q 'LEXER_LINK_O' "$MF" || die "Makefile missing LEXER_LINK_O"
grep -q 'AST_LINK_O' "$MF" || die "Makefile missing AST_LINK_O"
grep -q 'SHUX_LEGACY_SEED_LEXER_AST' "$MF" || die "Makefile missing SHUX_LEGACY_SEED_LEXER_AST"
grep -q 'Phase E soft-retired' "$LEXER_C" || die "lexer.c missing Phase E marker"
grep -q 'Phase E soft-retired' "$AST_C" || die "ast.c missing Phase E marker"

# DRIVER_SEED_OBJS 默认不得硬编码 lexer.o / ast_seed.o
if sed -n '/^DRIVER_SEED_OBJS =/,/^$/p' "$MF" | grep -qE 'src/lexer/lexer\.o|src/ast/ast_seed\.o'; then
  die "DRIVER_SEED_OBJS still hardcodes lexer.o or ast_seed.o (use LEXER_LINK_O / AST_LINK_O)"
fi

# 默认 LEXER_LINK_O / AST_LINK_O 须为空
if ! awk '/^ifeq \(\$\(SHUX_LEGACY_C_FRONTEND\),1\)/,/^endif/' "$MF" | grep -q '^LEXER_LINK_O = src/lexer/lexer.o'; then
  die "Makefile E-03 lexer/ast block missing legacy lexer.o"
fi
if ! awk '/^else$/,/^endif/' "$MF" | grep -q '^LEXER_LINK_O =$'; then
  die "Makefile E-03 block missing empty LEXER_LINK_O default"
fi

# bootstrap 链接行不得硬编码 lexer.o / ast_seed.o
if grep -E 'bootstrap-driver-seed:|^shux-x:' "$MF" | grep -qE 'src/lexer/lexer\.o|src/ast/ast_seed\.o'; then
  die "Makefile bootstrap link still hardcodes lexer.o or ast_seed.o"
fi

echo "e03 track: OBJS_CORE still lists lexer.o / ast.o (shux-c cold start; defer E-03 v3)"
echo "e03 track: build_shux_asm SEED still cc -c lexer/ast (strict relink archaeology; defer)"

if [ "${SHUX_E03_LEXER_AST_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "e03 lexer-ast soft-retire gate OK (manifest only)"
  exit 0
fi

echo "e03 lexer-ast soft-retire gate OK (default LEXER/AST_LINK_O=empty; LEGACY=SHUX_LEGACY_SEED_LEXER_AST=1)"
