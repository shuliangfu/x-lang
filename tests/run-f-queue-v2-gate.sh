#!/usr/bin/env bash
# F-queue v2：std.queue 竞争烟测 F-ZC（queue_contention_os_glue.c → runtime_queue_contention.inc）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_QUEUE_V2_FAIL:-0}
DOC="analysis/phase-f-queue-v2.md"
MANIFEST="tests/baseline/f-queue-v2-closure.tsv"
die() { echo "f-queue-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-queue v2: contention smoke → queue.x + runtime ==="
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
grep -q 'queue_glue.c' compiler/Makefile && die "Makefile still references queue_glue.c"
grep -q 'runtime_queue_contention' compiler/Makefile || die "Makefile missing runtime_queue_contention.o"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/queue/queue.o >/dev/null 2>&1 || die "make queue.o failed"
else
  echo "f-queue-v2 SKIP queue.o build (no shux-c)" >&2
fi
chmod +x tests/run-std-queue-concurrent-gate.sh
tests/run-std-queue-concurrent-gate.sh || die "run-std-queue-concurrent-gate failed"
echo "f-queue-v2 gate OK"
