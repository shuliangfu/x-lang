#!/usr/bin/env bash
# C-04 pipeline -E-extern archaeology honesty under product NO_C_FRONTEND.
#
# Usage: ./tests/run-pipeline-e-extern-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-pipeline-e-extern-gate.sh
# 2026-08-27: Honesty — hard-fail structural + prefer-asm probe that product
# refuses -E-extern with BLD001/NO_C_FRONTEND. Soft XLANG_PIPELINE_E_EXTERN_FAIL
# retired. Root: soft die→exit0 + -E-extern+cc batch while every product
# binary refuses -E-extern = portable false-green / prefer-c dual authority.
# Full -E-extern+cc batch retired. Report refuse=/skip=.
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired in tests/lib/prefer-asm-e-extern-refuse.sh. Explicit-bad XLANG
# / missing native = hard die FIRST (before DOC / static; refuse leftover
# ignore of explicit-bad). leftover nested -E-extern refuse probe stay.
# G.7: complete existing prefer_asm_resolve_xlang; converge dod_native_exe.
# Authority: tests/lib/prefer-asm-e-extern-refuse.sh
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/prefer-asm-e-extern-refuse.sh
source "$(dirname "$0")/lib/prefer-asm-e-extern-refuse.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-c-c04-v1.md"
PREFIX="xlang: [XLANG_PIPELINE_E_EXTERN]"
PROBE="compiler/src/pipeline/pipeline.x"

REFUSE_OK=0
SKIP=1

die() {
  echo "pipeline-e-extern-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail refuse=${REFUSE_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

# Explicit-bad XLANG dies FIRST (before DOC / leftover nested refuse probe).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(prefer_asm_resolve_xlang)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== pipeline -E-extern archaeology (honesty; NO_C_FRONTEND refuse) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
grep -q 'C-04' "$DOC" || die "doc missing C-04 marker"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f "$PROBE" ] || die "missing $PROBE"

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(prefer_asm_resolve_xlang)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
else
  XLANG_BIN="$(prefer_asm_resolve_xlang)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover XLANG fallthrough / leftover SKIP→OK / leftover auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
SKIP=0

prefer_asm_assert_e_extern_refuse "$XLANG_BIN" "$PROBE" \
  || die "product refuse probe failed for $PROBE"
REFUSE_OK=1

echo "pipeline-e-extern-gate OK (refuse=${REFUSE_OK}; -E-extern+cc batch retired)"
echo "${PREFIX} status=ok refuse=${REFUSE_OK} skip=${SKIP} host=$(ci_host_summary)"
