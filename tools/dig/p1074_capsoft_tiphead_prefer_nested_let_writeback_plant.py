# -*- coding: utf-8 -*-
"""10.74 Cap soft tiphead dig — Prefer nested_let writeback-by-abs (mainline).

Base: P1074 Prefer dig 1f78def393fc (SoftCap 8/8, call_arg 0, protect OK).
After P1072 sequential clamp tramp assigns ebx=new_home, scan Prefer
g_pipe_al_* last→first for abs(offset)==old_abs (eax) and write ebx so
assign Prefer-find matches let-init store home (tip.x
asm_ctx_local_set_offset_by_name true-form; dig PE lacked the symbol).

BSS addresses via RIP-relative LEA (ASLR-safe; movabs preferred-base AVs).
NOT fsmap — keeps sequential homes (protect block_pt/n_no_assign vs 1e59).
Soft Cap 74d0 + tiphead 9ecd HOLD. Dig PE != banned shas.
"""
from __future__ import annotations

import hashlib
import struct
import subprocess
from pathlib import Path

DIGDIR = Path(r"C:\xlang_tmp\p1060\g05th_dig")
SRC = DIGDIR / "lab_CapSoftWin_tiphead_P1074_prefer_w1521_param_home_1f78def393fc.exe"
OUT = DIGDIR / "lab_CapSoftWin_tiphead_P1074_prefer_nested_let_writeback.exe"
PROD = Path(r"C:\xlang_tmp\prod_softcap\lab_SoftCap_76795.exe")
CAVE = Path(r"C:\xlang_tmp\p1060\cave\lab_SoftCap_76795.exe")
TIP = Path(r"C:\xlang_tmp\p1060\cave\lab_CapSoftWin_tiphead.exe")

EXPECT_SRC = "1f78def393fc"
EXPECT_PROD = "74d0bd9c9fbf"
EXPECT_TIP = "9ecd26ea44ab"
TRAMP_SIG = bytes.fromhex("8b1d4a1900008305431900000883c318e9d8ffffff")
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
    "e9d0ff140add",  # prior ASLR-broken plant
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
    sec = opt + optsz
    secs = []
    for i in range(nsec):
        o = sec + i * 40
        name = bytes(data[o : o + 8]).split(b"\0", 1)[0].decode("ascii", "replace")
        vsz, sva, rsz, rdo = struct.unpack_from("<IIII", data, o + 8)
        secs.append(
            {
                "i": i,
                "o": o,
                "name": name,
                "sva": sva,
                "rdo": rdo,
                "rsz": rsz,
                "vsz": vsz,
            }
        )
    return {"ib": ib, "secs": secs}


def va_of_file(pe: dict, file_off: int) -> int:
    for s in pe["secs"]:
        if s["rdo"] <= file_off < s["rdo"] + s["rsz"]:
            return pe["ib"] + s["sva"] + (file_off - s["rdo"])
    raise KeyError(hex(file_off))


def nm_abs(exe: Path, name: str) -> int:
    out = subprocess.check_output(["nm", str(exe)], text=True, errors="replace")
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 3 and parts[-1] == name:
            return int(parts[0], 16)
    raise KeyError(name)


