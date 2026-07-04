#!/usr/bin/env bash
# F-task v2：std.task TaskGroup/JoinSet 逻辑全量 .x（删除 task_async_glue.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_TASK_V2_FAIL:-0}
DOC="analysis/phase-f-task-v2.md"
MANIFEST="tests/baseline/f-task-v2-closure.tsv"
die() { echo "f-task-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-task v2: TaskGroup/JoinSet → task.x (zero glue) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-task v2' "$DOC" || die "doc marker"
[ -f std/task/task.x ] || die "missing task.x"
[ ! -f std/task/task_async_glue.c ] || die "task_async_glue.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'task_group_create_c' std/task/task.x || die "task.x missing task_group_create_c"
grep -q 'task_group_spawn_c' std/task/task.x || die "task.x missing task_group_spawn_c"
grep -q 'join_set_create_c' std/task/task.x || die "task.x missing join_set_create_c"
grep -q 'task_supervise_retry_c' std/task/task.x || die "task.x missing supervise"
grep -q 'task_smoke_c' std/task/task.x || die "task.x missing smoke"
grep -q 'task_echo_fn_ptr_c' std/task/task.x || die "task.x missing echo fn ptr"
grep -q 'task_f_task_v1_marker_c' std/task/task.x || die "task.x missing v1 marker"
grep -q 'task_f_task_v2_marker_c' std/task/task.x || die "task.x missing v2 marker"
grep -q 'shux_async_spawn_i32' std/task/task.x || die "task.x missing spawn extern"
grep -q 'task_echo_fn_ptr_c()' std/task/task.x || die "task.x smoke should use task_echo_fn_ptr_c"
grep -q 'F-task v2' compiler/Makefile || die "Makefile missing F-task v2 note"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/task/task.o >/dev/null 2>&1 || die "make task.o failed"
else
  echo "f-task-v2 SKIP task.o build (no shux-c)" >&2
fi
if [ -f tests/run-std-task-gate.sh ]; then
  chmod +x tests/run-std-task-gate.sh
  tests/run-std-task-gate.sh || die "std-task gate failed"
fi
echo "f-task-v2 gate OK"
