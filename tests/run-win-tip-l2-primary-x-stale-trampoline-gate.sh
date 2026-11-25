#!/usr/bin/env bash
# Knife 11.55: Win tip L2 primary_x stale→live trampoline gate.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PREFIX="xlang: [WIN_TIP_L2_PRIMARY_X_STALE_TRAMPOLINE]"

die() { echo "${PREFIX} FAIL: $*" >&2; exit 1; }

DOC=analysis/xlang-win-tip-l2-primary-x-stale-trampoline.md
PRIOR=analysis/xlang-win-tip-l2-check-strict-wh-if-p001.md
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$PRIOR" ] || die "missing 11.54 DIG $PRIOR"
grep -qE 'stale|trampoline|primary_x|parse_primary' "$DOC" || die "diagnose missing primary/stale/trampoline"
grep -q 'CLOSE residual HOLD' "$PRIOR" || die "11.54 DIG must be CLOSE residual HOLD"
grep -qE 'Residual|DIG|修靶' "$DOC" || die "diagnose missing DIG/Residual"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    if [ -x ./compiler/xlang_asm.exe ]; then XLANG=./compiler/xlang_asm.exe
    elif [ -x ./compiler/xlang.exe ]; then XLANG=./compiler/xlang.exe
    else die "missing tip PE"; fi
    TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_win_prim_tramp_$$}"
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
    cat >"$TMP/paren1.x" <<'EOFX'
export function main(): i32 {
  return (1);
}
EOFX
    cat >"$TMP/ident_x.x" <<'EOFX'
export function main(): i32 {
  let x: i32 = 1;
  return x;
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
    "$XLANG" check "$TMP/NOIF.x" >"$TMP/nc.log" 2>&1; ncrc=$?
    "$XLANG" check "$TMP/WH0.x" >"$TMP/wc.log" 2>&1; wcrc=$?
    "$XLANG" check "$TMP/IF_min.x" >"$TMP/ic.log" 2>&1; icrc=$?
    "$XLANG" check "$TMP/paren1.x" >"$TMP/pc.log" 2>&1; pcrc=$?
    "$XLANG" check "$TMP/ident_x.x" >"$TMP/xc.log" 2>&1; xcrc=$?
    "$XLANG" -c -o "$TMP/i.o" "$TMP/IF_min.x" >"$TMP/i.log" 2>&1; irc=$?
    set -e
    [ "$mrc" -eq 0 ] || die "match10 must stay OK; log=$(head -3 "$TMP/m.log" | tr '\n' ' ')"
    [ "$wrc" -eq 0 ] || die "WH0 -c must stay OK; log=$(head -3 "$TMP/w.log" | tr '\n' ' ')"
    [ "$ncrc" -eq 0 ] || die "check NOIF must stay OK; log=$(head -3 "$TMP/nc.log" | tr '\n' ' ')"
    # Unlock targets (HOLD until tip-local primary bind lands)
    if [ "$wcrc" -ne 0 ] || [ "$icrc" -ne 0 ] || [ "$pcrc" -ne 0 ] || [ "$xcrc" -ne 0 ]; then
      echo "${PREFIX} HOLD: check WH/IF/paren/ident still fail (expected until tip-local primary_x live); wcrc=$wcrc icrc=$icrc pcrc=$pcrc xcrc=$xcrc"
      exit 2
    fi
    if [ "$irc" -ne 0 ]; then
      echo "${PREFIX} HOLD: IF_min -c still fail irc=$irc; log=$(head -3 "$TMP/i.log" | tr '\n' ' ')"
      exit 2
    fi
    echo "${PREFIX} OK: check WH/IF/paren/ident + IF -c unlocked; match10/NOIF OK"
    ;;
  *)
    echo "${PREFIX} SKIP runtime (host=$uname_s); plant+prior CLOSE checked"
    ;;
esac
exit 0
