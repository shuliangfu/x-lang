#!/usr/bin/env python3
"""PE-patch Win tip COFF fwrite skipping 0x8664 (DIG 2026-11-10).

Root cause in uasb_out_append (tip-aside PE, 0x1403828bc):
product CodegenOutBuf is length-first (i32 len @0, data[] @+4, cap 0x900000).
The tip passes UASB_OUT_CAP (0x900000) to uasb_rd32/uasb_wr32 as the length
slot, and stores payload at out[len] instead of out[4+len]. The COFF writer
therefore lays a complete object at out+0, starting with
  64 86 01 00  (IMAGE_FILE_MACHINE_AMD64 + 1 section).
driver_codegen_outbuf_len reads that first i32 as the length → 99940
(0x18664). outbuf_data returns out+4, so fwrite skips the 0x8664 prefix
and writes 99940 bytes starting at the timestamp. Prepending 64 86 01 00
makes the dumped file a valid COFF that objdump/nm already understand
(min_assign: 1 section, T main; xfla: 62 symbols).

The cap compare (`cmp ebx, 0x900000`) is left unchanged.

Patch (3 unique sites in uasb_out_append):
  rd32/wr32 offset  mov eax,0x900000 → mov eax,0
  store             lea rax,[rax+rbx]; mov rbx,rax
                    → lea rbx,[rax+rbx+4]; nop; nop

Idempotent. Apply after post_parse_state_off on tip-aside install.
PLATFORM: WINDOWS|X86_64 tip PE only. Soft Cap / tiphead HOLD.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

FUNC_LO = 0x1403828BC  # uasb_out_append
FUNC_HI = 0x140382AAB

# mov eax, 0x900000
MOV_CAP = bytes.fromhex("b800009000")
# mov eax, 0
MOV_ZERO = bytes.fromhex("b800000000")
# after rd32-off: mov qword ptr [rbp-0x48], rax
RD32_AFTER = bytes.fromhex("488945b8")
# after wr32-off: mov qword ptr [rbp-0x50], rax
WR32_AFTER = bytes.fromhex("488945b0")
# lea rax,[rax+rbx]; mov rbx,rax
LEA_OLD = bytes.fromhex("488d04184889c3")
# lea rbx,[rax+rbx+4]; nop; nop
LEA_NEW = bytes.fromhex("488d5c18049090")
# unique lea context
LEA_BEFORE = bytes.fromhex("488b45f050488b45d048984889c358")
LEA_AFTER = bytes.fromhex("588803")


def pe_meta(data: bytearray):
    import struct

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
    lo = fo_for(ib, secs, FUNC_LO)
    hi = fo_for(ib, secs, FUNC_HI)

    rd_old = MOV_CAP + RD32_AFTER
    rd_new = MOV_ZERO + RD32_AFTER
    wr_old = MOV_CAP + WR32_AFTER
    wr_new = MOV_ZERO + WR32_AFTER
    lea_old = LEA_BEFORE + LEA_OLD + LEA_AFTER
    lea_new = LEA_BEFORE + LEA_NEW + LEA_AFTER

    already = 0
    todo = 0

    def check_pair(old: bytes, new: bytes, label: str):
        nonlocal already, todo
        c_old = data[lo:hi].count(old)
        c_new = data[lo:hi].count(new)
        if c_old == 1 and c_new == 0:
            todo += 1
            return ("OLD", data.find(old, lo, hi))
        if c_old == 0 and c_new == 1:
            already += 1
            return ("NEW", data.find(new, lo, hi))
        print(f"FAIL {label}: old={c_old} new={c_new} in function window", file=sys.stderr)
        return None

    r = check_pair(rd_old, rd_new, "rd32-off")
    w = check_pair(wr_old, wr_new, "wr32-off")
    l = check_pair(lea_old, lea_new, "store-data-off")
    if None in (r, w, l):
        return 2
    states = {r[0], w[0], l[0]}
    if states == {"NEW"}:
        print(f"OK already uasb-out-append-len-off (3 sites) in {path}")
        return 0
    if states != {"OLD"}:
        print("FAIL mixed OLD/NEW sites; refuse partial patch", file=sys.stderr)
        return 2
    if dry_run:
        print("DRY-RUN would patch 3 uasb_out_append sites:")
        print(f"  0x{FUNC_LO + (r[1]-lo):x}  mov eax,0x900000 -> mov eax,0   (rd32 OUT_LEN_OFF)")
        print(f"  0x{FUNC_LO + (l[1]-lo + len(LEA_BEFORE)):x}  lea rax,[rax+rbx]; mov rbx,rax -> lea rbx,[rax+rbx+4]")
        print(f"  0x{FUNC_LO + (w[1]-lo):x}  mov eax,0x900000 -> mov eax,0   (wr32 OUT_LEN_OFF)")
        return 0
    data[r[1] : r[1] + len(rd_old)] = rd_new
    data[w[1] : w[1] + len(wr_old)] = wr_new
    data[l[1] : l[1] + len(lea_old)] = lea_new
    path.write_bytes(data)
    print(f"PATCHED 3 uasb_out_append len/data-off sites in {path}")
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
