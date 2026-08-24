#!/usr/bin/env bash
# F-async-future v2：std.async Future 逻辑全量 .x（删除 future_glue.c）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_ASYNC_FUTURE_V2_FAIL:-0}
DOC="analysis/archive/phase/phase-f-async-future-v2.md"
MANIFEST="tests/baseline/f-async-future-v2-closure.tsv"
die() { echo "f-async-future-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-async-future v2: Future/Poll → future.x (zero glue) ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-async-future v2' "$DOC" || die "doc marker"
[ -f std/async/future.x ] || die "missing future.x"
[ ! -f std/async/future_glue.c ] || die "future_glue.c should be deleted"
[ -f compiler/seeds/runtime_scheduler_glue.from_x.c ] || die "runtime_scheduler_glue.inc should remain (v1)"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'xlang_async_future_create_c' std/async/future.x || die "future.x missing create"
grep -q 'xlang_async_future_poll_c' std/async/future.x || die "future.x missing poll"
grep -q 'xlang_async_future_complete_c' std/async/future.x || die "future.x missing complete"
grep -q 'xlang_async_future_take_c' std/async/future.x || die "future.x missing take"
grep -q 'xlang_async_future_reset_c' std/async/future.x || die "future.x missing reset"
grep -q 'xlang_async_future_wait_c' std/async/future.x || die "future.x missing wait"
grep -q 'xlang_async_future_smoke_c' std/async/future.x || die "future.x missing smoke"
grep -q 'future_f_async_future_v1_marker_c' std/async/future.x || die "future.x missing v1 marker"
grep -q 'future_f_async_future_v2_marker_c' std/async/future.x || die "future.x missing v2 marker"
grep -q 'xlang_async_run_drain_until_idle' std/async/future.x || die "future.x missing drain extern"
grep -q 'xlang_io_poll_async_completions' std/async/future.x || die "future.x missing io poll extern"
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/async/future.o >/dev/null 2>&1 || die "ensure future.o failed (xlang_compiler_make)"
else
  echo "f-async-future-v2 SKIP future.o build (no xlang-c)" >&2
fi
for sub in run-std-async-future-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-async-future-v2 gate OK"
