# -*- coding: utf-8 -*-
"""10.84 SoftCap dig-egg CONT bump-allocate distinct-homes plant."""
from __future__ import annotations
import hashlib, struct
from pathlib import Path

EXPECT = "d8e2d409a140"
HOOK = 0x140119338
CONT = 0x140119121
FIND = 0x1402b2c8f
LAZY = 0x140248bcf
PIPE_AL_FIND = 0x1402b21ab
PIPE_AL_AT = 0x1402b2727
G_PIPE_AL_N = 0x140bab440

def sha12(b):
    if isinstance(b, Path):
        b = b.read_bytes()
    return hashlib.sha256(bytes(b)).hexdigest()[:12]

def parse_pe(data):
    e = struct.unpack_from("<I", data, 0x3C)[0]
    coff = e + 4
    nsec = struct.unpack_from("<H", data, coff + 2)[0]
    optsz = struct.unpack_from("<H", data, coff + 16)[0]
    opt = coff + 20
    ib = struct.unpack_from("<Q", data, opt + 24)[0]
    sa = struct.unpack_from("<I", data, opt + 32)[0]
    fa = struct.unpack_from("<I", data, opt + 36)[0]
    soi = struct.unpack_from("<I", data, opt + 56)[0]
    soh = struct.unpack_from("<I", data, opt + 60)[0]
    sec = opt + optsz
    secs = []
    for i in range(nsec):
        o = sec + i * 40
        name = bytes(data[o:o + 8]).split(b"\0", 1)[0].decode()
        vsz, sva, rsz, rdo = struct.unpack_from("<IIII", data, o + 8)
        secs.append(dict(i=i, o=o, name=name, sva=sva, rdo=rdo, rsz=rsz, vsz=vsz))
    return dict(e=e, coff=coff, opt=opt, optsz=optsz, ib=ib, sa=sa, fa=fa, soi=soi, soh=soh, nsec=nsec, secs=secs)

def va_off(pe, va):
    rva = va - pe["ib"]
    for s in pe["secs"]:
        if s["sva"] <= rva < s["sva"] + max(s["vsz"], s["rsz"]):
            return s["rdo"] + (rva - s["sva"])
    raise KeyError(hex(va))

def rel32(frm, to):
    return to - frm

