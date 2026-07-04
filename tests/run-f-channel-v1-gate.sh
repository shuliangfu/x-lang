#!/usr/bin/env bash
# F-channel v1：std.channel 去 C（channel.c → channel.x + runtime_channel_glue.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_CHANNEL_V1_FAIL:-0}
DOC="analysis/phase-f-channel-v1.md"
MANIFEST="tests/baseline/f-channel-v1-closure.tsv"
die() { echo "f-channel-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-channel v1: channel.c → channel.x ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-channel v1' "$DOC" || die "doc marker"
[ -f "$MANIFEST" ] || die "missing manifest"
[ -f std/channel/channel.x ] || die "missing channel.x"
[ -f compiler/src/asm/runtime_channel_glue.c ] || die "missing runtime_channel_glue.c"
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
grep -q 'runtime_channel_glue' compiler/Makefile || die "Makefile missing runtime_channel_glue"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/channel/channel.o >/dev/null 2>&1 || die "make channel.o failed"
else
  echo "f-channel-v1 SKIP channel.o build (no shux-c)" >&2
fi
make -C compiler -q runtime_channel_glue.o 2>/dev/null || make -C compiler runtime_channel_glue.o >/dev/null 2>&1 || die "runtime_channel_glue.o build failed"
for sub in run-std-channel-select-gate.sh run-std-channel-unbounded-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-channel-v1 gate OK"
