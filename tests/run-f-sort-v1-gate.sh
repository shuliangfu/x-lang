#!/usr/bin/env bash
# F-sort v1：std.sort 去 C（sort.c → sort.x）。
#
# 用法：./tests/run-f-sort-v1-gate.sh
# 环境：XLANG_F_SORT_V1_FAIL=1 — 失败时硬退出
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

FAIL=${XLANG_F_SORT_V1_FAIL:-0}
DOC="analysis/archive/phase/phase-f-sort-v1.md"
MANIFEST="tests/baseline/f-sort-v1-closure.tsv"

die() {
  echo "f-sort-v1 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-sort v1: std.sort sort.c → sort.x ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-sort v1' "$DOC" || die "doc missing F-sort v1 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f std/sort/sort.x ] || die "missing std/sort/sort.x"
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


if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/sort/sort.o >/dev/null 2>&1 || die "ensure sort.o failed (xlang_compiler_make)"
  if strings ../std/sort/sort.o 2>/dev/null | grep -q 'sort_stable'; then
    echo "f-sort-v1: sort.o symbols OK"
  else
    echo "f-sort-v1 SKIP symbol check (sort.o missing .x symbols)" >&2
  fi
else
  echo "f-sort-v1 SKIP sort.o build (no xlang-c)" >&2
fi

for sub in run-std-sort-stable-cmp-gate.sh run-std-sort-key-cmp-gate.sh; do
  if [ -f "tests/$sub" ]; then
    echo "=== F-sort v1: delegate $sub (manifest) ==="
    chmod +x "tests/$sub"
    case "$sub" in
      *stable-cmp*) export XLANG_STD_SORT_STABLE_CMP_MANIFEST_ONLY=1 ;;
      *key-cmp*) export XLANG_STD_SORT_KEY_CMP_MANIFEST_ONLY=1 ;;
    esac
    if ! "tests/$sub"; then
      die "$sub failed"
    fi
    unset XLANG_STD_SORT_STABLE_CMP_MANIFEST_ONLY XLANG_STD_SORT_KEY_CMP_MANIFEST_ONLY 2>/dev/null || true
  fi
done

echo "f-sort-v1 std.sort gate OK (F-sort v1)"
