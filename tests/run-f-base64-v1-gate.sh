#!/usr/bin/env bash
# F-base64 v1: std.base64 de-C (base64.c → base64.x).
#
# Usage: ./tests/run-f-base64-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-base64-v1-gate.sh
# 2026-08-26: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-109 stream delegate. Soft XLANG_F_BASE64_V1_FAIL retired. Root: orphan
# `die Makefile…; fi` after Makefile delete → bash syntax error; soft
# de-c-batch swallowed RC≠0 (portable false-green). Report
# static=/ensure=/stream=/skip=. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-base64-v1.md"
MANIFEST="tests/baseline/f-base64-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_BASE64_V1]"

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
  echo "f-base64-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} stream=${STREAM_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
STREAM_OK=0
SKIP=1

echo "=== F-base64 v1: std.base64 base64.c → base64.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-base64 v1' "$DOC" || die "doc missing F-base64 v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
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

xlang_compiler_make ../std/base64/base64.o >/dev/null 2>&1 \
  || die "ensure base64.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

if [ -f tests/run-std-base64-stream-gate.sh ]; then
  echo "=== F-base64 v1: delegate run-std-base64-stream-gate ==="
  chmod +x tests/run-std-base64-stream-gate.sh
  if ! tests/run-std-base64-stream-gate.sh; then
    die "std-base64-stream sub-gate failed"
  fi
  STREAM_OK=1
else
  die "missing tests/run-std-base64-stream-gate.sh"
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} stream=${STREAM_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-base64-v1 std.base64 gate OK (F-base64 v1; honesty)"
