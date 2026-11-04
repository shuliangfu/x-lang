#!/usr/bin/env bash
# Knife 11.76: Win tip L2 binop sub codegen SEGV — DIG residual HOLD gate.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PREFIX="xlang: [WIN_TIP_L2_BINOP_SUB_CODEGEN_SEGV]"

die() { echo "${PREFIX} FAIL: $*" >&2; exit 1; }

DOC=analysis/xlang-win-tip-l2-binop-sub-codegen-segv.md
PRIOR=analysis/xlang-win-tip-l2-import-module-enum-dot-t001.md
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$PRIOR" ] || die "missing 11.75 DIG $PRIOR"
grep -qE 'binop|append_bytes|0 - x|Residual HOLD|DIG' "$DOC" || die "diagnose missing binop/DIG"
grep -qE 'CLOSE ACCEPT|正式 CLOSE ACCEPT|ACCEPT-ready' "$PRIOR" || die "11.75 DIG must be ACCEPT/CLOSE ACCEPT"
grep -qE 'Residual HOLD|无 tip PE|无 PE 修|无本刀 PE' "$DOC" || die "diagnose missing Residual HOLD"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    if [ -x ./compiler/xlang_asm.exe ]; then XLANG=./compiler/xlang_asm.exe
    elif [ -x ./compiler/xlang.exe ]; then XLANG=./compiler/xlang.exe
    else die "missing tip PE"; fi
    TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_win_binop_sub_$$}"
    mkdir -p "$TMP"

    # unary -x must stay green (control)
    cat >"$TMP/unary.x" <<'EOFX'
export function f(x: i32): i32 { return -x; }
EOFX
    set +e
    "$XLANG" check "$TMP/unary.x" >"$TMP/unary_chk.log" 2>&1
    u_chk=$?
    "$XLANG" -c -o "$TMP/unary.o" "$TMP/unary.x" >"$TMP/unary_c.log" 2>&1
    u_c=$?
    set -e
    [ "$u_chk" -eq 0 ] || die "unary -x check regress u_chk=$u_chk"
    [ "$u_c" -eq 0 ] || die "unary -x -c regress u_c=$u_c (expected green control)"

    # binop 0 - x: residual locked as SEGV (or hard fail) on -c
    cat >"$TMP/binop.x" <<'EOFX'
export function f(x: i32): i32 { return 0 - x; }
EOFX
    set +e
    "$XLANG" check "$TMP/binop.x" >"$TMP/binop_chk.log" 2>&1
    b_chk=$?
    "$XLANG" -c -o "$TMP/binop.o" "$TMP/binop.x" >"$TMP/binop_c.log" 2>&1
    b_c=$?
    set -e
    [ "$b_chk" -eq 0 ] || die "binop check regress b_chk=$b_chk"
    if [ "$b_c" -eq 0 ]; then
      # residual cleared — HOLD 位可随绿改；仍保 hello
      set +e
      "$XLANG" check examples/hello.x >"$TMP/hello.log" 2>&1
      hello_ec=$?
      "$XLANG" -o "$TMP/hello.exe" examples/hello.x >"$TMP/hello_bld.log" 2>&1
      hello_b=$?
      set -e
      [ "$hello_ec" -eq 0 ] || die "hello check regress"
      [ "$hello_b" -eq 0 ] || die "hello -o regress"
      echo "${PREFIX} OK: binop sub -c green (residual cleared); unary+hello OK"
      exit 0
    fi
    # expect SEGV 139/11 or other non-zero without silent green
    if [ "$b_c" -ne 139 ] && [ "$b_c" -ne 11 ] && [ "$b_c" -ne 1 ]; then
      die "binop -c unexpected ec=$b_c (lock SEGV139/11 or codegen fail); see $TMP/binop_c.log"
    fi

    # hello protect (11.73 check + post-11.75 -o green)
    set +e
    "$XLANG" check examples/hello.x >"$TMP/hello.log" 2>&1
    hello_ec=$?
    "$XLANG" -o "$TMP/hello.exe" examples/hello.x >"$TMP/hello_bld.log" 2>&1
    hello_b=$?
    set -e
    [ "$hello_ec" -eq 0 ] || die "hello check regress hello_ec=$hello_ec"
    [ "$hello_b" -eq 0 ] || die "hello -o regress hello_b=$hello_b"

    echo "${PREFIX} HOLD: binop '-' codegen SEGV (append_bytes); unary -x green; no tip PE plant; Soft Cap Prefer same class"
    exit 2
    ;;
  *)
    echo "${PREFIX} SKIP: non-Windows host ($uname_s); DIG docs present"
    exit 0
    ;;
esac
