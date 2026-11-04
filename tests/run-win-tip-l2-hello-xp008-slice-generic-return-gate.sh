#!/usr/bin/env bash
# Knife 11.63: Win tip L2 hello XP008 slice generic return gate.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PREFIX="xlang: [WIN_TIP_L2_HELLO_XP008_SLICE_GENERIC_RETURN]"

die() { echo "${PREFIX} FAIL: $*" >&2; exit 1; }

DOC=analysis/xlang-win-tip-l2-hello-xp008-slice-generic-return.md
PRIOR=analysis/xlang-win-tip-l2-hello-xp008-user-struct-ptr-param.md
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$PRIOR" ] || die "missing 11.62 DIG $PRIOR"
grep -qE 'io_read_ptr_slice|u8\[\]|slice|generic|postfix' "$DOC" || die "diagnose missing slice-generic"
grep -q 'CLOSE ACCEPT' "$PRIOR" || die "11.62 DIG must be CLOSE ACCEPT"
grep -qE 'Residual|DIG|修靶' "$DOC" || die "diagnose missing DIG/Residual"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    if [ -x ./compiler/xlang_asm.exe ]; then XLANG=./compiler/xlang_asm.exe
    elif [ -x ./compiler/xlang.exe ]; then XLANG=./compiler/xlang.exe
    else die "missing tip PE"; fi
    TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_win_hello_slice_gen_$$}"
    mkdir -p "$TMP"
    cat >"$TMP/ptr_param.x" <<'EOFX'
allow(padding) struct IoBatchBuf { ptr: *u8; length: usize; handle: usize; }
export function f(bufs: *IoBatchBuf): i32 { return 0; }
EOFX
    cat >"$TMP/let_arr.x" <<'EOFX'
let x: [4]i32 = [0, 0, 0, 0];
EOFX
    cat >"$TMP/slice_ret.x" <<'EOFX'
type io_read_ptr = *u8;
export function io_read_ptr_slice(handle: usize, timeout_ms: u32): u8[]<io_read_ptr> {
  let out: u8[]<io_read_ptr>;
  return out;
}
EOFX
    set +e
    "$XLANG" check "$TMP/ptr_param.x" >"$TMP/p.log" 2>&1; prc=$?
    "$XLANG" check "$TMP/let_arr.x" >"$TMP/a.log" 2>&1; arc=$?
    "$XLANG" check "$TMP/slice_ret.x" >"$TMP/s.log" 2>&1; src=$?
    set -e
    [ "$prc" -eq 0 ] || die "11.62 *IoBatchBuf param regress"
    [ "$arc" -eq 0 ] || die "11.61 array let regress"
    if [ "$src" -ne 0 ]; then
      echo "${PREFIX} HOLD: u8[]<Named> return still fail src=$src; log=$(head -2 "$TMP/s.log" | tr '\n' ' ')"
      exit 2
    fi
    echo "${PREFIX} OK: slice generic return + ptr param + array let"
    ;;
  *)
    echo "${PREFIX} SKIP: non-Windows host (docs-only check passed)"
    ;;
esac
