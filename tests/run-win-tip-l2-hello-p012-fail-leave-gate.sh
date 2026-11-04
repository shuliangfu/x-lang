#!/usr/bin/env bash
# Knife 11.49: Win tip L2 hello/fmt P012 fail-leave gate.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PREFIX="xlang: [WIN_TIP_L2_HELLO_P012_FAIL_LEAVE]"

die() { echo "${PREFIX} FAIL: $*" >&2; exit 1; }

DOC=analysis/xlang-win-tip-l2-hello-p012-fail-leave.md
PRIOR=analysis/xlang-win-tip-l2-vlet-win64-manyarg-abi.md
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$PRIOR" ] || die "missing 11.48 DIG $PRIOR"
grep -q 'P012' "$DOC" || die "diagnose missing P012"
grep -q 'Residual\|DIG 靶\|fail-leave' "$DOC" || die "diagnose missing DIG/Residual"
grep -q 'CLOSE ACCEPT' "$PRIOR" || die "11.48 DIG must be CLOSE ACCEPT"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    if [ -x ./compiler/xlang_asm.exe ]; then XLANG=./compiler/xlang_asm.exe
    elif [ -x ./compiler/xlang.exe ]; then XLANG=./compiler/xlang.exe
    else die "missing tip PE"; fi
    TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_win_hello_p012_$$}"
    mkdir -p "$TMP"
    cat >"$TMP/t_empty.x" <<'EOFX'
export function f1(): i32 {
  let digits: u8[10] = [];
  let num_digits: i32 = 0;
  return num_digits;
}
export function f2(): i32 {
  let digits: u8[10] = [];
  let num_digits: i32 = 0;
  return num_digits;
}
EOFX
    cat >"$TMP/match10.x" <<'EOFX'
export function f1(): i32 {
  let digits: u8[10] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57];
  let num_digits: i32 = 0;
  return num_digits;
}
EOFX
    set +e
    "$XLANG" -c -o "$TMP/te.o" "$TMP/t_empty.x" >"$TMP/te.log" 2>&1; terc=$?
    "$XLANG" -c -o "$TMP/m.o" "$TMP/match10.x" >"$TMP/m.log" 2>&1; mrc=$?
    if [ -f examples/hello.x ]; then
      "$XLANG" -c -o "$TMP/hello.o" examples/hello.x >"$TMP/hello.log" 2>&1; hrc=$?
    else
      hrc=1
      echo "missing examples/hello.x" >"$TMP/hello.log"
    fi
    set -e
    [ "$terc" -eq 0 ] || die "empty must stay OK; log=$(head -3 "$TMP/te.log" | tr '\n' ' ')"
    [ "$mrc" -eq 0 ] || die "match10 must stay OK (11.48); log=$(head -3 "$TMP/m.log" | tr '\n' ' ')"
    # hello may still be P012 until this knife lands
    if [ "$hrc" -ne 0 ]; then
      grep -q 'P012' "$TMP/hello.log" || die "hello fail without P012; log=$(head -4 "$TMP/hello.log" | tr '\n' ' ')"
    fi
    echo "${PREFIX} status=ok empty_ok=1 match10_ok=1 hello_locked=1 host=windows"
    ;;
  *)
    echo "${PREFIX} status=ok static_only host=${uname_s} (Win PE probe skipped)"
    ;;
esac
echo "win-tip-l2-hello-p012-fail-leave gate OK"
exit 0
