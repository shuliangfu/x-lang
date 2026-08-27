#!/usr/bin/env bash
# B-03 v0: #[repr(C)] lex-skip smoke (parse/typeck + run).
#
# Honesty: soft XLANG_REPR_C_ATTR_SKIP_FAIL retired — compile/run failure was
# portable false-green (soft die→exit0). Prefer xlang_asm; pin XLANG_LINK_XLANG.
# Missing compiler is hard die (refuse soft SKIP→OK).
#
# Usage: ./tests/run-repr-c-attribute-skip-gate.sh
# Report: run=/skip=
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

X="tests/lexer/repr_c_attribute_skip.x"
OUT="/tmp/xlang_repr_c_attr_skip.$$.out"
PREFIX="xlang: [XLANG_B03_REPR_C_ATTR_SKIP]"
RUN_OK=0
SKIP=1

die() {
  echo "repr-c-attribute-skip-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

stdlib_cm_native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 0 ;;
  esac
}

resolve_shu() {
  local cand
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

echo "=== B-03: #[repr(C)] attribute lex-skip (honesty) ==="

[ -f "$X" ] || die "missing $X"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

rm -f "$OUT" 2>/dev/null || true
if ! "$XLANG" build -o "$OUT" "$X" 2>/tmp/xlang_repr_c_attr_skip.log; then
  tail -n 8 /tmp/xlang_repr_c_attr_skip.log 2>/dev/null || true
  die "compile $X"
fi
[ -x "$OUT" ] || die "no executable $OUT"

rc=0
"$OUT" || rc=$?
rm -f "$OUT" 2>/dev/null || true
[ "$rc" -eq 10 ] || die "expected exit 10 (4+6), got $rc"

RUN_OK=1
SKIP=0
echo "repr-c-attribute-skip-gate OK (#[repr(C)] lex skip + main returns 10)"
echo "${PREFIX} status=ok run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
exit 0
