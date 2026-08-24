#!/usr/bin/env bash
# F-math v1：std.math 去 C（math.c → math.x + seeds/runtime_math_libm.from_x.c）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_MATH_V1_FAIL:-0}
DOC="analysis/archive/phase/phase-f-math-v1.md"
MANIFEST="tests/baseline/f-math-v1-closure.tsv"
die() { echo "f-math-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-math v1: std.math math.c → math.x + runtime libm ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-math v1' "$DOC" || die "doc marker"
[ -f "$MANIFEST" ] || die "missing manifest"
[ -f std/math/math.x ] || die "missing math.x"
[ -f compiler/seeds/runtime_math_libm.from_x.c ] || die "missing runtime_math_libm.inc"
[ ! -f std/math/math_libm_glue.c ] || die "math_libm_glue.c should be deleted"
[ ! -f std/math/math.c ] || die "math.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/math/math.o >/dev/null 2>&1 || die "ensure math.o failed (xlang_compiler_make)"
else
  echo "f-math-v1 SKIP math.o build (no xlang-c)" >&2
fi
for sub in run-std-math-special-gate.sh run-std-math-fenv-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-math-v1 std.math gate OK"
