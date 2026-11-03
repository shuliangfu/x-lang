# -*- coding: utf-8 -*-
"""10.84 Soft Cap dig-egg Prefer SoftCap distinct-homes plant (CONT+HOOK).

Mirrors tip.x Prefer-M2 SoftCap distinct-homes (10.84): SoftCap Prefer ensure+fill
at HOOK, then CONT-path remap when |off|>0x1000 OR SoftCap Prefer/clamp18
home ebp==0x18 while idx!=0 → 24+(idx*8), plus pipe_al writeback so Prefer-find
assign matches store homes. CONT hook covers SoftCap Prefer-skipped i64 lets
(HOOK-only plant left nested_let Prefer.o smash-identical). Not first_wins.

Base: dig Soft Cap egg d8e2. Never write Soft Cap PROD/cave 74d0 / tiphead 9ecd / nail.
"""
from __future__ import annotations

import argparse
import hashlib
import shutil
import struct
from pathlib import Path

EXPECT_BASE = "d8e2d409a140"
CLAMP_SIG = bytes.fromhex("483d001000007608bb18000000")
HOOK = 0x140119338
CONT = 0x140119121
FIND = 0x1402b2c8f
LAZY = 0x140248bcf
PIPE_AL_FIND = 0x1402b21ab
PIPE_AL_AT = 0x1402b2727
G_PIPE_AL_N = 0x140bab440

BANNED = {
    "d8e2d409a140",
    "deb4e77c9f87",
    "508763d1e3cb",
    "74d0bd9c9fbf",
    "e24f56c34394",
    "1f78def393fc",
    "a1491a74c08b",
    "5dff12e7772e",
    "1e59c5261663",
    "9ecd26ea44ab",
    "c8b504c47818",
    "07eadd3fe8bf",
    "897255a95d2d",
    "44273d092947",
    "38f48f569d03",
    "a9a1446ef579",
}


def sha12(b: bytes | bytearray | Path) -> str:
    if isinstance(b, Path):
        b = b.read_bytes()
    return hashlib.sha256(bytes(b)).hexdigest()[:12]


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
    soh = struct.unpack_from("<I", data, opt + 60)[0]
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
        "soh": soh,
        "nsec": nsec,
        "secs": secs,
    }


def va_off(pe: dict, va: int) -> int:
    rva = va - pe["ib"]
    for s in pe["secs"]:
        if s["sva"] <= rva < s["sva"] + max(s["vsz"], s["rsz"]):
            return s["rdo"] + (rva - s["sva"])
    raise KeyError(hex(va))


def rel32(frm: int, to: int) -> int:
    return to - frm


def build_prefer_ensure(tramp_va: int, cont_tramp_va: int) -> bytes:
    """SoftCap Prefer HOOK: ensure+fill, cmovns ebp, jmp CONT tramp (remap+wb)."""
    tramp = bytearray()
    patches: list[tuple[int, str, int | str]] = []
    labels: dict[str, int] = {}

    def here() -> int:
        return tramp_va + len(tramp)

    def emit(xs: bytes) -> None:
        tramp.extend(xs)

    def emit_call(target: int) -> None:
        at = len(tramp)
        emit(b"\xe8" + struct.pack("<i", 0))
        patches.append((at, "call", target))

    def emit_jcc8(op: bytes, label: str) -> None:
        at = len(tramp)
        emit(op + b"\x00")
        patches.append((at, "jcc8", label))

    emit(b"\x85\xc0")
    emit_jcc8(b"\x79", "got_found")
    emit(b"\x4c\x8b\x94\x24\x00\x01\x00\x00")
    emit(b"\x44\x8b\x9c\x24\x08\x01\x00\x00")
    emit(b"\x48\x83\xec\x30")
    emit(b"\x4c\x89\x54\x24\x20")
    emit(b"\x44\x89\x5c\x24\x28")
    emit(b"\x48\x89\xd9")
    emit(b"\x4c\x89\xea")
    emit(b"\x41\x89\xf0")
    emit(b"\x41\x89\xf9")
    emit_call(LAZY)
    emit(b"\x44\x8b\x44\x24\x28")
    emit(b"\x48\x8b\x54\x24\x20")
    emit(b"\x4c\x89\xe9")
    emit_call(FIND)
    emit(b"\x48\x83\xc4\x30")
    labels["got_found"] = here()
    emit(b"\x85\xc0")
    emit(b"\x0f\x49\xe8")
    emit(b"\xe9" + struct.pack("<i", rel32(here() + 5, cont_tramp_va)))

    for at, kind, lab in patches:
        if kind == "call":
            tgt = int(lab)
            struct.pack_into("<i", tramp, at + 1, tgt - (tramp_va + at + 5))
        elif kind == "jcc8":
            tgt = labels[str(lab)]
            rel = tgt - (tramp_va + at + 2)
            assert -128 <= rel <= 127, (lab, rel)
            tramp[at + 1] = rel & 0xFF
    return bytes(tramp)


