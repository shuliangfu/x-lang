#!/usr/bin/env bash
# Knife 11.58: Win tip L2 user-struct param soft-fail → P012 gate.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PREFIX="xlang: [WIN_TIP_L2_USER_STRUCT_PARAM_SOFTFAIL]"

die() { echo "${PREFIX} FAIL: $*" >&2; exit 1; }

DOC=analysis/xlang-win-tip-l2-user-struct-param-softfail.md
PRIOR=analysis/xlang-win-tip-l2-hello-p012-after-if.md
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$PRIOR" ] || die "missing 11.57 DIG $PRIOR"
grep -qE 'param_ctx|Context|soft-fail|P012' "$DOC" || die "diagnose missing param/Context/P012"
grep -q 'CLOSE residual HOLD' "$PRIOR" || die "11.57 DIG must be CLOSE residual HOLD"
grep -qE 'Residual|DIG|修靶' "$DOC" || die "diagnose missing DIG/Residual"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    if [ -x ./compiler/xlang_asm.exe ]; then XLANG=./compiler/xlang_asm.exe
    elif [ -x ./compiler/xlang.exe ]; then XLANG=./compiler/xlang.exe
    else die "missing tip PE"; fi
    TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_win_struct_param_$$}"
    mkdir -p "$TMP"
    cat >"$TMP/IF_min.x" <<'EOFX'
export function main(): i32 {
  if (true) { return 1; }
  return 0;
}
EOFX
    cat >"$TMP/match10.x" <<'EOFX'
export function f1(): i32 {
  let digits: u8[10] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57];
  let num_digits: i32 = 0;
  return num_digits;
}
EOFX
    cat >"$TMP/param_ctx.x" <<'EOFX'
export struct Context { handle: i64; }
export function a(ctx: Context): i32 {
  let _rc: i32 = 0;
  return _rc;
}
export function b(ctx: Context): i64 {
  let _rc: i64 = 0;
  return _rc;
}
EOFX
    set +e
    "$XLANG" check "$TMP/IF_min.x" >"$TMP/ic.log" 2>&1; icrc=$?
    "$XLANG" -c -o "$TMP/i.o" "$TMP/IF_min.x" >"$TMP/i.log" 2>&1; irc=$?
    "$XLANG" -c -o "$TMP/m.o" "$TMP/match10.x" >"$TMP/m.log" 2>&1; mrc=$?
    "$XLANG" -c -o "$TMP/p.o" "$TMP/param_ctx.x" >"$TMP/p.log" 2>&1; prc=$?
    set -e
    [ "$icrc" -eq 0 ] && [ "$irc" -eq 0 ] || die "11.56 IF_min regress"
    [ "$mrc" -eq 0 ] || die "match10 regress"
    isz=$(wc -c <"$TMP/i.o" | tr -d ' ')
    [ "$isz" -gt 0 ] || die "IF_min empty .o fake-green"
    if [ "$prc" -ne 0 ] || [ ! -s "$TMP/p.o" ]; then
      echo "${PREFIX} HOLD: param_ctx still fail prc=$prc osz=$(wc -c <"$TMP/p.o" 2>/dev/null | tr -d ' ' || echo 0); log=$(head -2 "$TMP/p.log" | tr '\n' ' ')"
      exit 2
    fi
    echo "${PREFIX} OK: param_ctx -c nonempty; IF/match10 OK"
    ;;
  *)
    echo "${PREFIX} SKIP: non-Windows host (docs-only check passed)"
    ;;
esac
