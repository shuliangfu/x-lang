#!/usr/bin/env bash
# F-time v1：std.time 去 C（time.c → time.x + OS 胶层）。
#
# 用法：./tests/run-f-time-v1-gate.sh
# 环境：SHUX_F_TIME_V1_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F_TIME_V1_FAIL:-0}
DOC="analysis/phase-f-time-v1.md"
MANIFEST="tests/baseline/f-time-v1-closure.tsv"

die() {
  echo "f-time-v1 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-time v1: std.time time.c → time.x + glue ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-time v1' "$DOC" || die "doc missing F-time v1 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f std/time/time.x ] || die "missing std/time/time.x"
[ ! -f std/time/time_os_glue.c ] || die "time_os_glue.c should be deleted (F-ZC)"
[ -f compiler/src/asm/runtime_time_os.c ] || die "missing runtime_time_os.c"
[ ! -f std/time/time.c ] || die "std/time/time.c should be deleted"

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
  esac
done < "$MANIFEST"

grep -q 'time.x' compiler/Makefile || die "Makefile missing time.x rule"
grep -q 'runtime_time_os' compiler/Makefile || die "Makefile missing runtime_time_os.o"
if grep -q 'std/time/time\.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references std/time/time.c"
fi

if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/time/time.o >/dev/null 2>&1 || die "make time.o failed"
else
  echo "f-time-v1 SKIP time.o build (no shux-c)" >&2
fi

if [ -f tests/run-std-time-gate.sh ]; then
  echo "=== F-time v1: delegate run-std-time-gate ==="
  chmod +x tests/run-std-time-gate.sh
  if ! tests/run-std-time-gate.sh; then
    die "std-time sub-gate failed"
  fi
fi

echo "f-time-v1 std.time gate OK (F-time v1)"
