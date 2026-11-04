#!/usr/bin/env bash
# Knife 11.62: Win tip L2 hello XP008 user-struct ptr param gate.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PREFIX="xlang: [WIN_TIP_L2_HELLO_XP008_USER_STRUCT_PTR_PARAM]"

die() { echo "${PREFIX} FAIL: $*" >&2; exit 1; }

DOC=analysis/xlang-win-tip-l2-hello-xp008-user-struct-ptr-param.md
PRIOR=analysis/xlang-win-tip-l2-hello-xp008-array-let-type.md
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$PRIOR" ] || die "missing 11.61 DIG $PRIOR"
grep -qE 'IoBatchBuf|ptr|指针|\*UserStruct|user-struct' "$DOC" || die "diagnose missing ptr-param"
grep -q 'CLOSE ACCEPT' "$PRIOR" || die "11.61 DIG must be CLOSE ACCEPT"
grep -qE 'Residual|DIG|修靶' "$DOC" || die "diagnose missing DIG/Residual"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    if [ -x ./compiler/xlang_asm.exe ]; then XLANG=./compiler/xlang_asm.exe
    elif [ -x ./compiler/xlang.exe ]; then XLANG=./compiler/xlang.exe
    else die "missing tip PE"; fi
    TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_win_hello_ptr_param_$$}"
    mkdir -p "$TMP"
    cat >"$TMP/allow1.x" <<'EOFX'
allow(padding) struct IoBatchBuf { ptr: *u8; length: usize; handle: usize; }
EOFX
    cat >"$TMP/let_arr.x" <<'EOFX'
let x: [4]i32 = [0, 0, 0, 0];
EOFX
    cat >"$TMP/val_param.x" <<'EOFX'
allow(padding) struct IoBatchBuf { ptr: *u8; length: usize; handle: usize; }
export function f(b: IoBatchBuf): i32 { return 0; }
EOFX
    cat >"$TMP/ptr_param.x" <<'EOFX'
allow(padding) struct IoBatchBuf { ptr: *u8; length: usize; handle: usize; }
export function f(bufs: *IoBatchBuf): i32 { return 0; }
EOFX
    set +e
    "$XLANG" check "$TMP/allow1.x" >"$TMP/a.log" 2>&1; arc=$?
    "$XLANG" check "$TMP/let_arr.x" >"$TMP/arr.log" 2>&1; arrc=$?
    "$XLANG" check "$TMP/val_param.x" >"$TMP/v.log" 2>&1; vrc=$?
    "$XLANG" check "$TMP/ptr_param.x" >"$TMP/p.log" 2>&1; prc=$?
    set -e
    [ "$arc" -eq 0 ] || die "11.60 allow1 regress"
    [ "$arrc" -eq 0 ] || die "11.61 array let regress"
    [ "$vrc" -eq 0 ] || die "value IoBatchBuf param regress"
    if [ "$prc" -ne 0 ]; then
      echo "${PREFIX} HOLD: *IoBatchBuf param still fail prc=$prc; log=$(head -2 "$TMP/p.log" | tr '\n' ' ')"
      exit 2
    fi
    echo "${PREFIX} OK: *IoBatchBuf param + array let + allow1"
    ;;
  *)
    echo "${PREFIX} SKIP: non-Windows host (docs-only check passed)"
    ;;
esac
