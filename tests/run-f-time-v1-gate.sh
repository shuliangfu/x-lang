#!/usr/bin/env bash
# F-time v1：std.time 去 C（time.c → time.x + OS 胶层）。
#
# 用法：./tests/run-f-time-v1-gate.sh
# 环境：XLANG_F_TIME_V1_FAIL=1 — 失败时硬退出
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

FAIL=${XLANG_F_TIME_V1_FAIL:-0}
DOC="analysis/archive/phase/phase-f-time-v1.md"
MANIFEST="tests/baseline/f-time-v1-closure.tsv"

die() {
  echo "f-time-v1 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-time v1: std.time time.c → time.x + glue ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-time v1' "$DOC" || die "doc missing F-time v1 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f std/time/time.x ] || die "missing std/time/time.x"
[ ! -f std/time/time_os_glue.c ] || die "time_os_glue.c should be deleted (F-ZC)"
[ -f compiler/seeds/runtime_time_os.from_x.c ] || die "missing runtime_time_os.inc"
[ ! -f std/time/time.c ] || die "std/time/time.c should be deleted"

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

  die "Makefile still references std/time/time.c"
fi

if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/time/time.o >/dev/null 2>&1 || die "ensure time.o failed (xlang_compiler_make)"
else
  echo "f-time-v1 SKIP time.o build (no xlang-c)" >&2
fi

if [ -f tests/run-std-time-gate.sh ]; then
  echo "=== F-time v1: delegate run-std-time-gate ==="
  chmod +x tests/run-std-time-gate.sh
  if ! tests/run-std-time-gate.sh; then
    die "std-time sub-gate failed"
  fi
fi

echo "f-time-v1 std.time gate OK (F-time v1)"
