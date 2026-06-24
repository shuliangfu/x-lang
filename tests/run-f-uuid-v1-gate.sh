#!/usr/bin/env bash
# F-uuid v1：std.uuid 去 C（uuid.c → uuid.sx）。
#
# 用法：./tests/run-f-uuid-v1-gate.sh
# 环境：SHUX_F_UUID_V1_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F_UUID_V1_FAIL:-0}
DOC="analysis/phase-f-uuid-v1.md"
MANIFEST="tests/baseline/f-uuid-v1-closure.tsv"

die() {
  echo "f-uuid-v1 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-uuid v1: std.uuid uuid.c → uuid.sx ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-uuid v1' "$DOC" || die "doc missing F-uuid v1 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f std/uuid/uuid.sx ] || die "missing std/uuid/uuid.sx"
[ ! -f std/uuid/uuid.c ] || die "std/uuid/uuid.c should be deleted"

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

grep -q 'std/uuid/uuid.sx' compiler/Makefile || die "Makefile missing uuid.sx rule"
if grep -q 'std/uuid/uuid\.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references std/uuid/uuid.c"
fi

if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/uuid/uuid.o >/dev/null 2>&1 || die "make uuid.o failed"
else
  echo "f-uuid-v1 SKIP uuid.o build (no shux-c)" >&2
fi

if [ -f tests/run-std-uuid-gate.sh ]; then
  echo "=== F-uuid v1: delegate run-std-uuid-gate ==="
  chmod +x tests/run-std-uuid-gate.sh
  if ! SHUX_STD_UUID_MANIFEST_ONLY=1 tests/run-std-uuid-gate.sh; then
    die "std-uuid manifest sub-gate failed"
  fi
  if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
    if ! SHUX_F_UUID_V1_FAIL="$FAIL" tests/run-std-uuid-gate.sh; then
      die "std-uuid full sub-gate failed"
    fi
  fi
fi

echo "f-uuid-v1 std.uuid gate OK (F-uuid v1)"
