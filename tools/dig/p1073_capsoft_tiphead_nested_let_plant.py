"""10.73 Cap soft tiphead dig — Prefer-M2 SoftCap nested_let assign first-seen map.

Base: Cap soft tiphead dig identity a1491a74c08b (DIG3h SoftCap-green lineage).
Patch enc_store CLAMP18 fixed mov ebx,0x18 → tramp that maps each torn |off|
to a stable first-seen home 0x18, 0x20, … so assign re-store of the same local
(nested_let `y = x`) keeps the let-init home (10.72 sequential counter remapped
every clamp and broke nested_let).

Soft Cap PROD/cave 74d0bd9c9fbf + tiphead Prefer-M2 9ecd HOLD — never write.
Output lab_CapSoftWin_tiphead_*_P1073_*.exe sha != a1491a74c08b != 1e59c5261663.
"""
from __future__ import annotations

import hashlib
import shutil
import struct
from pathlib import Path

DIGDIR = Path(r"C:\xlang_tmp\p1060\g05th_dig")
SRC = DIGDIR / "lab_CapSoftWin_tiphead_P1071_dig_identity_a1491a74c08b.exe"
OUT = DIGDIR / "lab_CapSoftWin_tiphead_P1073_nested_let_fsmap.exe"
PROD = Path(r"C:\xlang_tmp\prod_softcap\lab_SoftCap_76795.exe")
CAVE = Path(r"C:\xlang_tmp\p1060\cave\lab_SoftCap_76795.exe")
TIP = Path(r"C:\xlang_tmp\p1060\cave\lab_CapSoftWin_tiphead.exe")

EXPECT_SRC = "a1491a74c08b"
EXPECT_PROD = "74d0bd9c9fbf"
EXPECT_TIP = "9ecd26ea44ab"
CLAMP_SIG = bytes.fromhex("483d001000007608bb18000000")
BANNED = {
    "a1491a74c08b",
    "1e59c5261663",
    "74d0bd9c9fbf",
    "9ecd26ea44ab",
    "07eadd3fe8bf",
    "d8e2d409a140",
    "ae663019bacc",
}

