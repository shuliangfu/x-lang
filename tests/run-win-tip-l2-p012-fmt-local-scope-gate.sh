#!/usr/bin/env bash
# Knife 11.45: Win tip L2 P012 fmt local-scope plant gate.
# Locks DIG + override source. Does NOT claim tip PE product green.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PREFIX="xlang: [WIN_TIP_L2_P012_FMT_LOCAL_SCOPE]"

die() { echo "${PREFIX} FAIL: $*" >&2; exit 1; }

DOC=analysis/xlang-win-tip-l2-p012-fmt-local-scope.md
OVR=compiler/seeds/win_tip_pe_overrides/stale_primary_array_x_into_override.c

[ -f "$DOC" ] || die "missing $DOC"
[ -f "$OVR" ] || die "missing $OVR"

grep -q 'stale_prim_parser_asm_primary_array_x_into_c' "$DOC" || die "diagnose missing stale primary_array smoking gun"
grep -q 'e_fmtstyle' "$DOC" || die "diagnose missing e_fmtstyle repro"
grep -q 'Residual HOLD' "$DOC" || die "diagnose missing Residual HOLD"
grep -q '__stale_prim_parser_asm_primary_array_x_into_c' "$OVR" || die "override missing stale symbol"
grep -q 'TOKEN_LBRACKET' "$OVR" || die "override missing LBRACKET"
grep -q 'EXPR_ARRAY_LIT' "$OVR" || die "override missing EXPR_ARRAY_LIT"
grep -qi 'Do NOT raise Soft Cap' "$OVR" || grep -q 'Do NOT raise Soft Cap' "$OVR" || \
  grep -q 'Do NOT raise Soft Cap / tiphead' "$OVR" || die "override missing Soft Cap raise ban comment"

# Prior 11.44 diagnose still present (fail-family context)
[ -f analysis/xlang-win-tip-l2-fail-family-diagnose.md ] || die "missing 11.44 diagnose"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    if [ -x ./compiler/xlang_asm.exe ]; then
      XLANG=./compiler/xlang_asm.exe
    elif [ -x ./compiler/xlang.exe ]; then
      XLANG=./compiler/xlang.exe
    else
      die "missing tip PE on Windows"
    fi
    TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_win_p012_$$}"
    mkdir -p "$TMP"
    cat >"$TMP/e_fmtstyle.x" <<'EOF'
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
EOF
    set +e
    "$XLANG" -c -o "$TMP/e.o" "$TMP/e_fmtstyle.x" >"$TMP/e.log" 2>&1
    erc=$?
    set -e
    # Residual lock: until PE plant lands, tip PE must still show P012 (no silent green).
    if [ "$erc" -eq 0 ]; then
      die "e_fmtstyle unexpectedly OK on tip PE (would claim green without documented PE plant)"
    fi
    grep -q 'P012' "$TMP/e.log" || die "e_fmtstyle expected residual P012; log=$(head -4 "$TMP/e.log" | tr '\n' ' ')"
    # empty array must stay OK (control)
    cat >"$TMP/t_empty.x" <<'EOF'
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
EOF
    set +e
    "$XLANG" -c -o "$TMP/te.o" "$TMP/t_empty.x" >"$TMP/te.log" 2>&1
    terc=$?
    set -e
    [ "$terc" -eq 0 ] || die "empty-array control must stay OK; log=$(head -4 "$TMP/te.log" | tr '\n' ' ')"
    echo "${PREFIX} status=ok residual_p012=locked empty_ok=1 host=windows"
    ;;
  *)
    echo "${PREFIX} status=ok static_only host=${uname_s} (Win PE residual probe skipped)"
    ;;
esac

echo "win-tip-l2-p012-fmt-local-scope gate OK"
exit 0
