#!/usr/bin/env bash
# F-sort v1：std.sort 去 C（sort.c → sort.sx）。
#
# 用法：./tests/run-f-sort-v1-gate.sh
# 环境：SHUX_F_SORT_V1_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F_SORT_V1_FAIL:-0}
DOC="analysis/phase-f-sort-v1.md"
MANIFEST="tests/baseline/f-sort-v1-closure.tsv"

die() {
  echo "f-sort-v1 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-sort v1: std.sort sort.c → sort.sx ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-sort v1' "$DOC" || die "doc missing F-sort v1 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f std/sort/sort.sx ] || die "missing std/sort/sort.sx"
[ ! -f std/sort/sort.c ] || die "std/sort/sort.c should be deleted"

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

grep -q 'std/sort/sort.sx' compiler/Makefile || die "Makefile missing sort.sx rule"
if grep -q 'std/sort/sort\.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references std/sort/sort.c"
fi

if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/sort/sort.o >/dev/null 2>&1 || die "make sort.o failed"
  if strings ../std/sort/sort.o 2>/dev/null | grep -q 'sort_stable'; then
    echo "f-sort-v1: sort.o symbols OK"
  else
    echo "f-sort-v1 SKIP symbol check (sort.o missing .sx symbols)" >&2
  fi
else
  echo "f-sort-v1 SKIP sort.o build (no shux-c)" >&2
fi

for sub in run-std-sort-stable-cmp-gate.sh run-std-sort-key-cmp-gate.sh; do
  if [ -f "tests/$sub" ]; then
    echo "=== F-sort v1: delegate $sub (manifest) ==="
    chmod +x "tests/$sub"
    case "$sub" in
      *stable-cmp*) export SHUX_STD_SORT_STABLE_CMP_MANIFEST_ONLY=1 ;;
      *key-cmp*) export SHUX_STD_SORT_KEY_CMP_MANIFEST_ONLY=1 ;;
    esac
    if ! "tests/$sub"; then
      die "$sub failed"
    fi
    unset SHUX_STD_SORT_STABLE_CMP_MANIFEST_ONLY SHUX_STD_SORT_KEY_CMP_MANIFEST_ONLY 2>/dev/null || true
  fi
done

echo "f-sort-v1 std.sort gate OK (F-sort v1)"
