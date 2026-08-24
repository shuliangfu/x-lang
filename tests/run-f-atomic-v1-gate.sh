#!/usr/bin/env bash
# F-atomic v1：std.atomic 去 C（atomic.c → atomic.x + seeds/runtime_atomic_glue.from_x.c）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_ATOMIC_V1_FAIL:-0}
DOC="analysis/archive/phase/phase-f-atomic-v1.md"
MANIFEST="tests/baseline/f-atomic-v1-closure.tsv"
die() { echo "f-atomic-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-atomic v1: atomic.c → atomic.x ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-atomic v1' "$DOC" || die "doc marker"
[ -f "$MANIFEST" ] || die "missing manifest"
[ -f std/atomic/atomic.x ] || die "missing atomic.x"
[ -f compiler/seeds/runtime_atomic_glue.from_x.c ] || die "missing runtime_atomic_glue.from_x.c"
[ ! -f std/atomic/atomic_glue.c ] || die "atomic_glue.c should be deleted"
[ ! -f std/atomic/atomic.c ] || die "atomic.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/atomic/atomic.o >/dev/null 2>&1 || die "ensure atomic.o failed (xlang_compiler_make)"
else
  echo "f-atomic-v1 SKIP atomic.o build (no xlang-c)" >&2
fi
xlang_compiler_make -q runtime_atomic_glue.o 2>/dev/null || xlang_compiler_make runtime_atomic_glue.o >/dev/null 2>&1 || die "runtime_atomic_glue.o build failed"
for sub in run-std-atomic-ordering-gate.sh run-std-atomic-widen-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-atomic-v1 gate OK"