def main():
    src = Path(r"C:/xlang_tmp/p1060/g05th_dig/lab_CapSoftWin_tiphead_P1065_dig5fwd_clamp18.exe")
    data = bytearray(src.read_bytes())
    assert sha12(data) == EXPECT
    pe = parse_pe(data)
    vsz = 0x600
    new_sva = pe["soi"]
    new_rsz = ((vsz + pe["fa"] - 1) // pe["fa"]) * pe["fa"]
    new_rdo = (len(data) + pe["fa"] - 1) // pe["fa"] * pe["fa"]
    if new_rdo > len(data):
        data.extend(b"\x00" * (new_rdo - len(data)))
    data.extend(b"\x00" * new_rsz)
    sh = pe["opt"] + pe["optsz"] + pe["nsec"] * 40
    data[sh:sh + 8] = b".tpad\0\0\0"
    # IMAGE_SCN_MEM_READ|WRITE|EXECUTE|CNT_CODE
    struct.pack_into("<IIIIIIHHI", data, sh + 8, vsz, new_sva, new_rsz, new_rdo, 0, 0, 0, 0, 0xE0000060)
    struct.pack_into("<H", data, pe["coff"] + 2, pe["nsec"] + 1)
    new_soi = ((new_sva + vsz + pe["sa"] - 1) // pe["sa"]) * pe["sa"]
    struct.pack_into("<I", data, pe["opt"] + 56, new_soi)
    pe = parse_pe(data)
    base = pe["ib"] + new_sva
    counter_va = base + 0x500
    prefer_va = base
    cont_va = base + 0x80

    # prefer ensure
    tramp = bytearray()
    patches = []
    labels = {}
    def H():
        return prefer_va + len(tramp)
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
    E(b"\x85\xc0"); J8(b"\x79", "got")
    E(b"\x4c\x8b\x94\x24\x00\x01\x00\x00")
    E(b"\x44\x8b\x9c\x24\x08\x01\x00\x00")
    E(b"\x48\x83\xec\x30")
    E(b"\x4c\x89\x54\x24\x20"); E(b"\x44\x89\x5c\x24\x28")
    E(b"\x48\x89\xd9"); E(b"\x4c\x89\xea"); E(b"\x41\x89\xf0"); E(b"\x41\x89\xf9")
    CALL(LAZY)
    E(b"\x44\x8b\x44\x24\x28"); E(b"\x48\x8b\x54\x24\x20"); E(b"\x4c\x89\xe9")
    CALL(FIND)
    E(b"\x48\x83\xc4\x30")
    labels["got"] = H()
    E(b"\x85\xc0"); E(b"\x0f\x49\xe8")
    E(b"\xe9" + struct.pack("<i", rel32(H() + 5, cont_va)))
    for at, k, lab in patches:
        if k == "call":
            struct.pack_into("<i", tramp, at + 1, lab - (prefer_va + at + 5))
        elif k == "jcc8":
            tramp[at + 1] = (labels[lab] - (prefer_va + at + 2)) & 0xFF
    prefer = bytes(tramp)
    assert len(prefer) <= 0x80, len(prefer)

    # CONT bump tramp
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
    E(b"\x3d\x00\x10\x00\x00"); J8(b"\x77", "do_bump")
    E(b"\x83\xfd\x18"); J8(b"\x75", "after")
    labels["do_bump"] = H()
    at = len(tramp); E(b"\x8b\x05" + struct.pack("<i", 0)); patches.append((at, "rip_abs", counter_va))
    E(b"\x8d\x2c\xc5\x18\x00\x00\x00")
    at = len(tramp); E(b"\xff\x05" + struct.pack("<i", 0)); patches.append((at, "rip_abs", counter_va))
    labels["after"] = H()

    E(b"\x83\xbc\x24\x08\x01\x00\x00\x00"); J32(b"\x0f\x8e", "done")
    E(b"\x48\x83\xbc\x24\x00\x01\x00\x00\x00"); J32(b"\x0f\x84", "done")
    E(b"\x50\x51\x52\x56\x57\x41\x50\x41\x51\x41\x52\x41\x53")
    E(b"\x48\x83\xec\x20"); E(b"\x89\x6c\x24\x18")
    E(b"\x4c\x89\xe9"); E(b"\x31\xd2"); CALL(PIPE_AL_FIND)
    E(b"\x85\xc0"); J32(b"\x0f\x88", "wb_restore")
    E(b"\x41\x89\xc2")
    at = len(tramp); E(b"\x48\x8d\x05" + struct.pack("<i", 0)); patches.append((at, "lea_rax", G_PIPE_AL_N))
    E(b"\x42\x8b\x0c\x90"); E(b"\xff\xc9"); J32(b"\x0f\x88", "wb_restore")
    E(b"\x41\x89\xcb")
    E(b"\x48\x8b\xb4\x24\x68\x01\x00\x00")
    E(b"\x44\x8b\x8c\x24\x70\x01\x00\x00")
    labels["ent_loop"] = H()
    E(b"\x44\x89\xd1"); E(b"\x44\x89\xda"); CALL(PIPE_AL_AT)
    E(b"\x48\x85\xc0"); J32(b"\x0f\x84", "wb_restore")
    E(b"\x49\x89\xc0")
    E(b"\x41\x8b\x80\x00\x01\x00\x00"); E(b"\x44\x39\xc8"); J8(b"\x75", "cont_ent")
    E(b"\x31\xd2")
    labels["cmp_loop"] = H()
    E(b"\x44\x39\xca"); J8(b"\x7d", "match")
    E(b"\x0f\xb6\x04\x16"); E(b"\x41\x0f\xb6\x0c\x10"); E(b"\x39\xc8"); J8(b"\x75", "cont_ent")
    E(b"\xff\xc2"); JMP("cmp_loop")
    labels["match"] = H()
    E(b"\x8b\x44\x24\x18"); E(b"\x41\x89\x80\x04\x01\x00\x00"); JMP("wb_restore")
    labels["cont_ent"] = H()
    E(b"\x41\xff\xcb"); J32(b"\x0f\x89", "ent_loop")
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
    cont = bytes(tramp)
    print("prefer", len(prefer), "cont", len(cont))
    assert 0x80 + len(cont) < 0x500

    off = va_off(pe, base)
    data[off:off + len(prefer)] = prefer
    data[off + 0x80:off + 0x80 + len(cont)] = cont
    data[off + 0x80 + len(cont):off + 0x80 + len(cont) + 9] = b"P1084bump\0"

    off_h = va_off(pe, HOOK)
    assert bytes(data[off_h:off_h + 10]) == bytes.fromhex("85c00f49e8e9dffdffff")
    data[off_h:off_h + 10] = b"\xe9" + struct.pack("<i", prefer_va - (HOOK + 5)) + b"\x90" * 5
    off_c = va_off(pe, CONT)
    assert bytes(data[off_c:off_c + 5]) == bytes.fromhex("44897c2438")
    data[off_c:off_c + 5] = b"\xe9" + struct.pack("<i", cont_va - (CONT + 5))

    h = sha12(data)
    banned = {EXPECT, "74d0bd9c9fbf", "9ecd26ea44ab", "a9a1446ef579", "c087ce7e69ac", "e24f56c34394", "1f78def393fc"}
    assert h not in banned, h
    prod = sha12(Path(r"C:/xlang_tmp/prod_softcap/lab_SoftCap_76795.exe"))
    tip = sha12(Path(r"C:/xlang_tmp/p1060/cave/lab_CapSoftWin_tiphead.exe"))
    assert prod == "74d0bd9c9fbf" and tip == "9ecd26ea44ab"
    out = Path(r"C:/xlang_tmp/p1060/g05th_dig") / f"lab_SoftCap_d8e2_preferM2_distinct_homes_P1084_BUMP_{h}.exe"
    out.write_bytes(data)
    print("PLANTED", out)
    print("SHA", h)
    print("SIZE", len(data))
    print("HOLD_OK", prod, tip)

if __name__ == "__main__":
    main()
