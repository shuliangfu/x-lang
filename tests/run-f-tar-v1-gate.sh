#!/usr/bin/env bash
# F-tar v1: std.tar de-C (tar.c → tar.x; glue superseded by v2).
#
# Usage: ./tests/run-f-tar-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-tar-v1-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-tar ustar／extended hard delegate. Soft XLANG_F_TAR_V1_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+STD already green).
# Report static=/ensure=/ustar=/ext=/skip=. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-tar-v1.md"
MANIFEST="tests/baseline/f-tar-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_TAR_V1]"

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
  echo "f-tar-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} ustar=${USTAR_OK:-0} ext=${EXT_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
USTAR_OK=0
EXT_OK=0
SKIP=1

echo "=== F-tar v1: std.tar tar.c → tar.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-tar v1' "$DOC" || die "doc missing F-tar v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/tar/tar.x ] || die "missing std/tar/tar.x"
[ ! -f std/tar/tar.c ] || die "tar.c should be deleted"

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

xlang_compiler_make ../std/tar/tar.o >/dev/null 2>&1 \
  || die "ensure tar.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

if [ -f tests/run-std-tar-ustar-gate.sh ]; then
  echo "=== F-tar v1: delegate run-std-tar-ustar-gate ==="
  chmod +x tests/run-std-tar-ustar-gate.sh
  if ! tests/run-std-tar-ustar-gate.sh; then
    die "std-tar-ustar sub-gate failed"
  fi
  USTAR_OK=1
fi

if [ -f tests/run-std-tar-extended-gate.sh ]; then
  echo "=== F-tar v1: delegate run-std-tar-extended-gate ==="
  chmod +x tests/run-std-tar-extended-gate.sh
  if ! tests/run-std-tar-extended-gate.sh; then
    die "std-tar-extended sub-gate failed"
  fi
  EXT_OK=1
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} ustar=${USTAR_OK} ext=${EXT_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-tar-v1 std.tar gate OK (F-tar v1; honesty)"
