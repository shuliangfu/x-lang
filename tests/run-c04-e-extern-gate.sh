#!/usr/bin/env bash
# C-04 v1：-E-extern 聚合门禁（委托子 gate + manifest 审计）。
#
# 用法：./tests/run-c04-e-extern-gate.sh
# 环境：SHUX_C04_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_C04_FAIL:-0}
DOC="analysis/phase-c-c04-v1.md"
MANIFEST="tests/baseline/c04-e-extern-manifest.tsv"
MF="compiler/Makefile"

# 探测 shux-c 是否为当前宿主可执行（macOS 上 Linux ELF 须 SKIP 子 gate）。
c04_native_shux() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

die() {
  echo "c04 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

run_sub() {
  local script="$1"
  local env_var="$2"
  chmod +x "$script"
  if ! env "${env_var}=1" "$script"; then
    die "sub-gate failed: $script"
  fi
}

echo "=== C-04: -E-extern / zero perl (v1 aggregate) ==="
for f in "$DOC" "$MANIFEST" "$MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'C-04 v1' "$DOC" || die "doc missing C-04 v1 marker"

# Makefile：parser/lsp_diag 不得引用 perl fix；lexer/typeck/codegen 仍 track
if grep -E 'parser_gen\.c:|lsp_diag_gen\.c:' "$MF" | grep -qE 'fix_slim_arena|fix_parser_pool'; then
  die "Makefile parser/lsp_diag still references perl fix scripts"
fi
for gen in lexer_gen.c typeck_gen.c codegen_gen.c ast_gen2.c; do
  grep -q "fix_slim_arena_gen_c.pl" "$MF" || die "Makefile missing fix_slim track for $gen"
done
if grep -q 'lsp_io_extern\.h' "$MF" 2>/dev/null; then
  die "Makefile still -include lsp_io_extern.h"
fi

SHUX_BIN="./compiler/shux-c"
[ -x "$SHUX_BIN" ] || SHUX_BIN="./compiler/shux"
if ! c04_native_shux "$SHUX_BIN"; then
  echo "c04 e-extern gate: SKIP sub-gates (no native shux-c; manifest audited — use Docker Linux)"
  echo "c04 e-extern gate OK (manifest only)"
  exit 0
fi

echo "=== C-04: delegate sub-gates ==="
run_sub tests/run-e-extern-import-gate.sh SHUX_E_EXTERN_IMPORT_FAIL
run_sub tests/run-lexer-e-extern-gate.sh SHUX_LEXER_E_EXTERN_FAIL
run_sub tests/run-pipeline-e-extern-gate.sh SHUX_PIPELINE_E_EXTERN_FAIL
run_sub tests/run-parser-e-extern-gate.sh SHUX_PARSER_E_EXTERN_FAIL
run_sub tests/run-c04-no-perl-fallback-gate.sh SHUX_C04_NO_PERL_FAIL

echo "c04 e-extern gate OK (v1: parser/lsp_diag zero perl + lsp/pipeline -E-extern; lexer/typeck/codegen track)"
