"""10.74 Cap soft tiphead dig — Prefer + nested_let first-seen map (experimental).

Base: P1074 Prefer dig 1f78def393fc (SoftCap 8/8, call_arg 0, protect OK).
Overwrite P1072 sequential clamp tramp at .text+0x672560 with first-seen
home map (P1073 pattern, RIP-rel to .data) so assign can reuse let-init home.

Observed dig 623e (.tpad RIP-rel plant): SoftCap 8/8, call_arg 0, nested_let
still 1; block_pt/n_no_assign regress vs 1e59/1f78. Soft Cap 74d0 + tiphead
9ecd HOLD. Prefer dig PE != 5dff/a149/1e59/9ecd/74d0/1f78.
"""
from __future__ import annotations

import hashlib
import struct
from pathlib import Path

DIGDIR = Path(r"C:\xlang_tmp\p1060\g05th_dig")
SRC = DIGDIR / "lab_CapSoftWin_tiphead_P1074_prefer_w1521_param_home_1f78def393fc.exe"
OUT = DIGDIR / "lab_CapSoftWin_tiphead_P1074_prefer_nested_let_fsmap.exe"
PROD = Path(r"C:\xlang_tmp\prod_softcap\lab_SoftCap_76795.exe")
CAVE = Path(r"C:\xlang_tmp\p1060\cave\lab_SoftCap_76795.exe")
TIP = Path(r"C:\xlang_tmp\p1060\cave\lab_CapSoftWin_tiphead.exe")

EXPECT_SRC = "1f78def393fc"
EXPECT_PROD = "74d0bd9c9fbf"
EXPECT_TIP = "9ecd26ea44ab"
PLANTED_CLAMP = bytes.fromhex("483d001000007608e9")
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
}
MAP_CAP = 16


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


def va_of_file(pe: dict, file_off: int) -> int:
    for s in pe["secs"]:
        if s["rdo"] <= file_off < s["rdo"] + s["rsz"]:
            return pe["ib"] + s["sva"] + (file_off - s["rdo"])
    raise KeyError(hex(file_off))


def rip_rel(target_va: int, insn_va: int, insn_len: int) -> bytes:
    return struct.pack("<i", target_va - (insn_va + insn_len))


