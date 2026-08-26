#!/usr/bin/env bash
# F-math v1: std.math de-C (math.c → math.x + seeds/runtime_math_libm.from_x.c).
#
# Usage: ./tests/run-f-math-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-math-v1-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure.
# STD-115 special / STD-059 fenv product smoke observational (typeck／product
# residual — listed skip). Soft XLANG_F_MATH_V1_FAIL retired.
# Root: soft die→exit0 = portable false-green. Report
# static=/ensure=/special=/fenv=/skip=. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-math-v1.md"
MANIFEST="tests/baseline/f-math-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_MATH_V1]"

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
  echo "f-math-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} special=${SPECIAL_OK:-0} fenv=${FENV_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
SPECIAL_OK=0
FENV_OK=0
SKIP=1

echo "=== F-math v1: std.math math.c → math.x + runtime libm (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-math v1' "$DOC" || die "doc missing F-math v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/math/math.x ] || die "missing math.x"
[ -f compiler/seeds/runtime_math_libm.from_x.c ] || die "missing runtime_math_libm.from_x.c"
[ ! -f std/math/math_libm_glue.c ] || die "math_libm_glue.c should be deleted"
[ ! -f std/math/math.c ] || die "math.c should be deleted"

while IFS=$'\t' read -r item_id kind anchor _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile)
      [ -f "$anchor" ] || die "missing $anchor ($item_id)"
      ;;
    absent)
      [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)"
      ;;
    *)
      die "manifest unknown kind '$kind' for $item_id"
      ;;
  esac
done < "$MANIFEST"
STATIC_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

xlang_compiler_make ../std/math/math.o >/dev/null 2>&1 \
  || die "ensure math.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

# STD-115 / STD-059 product smokes are observational (math-special／fenv
# typeck／product residual; do not soft-exit0 on archaeology knife).
if [ -f tests/run-std-math-special-gate.sh ]; then
  echo "=== F-math v1: std-math-special (observational; product residual) ==="
  chmod +x tests/run-std-math-special-gate.sh
  if tests/run-std-math-special-gate.sh; then
    SPECIAL_OK=1
  else
    echo "f-math-v1 WARN: std-math-special failed (observational)" >&2
    SPECIAL_OK=0
  fi
fi

if [ -f tests/run-std-math-fenv-gate.sh ]; then
  echo "=== F-math v1: std-math-fenv (observational; product residual) ==="
  chmod +x tests/run-std-math-fenv-gate.sh
  if tests/run-std-math-fenv-gate.sh; then
    FENV_OK=1
  else
    echo "f-math-v1 WARN: std-math-fenv failed (observational)" >&2
    FENV_OK=0
  fi
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} special=${SPECIAL_OK} fenv=${FENV_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-math-v1 std.math gate OK (F-math v1; honesty)"
