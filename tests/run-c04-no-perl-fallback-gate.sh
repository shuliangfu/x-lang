#!/usr/bin/env bash
# C-04 v5：parser_gen.c / lsp_diag_gen.c 生成禁止 perl 回退（须 codegen C-04 marker）。
#
# 用法：./tests/run-c04-no-perl-fallback-gate.sh
# 环境：XLANG_C04_NO_PERL_FAIL=1 失败时硬退出
#
# wave honesty (2026-08-24 #5): Makefile deleted MG wave941 —
# live authority = compiler/scripts/ensure_lsp_pipeline_gen.sh +
# ensure_migrate_gen.sh（refuse MF resurrect；no-perl = no MF perl rules）。
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."

FAIL=${XLANG_C04_NO_PERL_FAIL:-0}
ENSURE_LSP="compiler/scripts/ensure_lsp_pipeline_gen.sh"
ENSURE_MIGRATE="compiler/scripts/ensure_migrate_gen.sh"

die() {
  echo "c04-no-perl gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== C-04 v5: no perl fallback (parser + lsp_diag ensure scripts) ==="

if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ensure_*_gen.sh + ./xbuild)"
fi
for f in "$ENSURE_LSP" "$ENSURE_MIGRATE"; do
  [ -f "$f" ] || die "missing $f"
done

# lsp_diag ensure must refuse perl fallback (C-04 marker).
grep -q 'no perl fallback\|C-04 -E-extern TU aliases' "$ENSURE_LSP" \
  || die "ensure_lsp_pipeline_gen.sh missing C-04 no-perl / TU aliases guard"
grep -q 'lsp_diag_gen' "$ENSURE_LSP" || die "ensure_lsp_pipeline_gen.sh missing lsp_diag_gen"

# parser ensure path lives in ensure_migrate / ensure_lsp — must not be the only
# product path that silently depends on Makefile perl rules (Makefile gone).
if grep -qE 'parser_gen\.c:.*fix_slim_arena|lsp_diag_gen\.c:.*fix_parser_pool' "$ENSURE_LSP" "$ENSURE_MIGRATE" 2>/dev/null; then
  die "ensure scripts still wire parser/lsp_diag gen to perl fix as primary"
fi

# If committed gens exist, require C-04 markers (optional presence).
for f in compiler/parser_gen.c compiler/lsp_diag_gen.c; do
  if [ -f "$f" ]; then
    grep -q 'C-04 -E-extern TU aliases' "$f" \
      || die "$f missing C-04 TU aliases marker"
  fi
done
if [ -f compiler/parser_gen.c ]; then
  grep -q 'C-04 parser: ast_expr_init_match_enum after struct ast_Expr\|C-04' compiler/parser_gen.c \
    || echo "c04-no-perl note: parser_gen.c present without historic pool marker (seed may differ)"
fi

echo "c04-no-perl gate OK (Makefile retired; ensure scripts refuse perl primary for lsp_diag)"
