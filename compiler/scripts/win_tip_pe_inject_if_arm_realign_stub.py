#!/usr/bin/env python3
"""PLATFORM: WINDOWS tip PE only — knife 11.56.

Rewrite weak stub parser_asm_realign_lex_after_if_arm_into_c from a
miswired jmp lex_set_pos_c into the intended success stub:

  mov eax, 1; ret; nop; nop

Post-11.55 (paren+ident live), this tip-only trampoline fix unlocks IF
then-block covering (XT001 / -c). No Soft Cap bytes copied; semantics =
return-success no-op after IF arm (same contract Soft Cap already had).
"""
from __future__ import annotations

import argparse
import hashlib
import struct
import subprocess
import sys
from pathlib import Path

SYM = "parser_asm_realign_lex_after_if_arm_into_c"
BAD = bytes.fromhex("e909fc0000000000")  # jmp lex_set_pos_c (tip pre-11.56)
GOOD = bytes.fromhex("b801000000c39090")  # mov eax,1; ret; nop; nop


def pe_map(data: bytes):
    e = struct.unpack_from("<I", data, 0x3C)[0]
    nsec = struct.unpack_from("<H", data, e + 6)[0]
    opt = struct.unpack_from("<H", data, e + 20)[0]
    img_base = struct.unpack_from("<Q", data, e + 24 + 24)[0]
    sec0 = e + 24 + opt
    secs = []
    for i in range(nsec):
        o = sec0 + i * 40
        name = data[o : o + 8].split(b"\0")[0].decode()
        vsz, va, rsz, ro = struct.unpack_from("<IIII", data, o + 8)
        secs.append({"name": name, "va": va, "vsz": vsz, "ro": ro, "rsz": rsz})
    return img_base, secs


def va_to_off(img_base: int, secs, va: int) -> int:
    rva = va - img_base
    for s in secs:
        if s["va"] <= rva < s["va"] + max(s["vsz"], s["rsz"]):
            return s["ro"] + (rva - s["va"])
    raise ValueError(f"VA {hex(va)} not mapped")


def nm_sym(exe: Path, name: str) -> int:
    out = subprocess.check_output(["nm", str(exe)], text=True, errors="replace")
    best = None
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 3 and parts[2] == name and all(
            c in "0123456789abcdefABCDEF" for c in parts[0]
        ):
            va = int(parts[0], 16)
            if parts[1] in "WwTt" and (best is None or parts[1] in "Ww"):
                best = va
    if best is None:
        raise SystemExit(f"symbol {name} missing in {exe}")
    return best


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("exe", type=Path)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    data = bytearray(args.exe.read_bytes())
    img_base, secs = pe_map(data)
    try:
        va = nm_sym(args.exe, SYM)
    except Exception as ex:
        # product PE may have stale PointerToSymbolTable after .text grow;
        # fall back to known tip VA from 11.55/11.56 dig.
        print(f"nm failed ({ex}); fallback VA 0x1405f16b4", file=sys.stderr)
        va = 0x1405F16B4
    off = va_to_off(img_base, secs, va)
    cur = bytes(data[off : off + 8])
    print(f"{SYM} VA={hex(va)} fileoff={hex(off)} before={cur.hex()}")
    if cur == GOOD:
        print("already patched; md5", hashlib.md5(data).hexdigest())
        return 0
    if cur != BAD and cur[:5] != bytes.fromhex("e9"):
        print("unexpected stub bytes; refuse", file=sys.stderr)
        return 2
    if args.dry_run:
        print("dry-run: would write", GOOD.hex())
        return 0
    data[off : off + 8] = GOOD
    args.exe.write_bytes(data)
    print("after", GOOD.hex(), "md5", hashlib.md5(data).hexdigest())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
