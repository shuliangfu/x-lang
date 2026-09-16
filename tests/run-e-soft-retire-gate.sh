#!/usr/bin/env bash
# Phase E-soft aggregate: manifest + E-01/E-02/E-03-lexer + C-03/C-04/C-06/C-09.
#
# Usage: ./tests/run-e-soft-retire-gate.sh
#        XLANG_E_SOFT_MANIFEST_ONLY=1 ./tests/run-e-soft-retire-gate.sh
# 2026-08-26: Honesty — hard-fail archive DOC + mk audit + child gates
# (no soft die→exit0; no soft child FAIL pass-through). Soft
# XLANG_E_SOFT_FAIL retired. Gate was portable-false-green (soft FAIL
# exit0 while archive DOC + sub-gates already green; TSV listed
# e03-lexer-ast but aggregate never delegated it; e03-lexer itself was
# fossil false-green on deleted Makefile / top-level DOC).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_E_SOFT_DOC:-analysis/archive/phase/phase-e-soft-v2-closure.md}"
DOC_V1="${XLANG_E_SOFT_DOC_V1:-analysis/archive/phase/phase-e-soft-v1.md}"
MANIFEST="tests/baseline/phase-e-soft-retire.tsv"
PREFIX="xlang: [XLANG_E_SOFT]"

die() {
  echo "e-soft gate FAIL: $*" >&2
  echo "${PREFIX} status=fail manifest=${MANIFEST_OK:-0} e01=${E01_OK:-0} e02=${E02_OK:-0} e03_lexer=${E03_OK:-0} c06=${C06_OK:-0} c09=${C09_OK:-0} c03=${C03_OK:-0} c04=${C04_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

MANIFEST_OK=0
E01_OK=0
E02_OK=0
E03_OK=0
C06_OK=0
C09_OK=0
C03_OK=0
C04_OK=0
SKIP=1

run_child() {
  local script="$1"
  local label="$2"
  [ -f "$script" ] || die "missing $script"
  echo "=== E-soft: delegate $(basename "$script") (hard) ==="
  chmod +x "$script"
  if ! "$script"; then
    die "$label sub-gate failed"
  fi
}

echo "=== E-soft v2: compiler C/H soft-retire CLOSED (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$DOC_V1" ] || die "missing $DOC_V1"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
grep -q 'E-soft v2' "$DOC" || die "doc missing E-soft v2 closure marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
grep -q 'E-soft v1' "$DOC_V1" || die "doc missing E-soft v1 marker"
if [ -f analysis/phase-e-soft-v2-closure.md ] || [ -f analysis/phase-e-soft-v1.md ]; then
  die "top-level E-soft DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use mk/driver_seed_*.mk + ./xbuild)"
fi
if [ -f compiler/seeds/runtime.from_x.c ]; then
  die "seeds/runtime.from_x.c resurrected"
fi
[ -f xbuild ] || die "missing xbuild"

# shellcheck source=tests/lib/phase-e-soft-audit.sh
. tests/lib/phase-e-soft-audit.sh

if ! phase_e_soft_audit_manifest "$MANIFEST"; then
  die "phase-e-soft-retire manifest audit failed"
fi
if ! phase_e_soft_audit_makefile_no_c_frontend; then
  die "mk default seed still links C frontend"
fi

ret_n=$(phase_e_soft_count_retired "$MANIFEST")
act_n=$(phase_e_soft_count_active "$MANIFEST")
echo "e-soft: soft_retired=${ret_n} active_c=${act_n} (files on disk; default B-strict skips retired)"
MANIFEST_OK=1

if [ "${XLANG_E_SOFT_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=0
  echo "e-soft gate OK (manifest only)"
  echo "${PREFIX} status=ok manifest=${MANIFEST_OK} e01=${E01_OK} e02=${E02_OK} e03_lexer=${E03_OK} c06=${C06_OK} c09=${C09_OK} c03=${C03_OK} c04=${C04_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

# Hard-delegate children. Do NOT export retired XLANG_*_FAIL envs.
# PLATFORM: SHARED archaeology.
run_child tests/run-e01-extern-h-soft-gate.sh e01
E01_OK=1

run_child tests/run-e03-lexer-ast-soft-gate.sh e03-lexer-ast
E03_OK=1

run_child tests/run-c06-x-frontend-default-gate.sh c06
C06_OK=1

run_child tests/run-c09-parser-no-c-fallback-gate.sh c09
C09_OK=1

if [ -f tests/run-c03-no-pipeline-gen-gate.sh ]; then
  run_child tests/run-c03-no-pipeline-gen-gate.sh c03
  C03_OK=1
fi

if [ -f tests/run-c04-e-extern-gate.sh ]; then
  run_child tests/run-c04-e-extern-gate.sh c04
  C04_OK=1
fi

if [ -f tests/run-e02-lsp-diag-soft-gate.sh ]; then
  run_child tests/run-e02-lsp-diag-soft-gate.sh e02
  E02_OK=1
fi

SKIP=0
echo "e-soft retire gate OK (archive DOC + mk DRIVER_SEED + hard sub-gates)"
echo "${PREFIX} status=ok manifest=${MANIFEST_OK} e01=${E01_OK} e02=${E02_OK} e03_lexer=${E03_OK} c06=${C06_OK} c09=${C09_OK} c03=${C03_OK} c04=${C04_OK} skip=${SKIP} host=$(ci_host_summary)"
