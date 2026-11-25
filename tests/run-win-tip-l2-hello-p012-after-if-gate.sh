#!/usr/bin/env bash
# Knife 11.57: Win tip L2 hello/fmt P012 after IF unlock gate.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PREFIX="xlang: [WIN_TIP_L2_HELLO_P012_AFTER_IF]"

die() { echo "${PREFIX} FAIL: $*" >&2; exit 1; }

DOC=analysis/xlang-win-tip-l2-hello-p012-after-if.md
PRIOR=analysis/xlang-win-tip-l2-if-then-block-xt001.md
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$PRIOR" ] || die "missing 11.56 DIG $PRIOR"
grep -qE 'P012|hello|fmt' "$DOC" || die "diagnose missing P012/hello"
grep -q 'CLOSE ACCEPT' "$PRIOR" || die "11.56 DIG must be CLOSE ACCEPT"
grep -qE 'Residual|DIG|修靶' "$DOC" || die "diagnose missing DIG/Residual"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    if [ -x ./compiler/xlang_asm.exe ]; then XLANG=./compiler/xlang_asm.exe
    elif [ -x ./compiler/xlang.exe ]; then XLANG=./compiler/xlang.exe
    else die "missing tip PE"; fi
    TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_win_hello_p012_$$}"
    mkdir -p "$TMP"
    cat >"$TMP/IF_min.x" <<'EOFX'
export function main(): i32 {
  if (true) { return 1; }
  return 0;
}
EOFX
    cat >"$TMP/WH0.x" <<'EOFX'
export function main(): i32 {
  while (false) { }
  return 1;
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
    "$XLANG" check "$TMP/IF_min.x" >"$TMP/ic.log" 2>&1; icrc=$?
    "$XLANG" -c -o "$TMP/i.o" "$TMP/IF_min.x" >"$TMP/i.log" 2>&1; irc=$?
    "$XLANG" check "$TMP/WH0.x" >"$TMP/wc.log" 2>&1; wcrc=$?
    "$XLANG" -c -o "$TMP/m.o" "$TMP/match10.x" >"$TMP/m.log" 2>&1; mrc=$?
    HELLO=examples/hello.x
    "$XLANG" check "$HELLO" >"$TMP/h.log" 2>&1; hrc=$?
    set -e
    [ "$icrc" -eq 0 ] && [ "$irc" -eq 0 ] || die "11.56 IF_min regress"
    [ "$wcrc" -eq 0 ] || die "WH regress"
    [ "$mrc" -eq 0 ] || die "match10 regress"
    if [ "$hrc" -ne 0 ]; then
      echo "${PREFIX} HOLD: hello still fail hrc=$hrc; log=$(head -3 "$TMP/h.log" | tr '\n' ' ')"
      exit 2
    fi
    echo "${PREFIX} OK: hello check unlocked; IF/WH/match10 OK"
    ;;
  *)
    echo "${PREFIX} SKIP: non-Windows host (docs-only check passed)"
    ;;
esac
