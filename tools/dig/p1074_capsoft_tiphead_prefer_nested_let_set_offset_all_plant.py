# -*- coding: utf-8 -*-
"""10.74 Cap soft tiphead dig — Prefer nested_let set_offset ALL name hits.

Base: P1074 Prefer dig 1f78def393fc (SoftCap 8/8, protect OK).
Root: fill-tree appends y@0x28 while emit_let_init/lazy store home is
ebx=y@0x20; Prefer assign (scoped/unscoped) still hits fill entry @0x28.
Prior single-hit set_offset (ed58) only rewrote last→first lazy @0x20 —
nested asm identical to 1f78. Tip.x set_offset_by_name is single-hit but
tip only writebacks on clamp when homes already cohere; dig residual needs
ALL same-name entries in this ctx written to ebx so assign cannot see 0x28.

Hook @ emit_let_init 0x140016b4b → .tpad cave → cont @ 0x140016b54.
Soft Cap 74d0 + tiphead 9ecd HOLD.
"""
from __future__ import annotations

import hashlib
import struct
import subprocess
from pathlib import Path

DIGDIR = Path(r"C:\xlang_tmp\p1060\g05th_dig")
SRC = DIGDIR / "lab_CapSoftWin_tiphead_P1074_prefer_w1521_param_home_1f78def393fc.exe"
OUT = DIGDIR / "lab_CapSoftWin_tiphead_P1074_prefer_nested_let_set_offset_all.exe"
PROD = Path(r"C:\xlang_tmp\prod_softcap\lab_SoftCap_76795.exe")
CAVE = Path(r"C:\xlang_tmp\p1060\cave\lab_SoftCap_76795.exe")
TIP = Path(r"C:\xlang_tmp\p1060\cave\lab_CapSoftWin_tiphead.exe")

EXPECT_SRC = "1f78def393fc"
EXPECT_PROD = "74d0bd9c9fbf"
EXPECT_TIP = "9ecd26ea44ab"

HOOK_VA = 0x140016B4B
CONT_VA = 0x140016B54
STEAL_LEN = 9
STEAL_HEX = "4489742420895c2428"

