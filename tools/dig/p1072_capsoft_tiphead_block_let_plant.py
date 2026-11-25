"""10.72 Cap soft tiphead dig — Prefer-M2 SoftCap block_let clamp non-collide plant.

Base: Cap soft tiphead dig identity a1491a74c08b (DIG3h SoftCap-green lineage).
Patch enc_store CLAMP18 fixed mov ebx,0x18 → tramp that assigns sequential
homes 0x18, 0x20, 0x28… via a .data counter so N>=2 SoftCap scalar lets
(block_let / nested_let) do not smash one slot.

Soft Cap PROD/cave 74d0bd9c9fbf + tiphead Prefer-M2 9ecd HOLD — never write.
Output lab_CapSoftWin_tiphead_*_P1072_*.exe sha != a1491a74c08b.
"""
from __future__ import annotations

import hashlib
import shutil
import struct
from pathlib import Path

DIGDIR = Path(r"C:\xlang_tmp\p1060\g05th_dig")
SRC = DIGDIR / "lab_CapSoftWin_tiphead_P1071_dig_identity_a1491a74c08b.exe"
OUT = DIGDIR / "lab_CapSoftWin_tiphead_P1072_block_let_clamp_nc.exe"
PROD = Path(r"C:\xlang_tmp\prod_softcap\lab_SoftCap_76795.exe")
CAVE = Path(r"C:\xlang_tmp\p1060\cave\lab_SoftCap_76795.exe")
TIP = Path(r"C:\xlang_tmp\p1060\cave\lab_CapSoftWin_tiphead.exe")

EXPECT_SRC = "a1491a74c08b"
EXPECT_PROD = "74d0bd9c9fbf"
EXPECT_TIP = "9ecd26ea44ab"
CLAMP_SIG = bytes.fromhex("483d001000007608bb18000000")
BANNED = {
    "a1491a74c08b",
    "74d0bd9c9fbf",
    "9ecd26ea44ab",
    "07eadd3fe8bf",
    "d8e2d409a140",
    "ae663019bacc",
}


def sha12(p: Path | bytes | bytearray) -> str:
    if isinstance(p, (bytes, bytearray)):
        return hashlib.sha256(bytes(p)).hexdigest()[:12]
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()[:12]


def parse_pe(data: bytearray | bytes) -> dict:
    e = struct.unpack_from("<I", data, 0x3C)[0]
    coff = e + 4
    nsec = struct.unpack_from("<H", data, coff + 2)[0]
    optsz = struct.unpack_from("<H", data, coff + 16)[0]
    opt = coff + 20
    assert struct.unpack_from("<H", data, opt)[0] == 0x20B
    ib = struct.unpack_from("<Q", data, opt + 24)[0]
    sa = struct.unpack_from("<I", data, opt + 32)[0]
    fa = struct.unpack_from("<I", data, opt + 36)[0]
    soi = struct.unpack_from("<I", data, opt + 56)[0]
    sec = opt + optsz
    secs = []
    for i in range(nsec):
        o = sec + i * 40
        name = bytes(data[o : o + 8]).split(b"\0", 1)[0].decode("ascii", "replace")
        vsz, sva, rsz, rdo = struct.unpack_from("<IIII", data, o + 8)
        secs.append(
            {"i": i, "o": o, "name": name, "sva": sva, "rdo": rdo, "rsz": rsz, "vsz": vsz}
        )
    return {
        "e": e,
        "coff": coff,
        "opt": opt,
        "optsz": optsz,
        "ib": ib,
        "sa": sa,
        "fa": fa,
        "soi": soi,
        "nsec": nsec,
        "secs": secs,
    }


def va_of_file(pe: dict, file_off: int) -> int:
    for s in pe["secs"]:
        if s["rdo"] <= file_off < s["rdo"] + s["rsz"]:
            return pe["ib"] + s["sva"] + (file_off - s["rdo"])
    raise KeyError(hex(file_off))


