#!/usr/bin/env bash
# F-random v1: std.random de-C (random.c → random.x + OS glue).
#
# Usage: ./tests/run-f-random-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-random-v1-gate.sh
# 2026-08-26: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-130 rng delegate. Soft XLANG_F_RANDOM_V1_FAIL retired. Root: orphan
# `die Makefile…; fi` after Makefile delete → bash syntax error; soft
# de-c-batch swallowed RC≠0 (portable false-green). Report
# static=/ensure=/rng=/skip=. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-random-v1.md"
MANIFEST="tests/baseline/f-random-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_RANDOM_V1]"

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
  echo "f-random-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} rng=${RNG_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
RNG_OK=0
SKIP=1

echo "=== F-random v1: std.random random.c → random.x + glue (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-random v1' "$DOC" || die "doc missing F-random v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/random/random.x ] || die "missing std/random/random.x"
[ ! -f std/random/random_os_glue.c ] || die "random_os_glue.c should be deleted (F-ZC)"
[ -f compiler/seeds/runtime_random_fill.from_x.c ] || die "missing runtime_random_fill.inc"
[ ! -f std/random/random.c ] || die "std/random/random.c should be deleted"

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

xlang_compiler_make ../std/random/random.o >/dev/null 2>&1 \
  || die "ensure random.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

if [ -f tests/run-std-random-rng-gate.sh ]; then
  echo "=== F-random v1: delegate run-std-random-rng-gate ==="
  chmod +x tests/run-std-random-rng-gate.sh
  if ! tests/run-std-random-rng-gate.sh; then
    die "std-random-rng sub-gate failed"
  fi
  RNG_OK=1
else
  die "missing tests/run-std-random-rng-gate.sh"
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} rng=${RNG_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-random-v1 std.random gate OK (F-random v1; honesty)"
