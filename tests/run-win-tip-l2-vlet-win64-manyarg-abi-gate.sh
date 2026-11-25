#!/usr/bin/env bash
# Knife 11.48: Win tip L2 vlet Win64 many-arg ABI gate.
# Locks 11.47 residual DIG. empty/dual must OK; e_fmtstyle must NOT be P012.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PREFIX="xlang: [WIN_TIP_L2_VLET_WIN64_MANYARG_ABI]"

die() { echo "${PREFIX} FAIL: $*" >&2; exit 1; }

DOC=analysis/xlang-win-tip-l2-vlet-win64-manyarg-abi.md
PRIOR=analysis/xlang-win-tip-l2-cg002-nonempty-array.md
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$PRIOR" ] || die "missing 11.47 DIG $PRIOR"
grep -q 'vlet_scalar_one' "$DOC" || die "diagnose missing vlet_scalar_one"
grep -q 'many-arg\|manyarg\|Win64\|MSVC' "$DOC" || die "diagnose missing Win64/MSVC many-arg"
grep -q 'Residual' "$DOC" || die "diagnose missing Residual"
grep -q 'vlet_scalar_one' "$PRIOR" || die "11.47 DIG missing vlet_scalar_one cite"
grep -q 'r8' "$PRIOR" || die "11.47 DIG missing r8 overwrite cite"
grep -q 'CLOSE residual HOLD\|residual HOLD' "$PRIOR" || die "11.47 not marked residual HOLD"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    if [ -x ./compiler/xlang_asm.exe ]; then XLANG=./compiler/xlang_asm.exe
    elif [ -x ./compiler/xlang.exe ]; then XLANG=./compiler/xlang.exe
    else die "missing tip PE"; fi
    TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_win_vlet_abi_$$}"
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
    cat >"$TMP/dual_ptr_empty.x" <<'EOFX'
export function f1(buf: *u8, cap: i32, x: i32): i32 {
  let digits: u8[10] = [];
  let num_digits: i32 = 0;
  return num_digits;
}
export function f2(buf: *u8, cap: i32, u: u32): i32 {
  let digits: u8[10] = [];
  let num_digits: i32 = 0;
  return num_digits;
}
EOFX
    cat >"$TMP/e_fmtstyle.x" <<'EOFX'
export function f1(buf: *u8, cap: i32, x: i32): i32 {
  let digits: u8[10] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57];
  let num_digits: i32 = 0;
  return num_digits;
}
export function f2(buf: *u8, cap: i32, u: u32): i32 {
  let digits: u8[10] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57];
  let num_digits: i32 = 0;
  return num_digits;
}
EOFX
    cat >"$TMP/match10.x" <<'EOFX'
export function f1(): i32 {
  let digits: u8[10] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57];
  return 0;
}
EOFX
    set +e
    "$XLANG" -c -o "$TMP/te.o" "$TMP/t_empty.x" >"$TMP/te.log" 2>&1; terc=$?
    "$XLANG" -c -o "$TMP/dpe.o" "$TMP/dual_ptr_empty.x" >"$TMP/dpe.log" 2>&1; dperc=$?
    "$XLANG" -c -o "$TMP/e.o" "$TMP/e_fmtstyle.x" >"$TMP/e.log" 2>&1; erc=$?
    "$XLANG" -c -o "$TMP/m.o" "$TMP/match10.x" >"$TMP/m.log" 2>&1; mrc=$?
    set -e
    [ "$terc" -eq 0 ] || die "empty dual must stay OK; log=$(head -3 "$TMP/te.log" | tr '\n' ' ')"
    [ "$dperc" -eq 0 ] || die "dual_ptr_empty must stay OK; log=$(head -3 "$TMP/dpe.log" | tr '\n' ' ')"
    if grep -q 'P012' "$TMP/e.log"; then
      die "e_fmtstyle regress to P012; log=$(head -4 "$TMP/e.log" | tr '\n' ' ')"
    fi
    [ "$mrc" -eq 0 ] || die "match10 must be OK after 11.48 ABI fix; log=$(head -3 "$TMP/m.log" | tr '\n' ' ')"
    [ "$erc" -eq 0 ] || die "e_fmtstyle must be OK after 11.48; log=$(head -4 "$TMP/e.log" | tr '\n' ' ')"
    echo "${PREFIX} status=ok empty_ok=1 dual_ptr_empty_ok=1 e_fmtstyle_ok=1 match10_ok=1 host=windows"
    ;;
  *)
    echo "${PREFIX} status=ok static_only host=${uname_s} (Win PE probe skipped)"
    ;;
esac
echo "win-tip-l2-vlet-win64-manyarg-abi gate OK"
exit 0
