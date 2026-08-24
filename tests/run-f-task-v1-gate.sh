#!/usr/bin/env bash
# F-task v1：std.task 去 C（task.c → task.x；v2 删除 task_async_glue.c）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_TASK_V1_FAIL:-0}
DOC="analysis/archive/phase/phase-f-task-v1.md"
MANIFEST="tests/baseline/f-task-v1-closure.tsv"
die() { echo "f-task-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-task v1: task.c → task.x + glue ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-task v1' "$DOC" || die "doc marker"
[ -f std/task/task.x ] || die "missing task.x"
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
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/task/task.o >/dev/null 2>&1 || die "ensure task.o failed (xlang_compiler_make)"
else
  echo "f-task-v1 SKIP task.o build (no xlang-c)" >&2
fi
if [ -f tests/run-std-task-gate.sh ]; then
  chmod +x tests/run-std-task-gate.sh
  tests/run-std-task-gate.sh || die "std-task gate failed"
fi
echo "f-task-v1 gate OK"