def build_cont_tramp(tramp_va: int, cont_plus5: int) -> bytes:
    """CONT: distinct-homes remap + pipe_al writeback + stolen CONT insn."""
    tramp = bytearray()
    patches: list[tuple[int, str, int | str]] = []
    labels: dict[str, int] = {}

    def here() -> int:
        return tramp_va + len(tramp)

    def emit(xs: bytes) -> None:
        tramp.extend(xs)

    def emit_call(target: int) -> None:
        at = len(tramp)
        emit(b"\xe8" + struct.pack("<i", 0))
        patches.append((at, "call", target))

    def emit_jcc8(op: bytes, label: str) -> None:
        at = len(tramp)
        emit(op + b"\x00")
        patches.append((at, "jcc8", label))

    def emit_jcc32(op: bytes, label: str) -> None:
        at = len(tramp)
        emit(op + b"\x00\x00\x00\x00")
        patches.append((at, "jcc32", label))

    def emit_jmp32(label: str) -> None:
        at = len(tramp)
        emit(b"\xe9" + struct.pack("<i", 0))
        patches.append((at, "jmp32", label))

    # abs(ebp); remap if torn OR (ebp==0x18 && idx!=0)
    emit(b"\x89\xe8")
    emit(b"\x99")
    emit(b"\x31\xd0\x29\xd0")
    emit(b"\x3d\x00\x10\x00\x00")
    emit_jcc8(b"\x77", "do_remap")
    emit(b"\x83\xfd\x18")
    emit_jcc8(b"\x75", "after_remap")
    emit(b"\x85\xff")
    emit_jcc8(b"\x74", "after_remap")
    labels["do_remap"] = here()
    emit(b"\x8d\x2c\xfd\x18\x00\x00\x00")
    labels["after_remap"] = here()

    emit(b"\x83\xbc\x24\x08\x01\x00\x00\x00")
    emit_jcc32(b"\x0f\x8e", "done")
    emit(b"\x48\x83\xbc\x24\x00\x01\x00\x00\x00")
    emit_jcc32(b"\x0f\x84", "done")

    emit(b"\x50\x51\x52\x56\x57\x41\x50\x41\x51\x41\x52\x41\x53")
    emit(b"\x48\x83\xec\x20")
    emit(b"\x89\x6c\x24\x18")

    emit(b"\x4c\x89\xe9")
    emit(b"\x31\xd2")
    emit_call(PIPE_AL_FIND)
    emit(b"\x85\xc0")
    emit_jcc32(b"\x0f\x88", "wb_restore")
    emit(b"\x41\x89\xc2")

    emit(b"\x48\x8d\x05" + struct.pack("<i", 0))
    patches.append((len(tramp) - 7, "lea_rax", G_PIPE_AL_N))
    emit(b"\x42\x8b\x0c\x90")
    emit(b"\xff\xc9")
    emit_jcc32(b"\x0f\x88", "wb_restore")
    emit(b"\x41\x89\xcb")

    emit(b"\x48\x8b\xb4\x24\x68\x01\x00\x00")
    emit(b"\x44\x8b\x8c\x24\x70\x01\x00\x00")

    labels["ent_loop"] = here()
    emit(b"\x44\x89\xd1")
    emit(b"\x44\x89\xda")
    emit_call(PIPE_AL_AT)
    emit(b"\x48\x85\xc0")
    emit_jcc32(b"\x0f\x84", "wb_restore")
    emit(b"\x49\x89\xc0")

    emit(b"\x41\x8b\x80\x00\x01\x00\x00")
    emit(b"\x44\x39\xc8")
    emit_jcc8(b"\x75", "cont_ent")

    emit(b"\x31\xd2")
    labels["cmp_loop"] = here()
    emit(b"\x44\x39\xca")
    emit_jcc8(b"\x7d", "match")
    emit(b"\x0f\xb6\x04\x16")
    emit(b"\x41\x0f\xb6\x0c\x10")
    emit(b"\x39\xc8")
    emit_jcc8(b"\x75", "cont_ent")
    emit(b"\xff\xc2")
    emit_jmp32("cmp_loop")

    labels["match"] = here()
    emit(b"\x8b\x44\x24\x18")
    emit(b"\x41\x89\x80\x04\x01\x00\x00")
    emit_jmp32("wb_restore")

    labels["cont_ent"] = here()
    emit(b"\x41\xff\xcb")
    emit_jcc32(b"\x0f\x89", "ent_loop")

    labels["wb_restore"] = here()
    emit(b"\x48\x83\xc4\x20")
    emit(b"\x41\x5b\x41\x5a\x41\x59\x41\x58\x5f\x5e\x5a\x59\x58")

    labels["done"] = here()
    # stolen CONT: mov dword [rsp+0x38], r15d
    emit(b"\x44\x89\x7c\x24\x38")
    emit(b"\xe9" + struct.pack("<i", rel32(here() + 5, cont_plus5)))

    for at, kind, lab in patches:
        if kind == "call":
            tgt = int(lab)
            struct.pack_into("<i", tramp, at + 1, tgt - (tramp_va + at + 5))
        elif kind == "lea_rax":
            tgt = int(lab)
            struct.pack_into("<i", tramp, at + 3, tgt - (tramp_va + at + 7))
        elif kind == "jcc8":
            tgt = labels[str(lab)]
            rel = tgt - (tramp_va + at + 2)
            assert -128 <= rel <= 127, (lab, rel)
            tramp[at + 1] = rel & 0xFF
        elif kind == "jcc32":
            tgt = labels[str(lab)]
            struct.pack_into("<i", tramp, at + 2, tgt - (tramp_va + at + 6))
        elif kind == "jmp32":
            tgt = labels[str(lab)]
            struct.pack_into("<i", tramp, at + 1, tgt - (tramp_va + at + 5))
    return bytes(tramp)


