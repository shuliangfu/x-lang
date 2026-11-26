#!/usr/bin/env python3
"""Retarget typool lexer_next_body_into int-digit `else { break; }` jmps.

typool compiles the number-span while in lexer_next_body_into:

    while (l.pos < data.length) {
        if (lexer_is_digit(data[l.pos])) { accumulate; advance; }
        else if (lexer_is_digit_sep(data, l.pos, 0)) { advance '_'; }
        else { break; }
    }

The typool-wrong `else { break; }` is a jmp back to the while head,
same typool break-as-jmp class as skip_ws / skip_comment / bound-scan.
Live fromsrc_s106_noaslr hello check hung at typool
lexer_next_body_into+19233 @ 0x140037199 (e9 96 fd ff ff -> loop head
0x140036f34). pos stuck at 849, the ';' of `return 0;` in
core/fmt/mod.x line 22; ival=0; lexer_is_digit / lexer_is_digit_sep
correctly return 0 on ';'. After the failed is_digit_sep, typool
`je`s to that typool-wrong jmp instead of leaving the while
(after-loop is 0x1400371a3). typool is_digit and is_digit_sep are
the loop workers, not the hang writer.

The same typool encoding (post-is_digit_sep `je +0x3d` to a jmp-to-head,
with a continue trampoline immediately after) appears at every
int-digit while in typool lexer_next_body_into (decimal live; hex /
bin / oct / exponent siblings share the encoding). This script
retargets each typool-wrong break to skip the continue trampoline
and land on the after-loop code. It does not wholesale-fold typool
lexer_next_body_into.

Pattern is VA-independent (nm + body scan). Idempotent. Refuses
compiler/xlang_asm.exe. PLATFORM: WINDOWS|X86_64 unofficial from-source
DIG images only. Soft Cap / tiphead HOLD.

DIG s243: wired into g05_relink_xlang.sh (Win PE post-link, after
win_tip_p001_face_pe_patch). Live tip hang was is_digit(';') spin
after Soft Cap next_punct (s242); this Soft Cap closes that UNIQUE.
"""
from __future__ import annotations

import argparse
import struct
import subprocess
import sys
from pathlib import Path


# After typool's call lexer_is_digit_sep (cltq; add $0x20,%rsp; test;
# setne; movzbl; test; je +0x3d). The je target is the typool-wrong break.
POST_CALL = bytes.fromhex("48984883c42085c00f95c00fb6c085c00f843d000000")


def pe_va_to_off(data: bytes, va: int) -> tuple[int, int]:
    e_lfanew = struct.unpack_from("<I", data, 0x3C)[0]
    coff = e_lfanew + 4
    nsec = struct.unpack_from("<H", data, coff + 2)[0]
    optsz = struct.unpack_from("<H", data, coff + 16)[0]
    magic = struct.unpack_from("<H", data, coff + 20)[0]
    if magic == 0x20B:
        image_base = struct.unpack_from("<Q", data, coff + 20 + 24)[0]
    else:
        image_base = struct.unpack_from("<I", data, coff + 20 + 28)[0]
    sec_off = coff + 20 + optsz
    rva = va - image_base
    for i in range(nsec):
        o = sec_off + i * 40
        vsz, va_s, rawsz, rawptr = struct.unpack_from("<IIII", data, o + 8)
        if va_s <= rva < va_s + max(vsz, rawsz):
            return rawptr + (rva - va_s), image_base
    raise SystemExit(f"VA 0x{va:x} not mapped")


def is_official_product(path: Path) -> bool:
    parts = [p.lower() for p in path.resolve().parts]
    return path.name.lower() == "xlang_asm.exe" and "compiler" in parts


def nm_text_addrs(exe: Path, name: str) -> list[int]:
    out = subprocess.check_output(["nm", str(exe)], text=True, errors="replace")
    addrs: list[int] = []
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 3 and parts[-1] == name and parts[1] in "TtWw":
            addrs.append(int(parts[0], 16))
    return sorted(set(addrs))


def find_sites(data: bytearray, exe: Path) -> list[tuple[int, int, int, int, bytes]]:
    addrs = nm_text_addrs(exe, "lexer_next_body_into")
    if not addrs:
        raise SystemExit("missing lexer_next_body_into")
    print("SYM lexer_next_body_into", [hex(a) for a in addrs])
    hits: list[tuple[int, int, int, int, bytes]] = []
    for va in addrs:
        off, _image_base = pe_va_to_off(data, va)
        window = 0x8000
        blob = bytes(data[off : off + window])
        start = 0
        while True:
            i = blob.find(POST_CALL, start)
            if i < 0:
                break
            je_off = off + i + (len(POST_CALL) - 6)
            je_va = va + (je_off - off)
            disp = struct.unpack_from("<i", data, je_off + 2)[0]
            break_va = je_va + 6 + disp
            break_off, _ = pe_va_to_off(data, break_va)
            insn = bytes(data[break_off : break_off + 5])
            if insn[0] != 0xE9:
                print(f"SKIP not jmp face={hex(va)} break={hex(break_va)} {insn.hex()}")
                start = i + 1
                continue
            rel = struct.unpack_from("<i", insn, 1)[0]
            target = break_va + 5 + rel
            after = break_va + 10
            print(
                f"HIT face={hex(va)} je={hex(je_va)} break={hex(break_va)} "
                f"insn={insn.hex()} target={hex(target)} after={hex(after)}"
            )
            hits.append((break_va, break_off, target, after, insn))
            start = i + 1
    return hits


def patch_hits(data: bytearray, hits: list[tuple[int, int, int, int, bytes]]) -> int:
    n = 0
    for break_va, break_off, _target, after, insn in hits:
        new_rel = after - (break_va + 5)
        new = bytes([0xE9]) + struct.pack("<i", new_rel)
        if insn == new:
            print(f"ALREADY {hex(break_va)} {insn.hex()}")
            continue
        print(f"PATCH {hex(break_va)} {insn.hex()} -> {new.hex()} jmp {hex(after)}")
        data[break_off : break_off + 5] = new
        n += 1
    return n


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("exe", type=Path)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    exe = args.exe
    if is_official_product(exe):
        raise SystemExit(f"refusing official product: {exe}")
    data = bytearray(exe.read_bytes())
    hits = find_sites(data, exe)
    print("HITS", len(hits))
    if not hits:
        raise SystemExit("no typool int-digit else-break sites")
    if args.dry_run:
        return 0
    n = patch_hits(data, hits)
    if n:
        exe.write_bytes(data)
    print(f"PATCHED {n} / {len(hits)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
