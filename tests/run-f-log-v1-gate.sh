#!/usr/bin/env bash
# F-log v1：std.log 去 C（log.c → log.x + seeds/runtime_log_os.from_x.c）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_LOG_V1_FAIL:-0}
DOC="analysis/archive/phase/phase-f-log-v1.md"
MANIFEST="tests/baseline/f-log-v1-closure.tsv"
die() { echo "f-log-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-log v1: log.c → log.x ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-log v1' "$DOC" || die "doc marker"
[ -f "$MANIFEST" ] || die "missing manifest"
[ -f std/log/log.x ] || die "missing log.x"
[ -f compiler/seeds/runtime_log_os.from_x.c ] || die "missing runtime_log_os.inc"
[ ! -f std/log/log_os_glue.c ] || die "log_os_glue.c should be deleted"
[ ! -f std/log/log.c ] || die "log.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/log/log.o >/dev/null 2>&1 || die "ensure log.o failed (xlang_compiler_make)"
else
  echo "f-log-v1 SKIP log.o build (no xlang-c)" >&2
fi
for sub in run-std-log-multi-sink-gate.sh run-std-log-rotate-async-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-log-v1 gate OK"
