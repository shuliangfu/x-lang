#!/usr/bin/env bash
# F-queue v1: std.queue de-C (queue.c → queue.x; glue superseded by v2).
#
# Usage: ./tests/run-f-queue-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-queue-v1-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-048 queue-concurrent hard delegate. Soft XLANG_F_QUEUE_V1_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+STD already green).
# Report static=/ensure=/queue=/skip=. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-queue-v1.md"
MANIFEST="tests/baseline/f-queue-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_QUEUE_V1]"

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
  echo "f-queue-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} queue=${QUEUE_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
QUEUE_OK=0
SKIP=1

echo "=== F-queue v1: std.queue queue.c → queue.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-queue v1' "$DOC" || die "doc missing F-queue v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/queue/queue.x ] || die "missing std/queue/queue.x"
[ ! -f std/queue/queue.c ] || die "queue.c should be deleted"

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

xlang_compiler_make ../std/queue/queue.o >/dev/null 2>&1 \
  || die "ensure queue.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

if [ -f tests/run-std-queue-concurrent-gate.sh ]; then
  echo "=== F-queue v1: delegate run-std-queue-concurrent-gate ==="
  chmod +x tests/run-std-queue-concurrent-gate.sh
  if ! tests/run-std-queue-concurrent-gate.sh; then
    die "std-queue-concurrent sub-gate failed"
  fi
  QUEUE_OK=1
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} queue=${QUEUE_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-queue-v1 std.queue gate OK (F-queue v1; honesty)"
