#!/usr/bin/env bash
# F-queue v1：std.queue 去 C（queue.c → queue.x；胶层 v2 已拆，见 run-f-queue-v2-gate.sh）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_QUEUE_V1_FAIL:-0}
DOC="analysis/archive/phase/phase-f-queue-v1.md"
MANIFEST="tests/baseline/f-queue-v1-closure.tsv"
die() { echo "f-queue-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-queue v1: queue.c → queue.x (glue superseded by v2) ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-queue v1' "$DOC" || die "doc marker"
[ -f std/queue/queue.x ] || die "missing queue.x"
[ ! -f std/queue/queue.c ] || die "queue.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/queue/queue.o >/dev/null 2>&1 || die "ensure queue.o failed (xlang_compiler_make)"
else
  echo "f-queue-v1 SKIP queue.o build (no xlang-c)" >&2
fi
chmod +x tests/run-std-queue-concurrent-gate.sh
tests/run-std-queue-concurrent-gate.sh || die "run-std-queue-concurrent-gate failed"
echo "f-queue-v1 gate OK"
