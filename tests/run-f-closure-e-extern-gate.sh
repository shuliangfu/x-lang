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
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-closure-e-extern.md"
PREFIX="xlang: [XLANG_F_CLOSURE]"
PROBE_MOD="std/cli/mod.x"

REFUSE_OK=0
MODS=0
SKIP=1

resolve_shu() {
  local cand abs
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$(pwd)/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

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

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
SKIP=0

# Product pure-asm (NO_C_FRONTEND) must refuse -E-extern. Accepting success
# would resurrect prefer-c dual authority. PLATFORM: SHARED archaeology.
LOG="/tmp/xlang_f_closure_refuse.$$.log"
GEN="/tmp/xlang_f_closure_refuse.$$.c"
rm -f "$LOG" "$GEN"
set +e
"$XLANG_BIN" build -E-extern -L . "$PROBE_MOD" >"$GEN" 2>"$LOG"
RC=$?
set -e
if [ "$RC" -eq 0 ]; then
  rm -f "$LOG" "$GEN"
  die "product $XLANG_BIN accepted -E-extern (NO_C_FRONTEND expected refuse; prefer-c resurrected)"
fi
if ! grep -qE 'NO_C_FRONTEND|-E-extern requires C parser/codegen|BLD001' "$LOG"; then
  echo "f-closure-e-extern-gate: refuse log:" >&2
  tail -n 20 "$LOG" >&2 || true
  rm -f "$LOG" "$GEN"
  die "product refused -E-extern without NO_C_FRONTEND/BLD001 marker"
fi
rm -f "$LOG" "$GEN"
REFUSE_OK=1

echo "f-closure-e-extern-gate OK (refuse=${REFUSE_OK} mods=${MODS}; -E-extern+cc batch retired)"
echo "${PREFIX} status=ok refuse=${REFUSE_OK} mods=${MODS} skip=${SKIP} host=$(ci_host_summary)"
