#!/usr/bin/env bash
# F-backtrace v1: std.backtrace de-C (backtrace.c → backtrace.x; glue in v2).
#
# Usage: ./tests/run-f-backtrace-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-backtrace-v1-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-052 symbolicate hard delegate. Soft XLANG_F_BACKTRACE_V1_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+STD-052 already green;
# STD-147 xplat still red on fossil DOC sections). xplat observational.
# Report static=/ensure=/sym=/xplat=/skip=. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-backtrace-v1.md"
MANIFEST="tests/baseline/f-backtrace-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_BACKTRACE_V1]"

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
  echo "f-backtrace-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} sym=${SYM_OK:-0} xplat=${XPLAT_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
SYM_OK=0
XPLAT_OK=0
SKIP=1

echo "=== F-backtrace v1: backtrace.c → backtrace.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-backtrace v1' "$DOC" || die "doc missing F-backtrace v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/backtrace/backtrace.x ] || die "missing backtrace.x"
[ ! -f std/backtrace/backtrace.c ] || die "backtrace.c should be deleted"
grep -q 'backtrace_f_backtrace_v1_marker_c' std/backtrace/backtrace.x || die "backtrace.x missing v1 marker"

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

xlang_compiler_make ../std/backtrace/backtrace.o >/dev/null 2>&1 \
  || die "ensure backtrace.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

# Hard-delegate already soft→硬绿 STD-052 symbolicate.
if [ -f tests/run-std-backtrace-symbolicate-gate.sh ]; then
  echo "=== F-backtrace v1: delegate run-std-backtrace-symbolicate-gate ==="
  chmod +x tests/run-std-backtrace-symbolicate-gate.sh
  if ! tests/run-std-backtrace-symbolicate-gate.sh; then
    die "std-backtrace-symbolicate sub-gate failed"
  fi
  SYM_OK=1
fi

# STD-147 xplat observational: fossil DOC sections (product residual).
if [ -f tests/run-std-backtrace-xplat-gate.sh ]; then
  echo "=== F-backtrace v1: std-backtrace-xplat (observational; DOC residual) ==="
  chmod +x tests/run-std-backtrace-xplat-gate.sh
  if tests/run-std-backtrace-xplat-gate.sh; then
    XPLAT_OK=1
  else
    echo "f-backtrace-v1 WARN: std-backtrace-xplat failed (observational)" >&2
    XPLAT_OK=0
  fi
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} sym=${SYM_OK} xplat=${XPLAT_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-backtrace-v1 std.backtrace gate OK (F-backtrace v1; honesty)"
