#!/usr/bin/env bash
# Knife 11.72: Win tip L2 hello XP008 struct lit parse gate.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PREFIX="xlang: [WIN_TIP_L2_HELLO_XP008_STRUCT_LIT_PARSE]"

die() { echo "${PREFIX} FAIL: $*" >&2; exit 1; }

DOC=analysis/xlang-win-tip-l2-hello-xp008-struct-lit-parse.md
PRIOR=analysis/xlang-win-tip-l2-hello-xp008-named-init-named-miss.md
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$PRIOR" ] || die "missing 11.71 DIG $PRIOR"
grep -qE 'struct.?lit|\{ a:|handle:|parse skip|P001' "$DOC" || die "diagnose missing struct-lit locus"
grep -q 'CLOSE ACCEPT' "$PRIOR" || die "11.71 DIG must be CLOSE ACCEPT"
grep -qE 'Residual|DIG|修靶|struct' "$DOC" || die "diagnose missing DIG/Residual"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    if [ -x ./compiler/xlang_asm.exe ]; then XLANG=./compiler/xlang_asm.exe
    elif [ -x ./compiler/xlang.exe ]; then XLANG=./compiler/xlang.exe
    else die "missing tip PE"; fi
    TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_win_hello_struct_lit_$$}"
    mkdir -p "$TMP"
    cat >"$TMP/nested.x" <<'EOFX'
allow(padding) struct Slot { a: i32; }
allow(padding) struct S { s: Slot; }
export function f(): i32 { return 0; }
EOFX
    cat >"$TMP/a_val.x" <<'EOFX'
struct A { a: i32; }
export function id(x: A): A { return x; }
EOFX
    cat >"$TMP/field_assign.x" <<'EOFX'
struct A { a: i32; }
export function mk(): A { let _rc: A; _rc.a = 0; return _rc; }
EOFX
    cat >"$TMP/struct_lit.x" <<'EOFX'
struct A { a: i32; }
export function mk(): A { let _rc: A = { a: 0 }; return _rc; }
EOFX
    set +e
    "$XLANG" check "$TMP/nested.x" >"$TMP/n.log" 2>&1; nrc=$?
    "$XLANG" check "$TMP/a_val.x" >"$TMP/v.log" 2>&1; vrc=$?
    "$XLANG" check "$TMP/field_assign.x" >"$TMP/fa.log" 2>&1; farc=$?
    "$XLANG" check "$TMP/struct_lit.x" >"$TMP/sl.log" 2>&1; slrc=$?
    "$XLANG" check std/context/context.x >"$TMP/c.log" 2>&1; crc=$?
    set -e
    [ "$nrc" -eq 0 ] || die "11.67 nested regress"
    [ "$vrc" -eq 0 ] || die "11.71 A_val regress"
    [ "$farc" -eq 0 ] || die "field-assign path regress"
    [ "$crc" -eq 0 ] || die "context.x regress"
    if [ "$slrc" -ne 0 ]; then
      echo "${PREFIX} HOLD: struct lit still fail slrc=$slrc; $(head -2 "$TMP/sl.log" | tr '\n' ' ')"
      exit 2
    fi
    echo "${PREFIX} OK: struct lit + field-assign + A_val + nested + context.x"
    ;;
  *)
    echo "${PREFIX} SKIP: non-Windows host (docs-only check passed)"
    ;;
esac
