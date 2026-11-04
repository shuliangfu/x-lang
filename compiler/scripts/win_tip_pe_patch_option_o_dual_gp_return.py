#!/usr/bin/env python3
"""PLATFORM: WINDOWS — tip-produced core/option/option.o dual-GP return fix.

tip Soft Cap return of named 9–16B Option is rax-only (drops value@+8 / rdx).
.c79srvp caller store is dual-GP; callee must also return rdx. Patch tip-built
option.o return sites for or/and/map/and_then i32+u8. Ban Soft Cap Prefer.
Long-term: tip PE return/load_var dual-GP inject then tip-rebuild option.o.
"""
from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path


def text_raw(data: bytes) -> int:
    nsections = struct.unpack_from("<H", data, 2)[0]
    opthdr = struct.unpack_from("<H", data, 16)[0]
    sec_off = 20 + opthdr
    for i in range(nsections):
        o = sec_off + i * 40
        name = data[o : o + 8].split(b"\0")[0]
        if name == b".text":
            return struct.unpack_from("<I", data, o + 20)[0]
    raise SystemExit("no .text")


def patch(data, traw, off, old, new, label):
    a = traw + off
    cur = bytes(data[a : a + len(old)])
    if cur != old:
        raise SystemExit(f"{label}: got {cur.hex()} want {old.hex()}")
    assert len(old) == len(new)
    data[a : a + len(new)] = new
    print("OK", label)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("obj")
    args = ap.parse_args()
    p = Path(args.obj)
    data = bytearray(p.read_bytes())
    traw = text_raw(data)
    patch(data, traw, 0x1EF, bytes.fromhex("488b45e0e90e000000e900000000488b45c8e900000000"), bytes.fromhex("488b45e0488b55e8eb0d90909090488b45c8488b55d090"), "or_i32")
    patch(data, traw, 0x272, bytes.fromhex("488b45c8e92c000000e900000000"), bytes.fromhex("488b45c8488b55d0e92800000090"), "and_i32 some")
    patch(data, traw, 0x29E, bytes.fromhex("488b45b0e900000000"), bytes.fromhex("488b45b0488b55b890"), "and_i32 none")
    patch(data, traw, 0x4AF, bytes.fromhex("488b45e0e90e000000e900000000488b45c8e900000000"), bytes.fromhex("488b45e0488b55e8eb0d90909090488b45c8488b55d090"), "or_u8")
    patch(data, traw, 0x532, bytes.fromhex("488b45c8e92c000000e900000000"), bytes.fromhex("488b45c8488b55d0e92800000090"), "and_u8 some")
    patch(data, traw, 0x55E, bytes.fromhex("488b45b0e900000000"), bytes.fromhex("488b45b0488b55b890"), "and_u8 none")
    patch(data, traw, 0x692, bytes.fromhex("488b45c0e92c000000e900000000"), bytes.fromhex("488b45c0488b55c8e92800000090"), "map_i32 some")
    patch(data, traw, 0x6BE, bytes.fromhex("488b45c0e900000000"), bytes.fromhex("488b45c0488b55c890"), "map_i32 none")
    patch(data, traw, 0x755, bytes.fromhex("488b45c0e92c000000e900000000"), bytes.fromhex("488b45c0488b55c8e92800000090"), "map_u8 some")
    patch(data, traw, 0x781, bytes.fromhex("488b45c0e900000000"), bytes.fromhex("488b45c0488b55c890"), "map_u8 none")
    patch(data, traw, 0x7F6, bytes.fromhex("488b45c8e92c000000e900000000"), bytes.fromhex("488b45c8488b55d0e92800000090"), "and_then some")
    patch(data, traw, 0x822, bytes.fromhex("488b45b0e900000000"), bytes.fromhex("488b45b0488b55b890"), "and_then none")
    p.write_bytes(data)
    print("patched", p)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