def main() -> None:
    assert sha12(SRC) == EXPECT_SRC, sha12(SRC)
    assert sha12(PROD) == EXPECT_PROD
    assert sha12(CAVE) == EXPECT_PROD
    assert sha12(TIP) == EXPECT_TIP

    data = bytearray(SRC.read_bytes())
    pe = parse_pe(data)
    ib = pe["ib"]

    i = data.find(PLANTED_CLAMP)
    assert i > 0 and data.find(PLANTED_CLAMP, i + 1) < 0, hex(i)
    mov_off = i + 8
    assert data[mov_off] == 0xE9
    mov_va = va_of_file(pe, mov_off)
    cont_va = mov_va + 5

    # Local cave: same slot as P1072 sequential tramp (mov_off+0x18).
    tramp_off = mov_off + 0x18
    assert tramp_off == i + 0x20
    seq = bytes.fromhex("8b1d4a1900008305431900000883c318e9d8ffffff")
    assert data[tramp_off : tramp_off + len(seq)] == seq, data[tramp_off : tramp_off + 24].hex()
    assert data[tramp_off + len(seq) : tramp_off + 160] == b"\x00" * (160 - len(seq))
    tramp_va = va_of_file(pe, tramp_off)

    dsec = next(s for s in pe["secs"] if s["name"] == ".data")
    map_bytes = 8 + MAP_CAP * 8
    assert dsec["rsz"] - dsec["vsz"] >= map_bytes
    map_file = dsec["rdo"] + dsec["vsz"]
    assert data[map_file : map_file + map_bytes] == b"\x00" * map_bytes
    n_rva = dsec["sva"] + dsec["vsz"]
    next_rva = n_rva + 4
    ents_rva = n_rva + 8
    n_va = ib + n_rva
    next_va = ib + next_rva
    ents_va = ib + ents_rva
    struct.pack_into("<I", data, map_file + 4, 0x18)

    tramp = bytearray()

    def here() -> int:
        return tramp_va + len(tramp)

    tramp += b"\x89\xc1"  # mov ecx, eax
    tramp += b"\x8b\x15" + rip_rel(n_va, here(), 6)
    tramp += b"\x4c\x8d\x05" + rip_rel(ents_va, here(), 7)
    tramp += b"\x45\x31\xc9"
    search = here()
    tramp += b"\x41\x39\xd1"
    jge_ins_at = len(tramp)
    tramp += b"\x7d\x00"
    tramp += b"\x43\x39\x0c\xc8"
    je_found_at = len(tramp)
    tramp += b"\x74\x00"
    tramp += b"\x41\xff\xc1"
    jmp_search_at = len(tramp)
    tramp += b"\xeb\x00"
    found = here()
    tramp[je_found_at + 1] = (found - (tramp_va + je_found_at + 2)) & 0xFF
    tramp += b"\x43\x8b\x5c\xc8\x04"
    jmp_cont_found_at = len(tramp)
    tramp += b"\xe9\x00\x00\x00\x00"
    insert = here()
    tramp[jge_ins_at + 1] = (insert - (tramp_va + jge_ins_at + 2)) & 0xFF
    tramp[jmp_search_at + 1] = (search - (tramp_va + jmp_search_at + 2)) & 0xFF
    tramp += b"\x83\xfa" + bytes([MAP_CAP])
    jge_fb_at = len(tramp)
    tramp += b"\x7d\x00"
    tramp += b"\x41\x89\x0c\xd0"
    tramp += b"\x8b\x1d" + rip_rel(next_va, here(), 6)
    tramp += b"\x41\x89\x5c\xd0\x04"
    tramp += b"\x83\x05" + rip_rel(next_va, here(), 7) + b"\x08"
    tramp += b"\xff\x05" + rip_rel(n_va, here(), 6)
    jmp_cont_ins_at = len(tramp)
    tramp += b"\xe9\x00\x00\x00\x00"
    fallback = here()
    tramp[jge_fb_at + 1] = (fallback - (tramp_va + jge_fb_at + 2)) & 0xFF
    tramp += b"\xbb\x18\x00\x00\x00"
    jmp_cont_fb_at = len(tramp)
    tramp += b"\xe9\x00\x00\x00\x00"
    for at in (jmp_cont_found_at, jmp_cont_ins_at, jmp_cont_fb_at):
        struct.pack_into("<i", tramp, at + 1, cont_va - (tramp_va + at + 5))
    assert len(tramp) <= 160, len(tramp)
    data[tramp_off : tramp_off + len(tramp)] = tramp

    rel = tramp_va - (mov_va + 5)
    data[mov_off] = 0xE9
    struct.pack_into("<i", data, mov_off + 1, rel)

    new_vsz = dsec["vsz"] + map_bytes
    struct.pack_into("<I", data, dsec["o"] + 8, new_vsz)

    h = sha12(data)
    assert h not in BANNED, h
    OUT.write_bytes(data)
    tagged = DIGDIR / f"lab_CapSoftWin_tiphead_P1074_prefer_nested_let_fsmap_{h}.exe"
    tagged.write_bytes(data)
    assert sha12(PROD) == EXPECT_PROD
    assert sha12(CAVE) == EXPECT_PROD
    assert sha12(TIP) == EXPECT_TIP
    print("OUT", OUT)
    print("TAGGED", tagged)
    print("SHA12", h)
    print("TRAMP_VA", hex(tramp_va), "len", len(tramp))
    print("MAP_VA", hex(n_va))
    print("HOLD SoftCap", EXPECT_PROD, "tiphead", EXPECT_TIP)
    print("P1074_NESTED_LET_FSMAP_LOCAL_OK")


if __name__ == "__main__":
    main()
