#!/usr/bin/env bash
# F-path v1: std.path de-C (path.c → mod.x cfg path_sep_c).
#
# Usage: ./tests/run-f-path-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-path-v1-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-140 / STD-021／022 hard delegate. Soft XLANG_F_PATH_V1_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+STD already green).
# Report static=/ensure=/extreme=/win=/skip=. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-path-v1.md"
MANIFEST="tests/baseline/f-path-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_PATH_V1]"

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
  echo "f-path-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} extreme=${EXTREME_OK:-0} win=${WIN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
EXTREME_OK=0
WIN_OK=0
SKIP=1

echo "=== F-path v1: std.path path.c → mod.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-path v1' "$DOC" || die "doc missing F-path v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/path/mod.x ] || die "missing std/path/mod.x"
[ ! -f std/path/path.c ] || die "std/path/path.c should be deleted"
grep -qE 'function sep\(' std/path/mod.x || die "mod.x missing sep"
grep -q 'extern function sep' std/path/mod.x && die "mod.x still extern sep"

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

xlang_compiler_make ../std/path/path.o >/dev/null 2>&1 \
  || die "ensure path.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

if [ -f tests/run-std-path-extreme-gate.sh ]; then
  echo "=== F-path v1: delegate run-std-path-extreme-gate ==="
  chmod +x tests/run-std-path-extreme-gate.sh
  if ! tests/run-std-path-extreme-gate.sh; then
    die "std-path-extreme sub-gate failed"
  fi
  EXTREME_OK=1
fi

if [ -f tests/run-std-path-fs-windows-gate.sh ]; then
  echo "=== F-path v1: delegate run-std-path-fs-windows-gate ==="
  chmod +x tests/run-std-path-fs-windows-gate.sh
  if ! tests/run-std-path-fs-windows-gate.sh; then
    die "std-path-fs-windows sub-gate failed"
  fi
  WIN_OK=1
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} extreme=${EXTREME_OK} win=${WIN_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-path-v1 std.path gate OK (F-path v1; honesty)"
