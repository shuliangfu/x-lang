#!/usr/bin/env bash
# Knife 11.56: Win tip L2 IF then-block XT001 gate.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PREFIX="xlang: [WIN_TIP_L2_IF_THEN_BLOCK_XT001]"

die() { echo "${PREFIX} FAIL: $*" >&2; exit 1; }

DOC=analysis/xlang-win-tip-l2-if-then-block-xt001.md
PRIOR=analysis/xlang-win-tip-l2-primary-x-stale-trampoline.md
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$PRIOR" ] || die "missing 11.55 DIG $PRIOR"
grep -qE 'XT001|then-block|IF_min' "$DOC" || die "diagnose missing IF/XT001/then"
grep -q 'CLOSE residual HOLD' "$PRIOR" || die "11.55 DIG must be CLOSE residual HOLD"
grep -qE 'Residual|DIG|修靶' "$DOC" || die "diagnose missing DIG/Residual"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    if [ -x ./compiler/xlang_asm.exe ]; then XLANG=./compiler/xlang_asm.exe
    elif [ -x ./compiler/xlang.exe ]; then XLANG=./compiler/xlang.exe
    else die "missing tip PE"; fi
    TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_win_if_then_$$}"
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
    "$XLANG" check "$TMP/WH0.x" >"$TMP/wc.log" 2>&1; wcrc=$?
    "$XLANG" check "$TMP/paren1.x" >"$TMP/pc.log" 2>&1; pcrc=$?
    "$XLANG" check "$TMP/ident_x.x" >"$TMP/xc.log" 2>&1; xcrc=$?
    "$XLANG" check "$TMP/NOIF.x" >"$TMP/nc.log" 2>&1; ncrc=$?
    "$XLANG" check "$TMP/IF_min.x" >"$TMP/ic.log" 2>&1; icrc=$?
    "$XLANG" -c -o "$TMP/i.o" "$TMP/IF_min.x" >"$TMP/i.log" 2>&1; irc=$?
    set -e
    [ "$mrc" -eq 0 ] || die "match10 must stay OK; log=$(head -3 "$TMP/m.log" | tr '\n' ' ')"
    [ "$wcrc" -eq 0 ] || die "11.55 WH check regress; log=$(head -3 "$TMP/wc.log" | tr '\n' ' ')"
    [ "$pcrc" -eq 0 ] || die "11.55 paren check regress; log=$(head -3 "$TMP/pc.log" | tr '\n' ' ')"
    [ "$xcrc" -eq 0 ] || die "11.55 ident check regress; log=$(head -3 "$TMP/xc.log" | tr '\n' ' ')"
    [ "$ncrc" -eq 0 ] || die "check NOIF must stay OK; log=$(head -3 "$TMP/nc.log" | tr '\n' ' ')"
    if [ "$icrc" -ne 0 ] || [ "$irc" -ne 0 ]; then
      echo "${PREFIX} HOLD: IF_min still fail icrc=$icrc irc=$irc; log=$(head -3 "$TMP/ic.log" | tr '\n' ' ')"
      exit 2
    fi
    echo "${PREFIX} OK: IF_min check+-c unlocked; WH/paren/ident/match10/NOIF OK"
    ;;
  *)
    echo "${PREFIX} SKIP runtime (host=$uname_s); plant+prior CLOSE checked"
    ;;
esac
exit 0
