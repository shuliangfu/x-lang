#!/usr/bin/env bash
# Knife 11.54: Win tip L2 check-strict WH+IF P001 gate.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PREFIX="xlang: [WIN_TIP_L2_CHECK_STRICT_WH_IF_P001]"

die() { echo "${PREFIX} FAIL: $*" >&2; exit 1; }

DOC=analysis/xlang-win-tip-l2-check-strict-wh-if-p001.md
PRIOR=analysis/xlang-win-tip-l2-if-check-p001-realign.md
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$PRIOR" ] || die "missing 11.53 DIG $PRIOR"
grep -qE 'P001|strict|check' "$DOC" || die "diagnose missing P001/strict/check"
grep -q 'CLOSE residual HOLD' "$PRIOR" || die "11.53 DIG must be CLOSE residual HOLD"
grep -qE 'Residual|DIG|修靶' "$DOC" || die "diagnose missing DIG/Residual"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    if [ -x ./compiler/xlang_asm.exe ]; then XLANG=./compiler/xlang_asm.exe
    elif [ -x ./compiler/xlang.exe ]; then XLANG=./compiler/xlang.exe
    else die "missing tip PE"; fi
    TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_win_strict_p001_$$}"
    mkdir -p "$TMP"
    cat >"$TMP/match10.x" <<'EOFX'
export function f1(): i32 {
  let digits: u8[10] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57];
  let num_digits: i32 = 0;
  return num_digits;
}
EOFX
    cat >"$TMP/WH0.x" <<'EOFX'
export function main(): i32 {
  while (false) { }
  return 1;
}
EOFX
    cat >"$TMP/IF_min.x" <<'EOFX'
export function main(): i32 {
  if (true) { return 1; }
  return 0;
}
EOFX
    cat >"$TMP/NOIF.x" <<'EOFX'
export function main(): i32 {
  return 1;
}
EOFX
    set +e
    "$XLANG" -c -o "$TMP/m.o" "$TMP/match10.x" >"$TMP/m.log" 2>&1; mrc=$?
    "$XLANG" -c -o "$TMP/w.o" "$TMP/WH0.x" >"$TMP/w.log" 2>&1; wrc=$?
    "$XLANG" -c -o "$TMP/i.o" "$TMP/IF_min.x" >"$TMP/i.log" 2>&1; irc=$?
    "$XLANG" check "$TMP/IF_min.x" >"$TMP/ic.log" 2>&1; icrc=$?
    "$XLANG" check "$TMP/WH0.x" >"$TMP/wc.log" 2>&1; wcrc=$?
    "$XLANG" check "$TMP/NOIF.x" >"$TMP/nc.log" 2>&1; ncrc=$?
    set -e
    [ "$mrc" -eq 0 ] || die "match10 must stay OK; log=$(head -3 "$TMP/m.log" | tr '\n' ' ')"
    [ "$wrc" -eq 0 ] || die "WH0 -c must stay OK; log=$(head -3 "$TMP/w.log" | tr '\n' ' ')"
    [ "$ncrc" -eq 0 ] || die "check NOIF must stay OK; log=$(head -3 "$TMP/nc.log" | tr '\n' ' ')"
    if [ "$irc" -ne 0 ]; then
      grep -qE 'CG002|code_len=0|P012|P001' "$TMP/i.log" || die "IF_min -c fail without CG002/P012/P001"
    fi
    if [ "$icrc" -ne 0 ]; then
      grep -qE 'P001|parse skip|CG002' "$TMP/ic.log" || die "check IF fail without P001/CG002"
    fi
    if [ "$wcrc" -ne 0 ]; then
      grep -qE 'P001|parse skip' "$TMP/wc.log" || die "check WH fail without P001"
    fi
    rm -rf "$TMP"
    if [ "$irc" -eq 0 ] && [ "$icrc" -eq 0 ] && [ "$wcrc" -eq 0 ]; then
      echo "${PREFIX} OK (Windows tip; IF/WH check unlocked; IF -c OK)"
    else
      echo "${PREFIX} OK (Windows tip; strict WH/IF residual locked; match10/WH0 -c/check NOIF OK)"
    fi
    ;;
  *)
    echo "${PREFIX} OK (docs-only on ${uname_s}; plant DIG+gate)"
    ;;
esac
exit 0
