#!/usr/bin/env bash
# F-random v1：std.random 去 C（random.c → random.x + OS 胶层）。
#
# 用法：./tests/run-f-random-v1-gate.sh
# 环境：SHUX_F_RANDOM_V1_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F_RANDOM_V1_FAIL:-0}
DOC="analysis/phase-f-random-v1.md"
MANIFEST="tests/baseline/f-random-v1-closure.tsv"

die() {
  echo "f-random-v1 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-random v1: std.random random.c → random.x + glue ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-random v1' "$DOC" || die "doc missing F-random v1 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f std/random/random.x ] || die "missing std/random/random.x"
[ ! -f std/random/random_os_glue.c ] || die "random_os_glue.c should be deleted (F-ZC)"
[ -f compiler/src/asm/runtime_random_fill.c ] || die "missing runtime_random_fill.c"
[ ! -f std/random/random.c ] || die "std/random/random.c should be deleted"

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

grep -q 'random.x' compiler/Makefile || die "Makefile missing random.x rule"
grep -q 'runtime_random_fill' compiler/Makefile || die "Makefile missing runtime_random_fill.o"
if grep -q 'std/random/random\.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references std/random/random.c"
fi

if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/random/random.o >/dev/null 2>&1 || die "make random.o failed"
else
  echo "f-random-v1 SKIP random.o build (no shux-c)" >&2
fi

if [ -f tests/run-std-random-rng-gate.sh ]; then
  echo "=== F-random v1: delegate run-std-random-rng-gate ==="
  chmod +x tests/run-std-random-rng-gate.sh
  if ! tests/run-std-random-rng-gate.sh; then
    die "std-random-rng sub-gate failed"
  fi
fi

echo "f-random-v1 std.random gate OK (F-random v1)"
