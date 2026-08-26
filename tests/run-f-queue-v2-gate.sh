#!/usr/bin/env bash
# F-queue v2: contention smoke F-ZC (queue_contention_os_glue → runtime).
#
# Usage: ./tests/run-f-queue-v2-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-queue-v2-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-048 queue-concurrent hard delegate (sync/c observational inside STD).
# Soft XLANG_F_QUEUE_V2_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+STD main already green).
# Report static=/ensure=/queue=/skip=. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-queue-v2.md"
MANIFEST="tests/baseline/f-queue-v2-closure.tsv"
PREFIX="xlang: [XLANG_F_QUEUE_V2]"

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
  echo "f-queue-v2 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} queue=${QUEUE_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
QUEUE_OK=0
SKIP=1

echo "=== F-queue v2: contention smoke → queue.x + runtime (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-queue v2' "$DOC" || die "doc missing F-queue v2 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/queue/queue.x ] || die "missing queue.x"
[ ! -f std/queue/queue_contention_os_glue.c ] || die "queue_contention_os_glue.c should be deleted (F-ZC)"
[ -f compiler/seeds/runtime_queue_contention.from_x.c ] || die "missing runtime_queue_contention.from_x.c"
[ ! -f std/queue/queue_glue.c ] || die "queue_glue.c should be deleted"

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
# Authority for contention smoke/worker moved to runtime_queue_contention
# (F-ZC); queue.x keeps only the v2 marker. Soft gate still grepped queue.x
# → soft die→exit0 hid the stale needle (portable false-green).
# PLATFORM: SHARED archaeology — needle must follow product authority.
grep -q 'queue_f_queue_v2_marker_c' std/queue/queue.x || die "queue.x missing v2 marker"
grep -q 'sync_queue_contention_smoke_c' compiler/seeds/runtime_queue_contention.from_x.c \
  || die "runtime missing sync_queue_contention_smoke_c"
grep -q 'queue_contention_worker_push_c' compiler/seeds/runtime_queue_contention.from_x.c \
  || die "runtime missing queue_contention_worker_push_c"
grep -q 'queue_os_run_two_workers_c' compiler/seeds/runtime_queue_contention.from_x.c \
  || die "runtime missing workers"
STATIC_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

xlang_compiler_make ../std/queue/queue.o >/dev/null 2>&1 \
  || die "ensure queue.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

# Hard-delegate already soft→硬绿 STD-048 (sync/c observational inside).
# Do NOT export retired XLANG_F_QUEUE_V2_FAIL.
# PLATFORM: SHARED archaeology.
if [ -f tests/run-std-queue-concurrent-gate.sh ]; then
  echo "=== F-queue v2: delegate run-std-queue-concurrent-gate (hard) ==="
  chmod +x tests/run-std-queue-concurrent-gate.sh
  if ! tests/run-std-queue-concurrent-gate.sh; then
    die "std-queue-concurrent sub-gate failed"
  fi
  QUEUE_OK=1
else
  die "missing tests/run-std-queue-concurrent-gate.sh"
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} queue=${QUEUE_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-queue-v2 gate OK (F-queue v2; honesty)"
