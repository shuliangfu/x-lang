#!/usr/bin/env bash
# F closure: std -E-extern archaeology honesty under product NO_C_FRONTEND.
#
# Usage: ./tests/run-f-closure-e-extern-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-closure-e-extern-gate.sh
# 2026-08-27: Honesty — hard-fail structural + prefer-asm probe that product
# refuses -E-extern with BLD001/NO_C_FRONTEND. Soft XLANG_F_CLOSURE_FAIL
# retired. Root: soft die→exit0 + undefined die + cwd-broken Makefile/xbuild
# checks swallowed 71/71 FAIL_XLANGC while every product binary refuses
# -E-extern (C frontend gone) = portable false-green / prefer-c archaeology
# dual authority. Full -E-extern+cc batch retired (cannot green on product
# pure-asm). Report refuse=/mods=/skip=.
# Authority refuse: tests/lib/prefer-asm-e-extern-refuse.sh (G.7 single path).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/prefer-asm-e-extern-refuse.sh
source "$(dirname "$0")/lib/prefer-asm-e-extern-refuse.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-closure-e-extern.md"
PREFIX="xlang: [XLANG_F_CLOSURE]"
PROBE_MOD="std/cli/mod.x"

REFUSE_OK=0
MODS=0
SKIP=1

die() {
  echo "f-closure-e-extern-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail refuse=${REFUSE_OK:-0} mods=${MODS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

echo "=== F closure -E-extern archaeology (honesty; NO_C_FRONTEND refuse) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-closure-e-extern' "$DOC" || die "doc missing F-closure-e-extern marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f "$PROBE_MOD" ] || die "missing $PROBE_MOD"

MODS=$(find std -name "mod.x" -type f 2>/dev/null | wc -l | tr -d ' ')
[ "$MODS" -gt 0 ] || die "no std/**/mod.x found"

if ! XLANG_BIN="$(prefer_asm_resolve_xlang 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
SKIP=0

prefer_asm_assert_e_extern_refuse "$XLANG_BIN" "$PROBE_MOD" \
  || die "product refuse probe failed for $PROBE_MOD"
REFUSE_OK=1

echo "f-closure-e-extern-gate OK (refuse=${REFUSE_OK} mods=${MODS}; -E-extern+cc batch retired)"
echo "${PREFIX} status=ok refuse=${REFUSE_OK} mods=${MODS} skip=${SKIP} host=$(ci_host_summary)"
