#!/usr/bin/env bash
# F-math v1：std.math 去 C（math.c → math.sx + runtime_math_libm.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_MATH_V1_FAIL:-0}
DOC="analysis/phase-f-math-v1.md"
MANIFEST="tests/baseline/f-math-v1-closure.tsv"
die() { echo "f-math-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-math v1: std.math math.c → math.sx + runtime libm ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-math v1' "$DOC" || die "doc marker"
[ -f "$MANIFEST" ] || die "missing manifest"
[ -f std/math/math.sx ] || die "missing math.sx"
[ -f compiler/src/asm/runtime_math_libm.c ] || die "missing runtime_math_libm.c"
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
grep -q 'runtime_math_libm' compiler/Makefile || die "Makefile missing runtime_math_libm"
if grep -q 'std/math/math\.c' compiler/Makefile 2>/dev/null; then die "Makefile still references math.c"; fi
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/math/math.o >/dev/null 2>&1 || die "make math.o failed"
else
  echo "f-math-v1 SKIP math.o build (no shux-c)" >&2
fi
for sub in run-std-math-special-gate.sh run-std-math-fenv-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-math-v1 std.math gate OK"
