#!/usr/bin/env bash
# F-channel v1：std.channel 去 C（channel.c → channel.x + seeds/runtime_channel_glue.from_x.c）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_CHANNEL_V1_FAIL:-0}
DOC="analysis/archive/phase/phase-f-channel-v1.md"
MANIFEST="tests/baseline/f-channel-v1-closure.tsv"
die() { echo "f-channel-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-channel v1: channel.c → channel.x ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-channel v1' "$DOC" || die "doc marker"
[ -f "$MANIFEST" ] || die "missing manifest"
[ -f std/channel/channel.x ] || die "missing channel.x"
[ -f compiler/seeds/runtime_channel_glue.from_x.c ] || die "missing runtime_channel_glue.from_x.c"
[ ! -f std/channel/channel_glue.c ] || die "channel_glue.c should be deleted"
[ ! -f std/channel/channel.c ] || die "channel.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/channel/channel.o >/dev/null 2>&1 || die "ensure channel.o failed (xlang_compiler_make)"
else
  echo "f-channel-v1 SKIP channel.o build (no xlang-c)" >&2
fi
xlang_compiler_make -q runtime_channel_glue.o 2>/dev/null || xlang_compiler_make runtime_channel_glue.o >/dev/null 2>&1 || die "runtime_channel_glue.o build failed"
for sub in run-std-channel-select-gate.sh run-std-channel-unbounded-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-channel-v1 gate OK"
