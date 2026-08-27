#!/usr/bin/env bash
# C-04 v1 aggregate: -E-extern archaeology honesty under product NO_C_FRONTEND.
#
# Usage: ./tests/run-c04-e-extern-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-c04-e-extern-gate.sh
# 2026-08-26: soft XLANG_C04_FAIL retired (die always hard).
# 2026-08-27: Honesty — prefer-asm refuse probe hard-required (BLD001 /
# NO_C_FRONTEND); soft SKIP exit0 when product refuses retired (was portable
# false-green while children still soft-exit0 on -E-extern+cc). Children
# rewritten to refuse probes; -E-extern+cc batch retired. Report
# refuse=/subs=/noperl=/skip=.
# Authority refuse: tests/lib/prefer-asm-e-extern-refuse.sh
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/prefer-asm-e-extern-refuse.sh
source "$(dirname "$0")/lib/prefer-asm-e-extern-refuse.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_C04_DOC:-analysis/archive/phase/phase-c-c04-v1.md}"
MANIFEST="tests/baseline/c04-e-extern-manifest.tsv"
ENSURE_MIGRATE="compiler/scripts/ensure_migrate_gen.sh"
PREFIX="xlang: [XLANG_C04]"
PROBE="compiler/src/lsp/lsp_io.x"

REFUSE_OK=0
SUBS=0
NOPERL=0
SKIP=1

die() {
  echo "c04 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail refuse=${REFUSE_OK:-0} subs=${SUBS:-0} noperl=${NOPERL:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

run_sub() {
  local script="$1"
  chmod +x "$script"
  if ! "$script"; then
    die "sub-gate failed: $script"
  fi
  SUBS=$((SUBS + 1))
}

echo "=== C-04: -E-extern archaeology (honesty; NO_C_FRONTEND refuse) ==="
for f in "$DOC" "$MANIFEST" "$ENSURE_MIGRATE" "$PROBE"; do
  [ -f "$f" ] || die "missing $f"
done
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
grep -q 'C-04' "$DOC" || die "doc missing C-04 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"

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

if ! XLANG_BIN="$(prefer_asm_resolve_xlang 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
SKIP=0

prefer_asm_assert_e_extern_refuse "$XLANG_BIN" "$PROBE" \
  || die "product refuse probe failed for $PROBE"
REFUSE_OK=1

echo "=== C-04: delegate honesty sub-gates ==="
run_sub tests/run-e-extern-import-gate.sh
run_sub tests/run-lexer-e-extern-gate.sh
run_sub tests/run-pipeline-e-extern-gate.sh
run_sub tests/run-parser-e-extern-gate.sh
run_sub tests/run-c04-no-perl-fallback-gate.sh
NOPERL=1

echo "c04 e-extern gate OK (refuse=${REFUSE_OK} subs=${SUBS} noperl=${NOPERL}; -E-extern+cc deferred/retired)"
echo "${PREFIX} status=ok refuse=${REFUSE_OK} subs=${SUBS} noperl=${NOPERL} skip=${SKIP} host=$(ci_host_summary)"
