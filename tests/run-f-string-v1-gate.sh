#!/usr/bin/env bash
# F-string v1：std.string 去 C（string.c → string.sx）。
#
# 用法：./tests/run-f-string-v1-gate.sh
# 环境：SHUX_F_STRING_V1_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F_STRING_V1_FAIL:-0}
DOC="analysis/phase-f-string-v1.md"
MANIFEST="tests/baseline/f-string-v1-closure.tsv"

die() {
  echo "f-string-v1 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-string v1: std.string string.c → string.sx ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-string v1' "$DOC" || die "doc missing F-string v1 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f std/string/string.sx ] || die "missing std/string/string.sx"
[ ! -f std/string/string.c ] || die "std/string/string.c should be deleted"

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

grep -q 'std/string/string.sx' compiler/Makefile || die "Makefile missing string.sx rule"
if grep -q 'std/string/string\.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references std/string/string.c"
fi

if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/string/string.o >/dev/null 2>&1 || die "make string.o failed"
else
  echo "f-string-v1 SKIP string.o build (no shux-c)" >&2
fi

echo "f-string-v1 std.string gate OK (F-string v1)"
