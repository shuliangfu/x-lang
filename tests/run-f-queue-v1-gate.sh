#!/usr/bin/env bash
# F-queue v1：std.queue 去 C（queue.c → queue.sx；胶层 v2 已拆，见 run-f-queue-v2-gate.sh）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_QUEUE_V1_FAIL:-0}
DOC="analysis/phase-f-queue-v1.md"
MANIFEST="tests/baseline/f-queue-v1-closure.tsv"
die() { echo "f-queue-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-queue v1: queue.c → queue.sx (glue superseded by v2) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-queue v1' "$DOC" || die "doc marker"
[ -f std/queue/queue.sx ] || die "missing queue.sx"
[ ! -f std/queue/queue.c ] || die "queue.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'queue.sx' compiler/Makefile || die "Makefile missing queue.sx"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/queue/queue.o >/dev/null 2>&1 || die "make queue.o failed"
else
  echo "f-queue-v1 SKIP queue.o build (no shux-c)" >&2
fi
chmod +x tests/run-std-queue-concurrent-gate.sh
tests/run-std-queue-concurrent-gate.sh || die "run-std-queue-concurrent-gate failed"
echo "f-queue-v1 gate OK"
