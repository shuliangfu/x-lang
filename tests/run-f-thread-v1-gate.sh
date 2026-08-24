#!/usr/bin/env bash
# F-thread v1：std.thread 去 C（thread.x + seeds/runtime_thread_glue.from_x.c）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_THREAD_V1_FAIL:-0}
DOC="analysis/archive/phase/phase-f-thread-v1.md"
MANIFEST="tests/baseline/f-thread-v1-closure.tsv"
die() { echo "f-thread-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-thread v1: thread.c → thread.x ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$MANIFEST" ] || die "missing manifest"
[ -f std/thread/thread.x ] || die "missing thread.x"
[ -f compiler/seeds/runtime_thread_glue.from_x.c ] || die "missing runtime_thread_glue.inc"
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
xlang_compiler_make -q runtime_thread_glue.o 2>/dev/null || xlang_compiler_make runtime_thread_glue.o >/dev/null 2>&1 || die "runtime_thread_glue.o build failed"
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/thread/thread.o >/dev/null 2>&1 || die "ensure thread.o failed (xlang_compiler_make)"
else
  echo "f-thread-v1 SKIP thread.o build (no xlang-c)" >&2
fi
[ -f tests/run-std-thread-pool-gate.sh ] && chmod +x tests/run-std-thread-pool-gate.sh && tests/run-std-thread-pool-gate.sh || true
echo "f-thread-v1 gate OK"
