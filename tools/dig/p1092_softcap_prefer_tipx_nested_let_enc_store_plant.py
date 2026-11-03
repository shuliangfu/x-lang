# -*- coding: utf-8 -*-
"""10.92 Soft Cap Prefer tip.x Prefer-M2 nested_let — Cont bump + Prefer writeback
+ glue_store edx slot_off thread onto Soft Cap Prefer tip.x call_arg plant 3f6ad.

Soft Cap Prefer dig tip PE already has Prefer-ensure HOOK→.tpad (same Prefer tramp
head as A2) but CONT/GLUE still Soft Cap egg originals → nested_let/n_no_assign run=1.
A2 plant bd9406 greens nested_let via Cont bump + GLUE mov edx,[rbp+0x30].
Plant Cont tramp into new .tpa2 on Soft Cap Prefer tip.x call_arg plant 3f6ad
(keeps win_param_home .tpph / call_arg ACCEPT); do NOT raise Soft Cap PROD.

Distinct from block_pt (10.89 HOLD) and call_arg (10.91 ACCEPT).
"""
from __future__ import annotations
import hashlib, struct
from pathlib import Path

DIGDIR = Path(r"C:\xlang_tmp\p1060\g05th_dig")
SRC = DIGDIR / "lab_SoftCap_d8e2_preferM2_SoftCapPrefer_tipx_call_arg_P1091_3f6ad9910c48.exe"
OUT = DIGDIR / "lab_SoftCap_d8e2_preferM2_SoftCapPrefer_tipx_nested_let_P1092.exe"
PROD = Path(r"C:\xlang_tmp\prod_softcap\lab_SoftCap_76795.exe")
CAVE = Path(r"C:\xlang_tmp\p1060\cave\lab_SoftCap_76795.exe")
TIP = Path(r"C:\xlang_tmp\p1060\cave\lab_CapSoftWin_tiphead.exe")

EXPECT_SRC = "3f6ad9910c48"
EXPECT_PROD = "74d0bd9c9fbf"
EXPECT_TIP = "9ecd26ea44ab"

HOOK = 0x140119338
CONT = 0x140119121
FIND = 0x1402b2c8f
LAZY = 0x140248bcf
PIPE_AL_FIND = 0x1402b21ab
PIPE_AL_AT = 0x1402b2727
G_PIPE_AL_N = 0x140bab440
GLUE_EDX = 0x14013886b
GLUE_EDX_EXPECT = bytes.fromhex("488b85c0fbffff4889c2")
CONT_EXPECT = bytes.fromhex("44897c2438")

BANNED = {
    "3f6ad9910c48", "bd9406ca693a", "b5ea4c985936", "e24f56c34394",
    "74d0bd9c9fbf", "9ecd26ea44ab", "4560ab6f1c69", "d8e2d409a140",
    "07eadd3fe8bf", "2df3fd7ee973", "1f78def393fc", "a1491a74c08b",
}


def sha12(p):
    if isinstance(p, (bytes, bytearray)):
        return hashlib.sha256(bytes(p)).hexdigest()[:12]
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()[:12]


def parse_pe(data):
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
    soh = struct.unpack_from("<I", data, opt + 60)[0]
    sec = opt + optsz
    secs = []
    for i in range(nsec):
        o = sec + i * 40
        name = bytes(data[o : o + 8]).split(b"\0", 1)[0].decode("ascii", "replace")
        vsz, sva, rsz, rdo = struct.unpack_from("<IIII", data, o + 8)
        secs.append({"i": i, "o": o, "name": name, "sva": sva, "rdo": rdo, "rsz": rsz, "vsz": vsz})
    return {"e": e, "coff": coff, "opt": opt, "optsz": optsz, "ib": ib, "sa": sa, "fa": fa, "soi": soi, "soh": soh, "nsec": nsec, "secs": secs}


def va_off(pe, va):
    rva = va - pe["ib"]
    for s in pe["secs"]:
        if s["sva"] <= rva < s["sva"] + max(s["vsz"], s["rsz"]):
            return s["rdo"] + (rva - s["sva"])
    raise KeyError(hex(va))


def rel32(frm, to):
    return to - frm


