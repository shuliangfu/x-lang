#!/usr/bin/env bash
# Knife 11.60: Win tip L2 hello XP008 parse skip gate.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PREFIX="xlang: [WIN_TIP_L2_HELLO_XP008_PARSE_SKIP]"

die() { echo "${PREFIX} FAIL: $*" >&2; exit 1; }

DOC=analysis/xlang-win-tip-l2-hello-xp008-parse-skip.md
PRIOR=analysis/xlang-win-tip-l2-named-type-x-live-missing.md
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$PRIOR" ] || die "missing 11.59 DIG $PRIOR"
grep -qE 'XP008|parse skip|hello' "$DOC" || die "diagnose missing XP008/hello"
grep -q 'CLOSE ACCEPT' "$PRIOR" || die "11.59 DIG must be CLOSE ACCEPT"
grep -qE 'Residual|DIG|修靶' "$DOC" || die "diagnose missing DIG/Residual"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    if [ -x ./compiler/xlang_asm.exe ]; then XLANG=./compiler/xlang_asm.exe
    elif [ -x ./compiler/xlang.exe ]; then XLANG=./compiler/xlang.exe
    else die "missing tip PE"; fi
    TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_win_hello_xp008_$$}"
    mkdir -p "$TMP"
    cat >"$TMP/IF_min.x" <<'EOFX'
export function main(): i32 {
  if (true) { return 1; }
  return 0;
}
EOFX
    cat >"$TMP/param_ctx.x" <<'EOFX'
export struct Context { handle: i64; }
export function a(ctx: Context): i32 {
  let _rc: i32 = 0;
  return _rc;
}
EOFX
    set +e
    "$XLANG" -c -o "$TMP/i.o" "$TMP/IF_min.x" >"$TMP/i.log" 2>&1; irc=$?
    "$XLANG" -c -o "$TMP/p.o" "$TMP/param_ctx.x" >"$TMP/p.log" 2>&1; prc=$?
    "$XLANG" -c -o "$TMP/h.o" examples/hello.x >"$TMP/h.log" 2>&1; hrc=$?
    set -e
    [ "$irc" -eq 0 ] && [ -s "$TMP/i.o" ] || die "11.56 IF_min regress"
    [ "$prc" -eq 0 ] && [ -s "$TMP/p.o" ] || die "11.59 param_ctx regress"
    if [ "$hrc" -ne 0 ] || [ ! -s "$TMP/h.o" ]; then
      echo "${PREFIX} HOLD: hello still fail hrc=$hrc; log=$(head -2 "$TMP/h.log" | tr '\n' ' ')"
      exit 2
    fi
    echo "${PREFIX} OK: hello -c nonempty; IF/param_ctx OK"
    ;;
  *)
    echo "${PREFIX} SKIP: non-Windows host (docs-only check passed)"
    ;;
esac
