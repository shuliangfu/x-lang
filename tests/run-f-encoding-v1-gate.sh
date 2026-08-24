#!/usr/bin/env bash
# F-encoding v1：std.encoding 去 C（encoding.c → encoding.x）。
#
# 用法：./tests/run-f-encoding-v1-gate.sh
# 环境：XLANG_F_ENCODING_V1_FAIL=1 — 失败时硬退出
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

FAIL=${XLANG_F_ENCODING_V1_FAIL:-0}
DOC="analysis/archive/phase/phase-f-encoding-v1.md"
MANIFEST="tests/baseline/f-encoding-v1-closure.tsv"

die() {
  echo "f-encoding-v1 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-encoding v1: std.encoding encoding.c → encoding.x ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-encoding v1' "$DOC" || die "doc missing F-encoding v1 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f std/encoding/encoding.x ] || die "missing std/encoding/encoding.x"
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

  die "Makefile still references std/encoding/encoding.c"
fi

if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/encoding/encoding.o >/dev/null 2>&1 || die "ensure encoding.o failed (xlang_compiler_make)"
else
  echo "f-encoding-v1 SKIP encoding.o build (no xlang-c)" >&2
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
