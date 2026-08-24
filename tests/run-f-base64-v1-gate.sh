#!/usr/bin/env bash
# F-base64 v1：std.base64 去 C（base64.c → base64.x）。
#
# 用法：./tests/run-f-base64-v1-gate.sh
# 环境：XLANG_F_BASE64_V1_FAIL=1 — 失败时硬退出
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

FAIL=${XLANG_F_BASE64_V1_FAIL:-0}
DOC="analysis/archive/phase/phase-f-base64-v1.md"
MANIFEST="tests/baseline/f-base64-v1-closure.tsv"

die() {
  echo "f-base64-v1 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-base64 v1: std.base64 base64.c → base64.x ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-base64 v1' "$DOC" || die "doc missing F-base64 v1 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f std/base64/base64.x ] || die "missing std/base64/base64.x"
[ ! -f std/base64/base64.c ] || die "std/base64/base64.c should be deleted"

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

  die "Makefile still references std/base64/base64.c"
fi

if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/base64/base64.o >/dev/null 2>&1 || die "ensure base64.o failed (xlang_compiler_make)"
else
  echo "f-base64-v1 SKIP base64.o build (no xlang-c)" >&2
fi

if [ -f tests/run-std-base64-stream-gate.sh ]; then
  echo "=== F-base64 v1: delegate run-std-base64-stream-gate ==="
  chmod +x tests/run-std-base64-stream-gate.sh
  if ! tests/run-std-base64-stream-gate.sh; then
    die "std-base64-stream sub-gate failed"
  fi
fi

echo "f-base64-v1 std.base64 gate OK (F-base64 v1)"