MAP_CAP = 16  # max first-seen entries


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
    assert sha12(PROD) == EXPECT_PROD, sha12(PROD)
    assert sha12(CAVE) == EXPECT_PROD, sha12(CAVE)
    assert sha12(TIP) == EXPECT_TIP, sha12(TIP)

    data = bytearray(SRC.read_bytes())
    pe = parse_pe(data)
    ib = pe["ib"]

    i = data.find(CLAMP_SIG)
    assert i > 0 and data.find(CLAMP_SIG, i + 1) < 0, "need exactly one CLAMP_SIG"
    body0 = i - 16
    mov_off = i + 8
    assert data[mov_off : mov_off + 5] == bytes.fromhex("bb18000000")
    mov_va = va_of_file(pe, mov_off)
    cont_va = mov_va + 5  # movsxd rbx, ebx …

    # .data map blob: n:u32, next_home:u32(=0x18), map[16]{key:u32,home:u32}
    dsec = next(s for s in pe["secs"] if s["name"] == ".data")
    map_bytes = 8 + MAP_CAP * 8  # 136
    assert dsec["rsz"] - dsec["vsz"] >= map_bytes, (dsec["rsz"] - dsec["vsz"], map_bytes)
    map_file = dsec["rdo"] + dsec["vsz"]
    assert data[map_file : map_file + map_bytes] == b"\x00" * map_bytes
    n_rva = dsec["sva"] + dsec["vsz"]
    next_rva = n_rva + 4
    ents_rva = n_rva + 8
    n_va = ib + n_rva
    next_va = ib + next_rva
    ents_va = ib + ents_rva

    # Init next_home = 0x18 (n=0, keys zero)
    struct.pack_into("<I", data, map_file + 4, 0x18)

    tramp_off = body0 + 48
    assert data[tramp_off : tramp_off + 160] == b"\x00" * 160
    tramp_va = va_of_file(pe, tramp_off)

    # Tramp (entry: eax=abs(off), ebx still original low32 unused as key — use eax):
    #   mov ecx, eax                  ; key = abs
    #   mov edx, [rip+n]
    #   lea r8, [rip+ents]
    #   xor r9d, r9d
    # search:
    #   cmp r9d, edx
    #   jge insert
    #   cmp dword [r8+r9*8], ecx
    #   je found
    #   inc r9d
    #   jmp search
    # found:
    #   mov ebx, [r8+r9*8+4]
    #   jmp cont
    # insert:
    #   cmp edx, MAP_CAP
    #   jge fallback
    #   mov [r8+rdx*8], ecx
    #   mov ebx, [rip+next]
    #   mov [r8+rdx*8+4], ebx
    #   add dword [rip+next], 8
    #   inc dword [rip+n]
    #   jmp cont
    # fallback:
    #   mov ebx, 0x18
    #   jmp cont
    tramp = bytearray()

    def here() -> int:
        return tramp_va + len(tramp)

    tramp += b"\x89\xc1"  # mov ecx, eax
    # mov edx, [rip+n]
    tramp += b"\x8b\x15" + rip_rel(n_va, here(), 6)
    # lea r8, [rip+ents]
    tramp += b"\x4c\x8d\x05" + rip_rel(ents_va, here(), 7)
    tramp += b"\x45\x31\xc9"  # xor r9d, r9d
    search = here()
    tramp += b"\x41\x39\xd1"  # cmp r9d, edx
    jge_ins_at = len(tramp)
    tramp += b"\x7d\x00"  # jge insert (patch)
    tramp += b"\x43\x39\x0c\xc8"  # cmp [r8+r9*8], ecx
    je_found_at = len(tramp)
    tramp += b"\x74\x00"  # je found
    tramp += b"\x41\xff\xc1"  # inc r9d
    jmp_search_at = len(tramp)
    tramp += b"\xeb\x00"  # jmp search
    found = here()
    tramp[je_found_at + 1] = found - (tramp_va + je_found_at + 2) & 0xFF
    tramp += b"\x43\x8b\x5c\xc8\x04"  # mov ebx, [r8+r9*8+4] REX.XB
    jmp_cont_found_at = len(tramp)
    tramp += b"\xe9\x00\x00\x00\x00"  # jmp cont
    insert = here()
    tramp[jge_ins_at + 1] = insert - (tramp_va + jge_ins_at + 2) & 0xFF
    # patch jmp search
    tramp[jmp_search_at + 1] = (search - (tramp_va + jmp_search_at + 2)) & 0xFF
    tramp += b"\x83\xfa" + bytes([MAP_CAP])  # cmp edx, MAP_CAP
    jge_fb_at = len(tramp)
    tramp += b"\x7d\x00"  # jge fallback
    tramp += b"\x41\x89\x0c\xd0"  # mov [r8+rdx*8], ecx
    tramp += b"\x8b\x1d" + rip_rel(next_va, here(), 6)  # mov ebx, [rip+next]
    tramp += b"\x41\x89\x5c\xd0\x04"  # mov [r8+rdx*8+4], ebx
    tramp += b"\x83\x05" + rip_rel(next_va, here(), 7) + b"\x08"  # add [next],8
    tramp += b"\xff\x05" + rip_rel(n_va, here(), 6)  # inc [n]
    jmp_cont_ins_at = len(tramp)
    tramp += b"\xe9\x00\x00\x00\x00"
    fallback = here()
    tramp[jge_fb_at + 1] = fallback - (tramp_va + jge_fb_at + 2) & 0xFF
    tramp += b"\xbb\x18\x00\x00\x00"  # mov ebx, 0x18
    jmp_cont_fb_at = len(tramp)
    tramp += b"\xe9\x00\x00\x00\x00"

    for at in (jmp_cont_found_at, jmp_cont_ins_at, jmp_cont_fb_at):
        struct.pack_into("<i", tramp, at + 1, cont_va - (tramp_va + at + 5))

    assert len(tramp) <= 160, len(tramp)
    data[tramp_off : tramp_off + len(tramp)] = tramp

    # Replace mov ebx,0x18 with jmp tramp
    rel = tramp_va - (mov_va + 5)
    data[mov_off] = 0xE9
    struct.pack_into("<i", data, mov_off + 1, rel)

    new_vsz = dsec["vsz"] + map_bytes
    struct.pack_into("<I", data, dsec["o"] + 8, new_vsz)

    h = sha12(data)
    assert h not in BANNED, h
    assert h != EXPECT_SRC
    OUT.write_bytes(data)
    tagged = DIGDIR / f"lab_CapSoftWin_tiphead_P1073_nested_let_fsmap_{h}.exe"
    shutil.copy2(OUT, tagged)

    assert sha12(PROD) == EXPECT_PROD
    assert sha12(CAVE) == EXPECT_PROD
    assert sha12(TIP) == EXPECT_TIP
    assert sha12(SRC) == EXPECT_SRC

    print("PLANTED", tagged)
    print("SHA", h)
    print("SIZE", tagged.stat().st_size)
    print("tramp_len", len(tramp), "tramp", tramp.hex())
    print("map_rva", hex(n_rva), "new_data_vsz", hex(new_vsz))
    print("HOLD_OK PROD", EXPECT_PROD, "TIP", EXPECT_TIP, "A149", EXPECT_SRC)


if __name__ == "__main__":
    main()
