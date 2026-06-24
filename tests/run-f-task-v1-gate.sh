#!/usr/bin/env bash
# F-task v1：std.task 去 C（task.c → task.sx；v2 删除 task_async_glue.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_TASK_V1_FAIL:-0}
DOC="analysis/phase-f-task-v1.md"
MANIFEST="tests/baseline/f-task-v1-closure.tsv"
die() { echo "f-task-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-task v1: task.c → task.sx + glue ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-task v1' "$DOC" || die "doc marker"
[ -f std/task/task.sx ] || die "missing task.sx"
[ ! -f std/task/task_async_glue.c ] || die "task_async_glue.c should be deleted (F-task v2)"
[ ! -f std/task/task.c ] || die "task.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'task.sx' compiler/Makefile || die "Makefile missing task.sx"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/task/task.o >/dev/null 2>&1 || die "make task.o failed"
else
  echo "f-task-v1 SKIP task.o build (no shux-c)" >&2
fi
if [ -f tests/run-std-task-gate.sh ]; then
  chmod +x tests/run-std-task-gate.sh
  tests/run-std-task-gate.sh || die "std-task gate failed"
fi
echo "f-task-v1 gate OK"