def main() -> None:
    assert sha12(SRC) == EXPECT_SRC, sha12(SRC)
    assert sha12(PROD) == EXPECT_PROD, sha12(PROD)
    assert sha12(CAVE) == EXPECT_PROD, sha12(CAVE)
    assert sha12(TIP) == EXPECT_TIP, sha12(TIP)

    data = bytearray(SRC.read_bytes())
    pe = parse_pe(data)
    ib = pe["ib"]

    tramp_off = data.find(TRAMP_SIG)
    assert tramp_off > 0 and data.find(TRAMP_SIG, tramp_off + 1) < 0, hex(tramp_off)
    jmp_off = tramp_off + len(TRAMP_SIG) - 5
    assert data[jmp_off] == 0xE9
    cont_rel = struct.unpack_from("<i", data, jmp_off + 1)[0]
    tramp_jmp_va = va_of_file(pe, jmp_off)
    cont_va = tramp_jmp_va + 5 + cont_rel
    movslq_off = tramp_off - 0x13
    assert data[movslq_off : movslq_off + 3] == bytes.fromhex("4863db")
    assert cont_va == va_of_file(pe, movslq_off)

    used_va = nm_abs(SRC, "g_pipe_al_used")
    n_va = nm_abs(SRC, "g_pipe_al_n")
    slots_va = nm_abs(SRC, "g_pipe_al_slots")

    tpad = next(s for s in pe["secs"] if s["name"].startswith(".tpad"))
    need = 0x100
    assert tpad["rsz"] - tpad["vsz"] >= need, (hex(tpad["rsz"]), hex(tpad["vsz"]))
    wb_file = tpad["rdo"] + tpad["vsz"]
    assert data[wb_file : wb_file + need] == b"\x00" * need
    wb_va = ib + tpad["sva"] + tpad["vsz"]

    wb = bytearray()
    patches: list[tuple[int, str, str]] = []
    labels: dict[str, int] = {}

    def here() -> int:
        return wb_va + len(wb)

    def emit(xs: bytes) -> None:
        wb.extend(xs)

    def emit_jcc32(opcode: bytes, label: str) -> None:
        at = len(wb)
        emit(opcode + b"\x00\x00\x00\x00")
        patches.append((at, "jcc32", label))

    def emit_jmp32(label: str) -> None:
        at = len(wb)
        emit(b"\xe9\x00\x00\x00\x00")
        patches.append((at, "jmp32", label))

    def emit_lea_r14(target_va: int) -> None:
        """lea r14, [rip+disp] — ASLR-safe (7 bytes)."""
        at = len(wb)
        emit(b"\x4c\x8d\x35\x00\x00\x00\x00")  # placeholder
        # disp = target - (insn_end); insn_end = wb_va + at + 7
        # patched after body known; store target in patches
        patches.append((at, "lea_r14", str(target_va)))

    # save rax..r9,r14 (9 pushes); rbx new_home at [rsp+0x38]
    emit(b"\x50\x53\x51\x52\x56\x57\x41\x50\x41\x51\x41\x56")
    emit(b"\x41\x89\xc0")  # mov r8d, eax  ; old_abs
    emit(b"\x45\x31\xc9")  # xor r9d, r9d

    labels["slot_loop"] = here()
    emit(b"\x41\x83\xf9\x40")  # cmp r9d, 64
    emit_jcc32(b"\x0f\x8d", "done")  # jge done

    emit_lea_r14(used_va)
    emit(b"\x43\x83\x3c\x8e\x00")  # cmp dword [r14+r9*4], 0
    emit_jcc32(b"\x0f\x84", "next_slot")

    emit_lea_r14(n_va)
    emit(b"\x43\x8b\x0c\x8e")  # mov ecx, [r14+r9*4]
    emit(b"\xff\xc9")  # dec ecx
    emit_jcc32(b"\x0f\x88", "next_slot")  # js

    labels["ent_loop"] = here()
    emit_lea_r14(slots_va)
    emit(b"\x4b\x8b\x34\xce")  # mov rsi, [r14+r9*8]
    emit(b"\x48\x85\xf6")
    emit_jcc32(b"\x0f\x84", "next_slot")

    emit(b"\x48\x89\xf7")  # mov rdi, rsi
    emit(b"\x48\x69\xd1\x08\x01\x00\x00")  # imul rdx, rcx, 264
    emit(b"\x48\x01\xd7")  # add rdi, rdx

    emit(b"\x8b\x97\x04\x01\x00\x00")  # mov edx, [rdi+260]
    emit(b"\x89\xd0")
    emit(b"\x85\xc0")
    emit(b"\x79\x02")
    emit(b"\xf7\xd8")
    emit(b"\x44\x39\xc0")  # cmp eax, r8d
    jne_at = len(wb)
    emit(b"\x75\x00")  # jne cont_ent

    emit(b"\x8b\x44\x24\x38")  # mov eax, [rsp+0x38] ; new_home
    emit(b"\x89\x87\x04\x01\x00\x00")  # mov [rdi+260], eax
    emit_jmp32("done")

    labels["cont_ent"] = here()
    rel8 = labels["cont_ent"] - (wb_va + jne_at + 2)
    assert -128 <= rel8 <= 127, rel8
    wb[jne_at + 1] = rel8 & 0xFF

    emit(b"\xff\xc9")
    emit_jcc32(b"\x0f\x89", "ent_loop")  # jns

    labels["next_slot"] = here()
    emit(b"\x41\xff\xc1")
    emit_jmp32("slot_loop")

    labels["done"] = here()
    emit(b"\x41\x5e\x41\x59\x41\x58\x5f\x5e\x5a\x59\x5b\x58")
    emit(b"\xe9" + struct.pack("<i", cont_va - (here() + 5)))

    for at, kind, lab in patches:
        if kind == "jcc32":
            tgt = labels[lab]
            struct.pack_into("<i", wb, at + 2, tgt - (wb_va + at + 6))
        elif kind == "jmp32":
            tgt = labels[lab]
            struct.pack_into("<i", wb, at + 1, tgt - (wb_va + at + 5))
        elif kind == "lea_r14":
            tgt = int(lab)
            # lea r14,[rip+disp]; len=7
            struct.pack_into("<i", wb, at + 3, tgt - (wb_va + at + 7))

    assert len(wb) <= need, len(wb)
    data[wb_file : wb_file + len(wb)] = wb
    struct.pack_into("<I", data, tpad["o"] + 8, tpad["vsz"] + len(wb))
    struct.pack_into("<i", data, jmp_off + 1, wb_va - (tramp_jmp_va + 5))

    h = sha12(data)
    assert h not in BANNED, h
    assert h != EXPECT_SRC
    OUT.write_bytes(data)
    tagged = DIGDIR / f"lab_CapSoftWin_tiphead_P1074_prefer_nested_let_writeback_{h}.exe"
    tagged.write_bytes(data)

    assert sha12(PROD) == EXPECT_PROD
    assert sha12(CAVE) == EXPECT_PROD
    assert sha12(TIP) == EXPECT_TIP
    assert sha12(SRC) == EXPECT_SRC

    print("PLANTED", tagged)
    print("SHA", h)
    print("SIZE", tagged.stat().st_size)
    print("wb_len", len(wb), "wb_va", hex(wb_va))
    print("cont_va", hex(cont_va), "tramp_jmp", hex(tramp_jmp_va))
    print("used", hex(used_va), "n", hex(n_va), "slots", hex(slots_va))
    print("HOLD_OK PROD", EXPECT_PROD, "TIP", EXPECT_TIP, "SRC", EXPECT_SRC)


if __name__ == "__main__":
    main()
