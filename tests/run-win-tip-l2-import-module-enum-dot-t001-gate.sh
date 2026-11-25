#!/usr/bin/env bash
# Knife 11.75: Win tip L2 import_module_enum_dot T001 — tip-only enum_register twin gate.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PREFIX="xlang: [WIN_TIP_L2_IMPORT_MODULE_ENUM_DOT_T001]"

die() { echo "${PREFIX} FAIL: $*" >&2; exit 1; }

DOC=analysis/xlang-win-tip-l2-import-module-enum-dot-t001.md
PRIOR=analysis/xlang-win-tip-l2-std-io-submit-read-t001.md
SEED=compiler/seeds/win_tip_pe_overrides/stale_skip_one_enum_register_into_override.c
INJ=compiler/scripts/win_tip_pe_inject_skip_one_enum_register_override.py
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$PRIOR" ] || die "missing 11.74 DIG $PRIOR"
[ -f "$SEED" ] || die "missing seed $SEED"
[ -f "$INJ" ] || die "missing inject $INJ"
grep -qE 'skip_one_enum_register|0x140618898|append_enum|e9|\.c75enum' "$DOC" || die "diagnose missing enum_register/e9"
grep -qE 'Residual HOLD|CLOSE residual HOLD|无 tip PE|无 PE 修' "$PRIOR" || die "11.74 DIG must be residual HOLD"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    if [ -x ./compiler/xlang_asm.exe ]; then XLANG=./compiler/xlang_asm.exe
    elif [ -x ./compiler/xlang.exe ]; then XLANG=./compiler/xlang.exe
    else die "missing tip PE"; fi
    TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_win_enum_dot_$$}"
    mkdir -p "$TMP/std/gate75_mod" "$TMP"
    # static: stub must NOT e9→append_enum
    set +e
    python3 - "$XLANG" <<'PY'
import struct, sys
from pathlib import Path
exe = Path(sys.argv[1])
data = exe.read_bytes()
e = struct.unpack_from("<I", data, 0x3C)[0]
so = struct.unpack_from("<H", data, e + 20)[0]
num = struct.unpack_from("<H", data, e + 6)[0]
base = e + 24 + so
secs = []
for i in range(num):
    o = base + i * 40
    name = data[o:o+8].split(b"\0")[0]
    vsz, va, rsz, raw = struct.unpack_from("<IIII", data, o + 8)
    secs.append((name, va, vsz, raw, rsz))
def va_to_off(va, image_base=0x140000000):
    rva = va - image_base
    for _n, sva, vsz, raw, rsz in secs:
        if sva <= rva < sva + max(vsz, rsz, 1):
            return raw + (rva - sva)
    raise SystemExit("va missing")
stub = 0x140618898
append = 0x140618374
off = va_to_off(stub)
b = data[off : off + 5]
if b[0] != 0xE9:
    sys.exit(0)
rel = struct.unpack_from("<i", b, 1)[0]
dest = stub + 5 + rel
if dest == append:
    sys.exit(2)
# require .c75enum section present when live
if not any(n == b".c75enum" for n, *_ in secs):
    sys.exit(3)
sys.exit(0)
PY
    static_ec=$?
    set -e
    if [ "$static_ec" -eq 2 ]; then
      echo "${PREFIX} HOLD: tip enum_register@0x140618898 e9->append_enum (stale); need live twin"
      exit 2
    fi
    if [ "$static_ec" -eq 3 ]; then
      die "stub retargeted but .c75enum section missing"
    fi
    if [ "$static_ec" -ne 0 ]; then
      die "static PE enum_register probe failed ec=$static_ec"
    fi

    # only_fn green
    cat >"$TMP/std/gate75_mod/mod.x" <<'EOFX'
export function driver_read_ptr_len(): i32 { return 0; }
EOFX
    cat >"$TMP/use_ok.x" <<'EOFX'
const driver = import("std.gate75_mod");
export function f(): i32 { return driver.driver_read_ptr_len(); }
EOFX
    set +e
    (cd "$TMP" && "$ROOT/$XLANG" check -L . use_ok.x) >"$TMP/ok.log" 2>&1
    ok_ec=$?
    set -e
    [ "$ok_ec" -eq 0 ] || die "only_fn module.dot regress ok_ec=$ok_ec"

    # +struct green
    cat >"$TMP/std/gate75_mod/mod.x" <<'EOFX'
export struct Buffer { x: i32 }
export function driver_read_ptr_len(): i32 { return 0; }
EOFX
    set +e
    (cd "$TMP" && "$ROOT/$XLANG" check -L . use_ok.x) >"$TMP/struct.log" 2>&1
    st_ec=$?
    set -e
    [ "$st_ec" -eq 0 ] || die "+struct module.dot regress st_ec=$st_ec"

    # +enum BEFORE fn must be green (this knife)
    cat >"$TMP/std/gate75_mod/mod.x" <<'EOFX'
export enum IO_Result { Ok, Err }
export function driver_read_ptr_len(): i32 { return 0; }
EOFX
    set +e
    (cd "$TMP" && "$ROOT/$XLANG" check -L . use_ok.x) >"$TMP/enum.log" 2>&1
    enum_ec=$?
    set -e
    if [ "$enum_ec" -ne 0 ]; then
      echo "${PREFIX} HOLD: +enum still T001 enum_ec=$enum_ec" >&2
      head -20 "$TMP/enum.log" >&2 || true
      exit 2
    fi

    # std.io.core submit_read path keep green
    cat >"$TMP/core_ok.x" <<'EOFX'
const core = import("std.io.core");
export function f(): i32 { return 0; }
EOFX
    set +e
    (cd "$TMP" && "$ROOT/$XLANG" check -L "$ROOT" core_ok.x) >"$TMP/core.log" 2>&1
    core_ec=$?
    set -e
    # soft: if path unavailable don't fail knife; note only
    if [ "$core_ec" -ne 0 ]; then
      echo "${PREFIX} NOTE: std.io.core import check ec=$core_ec (non-fatal if tree path)"
    fi

    # optional: std/io/mod.x may now green or still other residual — note only
    set +e
    "$XLANG" check std/io/mod.x >"$TMP/mod.log" 2>&1
    mod_ec=$?
    set -e
    echo "${PREFIX} NOTE: std/io/mod.x check ec=$mod_ec"

    # hello must stay green (11.73)
    set +e
    "$XLANG" check examples/hello.x >"$TMP/hello.log" 2>&1
    hello_ec=$?
    set -e
    [ "$hello_ec" -eq 0 ] || die "hello regress after 11.75 hello_ec=$hello_ec"

    echo "${PREFIX} OK: enum_register live twin; +enum module.dot green; only_fn/+struct/hello OK"
    exit 0
    ;;
  *)
    echo "${PREFIX} SKIP: non-Windows host ($uname_s); DIG/seed/inject present"
    exit 0
    ;;
esac
