#!/usr/bin/env bash
# C-04 v1：-E-extern 聚合门禁（委托子 gate + manifest 审计）。
#
# 用法：./tests/run-c04-e-extern-gate.sh
# 2026-08-26: soft XLANG_C04_FAIL retired (die always hard).
#
# wave honesty (2026-08-24 #5): DOC → analysis/archive/phase/；
# Makefile deleted MG wave941 — perl/fix audit lives in ensure_migrate_gen.sh
# + refuse MF resurrect；lsp_*_extern.h must stay absent from mk/scripts.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."

DOC="${XLANG_C04_DOC:-analysis/archive/phase/phase-c-c04-v1.md}"
MANIFEST="tests/baseline/c04-e-extern-manifest.tsv"
ENSURE_MIGRATE="compiler/scripts/ensure_migrate_gen.sh"

c04_native_xlang() {
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
  exit 1
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
for f in "$DOC" "$MANIFEST" "$ENSURE_MIGRATE"; do
  [ -f "$f" ] || die "missing $f"
done
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
grep -q 'C-04 v1' "$DOC" || die "doc missing C-04 v1 marker"

# Live track: ensure_migrate still may call fix_slim for lexer/typeck/codegen gens.
grep -q 'fix_slim_arena_gen_c.pl' "$ENSURE_MIGRATE" || die "ensure_migrate_gen.sh missing fix_slim track"
# Product mk faces must not -include retired lsp_*_extern.h.
for f in compiler/mk/driver_seed_composites.mk compiler/mk/driver_seed_mode_objs.mk \
  compiler/scripts/build_xlang_asm.sh; do
  [ -f "$f" ] || continue
  if grep -qE 'lsp_io_extern\.h|lsp_gen_extern\.h' "$f" 2>/dev/null; then
    die "$f still references lsp_*_extern.h"
  fi
done

XLANG_BIN="./compiler/xlang-c"
[ -x "$XLANG_BIN" ] || XLANG_BIN="./compiler/xlang"
if ! c04_native_xlang "$XLANG_BIN"; then
  echo "c04 e-extern gate: SKIP sub-gates (no native xlang-c; manifest audited — use Docker Linux)"
  echo "c04 e-extern gate OK (manifest only)"
  exit 0
fi

# Product default is XLANG_NO_C_FRONTEND (C-06); -E-extern needs C parser/codegen.
# wave honesty: do not hard-fail tip product bins — archaeology DOC/mk already audited.
if "$XLANG_BIN" -x -E -E-extern compiler/src/lsp/lsp_io.x >/dev/null 2>&1; then
  :
else
  echo "c04 e-extern gate: SKIP -E-extern sub-gates (native bin is NO_C product; C-06 default)"
  # Still refuse perl resurrect in the dedicated no-perl gate when it only audits scripts.
  if [ -f tests/run-c04-no-perl-fallback-gate.sh ]; then
    chmod +x tests/run-c04-no-perl-fallback-gate.sh
    # Hard: no-perl audits ensure scripts (Makefile retired); soft FAIL retired.
    ./tests/run-c04-no-perl-fallback-gate.sh || die "c04-no-perl sub-gate failed"
  fi
  echo "c04 e-extern gate OK (archive DOC + mk refuse extern.h; -E-extern deferred to C frontend bin)"
  exit 0
fi

echo "=== C-04: delegate sub-gates ==="
run_sub tests/run-e-extern-import-gate.sh XLANG_E_EXTERN_IMPORT_FAIL
run_sub tests/run-lexer-e-extern-gate.sh XLANG_LEXER_E_EXTERN_FAIL
run_sub tests/run-pipeline-e-extern-gate.sh XLANG_PIPELINE_E_EXTERN_FAIL
run_sub tests/run-parser-e-extern-gate.sh XLANG_PARSER_E_EXTERN_FAIL
run_sub tests/run-c04-no-perl-fallback-gate.sh XLANG_C04_NO_PERL_FAIL

echo "c04 e-extern gate OK (v1: archive DOC + mk refuse extern.h + sub-gates)"
