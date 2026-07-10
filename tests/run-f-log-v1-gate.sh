#!/usr/bin/env bash
# F-log v1：std.log 去 C（log.c → log.x + runtime_log_os.inc）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_LOG_V1_FAIL:-0}
DOC="analysis/phase-f-log-v1.md"
MANIFEST="tests/baseline/f-log-v1-closure.tsv"
die() { echo "f-log-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-log v1: log.c → log.x ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-log v1' "$DOC" || die "doc marker"
[ -f "$MANIFEST" ] || die "missing manifest"
[ -f std/log/log.x ] || die "missing log.x"
[ -f compiler/src/asm/runtime_log_os.inc ] || die "missing runtime_log_os.inc"
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
grep -q 'runtime_log_os' compiler/Makefile || die "Makefile missing runtime_log_os"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/log/log.o >/dev/null 2>&1 || die "make log.o failed"
else
  echo "f-log-v1 SKIP log.o build (no shux-c)" >&2
fi
for sub in run-std-log-multi-sink-gate.sh run-std-log-rotate-async-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-log-v1 gate OK"
