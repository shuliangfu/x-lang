#!/usr/bin/env bash
# Knife 11.61: Win tip L2 hello XP008 array let type gate.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PREFIX="xlang: [WIN_TIP_L2_HELLO_XP008_ARRAY_LET_TYPE]"

die() { echo "${PREFIX} FAIL: $*" >&2; exit 1; }

DOC=analysis/xlang-win-tip-l2-hello-xp008-array-let-type.md
PRIOR=analysis/xlang-win-tip-l2-hello-xp008-parse-skip.md
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$PRIOR" ] || die "missing 11.60 DIG $PRIOR"
grep -qE 'array|let|XP008|1048' "$DOC" || die "diagnose missing array/let"
grep -q 'CLOSE ACCEPT' "$PRIOR" || die "11.60 DIG must be CLOSE ACCEPT"
grep -qE 'Residual|DIG|修靶' "$DOC" || die "diagnose missing DIG/Residual"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    if [ -x ./compiler/xlang_asm.exe ]; then XLANG=./compiler/xlang_asm.exe
    elif [ -x ./compiler/xlang.exe ]; then XLANG=./compiler/xlang.exe
    else die "missing tip PE"; fi
    TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_win_hello_arr_let_$$}"
    mkdir -p "$TMP"
    cat >"$TMP/allow1.x" <<'EOFX'
allow(padding) struct IoBatchBuf { ptr: *u8; length: usize; handle: usize; }
EOFX
    cat >"$TMP/let_i32.x" <<'EOFX'
let x: i32 = 0;
EOFX
    cat >"$TMP/let_arr.x" <<'EOFX'
let x: [4]i32 = [0, 0, 0, 0];
EOFX
    cat >"$TMP/param_ctx.x" <<'EOFX'
export struct Context { handle: i64; }
export function a(ctx: Context): i32 {
  let _rc: i32 = 0;
  return _rc;
}
EOFX
    set +e
    "$XLANG" check "$TMP/allow1.x" >"$TMP/a.log" 2>&1; arc=$?
    "$XLANG" check "$TMP/let_i32.x" >"$TMP/l.log" 2>&1; lrc=$?
    "$XLANG" -c -o "$TMP/p.o" "$TMP/param_ctx.x" >"$TMP/p.log" 2>&1; prc=$?
    "$XLANG" check "$TMP/let_arr.x" >"$TMP/arr.log" 2>&1; arrc=$?
    set -e
    [ "$arc" -eq 0 ] || die "11.60 allow1 regress"
    [ "$lrc" -eq 0 ] || die "scalar let regress"
    [ "$prc" -eq 0 ] && [ -s "$TMP/p.o" ] || die "11.59 param_ctx regress"
    if [ "$arrc" -ne 0 ]; then
      echo "${PREFIX} HOLD: array let still fail arrc=$arrc; log=$(head -2 "$TMP/arr.log" | tr '\n' ' ')"
      exit 2
    fi
    echo "${PREFIX} OK: array let + allow1 + param_ctx"
    ;;
  *)
    echo "${PREFIX} SKIP: non-Windows host (docs-only check passed)"
    ;;
esac
