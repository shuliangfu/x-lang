#!/usr/bin/env bash
# F-string v1：std.string 去 C（string.c → string.x）。
#
# 用法：./tests/run-f-string-v1-gate.sh
# 环境：XLANG_F_STRING_V1_FAIL=1 — 失败时硬退出
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

FAIL=${XLANG_F_STRING_V1_FAIL:-0}
DOC="analysis/archive/phase/phase-f-string-v1.md"
MANIFEST="tests/baseline/f-string-v1-closure.tsv"

die() {
  echo "f-string-v1 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-string v1: std.string string.c → string.x ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-string v1' "$DOC" || die "doc missing F-string v1 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f std/string/string.x ] || die "missing std/string/string.x"
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

  die "Makefile still references std/string/string.c"
fi

if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/string/string.o >/dev/null 2>&1 || die "ensure string.o failed (xlang_compiler_make)"
else
  echo "f-string-v1 SKIP string.o build (no xlang-c)" >&2
fi

echo "f-string-v1 std.string gate OK (F-string v1)"
