#!/usr/bin/env python3
"""PE-patch Win tip named struct literal P001 (DIG 2026-11-10).

Root cause of `return S { a: 1, b: 2 }` (P001 no functions) is two
cooperating tip defects. Anonymous `{ a: 1, b: 2 }` and
`let s: S = []; s.a = ...; return s` already worked.

1) parser_asm_primary_ident_x_into_c, after stepping the type IDENT,
   peeks TOKEN_LBRACE into rax / [rbp-0x70] (0x14041145a) but the
   0x54 compare uses stale %ebx (a pointer, not 0x54). The first
   conjunct of `kind == LBRACE && name_was_self == 0` always fails,
   so parser_finish_struct_lit_ptr_into_c is never entered. The later
   LBRACE peek in the same function (0x140414804) and both suffix_loop
   LBRACE peeks already reload ebx.

   Patch @ 0x14041145e:
     mov eax, 0x54; cmp ebx, eax  ->  cmp eax, 0x54; nop * 4

2) Even after (1), finish still returns ok2=0. pthin_primary_face_struct
   (which=1) calls parser_asm_finish_struct_lit_from_type_ident_x_into_c
   with 7 Win64 args, but the tip emitted `push 0; push &refv` and only
   wrote name_buf / out_ok at [rsp+0x20] / [rsp+0x28] after those
   pushes. The 7th arg (out_expr_ref) is never stored; finish_x sees
   a NULL at [rbp+0x40] and returns 0 before
   parser_asm_parse_struct_lit_fields_x_into_c. Anonymous lits take
   the 5-arg path and are unaffected.

   Patch @ 0x140407d55 (14 bytes):
     mov eax,0; push rax; lea rax,[rbp-0x168]; push rax
       ->  lea rax,[rbp-0x168]; mov [rsp+0x30], rax; nop * 2
   Patch @ 0x140407df5:
     add rsp, 0x10  ->  nop * 4
   (the add balanced the two pushes; it must go once the pushes are
   gone).

Both sites are required; (1) alone still P001. Idempotent. Apply after
enum_ident_stale_ebx on tip-aside install.
PLATFORM: WINDOWS|X86_64 tip PE only. Soft Cap / tiphead HOLD.
"""
from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

# A: LBRACE stale ebx in parser_asm_primary_ident_x_into_c
SITE_A = 0x14041145E
OLD_A = bytes.fromhex("b85400000039c3")  # mov eax,0x54; cmp ebx,eax
NEW_A = bytes.fromhex("83f85490909090")  # cmp eax,0x54; nop*4
CTXA_BEFORE = bytes.fromhex("48894590")  # mov [rbp-0x70], rax
CTXA_AFTER = bytes.fromhex("0f94c0")  # sete al

# B: face_struct 7th-arg write (pthin_primary_face_struct)
SITE_B = 0x140407D55
OLD_B = bytes.fromhex("b80000000050488d8598feffff50")
NEW_B = bytes.fromhex("488d8598feffff48894424309090")

# C: drop the add rsp,0x10 that balanced the old pushes
SITE_C = 0x140407DF5
OLD_C = bytes.fromhex("4883c410")
NEW_C = bytes.fromhex("90909090")
CTXC_BEFORE = bytes.fromhex("e813e60000")  # call finish_x
CTXC_AFTER = bytes.fromhex("4898")  # cltq


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


def check(data: bytearray, fo: int, old: bytes, new: bytes, before: bytes = b"", after: bytes = b""):
    got = bytes(data[fo : fo + len(old)])
    ctx = bytes(data[fo - len(before) : fo + len(old) + len(after)])
    if got == new:
        want = before + new + after
        if before or after:
            if bytes(data[fo - len(before) : fo + len(new) + len(after)]) != want:
                return "bad_new_ctx"
        return "already"
    if got != old:
        return f"unexpected:{got.hex()}"
    if before or after:
        if ctx != before + old + after:
            return "bad_old_ctx"
    return "old"


def patch(path: Path, dry_run: bool) -> int:
    data = bytearray(path.read_bytes())
    ib, secs = pe_meta(data)
    fo_a = fo_for(ib, secs, SITE_A)
    fo_b = fo_for(ib, secs, SITE_B)
    fo_c = fo_for(ib, secs, SITE_C)
    st = {
        "A": check(data, fo_a, OLD_A, NEW_A, CTXA_BEFORE, CTXA_AFTER),
        "B": check(data, fo_b, OLD_B, NEW_B),
        "C": check(data, fo_c, OLD_C, NEW_C, CTXC_BEFORE, CTXC_AFTER),
    }
    bad = {k: v for k, v in st.items() if v not in ("old", "already")}
    if bad:
        print(f"FAIL unexpected site state {bad}", file=sys.stderr)
        return 2
    kinds = set(st.values())
    if kinds == {"already"}:
        print("OK already named-struct-lit @ 0x14041145e + 0x140407d55 + 0x140407df5")
        return 0
    if "already" in kinds and "old" in kinds:
        print(f"FAIL mixed already/old {st}", file=sys.stderr)
        return 2
    if dry_run:
        print("DRY-RUN would patch 3 named-struct-lit sites:")
        print("  0x14041145e  mov eax,0x54; cmp ebx,eax  ->  cmp eax,0x54; nop*4")
        print("  0x140407d55  push 0; push &refv  ->  mov [rsp+0x30], &refv")
        print("  0x140407df5  add rsp,0x10  ->  nop*4")
        return 0
    data[fo_a : fo_a + 7] = NEW_A
    data[fo_b : fo_b + 14] = NEW_B
    data[fo_c : fo_c + 4] = NEW_C
    path.write_bytes(data)
    print(f"PATCHED 3 named-struct-lit sites in {path}")
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