def append_sec(data, pe, need, name=b".tpa2"):
    hdr_used = pe["opt"] + pe["optsz"] + pe["nsec"] * 40
    assert pe["soh"] - hdr_used >= 40, (pe["soh"], hdr_used)
    fa = pe["fa"]
    new_sva = (pe["soi"] + pe["sa"] - 1) // pe["sa"] * pe["sa"]
    new_rsz = (need + fa - 1) // fa * fa
    if len(data) % fa:
        data.extend(b"\0" * (fa - (len(data) % fa)))
    new_rdo = len(data)
    data.extend(b"\0" * new_rsz)
    sh = pe["opt"] + pe["optsz"] + pe["nsec"] * 40
    nm = (name + b"\0\0\0\0\0\0\0\0")[:8]
    data[sh : sh + 8] = nm
    # CODE|EXECUTE|READ|WRITE — Cont tramp must be executable (A2 .tpad style)
    struct.pack_into("<IIIIIIHHI", data, sh + 8, need, new_sva, new_rsz, new_rdo, 0, 0, 0, 0, 0xE0000060)
    struct.pack_into("<H", data, pe["coff"] + 2, pe["nsec"] + 1)
    new_soi = new_sva + ((need + pe["sa"] - 1) // pe["sa"] * pe["sa"])
    struct.pack_into("<I", data, pe["opt"] + 56, new_soi)
    assert len(data) == new_rdo + new_rsz, (len(data), new_rdo, new_rsz)
    pe = parse_pe(data)
    return data, pe, pe["ib"] + new_sva


def build_cont(cont_va: int, counter_va: int) -> bytes:
    tramp = bytearray()
    patches = []
    labels = {}

    def H():
        return cont_va + len(tramp)

    def E(xs):
        tramp.extend(xs)

    def CALL(t):
        at = len(tramp)
        E(b"\xe8" + struct.pack("<i", 0))
        patches.append((at, "call", t))

    def J8(op, lab):
        at = len(tramp)
        E(op + b"\x00")
        patches.append((at, "jcc8", lab))

    def J32(op, lab):
        at = len(tramp)
        E(op + b"\x00\x00\x00\x00")
        patches.append((at, "jcc32", lab))

    def JMP(lab):
        at = len(tramp)
        E(b"\xe9" + struct.pack("<i", 0))
        patches.append((at, "jmp32", lab))

    E(b"\x89\xe8\x99\x31\xd0\x29\xd0")
    E(b"\x3d\x00\x10\x00\x00")
    J8(b"\x77", "do_bump")
    E(b"\x83\xfd\x18")
    J8(b"\x75", "after")
    labels["do_bump"] = H()
    at = len(tramp)
    E(b"\x8b\x05" + struct.pack("<i", 0))
    patches.append((at, "rip_abs", counter_va))
    E(b"\x8d\x2c\xc5\x18\x00\x00\x00")
    at = len(tramp)
    E(b"\xff\x05" + struct.pack("<i", 0))
    patches.append((at, "rip_abs", counter_va))
    labels["after"] = H()

    E(b"\x83\xbc\x24\x08\x01\x00\x00\x00")
    J32(b"\x0f\x8e", "done")
    E(b"\x48\x83\xbc\x24\x00\x01\x00\x00\x00")
    J32(b"\x0f\x84", "done")
    E(b"\x50\x51\x52\x56\x57\x41\x50\x41\x51\x41\x52\x41\x53")
    E(b"\x48\x83\xec\x20")
    E(b"\x89\x6c\x24\x18")
    E(b"\x4c\x89\xe9")
    E(b"\x31\xd2")
    CALL(PIPE_AL_FIND)
    E(b"\x85\xc0")
    J32(b"\x0f\x88", "wb_restore")
    E(b"\x41\x89\xc2")
    at = len(tramp)
    E(b"\x48\x8d\x05" + struct.pack("<i", 0))
    patches.append((at, "lea_rax", G_PIPE_AL_N))
    E(b"\x42\x8b\x0c\x90")
    E(b"\xff\xc9")
    J32(b"\x0f\x88", "wb_restore")
    E(b"\x41\x89\xcb")
    E(b"\x48\x8b\xb4\x24\x68\x01\x00\x00")
    E(b"\x44\x8b\x8c\x24\x70\x01\x00\x00")
    labels["ent_loop"] = H()
    E(b"\x44\x89\xd1")
    E(b"\x44\x89\xda")
    CALL(PIPE_AL_AT)
    E(b"\x48\x85\xc0")
    J32(b"\x0f\x84", "wb_restore")
    E(b"\x49\x89\xc0")
    E(b"\x41\x8b\x80\x00\x01\x00\x00")
    E(b"\x44\x39\xc8")
    J8(b"\x75", "cont_ent")
    E(b"\x31\xd2")
    labels["cmp_loop"] = H()
    E(b"\x44\x39\xca")
    J8(b"\x7d", "match")
    E(b"\x0f\xb6\x04\x16")
    E(b"\x41\x0f\xb6\x0c\x10")
    E(b"\x39\xc8")
    J8(b"\x75", "cont_ent")
    E(b"\xff\xc2")
    JMP("cmp_loop")
    labels["match"] = H()
    E(b"\x8b\x44\x24\x18")
    E(b"\x41\x89\x80\x04\x01\x00\x00")
    JMP("wb_restore")
    labels["cont_ent"] = H()
    E(b"\x41\xff\xcb")
    J32(b"\x0f\x89", "ent_loop")
    labels["wb_restore"] = H()
    E(b"\x48\x83\xc4\x20")
    E(b"\x41\x5b\x41\x5a\x41\x59\x41\x58\x5f\x5e\x5a\x59\x58")
    labels["done"] = H()
    E(b"\x44\x89\x7c\x24\x38")
    E(b"\xe9" + struct.pack("<i", rel32(H() + 5, CONT + 5)))

    for at, k, lab in patches:
        if k == "call":
            struct.pack_into("<i", tramp, at + 1, lab - (cont_va + at + 5))
        elif k == "lea_rax":
            struct.pack_into("<i", tramp, at + 3, lab - (cont_va + at + 7))
        elif k == "rip_abs":
            struct.pack_into("<i", tramp, at + 2, lab - (cont_va + at + 6))
        elif k == "jcc8":
            r = labels[lab] - (cont_va + at + 2)
            assert -128 <= r <= 127, (lab, r)
            tramp[at + 1] = r & 0xFF
        elif k == "jcc32":
            struct.pack_into("<i", tramp, at + 2, labels[lab] - (cont_va + at + 6))
        elif k == "jmp32":
            struct.pack_into("<i", tramp, at + 1, labels[lab] - (cont_va + at + 5))
    return bytes(tramp)


def main() -> None:
    assert sha12(SRC) == EXPECT_SRC, sha12(SRC)
    assert sha12(PROD) == EXPECT_PROD
    assert sha12(CAVE) == EXPECT_PROD
    assert sha12(TIP) == EXPECT_TIP

    data = bytearray(SRC.read_bytes())
    pe = parse_pe(data)
    # Soft Cap Prefer tip.x plant must still have egg CONT/GLUE originals
    off_c = va_off(pe, CONT)
    assert bytes(data[off_c : off_c + 5]) == CONT_EXPECT, bytes(data[off_c : off_c + 5]).hex()
    off_g = va_off(pe, GLUE_EDX)
    assert bytes(data[off_g : off_g + 10]) == GLUE_EDX_EXPECT, bytes(data[off_g : off_g + 10]).hex()
    # HOOK already Prefer-ensure on Soft Cap Prefer .tpad
    off_h = va_off(pe, HOOK)
    assert data[off_h] == 0xE9, data[off_h]

    need = 0x600
    data, pe, base = append_sec(data, pe, need, name=b".tpa2")
    cont_va = base
    counter_va = base + 0x500
    cont = build_cont(cont_va, counter_va)
    assert len(cont) < 0x500, len(cont)
    base_off = va_off(pe, base)
    data[base_off : base_off + len(cont)] = cont
    tag = b"P1092SCenc\0"; data[base_off + len(cont) : base_off + len(cont) + len(tag)] = tag

    data[off_c : off_c + 5] = b"\xe9" + struct.pack("<i", cont_va - (CONT + 5))
    data[off_g : off_g + 10] = bytes.fromhex("8b953000000090909090")

    h = sha12(data)
    assert h not in BANNED, h
    assert sha12(PROD) == EXPECT_PROD
    assert sha12(TIP) == EXPECT_TIP
    while len(data) % pe["fa"]:
        data.append(0)
    OUT.write_bytes(data)
    tagged = DIGDIR / f"lab_SoftCap_d8e2_preferM2_SoftCapPrefer_tipx_nested_let_P1092_{h}.exe"
    tagged.write_bytes(data)
    assert tagged.stat().st_size == len(data), (tagged.stat().st_size, len(data))
    pe2 = parse_pe(data)
    assert data[va_off(pe2, CONT)] == 0xE9
    assert bytes(data[va_off(pe2, GLUE_EDX) : va_off(pe2, GLUE_EDX) + 10]) == bytes.fromhex(
        "8b953000000090909090"
    )
    print("OUT", OUT)
    print("TAGGED", tagged)
    print("SHA12", h)
    print("CONT_VA", hex(cont_va))
    print("HOLD SoftCap", EXPECT_PROD, "tiphead", EXPECT_TIP, "SRC", EXPECT_SRC)
    print("P1092_SOFTCAP_PREFER_NESTED_LET_PLANT_OK")


if __name__ == "__main__":
    main()
