# -*- coding: utf-8 -*-
"""10.74 Cap soft tiphead dig — Prefer nested_let scoped-hit polarity (mainline).

Base: P1074 Prefer dig 1f78def393fc (SoftCap 8/8, call_arg 0, protect OK).

Root cause (DIG on 1f78): Prefer thin glue_var_expr_stack_off_elf_c @0x14019c050
calls T scoped, then gates with setl:
  scoped_off < 0  → return miss (skips Prefer-find)
  scoped_off >= 0 → FALL THROUGH to Prefer-find / top-level last-wins
Loads (glue_call_arg_resolve) return scoped immediately → home 0x20.
Assign store Prefer path ignores scoped hit → last-wins 0x28.
Residual: assign store -0x28 / load -0x20 → nested_let RUN1.

Plant: invert setl→setge so scoped hit returns; miss continues Prefer-find.
Soft Cap 74d0 + tiphead 9ecd HOLD. Dig PE != banned shas.
"""
from __future__ import annotations

import hashlib
import struct
from pathlib import Path

DIGDIR = Path(r"C:\xlang_tmp\p1060\g05th_dig")
SRC = DIGDIR / "lab_CapSoftWin_tiphead_P1074_prefer_w1521_param_home_1f78def393fc.exe"
OUT = DIGDIR / "lab_CapSoftWin_tiphead_P1074_prefer_nested_let_scoped_hit.exe"
PROD = Path(r"C:\xlang_tmp\prod_softcap\lab_SoftCap_76795.exe")
CAVE = Path(r"C:\xlang_tmp\p1060\cave\lab_SoftCap_76795.exe")
TIP = Path(r"C:\xlang_tmp\p1060\cave\lab_CapSoftWin_tiphead.exe")

EXPECT_SRC = "1f78def393fc"
EXPECT_PROD = "74d0bd9c9fbf"
EXPECT_TIP = "9ecd26ea44ab"

# mov eax,0; cmp ebx,eax; setl al; movzx eax,al; test eax,eax; je rel32
SIG = bytes.fromhex("b80000000039c30f9cc00fb6c085c00f84")
# Prefer stack_off VA window (thin body)
STACK_OFF_VA = 0x14019C050
STACK_OFF_END = 0x14019C9B0

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
    start = fo(pe, STACK_OFF_VA)
    end = fo(pe, STACK_OFF_END)
    window = bytes(data[start:end])
    hits = []
    i = 0
    while True:
        j = window.find(SIG, i)
        if j < 0:
            break
        hits.append(j)
        i = j + 1
    assert len(hits) == 1, hits
    setl_off = start + hits[0] + 7  # after b8..39c3 → at 0f9cc0
    assert data[setl_off : setl_off + 3] == bytes.fromhex("0f9cc0")
    data[setl_off + 1] = 0x9D  # setge al
    assert data[setl_off : setl_off + 3] == bytes.fromhex("0f9dc0")

    h = sha12(data)
    assert h not in BANNED, h
    assert h != EXPECT_SRC
    OUT.write_bytes(data)
    tagged = DIGDIR / f"lab_CapSoftWin_tiphead_P1074_prefer_nested_let_scoped_hit_{h}.exe"
    tagged.write_bytes(data)

    assert sha12(PROD) == EXPECT_PROD
    assert sha12(CAVE) == EXPECT_PROD
    assert sha12(TIP) == EXPECT_TIP
    assert sha12(SRC) == EXPECT_SRC

    print("PLANTED", tagged)
    print("SHA", h)
    print("SIZE", tagged.stat().st_size)
    print("setl_file_off", setl_off, "va", hex(pe["ib"] + (setl_off - pe["secs"][0]["rdo"] + pe["secs"][0]["sva"])))
    print("HOLD_OK PROD", EXPECT_PROD, "TIP", EXPECT_TIP, "SRC", EXPECT_SRC)


if __name__ == "__main__":
    main()
