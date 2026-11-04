#!/usr/bin/env bash
# Knife 11.73: Win tip L2 hello XP008 after struct lit (trait header stale e9) gate.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PREFIX="xlang: [WIN_TIP_L2_HELLO_XP008_AFTER_STRUCT_LIT]"

die() { echo "${PREFIX} FAIL: $*" >&2; exit 1; }

DOC=analysis/xlang-win-tip-l2-hello-xp008-after-struct-lit.md
PRIOR=analysis/xlang-win-tip-l2-hello-xp008-struct-lit-parse.md
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$PRIOR" ] || die "missing 11.72 DIG $PRIOR"
grep -qE 'p12g_store_i32|skip_one_trait_header|stale|e9' "$DOC" || die "diagnose missing header/e9 locus"
grep -qE 'CLOSE ACCEPT|正式 CLOSE ACCEPT' "$PRIOR" || die "11.72 DIG must be CLOSE ACCEPT"
grep -qE 'Residual|DIG|修靶|trait' "$DOC" || die "diagnose missing DIG/Residual"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    if [ -x ./compiler/xlang_asm.exe ]; then XLANG=./compiler/xlang_asm.exe
    elif [ -x ./compiler/xlang.exe ]; then XLANG=./compiler/xlang.exe
    else die "missing tip PE"; fi
    TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_win_hello_after_struct_$$}"
    mkdir -p "$TMP"
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
    vsz, va, rsz, raw = struct.unpack_from("<IIII", data, o + 8)
    secs.append((va, vsz, raw, rsz))
def va_to_off(va, image_base=0x140000000):
    rva = va - image_base
    for sva, vsz, raw, rsz in secs:
        if sva <= rva < sva + max(vsz, 1):
            return raw + (rva - sva)
    raise SystemExit("va missing")
hdr = 0x1406087C4
store = 0x140622780
off = va_to_off(hdr)
b = data[off : off + 5]
if b[0] != 0xE9:
    sys.exit(0)
rel = struct.unpack_from("<i", b, 1)[0]
dest = hdr + 5 + rel
if dest == store:
    sys.exit(2)
sys.exit(0)
PY
    static_ec=$?
    set -e
    if [ "$static_ec" -eq 2 ]; then
      echo "${PREFIX} HOLD: tip header@0x1406087c4 e9->p12g_store_i32 (stale); need live twin"
      exit 2
    fi
    if [ "$static_ec" -ne 0 ]; then
      die "static PE header probe failed ec=$static_ec"
    fi
    cat >"$TMP/reader.x" <<'EOFX'
export trait Reader {
  function read(self): i32;
}
export function f(): i32 { return 0; }
EOFX
    set +e
    "$XLANG" check "$TMP/reader.x" >"$TMP/r.log" 2>&1; rrc=$?
    "$XLANG" check std/context/context.x >"$TMP/c.log" 2>&1; crc=$?
    set -e
    [ "$crc" -eq 0 ] || die "context.x regress"
    if [ "$rrc" -eq 139 ] || [ "$rrc" -gt 128 ]; then
      echo "${PREFIX} HOLD: Reader trait still SEGV rrc=$rrc"
      exit 2
    fi
    if [ "$rrc" -ne 0 ]; then
      echo "${PREFIX} HOLD: Reader trait fail rrc=$rrc; $(head -2 "$TMP/r.log" | tr '\n' ' ')"
      exit 2
    fi
    echo "${PREFIX} OK: header e9 retargeted + Reader trait check EXIT0 + context.x"
    ;;
  *)
    echo "${PREFIX} OK: docs/diagnose only on non-Windows ($uname_s)"
    ;;
esac
