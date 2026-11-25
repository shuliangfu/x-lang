#!/usr/bin/env bash
# Knife 11.47: Win tip L2 CG002 nonempty array / stale primary_array gate.
# Locks DIG + override seed. empty/dual_ptr_empty must OK; e_fmtstyle must NOT be P012.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PREFIX="xlang: [WIN_TIP_L2_CG002_NONEMPTY_ARRAY]"

die() { echo "${PREFIX} FAIL: $*" >&2; exit 1; }

DOC=analysis/xlang-win-tip-l2-cg002-nonempty-array.md
PRIOR=analysis/xlang-win-tip-l2-p012-dual-fn-scope.md
OV=compiler/seeds/win_tip_pe_overrides/stale_primary_array_x_into_override.c
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$PRIOR" ] || die "missing 11.46 DIG $PRIOR"
[ -f "$OV" ] || die "missing primary_array override $OV"
grep -q 'primary_array' "$DOC" || die "diagnose missing primary_array"
grep -q 'CG002' "$DOC" || die "diagnose missing CG002"
grep -q 'Residual' "$DOC" || die "diagnose missing Residual"
grep -q '__stale_prim_parser_asm_primary_array_x_into_c' "$OV" || die "override missing stale symbol"
grep -q 'is_pointee' "$PRIOR" || die "11.46 DIG missing is_pointee cite"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    if [ -x ./compiler/xlang_asm.exe ]; then XLANG=./compiler/xlang_asm.exe
    elif [ -x ./compiler/xlang.exe ]; then XLANG=./compiler/xlang.exe
    else die "missing tip PE"; fi
    TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_win_cg002_arr_$$}"
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
    cat >"$TMP/one_arr.x" <<'EOFX'
export function f1(): i32 {
  let digits: u8[10] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57];
  let num_digits: i32 = 0;
  return num_digits;
}
EOFX
    set +e
    "$XLANG" -c -o "$TMP/te.o" "$TMP/t_empty.x" >"$TMP/te.log" 2>&1; terc=$?
    "$XLANG" -c -o "$TMP/dpe.o" "$TMP/dual_ptr_empty.x" >"$TMP/dpe.log" 2>&1; dperc=$?
    "$XLANG" -c -o "$TMP/e.o" "$TMP/e_fmtstyle.x" >"$TMP/e.log" 2>&1; erc=$?
    "$XLANG" -c -o "$TMP/one.o" "$TMP/one_arr.x" >"$TMP/one.log" 2>&1; orc=$?
    set -e
    [ "$terc" -eq 0 ] || die "empty dual must stay OK; log=$(head -3 "$TMP/te.log" | tr '\n' ' ')"
    [ "$dperc" -eq 0 ] || die "dual_ptr_empty must stay OK; log=$(head -3 "$TMP/dpe.log" | tr '\n' ' ')"
    if grep -q 'P012' "$TMP/e.log"; then
      die "e_fmtstyle regress to P012; log=$(head -4 "$TMP/e.log" | tr '\n' ' ')"
    fi
    # nonempty may be CG002 residual or OK after plant — both fine if not P012
    if [ "$erc" -ne 0 ]; then
      grep -q 'CG002' "$TMP/e.log" || die "e_fmtstyle fail without CG002; log=$(head -4 "$TMP/e.log" | tr '\n' ' ')"
    fi
    if [ "$orc" -ne 0 ]; then
      grep -q 'CG002' "$TMP/one.log" || die "one_arr fail without CG002; log=$(head -3 "$TMP/one.log" | tr '\n' ' ')"
    fi
    echo "${PREFIX} status=ok empty_ok=1 dual_ptr_empty_ok=1 e_fmtstyle_no_p012=1 one_arr_locked=1 host=windows"
    ;;
  *)
    echo "${PREFIX} status=ok static_only host=${uname_s} (Win PE probe skipped)"
    ;;
esac
echo "win-tip-l2-cg002-nonempty-array gate OK"
exit 0
