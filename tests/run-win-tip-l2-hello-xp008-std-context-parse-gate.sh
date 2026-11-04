#!/usr/bin/env bash
# Knife 11.64: Win tip L2 hello XP008 std.context parse gate.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PREFIX="xlang: [WIN_TIP_L2_HELLO_XP008_STD_CONTEXT_PARSE]"

die() { echo "${PREFIX} FAIL: $*" >&2; exit 1; }

DOC=analysis/xlang-win-tip-l2-hello-xp008-std-context-parse.md
PRIOR=analysis/xlang-win-tip-l2-hello-xp008-slice-generic-return.md
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$PRIOR" ] || die "missing 11.63 DIG $PRIOR"
grep -qE 'std\.context|background|1973|2059|context' "$DOC" || die "diagnose missing context locus"
grep -q 'CLOSE ACCEPT' "$PRIOR" || die "11.63 DIG must be CLOSE ACCEPT"
grep -qE 'Residual|DIG|修靶' "$DOC" || die "diagnose missing DIG/Residual"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    if [ -x ./compiler/xlang_asm.exe ]; then XLANG=./compiler/xlang_asm.exe
    elif [ -x ./compiler/xlang.exe ]; then XLANG=./compiler/xlang.exe
    else die "missing tip PE"; fi
    TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_win_hello_ctx_parse_$$}"
    mkdir -p "$TMP"
    cat >"$TMP/slice_ret.x" <<'EOFX'
type io_read_ptr = *u8;
export function io_read_ptr_slice(handle: usize, timeout_ms: u32): u8[]<io_read_ptr> {
  let out: u8[]<io_read_ptr>;
  return out;
}
EOFX
    cat >"$TMP/ptr_param.x" <<'EOFX'
allow(padding) struct IoBatchBuf { ptr: *u8; length: usize; handle: usize; }
export function f(bufs: *IoBatchBuf): i32 { return 0; }
EOFX
    set +e
    "$XLANG" check "$TMP/slice_ret.x" >"$TMP/s.log" 2>&1; src=$?
    "$XLANG" check "$TMP/ptr_param.x" >"$TMP/p.log" 2>&1; prc=$?
    "$XLANG" check std/context/context.x >"$TMP/c.log" 2>&1; crc=$?
    set -e
    [ "$src" -eq 0 ] || die "11.63 slice_ret regress"
    [ "$prc" -eq 0 ] || die "11.62 *IoBatchBuf param regress"
    if [ "$crc" -ne 0 ]; then
      echo "${PREFIX} HOLD: std.context still fail crc=$crc; log=$(head -2 "$TMP/c.log" | tr '\n' ' ')"
      exit 2
    fi
    echo "${PREFIX} OK: std.context + slice return + ptr param"
    ;;
  *)
    echo "${PREFIX} SKIP: non-Windows host (docs-only check passed)"
    ;;
esac