BANNED = {
    "1e59c5261663", "a1491a74c08b", "5dff12e7772e", "74d0bd9c9fbf",
    "9ecd26ea44ab", "1f78def393fc", "b995aaae2126", "e96f6a63596a",
    "623e3ba86574", "460444eac7a9", "5013ec743970", "9dcf964ea01a",
    "625427ca12f3", "fd7ec408609c", "e9d0ff140add", "e625fd49c2ce",
    "7872142a2558", "7864b74d2857", "7905d0ae3e81", "7ef06c5e5746",
    "9796e9644d54", "71fa8aac44f3", "ed58b661db52",
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
    sec = opt + optsz
    secs = []
    for i in range(nsec):
        o = sec + i * 40
        name = bytes(data[o : o + 8]).split(b"\0", 1)[0].decode("ascii", "replace")
        vsz, sva, rsz, rdo = struct.unpack_from("<IIII", data, o + 8)
        secs.append({"i": i, "o": o, "name": name, "sva": sva, "rdo": rdo, "rsz": rsz, "vsz": vsz})
    return {"ib": ib, "secs": secs}


def file_of_va(pe, va):
    rva = va - pe["ib"]
    for s in pe["secs"]:
        if s["sva"] <= rva < s["sva"] + s["rsz"]:
            return s["rdo"] + (rva - s["sva"])
    raise KeyError(hex(va))


def nm_abs(exe, name):
    out = subprocess.check_output(["nm", str(exe)], text=True, errors="replace")
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 3 and parts[-1] == name:
            return int(parts[0], 16)
    raise KeyError(name)


def main():
    assert sha12(SRC) == EXPECT_SRC, sha12(SRC)
    assert sha12(PROD) == EXPECT_PROD, sha12(PROD)
    assert sha12(CAVE) == EXPECT_PROD, sha12(CAVE)
    assert sha12(TIP) == EXPECT_TIP, sha12(TIP)

    data = bytearray(SRC.read_bytes())
    pe = parse_pe(data)
    ib = pe["ib"]

    hook_off = file_of_va(pe, HOOK_VA)
    assert bytes(data[hook_off : hook_off + STEAL_LEN]).hex() == STEAL_HEX
    assert data[hook_off + STEAL_LEN] == 0xE8

    find_va = nm_abs(SRC, "pipe_al_find")
    at_va = nm_abs(SRC, "pipe_al_at")
    n_va = nm_abs(SRC, "g_pipe_al_n")

    tpad = next(s for s in pe["secs"] if s["name"].startswith(".tpad"))
    free = tpad["rsz"] - tpad["vsz"]
    cave_file = tpad["rdo"] + tpad["vsz"]
    assert data[cave_file : cave_file + free] == b"\x00" * free, free
    cave_va = ib + tpad["sva"] + tpad["vsz"]

    wb = bytearray()
    patches = []
    labels = {}

    def here():
        return cave_va + len(wb)

    def emit(xs):
        wb.extend(xs)

    def emit_jcc32(opcode, label):
        at = len(wb)
        emit(opcode + b"\x00\x00\x00\x00")
        patches.append((at, "jcc32", label))

    def emit_jmp32(label):
        at = len(wb)
        emit(b"\xe9\x00\x00\x00\x00")
        patches.append((at, "jmp32", label))

    def emit_call(target_va):
        at = len(wb)
        emit(b"\xe8\x00\x00\x00\x00")
        patches.append((at, "call", target_va))

    def emit_lea_rax(target_va):
        at = len(wb)
        emit(b"\x48\x8d\x05\x00\x00\x00\x00")
        patches.append((at, "lea_rax", target_va))

    emit(b"\x44\x89\x74\x24\x20")
    emit(b"\x89\x5c\x24\x28")

    emit(b"\x83\xbc\x24\x08\x01\x00\x00\x00")
    emit_jcc32(b"\x0f\x8e", "done")
    emit(b"\x48\x83\xbc\x24\x00\x01\x00\x00\x00")
    emit_jcc32(b"\x0f\x84", "done")

    # push rbx,rax,rcx,rdx,rsi,rdi,r8,r9,r10,r11 (+0x50) + shadow 0x20 → +0x70
    # slot_off @ [rsp+0x68]; name @ [rsp+0x170]; llen @ [rsp+0x178]
    emit(b"\x53\x50\x51\x52\x56\x57\x41\x50\x41\x51\x41\x52\x41\x53")
    emit(b"\x48\x83\xec\x20")

    emit(b"\x4c\x89\xe9")
    emit(b"\x31\xd2")
    emit_call(find_va)
    emit(b"\x85\xc0")
    emit_jcc32(b"\x0f\x88", "restore")
    emit(b"\x41\x89\xc2")  # r10d = s

    emit_lea_rax(n_va)
    emit(b"\x42\x8b\x0c\x90")
    emit(b"\xff\xc9")
    emit_jcc32(b"\x0f\x88", "restore")
    emit(b"\x41\x89\xcb")  # r11d = i

    emit(b"\x48\x8b\xb4\x24\x70\x01\x00\x00")  # rsi = name

    labels["ent_loop"] = here()
    emit(b"\x44\x89\xd1")
    emit(b"\x44\x89\xda")
    emit_call(at_va)
    emit(b"\x48\x85\xc0")
    emit_jcc32(b"\x0f\x84", "cont_ent")  # null ent → continue (ALL-hit)
    emit(b"\x48\x89\xc7")

    emit(b"\x8b\x87\x00\x01\x00\x00")
    emit(b"\x3b\x84\x24\x78\x01\x00\x00")
    jne_at = len(wb)
    emit(b"\x75\x00")

    emit(b"\x31\xd2")
    labels["cmp_loop"] = here()
    emit(b"\x3b\x94\x24\x78\x01\x00\x00")
    jge_at = len(wb)
    emit(b"\x7d\x00")
    emit(b"\x0f\xb6\x04\x16")
    emit(b"\x44\x0f\xb6\x04\x17")
    emit(b"\x44\x39\xc0")
    jne2_at = len(wb)
    emit(b"\x75\x00")
    emit(b"\xff\xc2")
    emit_jmp32("cmp_loop")

    labels["match"] = here()
    rel = labels["match"] - (cave_va + jge_at + 2)
    assert -128 <= rel <= 127, rel
    wb[jge_at + 1] = rel & 0xFF
    emit(b"\x8b\x44\x24\x68")
    emit(b"\x89\x87\x04\x01\x00\x00")
    # ALL-hit: fall through to cont_ent (do NOT jmp restore)

    labels["cont_ent"] = here()
    for at in (jne_at, jne2_at):
        rel = labels["cont_ent"] - (cave_va + at + 2)
        assert -128 <= rel <= 127, (rel, at)
        wb[at + 1] = rel & 0xFF
    emit(b"\x41\xff\xcb")
    emit_jcc32(b"\x0f\x89", "ent_loop")

    labels["restore"] = here()
    emit(b"\x48\x83\xc4\x20")
    emit(b"\x41\x5b\x41\x5a\x41\x59\x41\x58\x5f\x5e\x5a\x59\x58\x5b")

    labels["done"] = here()
    emit(b"\xe9" + struct.pack("<i", CONT_VA - (here() + 5)))

    for at, kind, lab in patches:
        if kind == "jcc32":
            tgt = labels[lab]
            struct.pack_into("<i", wb, at + 2, tgt - (cave_va + at + 6))
        elif kind == "jmp32":
            tgt = labels[lab]
            struct.pack_into("<i", wb, at + 1, tgt - (cave_va + at + 5))
        elif kind == "call":
            tgt = int(lab)
            struct.pack_into("<i", wb, at + 1, tgt - (cave_va + at + 5))
        elif kind == "lea_rax":
            tgt = int(lab)
            struct.pack_into("<i", wb, at + 3, tgt - (cave_va + at + 7))

    assert len(wb) <= free, (len(wb), free)

    rel_hook = cave_va - (HOOK_VA + 5)
    data[hook_off : hook_off + 5] = b"\xe9" + struct.pack("<i", rel_hook)
    data[hook_off + 5 : hook_off + STEAL_LEN] = b"\x90" * (STEAL_LEN - 5)

    data[cave_file : cave_file + len(wb)] = wb
    struct.pack_into("<I", data, tpad["o"] + 8, tpad["vsz"] + len(wb))

    h = sha12(data)
    assert h not in BANNED, h
    assert h != EXPECT_SRC
    OUT.write_bytes(data)
    tagged = DIGDIR / f"lab_CapSoftWin_tiphead_P1074_prefer_nested_let_set_offset_all_{h}.exe"
    tagged.write_bytes(data)

    assert sha12(PROD) == EXPECT_PROD
    assert sha12(CAVE) == EXPECT_PROD
    assert sha12(TIP) == EXPECT_TIP
    assert sha12(SRC) == EXPECT_SRC

    print("PLANTED", tagged)
    print("SHA", h)
    print("wb_len", len(wb), "free", free, "cave_va", hex(cave_va))
    print("HOLD_OK PROD", EXPECT_PROD, "TIP", EXPECT_TIP, "SRC", EXPECT_SRC)


if __name__ == "__main__":
    main()
