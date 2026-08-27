#!/usr/bin/env bash
# C-04 parser -E-extern archaeology honesty under product NO_C_FRONTEND.
#
# Usage: ./tests/run-parser-e-extern-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-parser-e-extern-gate.sh
# 2026-08-27: Honesty — hard-fail structural + prefer-asm probe that product
# refuses -E-extern with BLD001/NO_C_FRONTEND. Soft XLANG_PARSER_E_EXTERN_FAIL
# retired. Root: soft die→exit0 + parser -E-extern+cc batch while every
# product binary refuses -E-extern = portable false-green / prefer-c dual
# authority. Full -E-extern+cc batch retired. Report refuse=/skip=.
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
PREFIX="xlang: [XLANG_PARSER_E_EXTERN]"
PROBE="compiler/src/parser/parser.x"

REFUSE_OK=0
SKIP=1

die() {
  echo "parser-e-extern-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail refuse=${REFUSE_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

echo "=== parser -E-extern archaeology (honesty; NO_C_FRONTEND refuse) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
grep -q 'C-04' "$DOC" || die "doc missing C-04 marker"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f "$PROBE" ] || die "missing $PROBE"

if ! XLANG_BIN="$(prefer_asm_resolve_xlang 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
SKIP=0

prefer_asm_assert_e_extern_refuse "$XLANG_BIN" "$PROBE" \
  || die "product refuse probe failed for $PROBE"
REFUSE_OK=1

echo "parser-e-extern-gate OK (refuse=${REFUSE_OK}; -E-extern+cc batch retired)"
echo "${PREFIX} status=ok refuse=${REFUSE_OK} skip=${SKIP} host=$(ci_host_summary)"
