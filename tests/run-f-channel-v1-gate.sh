#!/usr/bin/env bash
# F-channel v1: std.channel de-C (channel.x + seeds/runtime_channel_glue.from_x.c).
#
# Usage: ./tests/run-f-channel-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-channel-v1-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-098 channel-select hard delegate. Soft XLANG_F_CHANNEL_V1_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+STD-098 already green).
# channel-unbounded product residual observational (listed skip 复探红).
# Report static=/ensure=/glue=/select=/unbounded=/skip=.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-channel-v1.md"
MANIFEST="tests/baseline/f-channel-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_CHANNEL_V1]"

resolve_shu() {
  local cand abs
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$(pwd)/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

die() {
  echo "f-channel-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} glue=${GLUE_OK:-0} select=${SELECT_OK:-0} unbounded=${UNBOUNDED_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
GLUE_OK=0
SELECT_OK=0
UNBOUNDED_OK=0
SKIP=1

echo "=== F-channel v1: std.channel channel.c → channel.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-channel v1' "$DOC" || die "doc missing F-channel v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/channel/channel.x ] || die "missing channel.x"
[ -f compiler/seeds/runtime_channel_glue.from_x.c ] || die "missing runtime_channel_glue.from_x.c"
[ ! -f std/channel/channel_glue.c ] || die "channel_glue.c should be deleted"
[ ! -f std/channel/channel.c ] || die "channel.c should be deleted"

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
    *)
      die "manifest unknown kind '$kind' for $item_id"
      ;;
  esac
done < "$MANIFEST"
STATIC_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

xlang_compiler_make -q runtime_channel_glue.o 2>/dev/null \
  || xlang_compiler_make runtime_channel_glue.o >/dev/null 2>&1 \
  || die "runtime_channel_glue.o build failed"
GLUE_OK=1

xlang_compiler_make ../std/channel/channel.o >/dev/null 2>&1 \
  || die "ensure channel.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

# STD-098 channel-select already soft→硬绿; hard-delegate as product signal.
if [ -f tests/run-std-channel-select-gate.sh ]; then
  echo "=== F-channel v1: delegate run-std-channel-select-gate ==="
  chmod +x tests/run-std-channel-select-gate.sh
  if ! tests/run-std-channel-select-gate.sh; then
    die "std-channel-select sub-gate failed"
  fi
  SELECT_OK=1
fi

# Product residual (listed skip 复探红): unbounded — observational only.
if [ -f tests/run-std-channel-unbounded-gate.sh ]; then
  echo "=== F-channel v1: std-channel-unbounded (observational; product residual) ==="
  chmod +x tests/run-std-channel-unbounded-gate.sh
  if tests/run-std-channel-unbounded-gate.sh; then
    UNBOUNDED_OK=1
  else
    echo "f-channel-v1 WARN: std-channel-unbounded failed (observational)" >&2
    UNBOUNDED_OK=0
  fi
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} glue=${GLUE_OK} select=${SELECT_OK} unbounded=${UNBOUNDED_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-channel-v1 std.channel gate OK (F-channel v1; honesty)"
