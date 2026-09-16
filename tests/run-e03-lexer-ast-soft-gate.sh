#!/usr/bin/env bash
# E-03 v2 lexer/ast: lexer.c / ast.c hard-retired; default seed leaves
# LEXER_LINK_O / AST_LINK_O empty (X frontend via lexer_x / ast_pool).
#
# Usage: ./tests/run-e03-lexer-ast-soft-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-e03-lexer-ast-soft-gate.sh
# 2026-08-26: Honesty — hard-fail archive DOC + mk picks + absent .c
# (no soft die→exit0). Soft XLANG_E03_LEXER_AST_FAIL retired. Live face =
# compiler/mk/driver_seed_link_picks.mk + lexer.x / ast.x. Gate was
# portable-false-green (top-level DOC after archive; Makefile greps after
# Makefile deleted; Phase E marker on deleted lexer.c/ast.c; soft FAIL
# exit0). PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_E03_LEXER_AST_DOC:-analysis/archive/phase/phase-e-e03-v2-lexer-ast.md}"
MK_PICKS="${XLANG_E03_MK_PICKS:-compiler/mk/driver_seed_link_picks.mk}"
MK_COMPOSITES="${XLANG_E03_MK_COMPOSITES:-compiler/mk/driver_seed_composites.mk}"
LEXER_X="compiler/src/lexer/lexer.x"
AST_X="compiler/src/ast/ast.x"
PREFIX="xlang: [XLANG_E03_LEXER_AST]"

die() {
  echo "e03-lexer-ast gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} mk=${MK_OK:-0} absent=${ABSENT_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
MK_OK=0
ABSENT_OK=0
SKIP=1

echo "=== E-03 v2 lexer/ast: hard-retire honesty (live mk LEXER/AST_LINK_O) ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$MK_PICKS" ] || die "missing $MK_PICKS"
[ -f "$MK_COMPOSITES" ] || die "missing $MK_COMPOSITES"
[ -f "$LEXER_X" ] || die "missing $LEXER_X"
[ -f "$AST_X" ] || die "missing $AST_X"
[ -f xbuild ] || die "missing xbuild"

grep -q 'E-03 v2 lexer/ast' "$DOC" || die "doc missing E-03 v2 lexer/ast marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-e-e03-v2-lexer-ast.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use mk/driver_seed_*.mk + ./xbuild)"
fi

# G-02a: C sources must stay deleted.
if [ -f compiler/src/lexer/lexer.c ]; then
  die "compiler/src/lexer/lexer.c resurrected (hard-retired; live = lexer.x)"
fi
if [ -f compiler/src/ast/ast.c ]; then
  die "compiler/src/ast/ast.c resurrected (hard-retired; live = ast.x / ast_pool)"
fi
ABSENT_OK=1

grep -q 'LEXER_LINK_O' "$MK_PICKS" || die "$MK_PICKS missing LEXER_LINK_O"
grep -q 'AST_LINK_O' "$MK_PICKS" || die "$MK_PICKS missing AST_LINK_O"
grep -q 'XLANG_LEGACY_SEED_LEXER_AST' "$MK_PICKS" || die "$MK_PICKS missing XLANG_LEGACY_SEED_LEXER_AST"

# Default (non-LEGACY) branch must leave empty LEXER_LINK_O / AST_LINK_O.
# PLATFORM: SHARED — product seed uses X frontend; LEGACY_* keeps C objs.
grep -qE '^LEXER_LINK_O[[:space:]]*=[[:space:]]*$' "$MK_PICKS" \
  || die "$MK_PICKS missing empty default LEXER_LINK_O"
grep -qE '^AST_LINK_O[[:space:]]*=[[:space:]]*$' "$MK_PICKS" \
  || die "$MK_PICKS missing empty default AST_LINK_O"

# DRIVER_SEED_OBJS must expand via $(LEXER_LINK_O)/$(AST_LINK_O), not hardcode C objs.
if sed -n '/^DRIVER_SEED_OBJS =/,/^$/p' "$MK_COMPOSITES" | grep -qE 'src/lexer/lexer\.o|src/ast/ast_seed\.o'; then
  die "$MK_COMPOSITES DRIVER_SEED_OBJS hardcodes lexer.o or ast_seed.o (use LEXER_LINK_O / AST_LINK_O)"
fi
grep -q '\$(LEXER_LINK_O)' "$MK_COMPOSITES" || die "$MK_COMPOSITES missing \$(LEXER_LINK_O)"
grep -q '\$(AST_LINK_O)' "$MK_COMPOSITES" || die "$MK_COMPOSITES missing \$(AST_LINK_O)"

STATIC_OK=1
MK_OK=1
SKIP=0

if [ "${XLANG_E03_LEXER_AST_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "e03 lexer-ast soft-retire gate OK (manifest only)"
  echo "${PREFIX} status=ok static=${STATIC_OK} mk=${MK_OK} absent=${ABSENT_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

echo "e03 track: lexer.c/ast.c hard-retired; live lexer.x / ast.x + empty default LINK_O"
echo "e03 lexer-ast soft-retire gate OK (archive DOC + mk LINK_O empty; .c absent)"
echo "${PREFIX} status=ok static=${STATIC_OK} mk=${MK_OK} absent=${ABSENT_OK} skip=${SKIP} host=$(ci_host_summary)"