def append_tpad(data: bytearray, pe: dict, vsz: int = 0x400) -> tuple[bytearray, dict, int]:
    assert pe["soh"] - (pe["opt"] + pe["optsz"] + pe["nsec"] * 40) >= 40
    new_sva = pe["soi"]
    new_rsz = ((vsz + pe["fa"] - 1) // pe["fa"]) * pe["fa"]
    new_rdo = (len(data) + pe["fa"] - 1) // pe["fa"] * pe["fa"]
    if new_rdo > len(data):
        data.extend(b"\x00" * (new_rdo - len(data)))
    data.extend(b"\x00" * new_rsz)
    sh = pe["opt"] + pe["optsz"] + pe["nsec"] * 40
    data[sh : sh + 8] = b".tpad\0\0\0"
    struct.pack_into(
        "<IIIIIIHHI",
        data,
        sh + 8,
        vsz,
        new_sva,
        new_rsz,
        new_rdo,
        0,
        0,
        0,
        0,
        0x60000020,
    )
    struct.pack_into("<H", data, pe["coff"] + 2, pe["nsec"] + 1)
    new_soi = ((new_sva + vsz + pe["sa"] - 1) // pe["sa"]) * pe["sa"]
    struct.pack_into("<I", data, pe["opt"] + 56, new_soi)
    pe2 = parse_pe(data)
    tramp_va = pe2["ib"] + new_sva
    return data, pe2, tramp_va


def plant(src: Path, out_dir: Path) -> tuple[str, int, Path]:
    data = bytearray(src.read_bytes())
    assert sha12(data) == EXPECT_BASE, sha12(data)
    assert CLAMP_SIG in data, "base missing Soft Cap enc_store clamp18"
    pe = parse_pe(data)
    data, pe, tramp_va = append_tpad(data, pe, vsz=0x400)
    cont_tramp_va = tramp_va + 0x80
    prefer = build_prefer_ensure(tramp_va, cont_tramp_va)
    cont = build_cont_tramp(cont_tramp_va, CONT + 5)
    assert len(prefer) <= 0x80, len(prefer)
    assert 0x80 + len(cont) <= 0x400, len(cont)
    off_t = va_off(pe, tramp_va)
    assert data[off_t : off_t + 0x400] == b"\x00" * 0x400
    data[off_t : off_t + len(prefer)] = prefer
    data[off_t + 0x80 : off_t + 0x80 + len(cont)] = cont
    tag = b"P1084dhC\0"
    data[off_t + 0x80 + len(cont) : off_t + 0x80 + len(cont) + len(tag)] = tag

    off_h = va_off(pe, HOOK)
    pre = bytes(data[off_h : off_h + 10])
    assert pre == bytes.fromhex("85c00f49e8e9dffdffff"), pre.hex()
    data[off_h : off_h + 10] = (
        b"\xe9" + struct.pack("<i", tramp_va - (HOOK + 5)) + b"\x90" * 5
    )

    off_c = va_off(pe, CONT)
    pre_c = bytes(data[off_c : off_c + 5])
    assert pre_c == bytes.fromhex("44897c2438"), pre_c.hex()
    data[off_c : off_c + 5] = b"\xe9" + struct.pack("<i", cont_tramp_va - (CONT + 5))

    assert CLAMP_SIG in data, "enc_store clamp18 lost after plant"
    h = sha12(data)
    size = len(data)
    assert h not in BANNED, h
    assert size <= 10_000_000
    out_dir.mkdir(parents=True, exist_ok=True)
    out = out_dir / "lab_SoftCap_d8e2_preferM2_distinct_homes_P1084.exe"
    out.write_bytes(data)
    tagged = out_dir / f"lab_SoftCap_d8e2_preferM2_distinct_homes_P1084_{h}.exe"
    shutil.copy2(out, tagged)
    return h, size, tagged


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--src",
        type=Path,
        default=Path(r"C:\xlang_tmp\p1060\g05th_dig\lab_CapSoftWin_tiphead_P1065_dig5fwd_clamp18.exe"),
    )
    ap.add_argument(
        "--out-dir",
        type=Path,
        default=Path(r"C:\xlang_tmp\p1060\g05th_dig"),
    )
    ap.add_argument(
        "--prod",
        type=Path,
        default=Path(r"C:\xlang_tmp\prod_softcap\lab_SoftCap_76795.exe"),
    )
    ap.add_argument(
        "--cave",
        type=Path,
        default=Path(r"C:\xlang_tmp\p1060\cave\lab_SoftCap_76795.exe"),
    )
    ap.add_argument(
        "--tip",
        type=Path,
        default=Path(r"C:\xlang_tmp\p1060\cave\lab_CapSoftWin_tiphead.exe"),
    )
    args = ap.parse_args()
    assert sha12(args.prod) == "74d0bd9c9fbf", sha12(args.prod)
    assert sha12(args.cave) == "74d0bd9c9fbf", sha12(args.cave)
    assert sha12(args.tip) == "9ecd26ea44ab", sha12(args.tip)
    h, size, tagged = plant(args.src, args.out_dir)
    assert sha12(args.prod) == "74d0bd9c9fbf"
    assert sha12(args.cave) == "74d0bd9c9fbf"
    assert sha12(args.tip) == "9ecd26ea44ab"
    assert sha12(args.src) == EXPECT_BASE
    print("PLANTED", tagged)
    print("SHA", h)
    print("SIZE", size)
    print("HOLD_OK PROD 74d0bd9c9fbf TIP 9ecd26ea44ab SRC", EXPECT_BASE)


if __name__ == "__main__":
    main()
