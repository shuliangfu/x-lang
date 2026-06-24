#!/usr/bin/env bash
# F-encoding v1：std.encoding 去 C（encoding.c → encoding.sx）。
#
# 用法：./tests/run-f-encoding-v1-gate.sh
# 环境：SHUX_F_ENCODING_V1_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F_ENCODING_V1_FAIL:-0}
DOC="analysis/phase-f-encoding-v1.md"
MANIFEST="tests/baseline/f-encoding-v1-closure.tsv"

die() {
  echo "f-encoding-v1 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-encoding v1: std.encoding encoding.c → encoding.sx ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-encoding v1' "$DOC" || die "doc missing F-encoding v1 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f std/encoding/encoding.sx ] || die "missing std/encoding/encoding.sx"
[ ! -f std/encoding/encoding.c ] || die "std/encoding/encoding.c should be deleted"

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

grep -q 'encoding.sx' compiler/Makefile || die "Makefile missing encoding.sx rule"
if grep -q 'std/encoding/encoding\.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references std/encoding/encoding.c"
fi

if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/encoding/encoding.o >/dev/null 2>&1 || die "make encoding.o failed"
else
  echo "f-encoding-v1 SKIP encoding.o build (no shux-c)" >&2
fi

for sub in run-std-encoding-hex-base64-gate.sh run-std-encoding-extra-gate.sh; do
  if [ -f "tests/$sub" ]; then
    echo "=== F-encoding v1: delegate $sub ==="
    chmod +x "tests/$sub"
    if ! "tests/$sub"; then
      die "$sub failed"
    fi
  fi
done

echo "f-encoding-v1 std.encoding gate OK (F-encoding v1)"
