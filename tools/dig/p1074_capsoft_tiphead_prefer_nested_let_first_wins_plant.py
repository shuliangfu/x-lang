# -*- coding: utf-8 -*-
"""10.74 Cap soft tiphead dig — nested_let first-wins find (scoped + global).

Base: P1074 Prefer dig 1f78def393fc (SoftCap 8/8, call_arg 0, protect OK).

Root cause: assign Prefer @19c050 → T scoped @28e68f; find_scoped often
MISSes for assign LHS (falls through) then asm_ctx_local_find_offset @2d163f
last-wins resolves y→0x28 shadow; loads/init keep decl home 0x20.
Scoped-only first-wins (9796e9644d54) SoftCap 8/8 but nested_let still 1 /
y_after still 7 → Prefer uses find_offset path. Plant both.

Soft Cap 74d0 + tiphead 9ecd HOLD. Dig PE != banned shas.
"""
from __future__ import annotations

import hashlib
import struct
from pathlib import Path

DIGDIR = Path(r"C:\xlang_tmp\p1060\g05th_dig")
SRC = DIGDIR / "lab_CapSoftWin_tiphead_P1074_prefer_w1521_param_home_1f78def393fc.exe"
OUT = DIGDIR / "lab_CapSoftWin_tiphead_P1074_prefer_nested_let_first_wins.exe"
PROD = Path(r"C:\xlang_tmp\prod_softcap\lab_SoftCap_76795.exe")
CAVE = Path(r"C:\xlang_tmp\p1060\cave\lab_SoftCap_76795.exe")
TIP = Path(r"C:\xlang_tmp\p1060\cave\lab_CapSoftWin_tiphead.exe")

EXPECT_SRC = "1f78def393fc"
EXPECT_PROD = "74d0bd9c9fbf"
EXPECT_TIP = "9ecd26ea44ab"

# scoped last-wins → first-wins
START_VA = 0x14023A57C
DEC_VA = 0x14023A64A
CMP_VA = 0x14023A657

# find_offset last-wins → first-wins
FIND_START_VA = 0x1402D16AC  # sub eax,1 ; mov [rbp-4],eax
FIND_FOOT_VA = 0x1402D176E  # sub [rbp-4],1 ; cmp; jns; mov eax,-1

BANNED = {
    "1e59c5261663",
    "a1491a74c08b",
    "5dff12e7772e",
    "74d0bd9c9fbf",
    "9ecd26ea44ab",
    "1f78def393fc",
    "b995aaae2126",
    "e96f6a63596a",
    "623e3ba86574",
    "460444eac7a9",
    "5013ec743970",
    "9dcf964ea01a",
    "625427ca12f3",
    "fd7ec408609c",
    "e9d0ff140add",
    "e625fd49c2ce",
    "7ef06c5e5746",
    "9796e9644d54",
}


def sha12(p: Path | bytes | bytearray) -> str:
    if isinstance(p, (bytes, bytearray)):
        return hashlib.sha256(bytes(p)).hexdigest()[:12]
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()[:12]


def parse_pe(data: bytes | bytearray) -> dict:
    e = struct.unpack_from("<I", data, 0x3C)[0]
    coff = e + 4
    nsec = struct.unpack_from("<H", data, coff + 2)[0]
    optsz = struct.unpack_from("<H", data, coff + 16)[0]
    opt = coff + 20
    assert struct.unpack_from("<H", data, opt)[0] == 0x20B
    ib = struct.unpack_from("<Q", data, opt + 24)[0]
    sec = opt + optsz
    secs = []
    for i in range(nsec):
        o = sec + i * 40
        name = bytes(data[o : o + 8]).split(b"\0", 1)[0].decode("ascii", "replace")
        vsz, sva, rsz, rdo = struct.unpack_from("<IIII", data, o + 8)
        secs.append(
            {"i": i, "o": o, "name": name, "sva": sva, "rdo": rdo, "rsz": rsz, "vsz": vsz}
        )
    return {"ib": ib, "secs": secs}


def fo(pe: dict, va: int) -> int:
    rva = va - pe["ib"]
    for s in pe["secs"]:
        if s["sva"] <= rva < s["sva"] + max(s["vsz"], s["rsz"]):
            return s["rdo"] + (rva - s["sva"])
    raise KeyError(hex(va))


def main() -> None:
    assert sha12(SRC) == EXPECT_SRC
    assert sha12(PROD) == EXPECT_PROD
    assert sha12(CAVE) == EXPECT_PROD
    assert sha12(TIP) == EXPECT_TIP

    data = bytearray(SRC.read_bytes())
    pe = parse_pe(data)

    # ---- scoped first-wins ----
    off = fo(pe, START_VA)
    assert data[off : off + 9] == bytes.fromhex("8b85c400000083e801"), data[off : off + 9].hex()
    data[off : off + 9] = bytes.fromhex("8b85b0000000909090")

    off = fo(pe, DEC_VA)
    assert data[off : off + 7] == bytes.fromhex("83adb800000001")
    data[off + 1] = 0x85

    off = fo(pe, CMP_VA)
    assert data[off : off + 12] == bytes.fromhex("3b85b00000000f8d2dffffff")
    data[off : off + 12] = bytes.fromhex("3b85c40000000f8c2dffffff")

    # ---- find_offset first-wins ----
    # start: sub eax,1; mov [rbp-4],eax → xor eax,eax; nop; mov [rbp-4],eax
    off = fo(pe, FIND_START_VA)
    assert data[off : off + 6] == bytes.fromhex("83e8018945fc"), data[off : off + 6].hex()
    data[off : off + 6] = bytes.fromhex("31c0908945fc")

    # footer 19 bytes at 2d176e:
    # add [rbp-4],1; mov ecx,[rbp-0x14]; cmp [rbp-4],ecx; jl body; or eax,-1
    off = fo(pe, FIND_FOOT_VA)
    expect = bytes.fromhex("836dfc01837dfc000f893bffffffb8ffffffff")
    assert data[off : off + 19] == expect, data[off : off + 19].hex()
    # jl @ 2d1778 → body 2d16b7; rel = 2d16b7 - 2d177e = ffffff39
    patch = bytes.fromhex("8345fc018b4dec394dfc0f8c39ffffff83c8ff")
    assert len(patch) == 19
    data[off : off + 19] = patch

    h = sha12(data)
    assert h not in BANNED, h
    OUT.write_bytes(data)
    print("OUT", OUT)
    print("sha12", h)
    print("scoped+find first-wins planted OK")


if __name__ == "__main__":
    main()
