#!/usr/bin/env bash
# Knife 11.70: Win tip L2 hello XP008 named name_into empty gate.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PREFIX="xlang: [WIN_TIP_L2_HELLO_XP008_NAMED_NAME_INTO_EMPTY]"

die() { echo "${PREFIX} FAIL: $*" >&2; exit 1; }

DOC=analysis/xlang-win-tip-l2-hello-xp008-named-name-into-empty.md
PRIOR=analysis/xlang-win-tip-l2-hello-xp008-typeck-named-eq.md
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$PRIOR" ] || die "missing 11.69 DIG $PRIOR"
grep -qE 'name_into|0x84|empty|NAMED|name_len' "$DOC" || die "diagnose missing name_into empty locus"
grep -q 'CLOSE residual HOLD' "$PRIOR" || die "11.69 DIG must be CLOSE residual HOLD"
grep -q 'CLOSE residual HOLD' "$DOC" || die "11.70 DIG must be CLOSE residual HOLD"
grep -qE 'Residual|DIG|修靶|init_named' "$DOC" || die "diagnose missing DIG/Residual"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    if [ -x ./compiler/xlang_asm.exe ]; then XLANG=./compiler/xlang_asm.exe
    elif [ -x ./compiler/xlang.exe ]; then XLANG=./compiler/xlang.exe
    else die "missing tip PE"; fi
    TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_win_hello_name_into_$$}"
    mkdir -p "$TMP"
    cat >"$TMP/nested.x" <<'EOFX'
allow(padding) struct Slot { a: i32; }
allow(padding) struct S { s: Slot; }
export function f(): i32 { return 0; }
EOFX
    cat >"$TMP/ptr_param.x" <<'EOFX'
allow(padding) struct IoBatchBuf { ptr: *u8; length: usize; handle: usize; }
export function f(bufs: *IoBatchBuf): i32 { return 0; }
EOFX
    cat >"$TMP/a_val.x" <<'EOFX'
struct A { a: i32; }
export function id(x: A): A { return x; }
EOFX
    cat >"$TMP/a_ptr.x" <<'EOFX'
struct A { a: i32; }
export function id(p: *A): *A { return p; }
EOFX
    set +e
    "$XLANG" check "$TMP/nested.x" >"$TMP/n.log" 2>&1; nrc=$?
    "$XLANG" check "$TMP/ptr_param.x" >"$TMP/p.log" 2>&1; prc=$?
    "$XLANG" check "$TMP/a_val.x" >"$TMP/v.log" 2>&1; vrc=$?
    "$XLANG" check "$TMP/a_ptr.x" >"$TMP/r.log" 2>&1; rrc=$?
    "$XLANG" check std/context/context.x >"$TMP/c.log" 2>&1; crc=$?
    set -e
    [ "$nrc" -eq 0 ] || die "11.67 nested regress"
    [ "$prc" -eq 0 ] || die "11.62 *IoBatchBuf param regress"
    if [ "$vrc" -ne 0 ] || [ "$rrc" -ne 0 ] || [ "$crc" -ne 0 ]; then
      echo "${PREFIX} HOLD: name_into empty still fail vrc=$vrc rrc=$rrc crc=$crc"
      exit 2
    fi
    echo "${PREFIX} OK: A_val + *A return + context + nested + ptr param"
    ;;
  *)
    echo "${PREFIX} SKIP: non-Windows host (docs-only check passed)"
    ;;
esac
