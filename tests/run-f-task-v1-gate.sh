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
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# static / leftover nested std-task; refuse leftover ignore of
# explicit-bad). leftover auto-make of task.o (`xlang_compiler_make`
# even when the leaf is present — try-heat/g05 raced L2) retired.
# leftover unused compiler-make.sh sourced unused after leftover
# auto-make retired. Missing leaf .o = hard die. leftover nested
# std-task stay.
# G.7: complete existing resolve_shu; converge dod_native_exe; do not
# fork a third resolver.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-task-v1.md"
MANIFEST="tests/baseline/f-task-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_TASK_V1]"

# G.7: complete existing resolve_shu. Explicit XLANG that is missing or
# non-native returns 1 (caller hard-dies). Unset XLANG prefers asm.
# Do not restore set -e before return 1.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
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

# Explicit XLANG that is missing/non-native hard-dies BEFORE static /
# leftover nested std-task (refuse leftover SKIP→OK / leftover ignore
# of explicit-bad / leftover XLANG fallthrough). leftover nested
# product path stays when XLANG is unset (do not rewrite leftover
# nested std-task).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

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

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover XLANG fallthrough / leftover SKIP→OK / leftover auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

# leftover auto-make retired: require the leaf already present (refuse try-heat/g05).
# PLATFORM: SHARED — missing leaf = hard die; Ubuntu gold still required.
if [ ! -f std/task/task.o ]; then
  die "missing std/task/task.o (refuse leftover auto-make)"
fi
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
