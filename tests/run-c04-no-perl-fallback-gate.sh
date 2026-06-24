#!/usr/bin/env bash
# C-04 v5：Makefile 生成 parser_gen.c / lsp_diag_gen.c 时禁止 perl 回退（须 codegen C-04 marker）。
#
# 用法：./tests/run-c04-no-perl-fallback-gate.sh
# 环境：SHUX_C04_NO_PERL_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_C04_NO_PERL_FAIL:-0}
LOG="/tmp/shux_c04_no_perl_$$.log"

echo "=== C-04 v5: Makefile no perl fallback (parser + lsp_diag) ==="

if [ ! -f compiler/Makefile ]; then
  echo "c04-no-perl gate FAIL: missing compiler/Makefile" >&2
  exit 1
fi
if grep -E 'parser_gen\.c:|lsp_diag_gen\.c:' compiler/Makefile | grep -q 'fix_slim_arena\|fix_parser_pool'; then
  echo "c04-no-perl gate FAIL: Makefile parser/lsp_diag still references perl fix scripts" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c >/dev/null
rm -f compiler/parser_gen.c compiler/lsp_diag_gen.c 2>/dev/null || true

if ! make -C compiler parser_gen.c lsp_diag_gen.c 2>"$LOG" | tee -a "$LOG"; then
  echo "c04-no-perl gate FAIL: make parser_gen.c/lsp_diag_gen.c" >&2
  tail -n 12 "$LOG" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if grep -qE 'fix_slim_arena|fix_parser_pool' "$LOG" 2>/dev/null; then
  echo "c04-no-perl gate FAIL: build log mentions perl fix scripts" >&2
  grep -E 'fix_slim_arena|fix_parser_pool' "$LOG" >&2 || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

for f in parser_gen.c lsp_diag_gen.c; do
  if ! grep -q 'C-04 -E-extern TU aliases' "compiler/$f" 2>/dev/null; then
    echo "c04-no-perl gate FAIL: compiler/$f missing C-04 TU aliases" >&2
    [ "$FAIL" = "1" ] && exit 1
    exit 0
  fi
done
if ! grep -q 'C-04 parser: ast_expr_init_match_enum after struct ast_Expr' compiler/parser_gen.c 2>/dev/null; then
  echo "c04-no-perl gate FAIL: parser_gen.c missing C-04 parser pool marker" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rm -f "$LOG" 2>/dev/null || true
echo "c04-no-perl gate OK (parser_gen + lsp_diag_gen, zero perl)"
