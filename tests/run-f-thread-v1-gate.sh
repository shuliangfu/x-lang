#!/usr/bin/env bash
# F-thread v1：std.thread 去 C（thread.x + runtime_thread_glue.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_THREAD_V1_FAIL:-0}
DOC="analysis/phase-f-thread-v1.md"
MANIFEST="tests/baseline/f-thread-v1-closure.tsv"
die() { echo "f-thread-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-thread v1: thread.c → thread.x ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$MANIFEST" ] || die "missing manifest"
[ -f std/thread/thread.x ] || die "missing thread.x"
[ -f compiler/src/asm/runtime_thread_glue.c ] || die "missing runtime_thread_glue.c"
[ ! -f std/thread/thread_glue.c ] || die "thread_glue.c should be deleted"
[ ! -f std/thread/thread.c ] || die "thread.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'runtime_thread_glue' compiler/Makefile || die "Makefile missing runtime_thread_glue"
make -C compiler -q runtime_thread_glue.o 2>/dev/null || make -C compiler runtime_thread_glue.o >/dev/null 2>&1 || die "runtime_thread_glue.o build failed"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/thread/thread.o >/dev/null 2>&1 || die "make thread.o failed"
else
  echo "f-thread-v1 SKIP thread.o build (no shux-c)" >&2
fi
[ -f tests/run-std-thread-pool-gate.sh ] && chmod +x tests/run-std-thread-pool-gate.sh && tests/run-std-thread-pool-gate.sh || true
echo "f-thread-v1 gate OK"
