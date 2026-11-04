#!/usr/bin/env bash
# Knife 11.74: Win tip L2 std.io submit_read T001 — DIG residual HOLD gate.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PREFIX="xlang: [WIN_TIP_L2_STD_IO_SUBMIT_READ_T001]"

die() { echo "${PREFIX} FAIL: $*" >&2; exit 1; }

DOC=analysis/xlang-win-tip-l2-std-io-submit-read-t001.md
PRIOR=analysis/xlang-win-tip-l2-hello-xp008-trait-header-stale-e9.md
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$PRIOR" ] || die "missing 11.73 DIG $PRIOR"
grep -qE 'enum|submit_read|import_alias|method_call|Residual HOLD|DIG' "$DOC" || die "diagnose missing enum/DIG"
grep -qE 'CLOSE ACCEPT|正式 CLOSE ACCEPT' "$PRIOR" || die "11.73 DIG must be CLOSE ACCEPT"
grep -qE 'Residual HOLD|无 tip PE|无 PE 修' "$DOC" || die "diagnose missing Residual HOLD"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    if [ -x ./compiler/xlang_asm.exe ]; then XLANG=./compiler/xlang_asm.exe
    elif [ -x ./compiler/xlang.exe ]; then XLANG=./compiler/xlang.exe
    else die "missing tip PE"; fi
    TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_win_io_submit_read_$$}"
    mkdir -p "$TMP/std/gate74_mod" "$TMP"
    # only_fn must be green
    cat >"$TMP/std/gate74_mod/mod.x" <<'EOFX'
export function driver_read_ptr_len(): i32 { return 0; }
EOFX
    cat >"$TMP/use_ok.x" <<'EOFX'
const driver = import("std.gate74_mod");
export function f(): i32 { return driver.driver_read_ptr_len(); }
EOFX
    set +e
    (cd "$TMP" && "$ROOT/$XLANG" check -L . use_ok.x) >"$TMP/ok.log" 2>&1
    ok_ec=$?
    set -e
    [ "$ok_ec" -eq 0 ] || die "only_fn module.dot regress ok_ec=$ok_ec"

    # enum module → expect T001 (residual locked)
    cat >"$TMP/std/gate74_mod/mod.x" <<'EOFX'
export enum IO_Result { Ok, Err }
export function driver_read_ptr_len(): i32 { return 0; }
EOFX
    cat >"$TMP/use_enum.x" <<'EOFX'
const driver = import("std.gate74_mod");
export function f(): i32 { return driver.driver_read_ptr_len(); }
EOFX
    set +e
    (cd "$TMP" && "$ROOT/$XLANG" check -L . use_enum.x) >"$TMP/enum.log" 2>&1
    enum_ec=$?
    set -e
    if [ "$enum_ec" -eq 0 ]; then
      die "unexpected green: enum module.dot EXIT0 (residual would need re-DIG)"
    fi
    if ! grep -qE 'no impl for type with method|T001' "$TMP/enum.log"; then
      die "enum fixture failed without T001 (ec=$enum_ec); see $TMP/enum.log"
    fi
    # optional: std/io/mod.x still T001 submit_read
    set +e
    "$XLANG" check std/io/mod.x >"$TMP/mod.log" 2>&1
    mod_ec=$?
    set -e
    if [ "$mod_ec" -eq 0 ]; then
      echo "${PREFIX} NOTE: std/io/mod.x unexpectedly EXIT0"
    else
      grep -qE 'submit_read|T001' "$TMP/mod.log" || echo "${PREFIX} NOTE: mod.x fail without submit_read string"
    fi
    # hello must stay green (11.73)
    set +e
    "$XLANG" check examples/hello.x >"$TMP/hello.log" 2>&1
    hello_ec=$?
    set -e
    [ "$hello_ec" -eq 0 ] || die "hello regress after 11.73 hello_ec=$hello_ec"

    echo "${PREFIX} HOLD: import module with enum → module.dot T001 (submit_read surface); no tip PE plant; Soft Cap Prefer same class"
    exit 2
    ;;
  *)
    echo "${PREFIX} SKIP: non-Windows host ($uname_s); DIG docs present"
    exit 0
    ;;
esac
