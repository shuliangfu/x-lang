#!/usr/bin/env bash
# F-dynlib v2: dynlib logic in dynlib.x + runtime_dynlib_os (F-ZC).
#
# Usage: ./tests/run-f-dynlib-v2-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-dynlib-v2-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-027 dynlib-windows + STD-096 last-error hard delegate.
# Soft XLANG_F_DYNLIB_V2_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+STD already green).
# Report static=/ensure=/win=/err=/skip=. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-dynlib-v2.md"
MANIFEST="tests/baseline/f-dynlib-v2-closure.tsv"
PREFIX="xlang: [XLANG_F_DYNLIB_V2]"

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
  echo "f-dynlib-v2 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} win=${WIN_OK:-0} err=${ERR_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
WIN_OK=0
ERR_OK=0
SKIP=1

echo "=== F-dynlib v2: logic → dynlib.x + runtime (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-dynlib v2' "$DOC" || die "doc missing F-dynlib v2 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/dynlib/dynlib.x ] || die "missing dynlib.x"
[ ! -f std/dynlib/dynlib_os_glue.c ] || die "dynlib_os_glue.c should be deleted (F-ZC)"
[ -f compiler/seeds/runtime_dynlib_os.from_x.c ] || die "missing runtime_dynlib_os.from_x.c"
[ ! -f std/dynlib/dynlib_glue.c ] || die "dynlib_glue.c should be deleted"

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
grep -q 'dynlib_open_c' std/dynlib/dynlib.x || die "dynlib.x missing open"
grep -q 'dynlib_last_error_copy_c' std/dynlib/dynlib.x || die "dynlib.x missing last_error"
grep -q 'dynlib_f_dynlib_v2_marker_c' std/dynlib/dynlib.x || die "dynlib.x missing v2 marker"
grep -q 'dynlib_os_open_c' compiler/seeds/runtime_dynlib_os.from_x.c || die "runtime missing open"
STATIC_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

xlang_compiler_make ../std/dynlib/dynlib.o >/dev/null 2>&1 \
  || die "ensure dynlib.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

# Hard-delegate already soft→硬绿 STD-027 / STD-096.
# Do NOT export retired XLANG_F_DYNLIB_V2_FAIL.
# PLATFORM: SHARED archaeology.
if [ -f tests/run-std-dynlib-windows-gate.sh ]; then
  echo "=== F-dynlib v2: delegate run-std-dynlib-windows-gate (hard) ==="
  chmod +x tests/run-std-dynlib-windows-gate.sh
  if ! tests/run-std-dynlib-windows-gate.sh; then
    die "std-dynlib-windows sub-gate failed"
  fi
  WIN_OK=1
else
  die "missing tests/run-std-dynlib-windows-gate.sh"
fi

if [ -f tests/run-std-dynlib-last-error-gate.sh ]; then
  echo "=== F-dynlib v2: delegate run-std-dynlib-last-error-gate (hard) ==="
  chmod +x tests/run-std-dynlib-last-error-gate.sh
  if ! tests/run-std-dynlib-last-error-gate.sh; then
    die "std-dynlib-last-error sub-gate failed"
  fi
  ERR_OK=1
else
  die "missing tests/run-std-dynlib-last-error-gate.sh"
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} win=${WIN_OK} err=${ERR_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-dynlib-v2 gate OK (F-dynlib v2; honesty)"
