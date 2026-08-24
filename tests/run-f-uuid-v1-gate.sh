#!/usr/bin/env bash
# F-uuid v1：std.uuid 去 C（uuid.c → uuid.x）。
#
# 用法：./tests/run-f-uuid-v1-gate.sh
# 环境：XLANG_F_UUID_V1_FAIL=1 — 失败时硬退出
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

FAIL=${XLANG_F_UUID_V1_FAIL:-0}
DOC="analysis/archive/phase/phase-f-uuid-v1.md"
MANIFEST="tests/baseline/f-uuid-v1-closure.tsv"

die() {
  echo "f-uuid-v1 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-uuid v1: std.uuid uuid.c → uuid.x ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-uuid v1' "$DOC" || die "doc missing F-uuid v1 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f std/uuid/uuid.x ] || die "missing std/uuid/uuid.x"
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


if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/uuid/uuid.o >/dev/null 2>&1 || die "ensure uuid.o failed (xlang_compiler_make)"
else
  echo "f-uuid-v1 SKIP uuid.o build (no xlang-c)" >&2
fi

if [ -f tests/run-std-uuid-gate.sh ]; then
  echo "=== F-uuid v1: delegate run-std-uuid-gate ==="
  chmod +x tests/run-std-uuid-gate.sh
  if ! XLANG_STD_UUID_MANIFEST_ONLY=1 tests/run-std-uuid-gate.sh; then
    die "std-uuid manifest sub-gate failed"
  fi
  if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
    if ! XLANG_F_UUID_V1_FAIL="$FAIL" tests/run-std-uuid-gate.sh; then
      die "std-uuid full sub-gate failed"
    fi
  fi
fi

echo "f-uuid-v1 std.uuid gate OK (F-uuid v1)"
