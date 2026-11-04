#!/usr/bin/env bash
# Knife 11.51: Win tip L2 IF vs WHILE block path gate.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PREFIX="xlang: [WIN_TIP_L2_IF_VS_WHILE_BLOCK_PATH]"

die() { echo "${PREFIX} FAIL: $*" >&2; exit 1; }

DOC=analysis/xlang-win-tip-l2-if-vs-while-block-path.md
PRIOR=analysis/xlang-win-tip-l2-if-x-fail-leave-brace.md
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$PRIOR" ] || die "missing 11.50 DIG $PRIOR"
grep -qE 'parse_block_ptr|into_slice|type_ref|WHILE|while' "$DOC" || die "diagnose missing IF/WHILE block path"
grep -q 'CLOSE residual HOLD' "$PRIOR" || die "11.50 DIG must be CLOSE residual HOLD"
grep -qE 'Residual|DIG|修靶' "$DOC" || die "diagnose missing DIG/Residual"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    if [ -x ./compiler/xlang_asm.exe ]; then XLANG=./compiler/xlang_asm.exe
    elif [ -x ./compiler/xlang.exe ]; then XLANG=./compiler/xlang.exe
    else die "missing tip PE"; fi
    TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_win_if_while_$$}"
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
    set +e
    "$XLANG" -c -o "$TMP/m.o" "$TMP/match10.x" >"$TMP/m.log" 2>&1; mrc=$?
    "$XLANG" -c -o "$TMP/w.o" "$TMP/WH0.x" >"$TMP/w.log" 2>&1; wrc=$?
    "$XLANG" -c -o "$TMP/i.o" "$TMP/IF_min.x" >"$TMP/i.log" 2>&1; irc=$?
    if [ -f examples/hello.x ]; then
      "$XLANG" -c -o "$TMP/hello.o" examples/hello.x >"$TMP/hello.log" 2>&1; hrc=$?
    else
      hrc=1
      echo "missing examples/hello.x" >"$TMP/hello.log"
    fi
    set -e
    [ "$mrc" -eq 0 ] || die "match10 must stay OK (11.48); log=$(head -3 "$TMP/m.log" | tr '\n' ' ')"
    [ "$wrc" -eq 0 ] || die "WH0 while must stay OK; log=$(head -3 "$TMP/w.log" | tr '\n' ' ')"
    if [ "$irc" -ne 0 ]; then
      grep -qE 'CG002|code_len=0|P012' "$TMP/i.log" || die "IF_min fail without CG002/P012; log=$(head -4 "$TMP/i.log" | tr '\n' ' ')"
    fi
    if [ "$hrc" -ne 0 ]; then
      grep -q 'P012' "$TMP/hello.log" || die "hello fail without P012; log=$(head -4 "$TMP/hello.log" | tr '\n' ' ')"
    fi
    echo "${PREFIX} status=ok match10_ok=1 while_ok=1 if_hello_locked=1 host=windows"
    ;;
  *)
    echo "${PREFIX} status=ok static_only host=${uname_s} (Win PE probe skipped)"
    ;;
esac
echo "win-tip-l2-if-vs-while-block-path gate OK"
exit 0
