#!/usr/bin/env python3
"""Patch driver_run_asm_backend 7th-arg load: mov 0x10(%rbp)->0x40(%rbp).
Tip codegen reads rcx home instead of stack argv. PLATFORM: WINDOWS."""
import struct
import subprocess
import sys
from pathlib import Path


def patch(path: Path) -> bool:
    data = bytearray(path.read_bytes())
    if data[:2] != b"MZ":
        return False
    e = struct.unpack_from("<I", data, 0x3c)[0]
    if data[e : e + 4] != b"PE\0\0":
        return False
    image_base = struct.unpack_from("<Q", data, e + 24 + 24)[0]
    out = subprocess.check_output(["nm", str(path)], text=True, errors="replace")
    va = None
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 3 and parts[1] in ("T", "t") and parts[2] == "driver_run_asm_backend":
            va = int(parts[0], 16)
            break
    if va is None:
        print(f"{path}: symbol missing")
        return False
    rva = va - image_base
    ns = struct.unpack_from("<H", data, e + 6)[0]
    osz = struct.unpack_from("<H", data, e + 20)[0]
    so = e + 24 + osz
    fo = None
    for s in range(ns):
        off = so + s * 40
        vsz, va_s, rsz, raw = struct.unpack_from("<IIII", data, off + 8)
        if va_s <= rva < va_s + max(vsz, rsz):
            fo = raw + (rva - va_s)
            break
    if fo is None:
        print(f"{path}: rva {rva:#x} not mapped")
        return False
    site = fo + 60
    cur = bytes(data[site : site + 4])
    if cur == bytes.fromhex("488b4540"):
        print(f"{path}: argv7 already patched")
        return True
    if cur != bytes.fromhex("488b4510"):
        print(f"{path}: unexpected +60 {cur.hex()}")
        return False
    data[site + 3] = 0x40
    path.write_bytes(data)
    print(f"{path}: patched argv7")
    return True


ok = True
for a in sys.argv[1:]:
    ok = patch(Path(a)) and ok
sys.exit(0 if ok else 1)
