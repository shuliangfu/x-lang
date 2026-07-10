#!/usr/bin/env bash
# F-process v1：std.process 去 C（process.x + runtime 胶层）。
#
# 用法：./tests/run-f-process-v1-gate.sh
# 环境：SHUX_F_PROCESS_V1_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F_PROCESS_V1_FAIL:-0}
DOC="analysis/phase-f-process-v1.md"
MANIFEST="tests/baseline/f-process-v1-closure.tsv"

die() {
  echo "f-process-v1 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-process v1: std.process process.x + runtime glue ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-process v1' "$DOC" || die "doc missing F-process v1 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f std/process/process.x ] || die "missing std/process/process.x"
[ -f compiler/src/asm/runtime_process_argv.inc ] || die "missing runtime_process_argv.inc"
[ -f compiler/src/asm/runtime_process_os_glue.c ] || die "missing runtime_process_os_glue.c"
[ ! -f std/process/process_os_glue.c ] || die "process_os_glue.c should be deleted (F-ZC)"
[ ! -f std/process/process_arg_glue.c ] || die "process_arg_glue.c should be deleted (F-ZC)"
[ ! -f std/process/process.c ] || die "std/process/process.c should be deleted"

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

grep -q 'process.x' compiler/Makefile || die "Makefile missing process.x rule"
grep -q 'runtime_process_argv' compiler/Makefile || die "Makefile missing runtime_process_argv.o rule"
grep -q 'runtime_process_os_glue' compiler/Makefile || die "Makefile missing runtime_process_os_glue.o rule"
if grep -q 'std/process/process\.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references std/process/process.c"
fi

make -C compiler -q runtime_process_os_glue.o 2>/dev/null || make -C compiler runtime_process_os_glue.o >/dev/null 2>&1 || die "runtime_process_os_glue.o build failed"

if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler runtime_process_argv.o ../std/process/process.o >/dev/null 2>&1 || die "make process.o failed"
else
  echo "f-process-v1 SKIP process.o build (no shux-c)" >&2
fi

if [ -f tests/run-std-process-xplat-gate.sh ]; then
  echo "=== F-process v1: delegate run-std-process-xplat-gate (manifest) ==="
  chmod +x tests/run-std-process-xplat-gate.sh
  if ! tests/run-std-process-xplat-gate.sh; then
    die "std-process-xplat sub-gate failed"
  fi
fi

echo "f-process-v1 std.process gate OK (F-process v1)"
