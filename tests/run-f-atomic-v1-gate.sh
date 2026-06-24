#!/usr/bin/env bash
# F-atomic v1：std.atomic 去 C（atomic.c → atomic.sx + runtime_atomic_glue.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_ATOMIC_V1_FAIL:-0}
DOC="analysis/phase-f-atomic-v1.md"
MANIFEST="tests/baseline/f-atomic-v1-closure.tsv"
die() { echo "f-atomic-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-atomic v1: atomic.c → atomic.sx ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-atomic v1' "$DOC" || die "doc marker"
[ -f "$MANIFEST" ] || die "missing manifest"
[ -f std/atomic/atomic.sx ] || die "missing atomic.sx"
[ -f compiler/src/asm/runtime_atomic_glue.c ] || die "missing runtime_atomic_glue.c"
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
grep -q 'runtime_atomic_glue' compiler/Makefile || die "Makefile missing runtime_atomic_glue"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/atomic/atomic.o >/dev/null 2>&1 || die "make atomic.o failed"
else
  echo "f-atomic-v1 SKIP atomic.o build (no shux-c)" >&2
fi
make -C compiler -q runtime_atomic_glue.o 2>/dev/null || make -C compiler runtime_atomic_glue.o >/dev/null 2>&1 || die "runtime_atomic_glue.o build failed"
for sub in run-std-atomic-ordering-gate.sh run-std-atomic-widen-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-atomic-v1 gate OK"
