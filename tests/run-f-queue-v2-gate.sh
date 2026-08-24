#!/usr/bin/env bash
# F-queue v2：std.queue 竞争烟测 F-ZC（queue_contention_os_glue.c → runtime_queue_contention.inc）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_QUEUE_V2_FAIL:-0}
DOC="analysis/archive/phase/phase-f-queue-v2.md"
MANIFEST="tests/baseline/f-queue-v2-closure.tsv"
die() { echo "f-queue-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-queue v2: contention smoke → queue.x + runtime ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-queue v2' "$DOC" || die "doc marker"
[ -f std/queue/queue.x ] || die "missing queue.x"
[ ! -f std/queue/queue_contention_os_glue.c ] || die "queue_contention_os_glue.c should be deleted (F-ZC)"
[ -f compiler/seeds/runtime_queue_contention.from_x.c ] || die "missing runtime_queue_contention.inc"
[ ! -f std/queue/queue_glue.c ] || die "queue_glue.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'sync_queue_contention_smoke_c' std/queue/queue.x || die "queue.x missing smoke"
grep -q 'queue_contention_worker_push_c' std/queue/queue.x || die "queue.x missing worker"
grep -q 'queue_f_queue_v2_marker_c' std/queue/queue.x || die "queue.x missing v2 marker"
grep -q 'queue_os_run_two_workers_c' compiler/seeds/runtime_queue_contention.from_x.c || die "runtime missing workers"
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/queue/queue.o >/dev/null 2>&1 || die "ensure queue.o failed (xlang_compiler_make)"
else
  echo "f-queue-v2 SKIP queue.o build (no xlang-c)" >&2
fi
chmod +x tests/run-std-queue-concurrent-gate.sh
tests/run-std-queue-concurrent-gate.sh || die "run-std-queue-concurrent-gate failed"
echo "f-queue-v2 gate OK"
