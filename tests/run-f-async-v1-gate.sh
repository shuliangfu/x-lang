#!/usr/bin/env bash
# F-async v1：std.async 去 C（scheduler/future.c → .x + *_glue.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_ASYNC_V1_FAIL:-0}
DOC="analysis/phase-f-async-v1.md"
MANIFEST="tests/baseline/f-async-v1-closure.tsv"
die() { echo "f-async-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-async v1: scheduler/future.c → .x + glue ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-async v1' "$DOC" || die "doc marker"
[ -f std/async/scheduler.x ] || die "missing scheduler.x"
[ -f std/async/future.x ] || die "missing future.x"
[ -f compiler/src/asm/runtime_scheduler_glue.c ] || die "missing scheduler glue"
[ ! -f std/async/scheduler_glue.c ] || die "scheduler_glue.c should be deleted (F-ZC)"
[ ! -f std/async/future_glue.c ] || die "future_glue.c should be deleted (see F-async-future v2)"
[ ! -f std/async/scheduler.c ] || die "scheduler.c should be deleted"
[ ! -f std/async/future.c ] || die "future.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'scheduler.x' compiler/Makefile || die "Makefile missing scheduler.x"
grep -q 'runtime_scheduler_glue' compiler/Makefile || die "Makefile missing runtime_scheduler_glue"
make -C compiler -q runtime_scheduler_glue.o 2>/dev/null || make -C compiler runtime_scheduler_glue.o >/dev/null 2>&1 || die "runtime_scheduler_glue.o build failed"
grep -q 'future.x' compiler/Makefile || die "Makefile missing future.x"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/async/scheduler.o >/dev/null 2>&1 || die "make scheduler.o failed"
  make -C compiler ../std/async/future.o >/dev/null 2>&1 || die "make future.o failed"
else
  echo "f-async-v1 SKIP scheduler/future.o build (no shux-c)" >&2
fi
for sub in run-std-async-future-gate.sh run-std-async-io-cps-gate.sh \
  run-std-async-context-gate.sh run-std-async-language-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-async-v1 gate OK"
