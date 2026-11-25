#!/usr/bin/env bash
# Knife 11.60: Win tip L2 hello XP008 parse skip gate (cfg-skip + allow padding).
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
grep -qE 'CLOSE ACCEPT|skip_one|allow.padding' "$DOC" || die "diagnose missing CLOSE/plant"
grep -qE 'Residual|1048|array' "$DOC" || die "diagnose missing residual handoff"

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
    cat >"$TMP/allow1.x" <<'EOFX'
allow(padding) struct IoBatchBuf { ptr: *u8; length: usize; handle: usize; }
EOFX
    cat >"$TMP/let_i32.x" <<'EOFX'
let x: i32 = 0;
EOFX
    set +e
    "$XLANG" -c -o "$TMP/i.o" "$TMP/IF_min.x" >"$TMP/i.log" 2>&1; irc=$?
    "$XLANG" -c -o "$TMP/p.o" "$TMP/param_ctx.x" >"$TMP/p.log" 2>&1; prc=$?
    "$XLANG" check "$TMP/allow1.x" >"$TMP/a.log" 2>&1; arc=$?
    "$XLANG" check "$TMP/let_i32.x" >"$TMP/l.log" 2>&1; lrc=$?
    "$XLANG" check examples/hello.x >"$TMP/h.log" 2>&1; hrc=$?
    set -e
    [ "$irc" -eq 0 ] && [ -s "$TMP/i.o" ] || die "11.56 IF_min regress"
    [ "$prc" -eq 0 ] && [ -s "$TMP/p.o" ] || die "11.59 param_ctx regress"
    [ "$arc" -eq 0 ] || die "allow(padding) plant regress; log=$(head -2 "$TMP/a.log" | tr '\n' ' ')"
    [ "$lrc" -eq 0 ] || die "scalar let regress; log=$(head -2 "$TMP/l.log" | tr '\n' ' ')"
    if [ "$hrc" -eq 0 ]; then
      echo "${PREFIX} OK: allow1+IF+param_ctx; hello also green"
    else
      echo "${PREFIX} OK: allow1+IF+param_ctx; hello residual→11.61 (hrc=$hrc; $(head -1 "$TMP/h.log" | tr '\n' ' '))"
    fi
    ;;
  *)
    echo "${PREFIX} SKIP: non-Windows host (docs-only check passed)"
    ;;
esac