def main() -> None:
    assert sha12(SRC) == EXPECT_SRC, sha12(SRC)
    assert sha12(PROD) == EXPECT_PROD, sha12(PROD)
    assert sha12(CAVE) == EXPECT_PROD, sha12(CAVE)
    assert sha12(TIP) == EXPECT_TIP, sha12(TIP)

    data = bytearray(SRC.read_bytes())
    pe = parse_pe(data)
    ib = pe["ib"]

    i = data.find(CLAMP_SIG)
    assert i > 0 and data.find(CLAMP_SIG, i + 1) < 0, "need exactly one CLAMP_SIG"
    # dig3h body: 16 bytes before CLAMP_SIG; mov ebx,0x18 is after cmp+jbe (= +8)
    # CLAMP_SIG = cmp rax,0x1000 (6) + jbe +8 (2) + mov ebx,0x18 (5)
    body0 = i - 16
    mov_off = i + 8
    assert data[mov_off : mov_off + 5] == bytes.fromhex("bb18000000"), data[
        mov_off : mov_off + 5
    ].hex()
    body_va = va_of_file(pe, body0)
    mov_va = va_of_file(pe, mov_off)
    cont_va = mov_va + 5  # movsxd rbx, ebx …

    # Counter at end of .data vsz (within rsz zero pad); bump vsz by 8
    dsec = next(s for s in pe["secs"] if s["name"] == ".data")
    assert dsec["rsz"] - dsec["vsz"] >= 8
    ctr_file = dsec["rdo"] + dsec["vsz"]
    assert data[ctr_file : ctr_file + 8] == b"\x00" * 8
    ctr_rva = dsec["sva"] + dsec["vsz"]
    ctr_va32 = (ib + ctr_rva) & 0xFFFFFFFF  # abs32 form (image <4G low half? PE64)
    # MSVC PE64 abs addressing uses low 32 bits of VA when image base is 0x140000000
    # — actually mov ebx,[abs32] uses 32-bit absolute address; for PE64 with
    # high ib this form is the disp32 absolute in low 4GB. ImageBase+rva fits
    # in 32 bits only if ib low + rva < 4G. 0x140000000 + 0x6748b0 = 0x1406748b0
    # does NOT fit in 32 bits!
    # Use RIP-relative from tramp instead.

    # Tramp in zeros after body (body is 45 bytes)
    tramp_off = body0 + 48
    assert data[tramp_off : tramp_off + 32] == b"\x00" * 32
    tramp_va = va_of_file(pe, tramp_off)

    # RIP-rel counter from tramp: counter at .data end
    # After bump, ctr_rva = dsec.sva + old_vsz
    # Encode:
    #   mov ebx, dword [rip+disp32]     8B 1D disp32     (disp = ctr - (rip))
    #   add dword [rip+disp32], 8       83 05 disp32 08
    #   add ebx, 0x18                   83 C3 18
    #   jmp cont                        E9 rel32
    #
    # For first insn at tramp_va, rip after insn = tramp_va+6
    # For second at tramp_va+6, length 7, rip = tramp_va+13

    tramp = bytearray()
    # mov ebx, [rip+d]
    d1 = (ib + ctr_rva) - (tramp_va + 6)
    tramp += b"\x8b\x1d" + struct.pack("<i", d1)
    # add dword [rip+d], 8
    d2 = (ib + ctr_rva) - (tramp_va + 6 + 7)
    tramp += b"\x83\x05" + struct.pack("<i", d2) + b"\x08"
    # add ebx, 0x18
    tramp += b"\x83\xc3\x18"
    # jmp cont
    jmp_at = tramp_va + len(tramp)
    tramp += b"\xe9" + struct.pack("<i", cont_va - (jmp_at + 5))

    assert len(tramp) <= 32, len(tramp)
    data[tramp_off : tramp_off + len(tramp)] = tramp

    # Replace mov ebx,0x18 with jmp tramp
    rel = tramp_va - (mov_va + 5)
    data[mov_off] = 0xE9
    struct.pack_into("<i", data, mov_off + 1, rel)

    # Bump .data vsz by 8 so counter is in section virtual size
    new_vsz = dsec["vsz"] + 8
    struct.pack_into("<I", data, dsec["o"] + 8, new_vsz)

    h = sha12(data)
    assert h not in BANNED, h
    assert h != EXPECT_SRC
    OUT.write_bytes(data)
    tagged = DIGDIR / f"lab_CapSoftWin_tiphead_P1072_block_let_clamp_nc_{h}.exe"
    shutil.copy2(OUT, tagged)

    # HOLD proof
    assert sha12(PROD) == EXPECT_PROD
    assert sha12(CAVE) == EXPECT_PROD
    assert sha12(TIP) == EXPECT_TIP
    assert sha12(SRC) == EXPECT_SRC

    print("PLANTED", tagged)
    print("SHA", h)
    print("SIZE", tagged.stat().st_size)
    print("tramp", tramp.hex())
    print("ctr_rva", hex(ctr_rva), "new_data_vsz", hex(new_vsz))
    print("HOLD_OK PROD", EXPECT_PROD, "TIP", EXPECT_TIP, "A149", EXPECT_SRC)


if __name__ == "__main__":
    main()
