#!/usr/bin/env python3
"""PLATFORM: WINDOWS tip PE only — knife 11.71.

Restore parser_asm_copy_slice_to_name64_at_end_buf subtract:
  tip @0x1405c1cec was a bare E9 to start-pos *_buf_c @0x1405c1b68,
  dropping `start = end_pos - nlen` (Prefer-M2 / pthin_lex_skip.x note).
  named_type_x then init_named the bytes AFTER the IDENT (')'/space).

Stub @0x140647fb0: movsxd rax,r9d; sub r8,rax; jmp body.
No Soft Cap mix; does not touch 11.67 wrap.
"""
from __future__ import annotations

import argparse
import hashlib
import struct
import sys
from pathlib import Path

AT_END = 0x1405C1CEC
BODY = 0x1405C1B68
STUB_VA = 0x140647FB0


def pe_meta(data: bytes):
    e = struct.unpack_from("<I", data, 0x3C)[0]
    img = struct.unpack_from("<Q", data, e + 24 + 24)[0]
    num = struct.unpack_from("<H", data, e + 6)[0]
    opt = struct.unpack_from("<H", data, e + 20)[0]
    soff = e + 24 + opt
    secs = []
    for i in range(num):
        o = soff + i * 40
        name = bytes(data[o : o + 8]).split(b"\0")[0]
        vsz, va, rsz, ro = struct.unpack_from("<IIII", data, o + 8)
        secs.append(dict(name=name, vsz=vsz, va=va, rsz=rsz, ro=ro))
    return dict(e=e, img=img, secs=secs)


def va_off(m, va: int) -> int:
    rva = va - m["img"]
    for s in m["secs"]:
        if s["va"] <= rva < s["va"] + max(s["vsz"], s["rsz"]):
            return s["ro"] + (rva - s["va"])
    raise ValueError(f"VA {hex(va)} not mapped")


def already_patched(data: bytes, m) -> bool:
    off = va_off(m, AT_END)
    if data[off] != 0xE9:
        return False
    rel = struct.unpack_from("<i", data, off + 1)[0]
    return AT_END + 5 + rel == STUB_VA


def patch(data: bytearray) -> None:
    m = pe_meta(data)
    off = va_off(m, AT_END)
    if already_patched(data, m):
        return
    # expect bare jmp to BODY
    if data[off] != 0xE9:
        raise SystemExit(f"unexpected at_end opcode {data[off]:02x}")
    rel = struct.unpack_from("<i", data, off + 1)[0]
    tgt = AT_END + 5 + rel
    if tgt != BODY and tgt != STUB_VA:
        raise SystemExit(f"unexpected at_end target {hex(tgt)}")
    so = va_off(m, STUB_VA)
    if tgt == BODY and data[so : so + 16] != b"\x00" * 16:
        raise SystemExit(f"stub cave not zero at {hex(STUB_VA)}")
    stub = bytearray(bytes.fromhex("4963c14929c0e900000000"))
    jmp_at = STUB_VA + 6
    struct.pack_into("<i", stub, 7, BODY - (jmp_at + 5))
    data[so : so + 11] = stub
    data[off] = 0xE9
    struct.pack_into("<i", data, off + 1, STUB_VA - (AT_END + 5))


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("pe", type=Path, nargs="?", default=Path("compiler/xlang_asm.exe"))
    ap.add_argument("--check", action="store_true")
    args = ap.parse_args()
    raw = args.pe.read_bytes()
    m = pe_meta(raw)
    if args.check:
        ok = already_patched(raw, m)
        print("patched" if ok else "unpatched", hashlib.sha256(raw).hexdigest()[:12])
        return 0 if ok else 2
    data = bytearray(raw)
    pre = hashlib.sha256(raw).hexdigest()
    patch(data)
    post = hashlib.sha256(bytes(data)).hexdigest()
    if post != pre:
        args.pe.write_bytes(bytes(data))
    print(f"pre={pre[:12]} post={post[:12]} pe={args.pe}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
