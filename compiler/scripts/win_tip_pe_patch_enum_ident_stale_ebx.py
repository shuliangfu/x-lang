#!/usr/bin/env python3
"""PE-patch Win tip same-module Enum.Variant T001 (DIG 2026-11-10).

Root cause in parser_asm_skip_one_enum_register_into_c (tip-aside PE):
after stepping past TOKEN_ENUM, the second parser_asm_lex_peek_kind_c
stores the kind in rax / [rbp-0x40] (0x140449b61..0x140449b63) but the
TOKEN_IDENT (0x3b) compare uses stale %ebx, still holding TOKEN_ENUM
(0x2f) from the first peek. The IDENT check always fails, the function
returns 1 without calling parser_asm_module_try_register_enum_name_c,
and module.num_module_enums stays 0. Later Color.RED / TokenKind.* /
TypeKind.* typeck then reports T001 unknown field.

The first peek (TOKEN_ENUM @ 0x140449ad9) and the later TOKEN_LBRACE
peek (@ 0x140449ed3) both reload ebx from [rbp-0x40]; only the IDENT
peek omits that reload.

Patch (1 site @ 0x140449b67): replace
  mov eax, 0x3b; cmp ebx, eax
with
  cmp eax, 0x3b; nop * 4
so the compare uses the kind still in eax after the store to [rbp-0x40].
Unique 24-byte window includes the preceding disp8 and following setne.

Idempotent. Apply after lex_int_token_start on tip-aside install.
PLATFORM: WINDOWS|X86_64 tip PE only. Soft Cap / tiphead HOLD.
"""
from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

FUNC_LO = 0x140449970  # parser_asm_skip_one_enum_register_into_c
FUNC_HI = 0x140449FB4
SITE = 0x140449B67
# mov eax, 0x3b; cmp ebx, eax
OLD = bytes.fromhex("b83b00000039c3")
# cmp eax, 0x3b; nop * 4
NEW = bytes.fromhex("83f83b90909090")
# unique context: last byte of `mov [rbp-0x40], rax` + site + setne/test/je
CTX_BEFORE = bytes.fromhex("c0")
CTX_AFTER = bytes.fromhex("0f95c00fb6c085c00f840f000000b801")


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
    ctx = bytes(data[fo - 1 : fo + 7 + len(CTX_AFTER)])
    if got == NEW:
        want_ctx = CTX_BEFORE + NEW + CTX_AFTER
        if ctx != want_ctx:
            print("FAIL site already NEW but unique context mismatch", file=sys.stderr)
            return 2
        print("OK already enum-ident-stale-ebx @ 0x140449b67")
        return 0
    if got != OLD:
        print(
            f"FAIL unexpected bytes at 0x{SITE:x}: {got.hex()} (want OLD {OLD.hex()} or NEW {NEW.hex()})",
            file=sys.stderr,
        )
        return 2
    want_ctx = CTX_BEFORE + OLD + CTX_AFTER
    if ctx != want_ctx:
        print("FAIL unique context mismatch around 0x140449b67", file=sys.stderr)
        return 2
    if dry_run:
        print("DRY-RUN would patch 1 enum-ident-stale-ebx site:")
        print("  0x140449b67  mov eax,0x3b; cmp ebx,eax  ->  cmp eax,0x3b; nop*4")
        return 0
    data[fo : fo + 7] = NEW
    path.write_bytes(data)
    print(f"PATCHED 1 enum-ident-stale-ebx site @ 0x140449b67 in {path}")
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
