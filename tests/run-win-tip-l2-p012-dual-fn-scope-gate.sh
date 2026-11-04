#!/usr/bin/env bash
# Knife 11.46: Win tip L2 P012 dual-fn scope / local-table gate.
# After is_pointee tip patch: *T dual empty OK; e_fmtstyle must NOT be P012
# (CG002 residual OK). empty dual must stay OK. NOT product green / hello.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PREFIX="xlang: [WIN_TIP_L2_P012_DUAL_FN_SCOPE]"

die() { echo "${PREFIX} FAIL: $*" >&2; exit 1; }

DOC=analysis/xlang-win-tip-l2-p012-dual-fn-scope.md
PRIOR=analysis/xlang-win-tip-l2-p012-fmt-local-scope.md
OV=compiler/seeds/win_tip_pe_overrides/is_pointee_type_token_override.c
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$PRIOR" ] || die "missing 11.45 diagnose $PRIOR"
[ -f "$OV" ] || die "missing is_pointee override seed $OV"
grep -q 'asm_module_top_level_let_name_exists' "$DOC" || die "diagnose missing top_level_let_name_exists"
grep -q 'body_let_bracket_compound_init\|pipeline_onefunc_append_let' "$DOC" || die "diagnose missing body_let path"
grep -q 'e_fmtstyle' "$DOC" || die "diagnose missing e_fmtstyle"
grep -q 'Residual' "$DOC" || die "diagnose missing Residual"
grep -q 'is_pointee_type_token\|num_digits' "$DOC" || die "diagnose missing is_pointee/num_digits"
grep -q 'parser_asm_is_pointee_type_token_c' "$OV" || die "override missing symbol"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    if [ -x ./compiler/xlang_asm.exe ]; then XLANG=./compiler/xlang_asm.exe
    elif [ -x ./compiler/xlang.exe ]; then XLANG=./compiler/xlang.exe
    else die "missing tip PE"; fi
    TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_win_p012_scope_$$}"
    mkdir -p "$TMP"
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
    cat >"$TMP/one_arr.x" <<'EOFX'
export function f1(): i32 {
  let digits: u8[10] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57];
  let num_digits: i32 = 0;
  return num_digits;
}
EOFX
    set +e
    "$XLANG" -c -o "$TMP/e.o" "$TMP/e_fmtstyle.x" >"$TMP/e.log" 2>&1; erc=$?
    "$XLANG" -c -o "$TMP/te.o" "$TMP/t_empty.x" >"$TMP/te.log" 2>&1; terc=$?
    "$XLANG" -c -o "$TMP/dpe.o" "$TMP/dual_ptr_empty.x" >"$TMP/dpe.log" 2>&1; dperc=$?
    "$XLANG" -c -o "$TMP/one.o" "$TMP/one_arr.x" >"$TMP/one.log" 2>&1; orc=$?
    set -e
    [ "$terc" -eq 0 ] || die "empty-array dual-fn must stay OK; log=$(head -3 "$TMP/te.log" | tr '\n' ' ')"
    [ "$dperc" -eq 0 ] || die "dual *u8 + empty must OK after is_pointee patch; log=$(head -4 "$TMP/dpe.log" | tr '\n' ' ')"
    if grep -q 'P012' "$TMP/e.log"; then
      die "e_fmtstyle still P012 (is_pointee *T chain not cleared); log=$(head -4 "$TMP/e.log" | tr '\n' ' ')"
    fi
    if [ "$erc" -eq 0 ]; then
      die "e_fmtstyle unexpectedly OK (nonempty codegen residual expected CG002)"
    fi
    grep -q 'CG002' "$TMP/e.log" || die "e_fmtstyle expected CG002 residual; log=$(head -4 "$TMP/e.log" | tr '\n' ' ')"
    if [ "$orc" -eq 0 ]; then
      die "one_arr unexpectedly OK on tip PE (expected CG002 residual until codegen lift)"
    fi
    grep -q 'CG002' "$TMP/one.log" || die "one_arr expected CG002; log=$(head -3 "$TMP/one.log" | tr '\n' ' ')"
    echo "${PREFIX} status=ok p012_star_cleared=1 empty_ok=1 dual_ptr_empty_ok=1 e_fmtstyle=CG002 one_arr=CG002 host=windows"
    ;;
  *)
    echo "${PREFIX} status=ok static_only host=${uname_s} (Win PE residual probe skipped)"
    ;;
esac
echo "win-tip-l2-p012-dual-fn-scope gate OK"
exit 0
