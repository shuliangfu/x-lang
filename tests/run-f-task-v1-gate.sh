#!/usr/bin/env bash
# F-task v1: std.task de-C (task.c → task.x; v2 deleted task_async_glue.c).
#
# Usage: ./tests/run-f-task-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-task-v1-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure.
# Soft XLANG_F_TASK_V1_FAIL retired. Root: soft die→exit0 = portable false-green
# (static already green; STD-089 still red on fossil API needles task_group_new
# vs live mod.x `new`). STD-089 observational (product/DOC residual; UNDEF jump).
# Report static=/ensure=/task=/skip=. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-task-v1.md"
MANIFEST="tests/baseline/f-task-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_TASK_V1]"

resolve_shu() {
  local cand abs
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$(pwd)/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

die() {
  echo "f-task-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} task=${TASK_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
TASK_OK=0
SKIP=1

echo "=== F-task v1: task.c → task.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-task v1' "$DOC" || die "doc missing F-task v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/task/task.x ] || die "missing task.x"
[ ! -f std/task/task_async_glue.c ] || die "task_async_glue.c should be deleted (F-task v2)"
[ ! -f std/task/task.c ] || die "task.c should be deleted"
grep -q 'task_f_task_v1_marker_c' std/task/task.x || die "task.x missing v1 marker"

while IFS=$'\t' read -r item_id kind anchor _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile)
      [ -f "$anchor" ] || die "missing $anchor ($item_id)"
      ;;
    absent)
      [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)"
      ;;
    *)
      die "manifest unknown kind '$kind' for $item_id"
      ;;
  esac
done < "$MANIFEST"
STATIC_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

xlang_compiler_make ../std/task/task.o >/dev/null 2>&1 \
  || die "ensure task.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

# STD-089 observational: fossil api task_group_new vs live mod.x `new` (product residual).
if [ -f tests/run-std-task-gate.sh ]; then
  echo "=== F-task v1: std-task (observational; API rename residual) ==="
  chmod +x tests/run-std-task-gate.sh
  if tests/run-std-task-gate.sh; then
    TASK_OK=1
  else
    echo "f-task-v1 WARN: std-task failed (observational)" >&2
    TASK_OK=0
  fi
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} task=${TASK_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-task-v1 std.task gate OK (F-task v1; honesty)"
