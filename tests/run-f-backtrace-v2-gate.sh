#!/usr/bin/env bash
# F-backtrace v2：std.backtrace 帧辅助/烟测下沉 + F-ZC 平台胶层迁入 compiler runtime。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_BACKTRACE_V2_FAIL:-0}
DOC="analysis/phase-f-backtrace-v2.md"
MANIFEST="tests/baseline/f-backtrace-v2-closure.tsv"
die() { echo "f-backtrace-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-backtrace v2: frame helpers/smoke → backtrace.x + runtime platform ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-backtrace v2' "$DOC" || die "doc marker"
[ -f std/backtrace/backtrace.x ] || die "missing backtrace.x"
[ -f compiler/seeds/runtime_backtrace_platform.from_x.c ] || die "missing runtime_backtrace_platform.inc"
[ ! -f std/backtrace/backtrace_platform_glue.c ] || die "backtrace_platform_glue.c should be deleted"
[ ! -f std/backtrace/backtrace_glue.c ] || die "backtrace_glue.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'backtrace_read_frame_addr_c' std/backtrace/backtrace.x || die "backtrace.x missing read_frame"
grep -q 'backtrace_symbolicate_smoke_c' std/backtrace/backtrace.x || die "backtrace.x missing smoke"
grep -q 'backtrace_f_backtrace_v2_marker_c' std/backtrace/backtrace.x || die "backtrace.x missing v2 marker"
grep -q 'backtrace_capture_c' compiler/seeds/runtime_backtrace_platform.from_x.c || die "runtime missing capture"
grep -q 'backtrace_gold_anchor_c' compiler/seeds/runtime_backtrace_platform.from_x.c || die "runtime missing anchor"
grep -q 'backtrace_glue.c' compiler/Makefile && die "Makefile still references backtrace_glue.c"
grep -q 'runtime_backtrace_platform' compiler/Makefile || die "Makefile missing runtime_backtrace_platform"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/backtrace/backtrace.o >/dev/null 2>&1 || die "make backtrace.o failed"
else
  echo "f-backtrace-v2 SKIP backtrace.o build (no shux-c)" >&2
fi
for sub in run-std-backtrace-symbolicate-gate.sh run-std-backtrace-xplat-gate.sh; do
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-backtrace-v2 gate OK"
