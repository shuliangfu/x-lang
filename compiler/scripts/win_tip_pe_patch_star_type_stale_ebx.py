#!/usr/bin/env python3
"""PE-patch Win tip **T / pointer-depth type parse P001 (DIG 2026-11-10).

Root cause in parser_asm_parse_star_type_x_into_c (tip-aside PE):
the while (kind == TOKEN_STAR) head at 0x1403f16b9 compares %ebx to
TOKEN_STAR (0x62), but the loop body increments ptr_depth with
  mov $1, %ebx; add %ebx, %eax
which clobbers ebx. The next peek stores the new kind in [rbp-0x48]
and jumps back to the head, which never reloads ebx. The loop therefore
runs exactly once: `*T` (pointee token sits in [rbp-0x48] after one
consume) still parses, but `**T` / `***T` leave the second `*` unconsumed.
is_pointee_type_token(STAR) fails, the type_ref is 0, and the enclosing
function is silently dropped. A later call to that function then typecks
as XT001 "cannot resolve ...()" / check_block failed. This is typeck.x
#393 typeck_soa_field_soa_index (call of typeck_soa_find_layout_module_and_idx
with **Module) and any other leaf whose body or callee mentions `**T`.

The first TOKEN_STAR check (@ 0x1403f168c) correctly loads ebx from
[rbp-0x48]; only the while-head omits that reload.

Patch (1 site @ 0x1403f16b9): replace
  mov eax, 0x62; cmp ebx, eax
with
  mov rbx, [rbp-0x48]; cmp ebx, 0x62
so the loop condition uses the kind just stored by peek. Unique 7-byte
window is preceded by `mov [rbp-0x50], rax` (ptr_depth = 0).

Idempotent. Apply after named_struct_lit on tip-aside install.
PLATFORM: WINDOWS|X86_64 tip PE only. Soft Cap / tiphead HOLD.
"""
from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

FUNC_LO = 0x1403F150C  # parser_asm_parse_star_type_x_into_c
FUNC_HI = 0x1403F1FBA
SITE = 0x1403F16B9
# mov eax, 0x62; cmp ebx, eax
OLD = bytes.fromhex("b86200000039c3")
# mov rbx, [rbp-0x48]; cmp ebx, 0x62
NEW = bytes.fromhex("488b5db883fb62")
# unique context: `mov [rbp-0x50], rax` + site + sete/test/je +0x7c
CTX_BEFORE = bytes.fromhex("488945b0")
CTX_AFTER = bytes.fromhex("0f94c00fb6c085c00f847c000000")


def pe_meta(data: bytearray):
    e = struct.unpack_from("<I", data, 0x3C)[0]
    ns = struct.unpack_from("<H", data, e + 6)[0]
    osize = struct.unpack_from("<H", data, e + 20)[0]
    ib = struct.unpack_from("<Q", data, e + 24 + 24)[0]
    so = e + 24 + osize
    secs = []
    for i in range(ns):
        o = so + i * 40
        vs, va, rs, rp = struct.unpack_from("<IIII", data, o + 8)
        secs.append({"va": va, "vsz": vs, "rsz": rs, "rp": rp})
    return ib, secs


def fo_for(ib: int, secs, va: int) -> int:
    rva = va - ib
    for s in secs:
        if s["va"] <= rva < s["va"] + max(s["vsz"], s["rsz"]):
            return s["rp"] + (rva - s["va"])
    raise SystemExit(f"VA 0x{va:x} not mapped")


def patch(path: Path, dry_run: bool) -> int:
    data = bytearray(path.read_bytes())
    ib, secs = pe_meta(data)
    fo = fo_for(ib, secs, SITE)
    lo = fo_for(ib, secs, FUNC_LO)
    hi = fo_for(ib, secs, FUNC_HI)
    if not (lo <= fo < hi):
        print(f"FAIL site 0x{SITE:x} outside function window", file=sys.stderr)
        return 2
    got = bytes(data[fo : fo + 7])
    ctx = bytes(data[fo - len(CTX_BEFORE) : fo + 7 + len(CTX_AFTER)])
    if got == NEW:
        want_ctx = CTX_BEFORE + NEW + CTX_AFTER
        if ctx != want_ctx:
            print("FAIL site already NEW but unique context mismatch", file=sys.stderr)
            return 2
        print("OK already star-type-stale-ebx @ 0x1403f16b9")
        return 0
    if got != OLD:
        print(
            f"FAIL unexpected bytes at 0x{SITE:x}: {got.hex()} (want OLD {OLD.hex()} or NEW {NEW.hex()})",
            file=sys.stderr,
        )
        return 2
    want_ctx = CTX_BEFORE + OLD + CTX_AFTER
    if ctx != want_ctx:
        print("FAIL unique context mismatch around 0x1403f16b9", file=sys.stderr)
        return 2
    if dry_run:
        print("DRY-RUN would patch 1 star-type-stale-ebx site:")
        print("  0x1403f16b9  mov eax,0x62; cmp ebx,eax  ->  mov rbx,[rbp-0x48]; cmp ebx,0x62")
        return 0
    data[fo : fo + 7] = NEW
    path.write_bytes(data)
    print(f"PATCHED 1 star-type-stale-ebx site @ 0x1403f16b9 in {path}")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("exe", type=Path)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    if not args.exe.is_file():
        print(f"FAIL missing {args.exe}", file=sys.stderr)
        return 2
    return patch(args.exe, args.dry_run)


if __name__ == "__main__":
    sys.exit(main())
