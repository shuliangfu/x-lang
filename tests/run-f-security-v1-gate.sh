#!/usr/bin/env bash
# F-security v1: std.security de-C (security.c → security.x; F-ZC pure .x).
#
# Usage: ./tests/run-f-security-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-security-v1-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-079 security hard delegate. Soft XLANG_F_SECURITY_V1_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+STD-079 already green).
# Report static=/ensure=/sec=/skip=. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-security-v1.md"
MANIFEST="tests/baseline/f-security-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_SECURITY_V1]"

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
  echo "f-security-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} sec=${SEC_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
SEC_OK=0
SKIP=1

echo "=== F-security v1: security.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-security v1' "$DOC" || die "doc missing F-security v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/security/security.x ] || die "missing security.x"
[ ! -f std/security/security_os_glue.c ] || die "security_os_glue.c should be deleted (F-ZC)"
[ ! -f std/security/security.c ] || die "security.c should be deleted"
grep -q 'security_mlock_c' std/security/security.x || die "security.x missing mlock"
grep -q 'security_f_zero_c_marker_c' std/security/security.x || die "security.x missing zero-c marker"

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

xlang_compiler_make ../std/security/security.o >/dev/null 2>&1 \
  || die "ensure security.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

# Hard-delegate already soft→硬绿 STD-079.
if [ -f tests/run-std-security-gate.sh ]; then
  echo "=== F-security v1: delegate run-std-security-gate ==="
  chmod +x tests/run-std-security-gate.sh
  if ! tests/run-std-security-gate.sh; then
    die "std-security sub-gate failed"
  fi
  SEC_OK=1
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} sec=${SEC_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-security-v1 std.security gate OK (F-security v1; honesty)"
