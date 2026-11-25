"""11.00 DIG07 SoftCap dig — adapt CapSoft Prefer p1074 w1521 param_home plant.

Base: DIG07 Cap soft tiphead Prefer-M2 SoftCap dig plant 07eadd3fe8bf (CG002 SoftCap four-gate).
Control green: CapSoft Prefer dig 1f78def393fc SoftCap four-gate 4/4.
Plant tip.x SoftCap Prefer win_param_home_thin .text into appended RX .tpad;
jmp Prefer pipeline_asm_emit_param_home_elf_c + fill_param_slots to Prefer body.

HOLD Soft Cap 09fe / tiphead Prefer-M2 9ecd / nail ecdb / Cap tip — never write those hosts.
Output new dig PE sha != DIG07/9ecd/1f78/09fe SoftCap-parity same-body empty.
"""
from __future__ import annotations

import hashlib
import struct
import subprocess
from pathlib import Path

DIGDIR = Path(r"C:\xlang_tmp\p1060\g05th_dig")
SRC = DIGDIR / "lab_CapSoftWin_tiphead_P1066_clamp18.exe"
OUT = DIGDIR / "lab_CapSoftWin_tiphead_P1100_dig07_prefer_w1521_param_home.exe"
OBJ = Path(
    r"C:\Users\shuliangfu\worker\xlang\x-lang\compiler\build_asm\selfhost_pabi\win_param_home.o"
)
PROD = Path(r"C:\xlang_tmp\prod_softcap\lab_SoftCap_76795.exe")
CAVE = Path(r"C:\xlang_tmp\p1060\cave\lab_SoftCap_76795.exe")
TIP = Path(r"C:\xlang_tmp\p1060\cave\lab_CapSoftWin_tiphead.exe")

EXPECT_SRC = "07eadd3fe8bf"
EXPECT_PROD = "09fe181dbd0e"
EXPECT_TIP = "9ecd26ea44ab"
BANNED = {
    "07eadd3fe8bf",
    "9ecd26ea44ab",
    "1f78def393fc",
    "09fe181dbd0e",
    "74d0bd9c9fbf",
    "1e59c5261663",
    "a1491a74c08b",
    "5dff12e7772e",
    "d8e2d409a140",
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


def nm_map(exe: Path) -> dict[str, int]:
    out = subprocess.check_output(["nm", str(exe)], text=True, errors="replace")
    m: dict[str, int] = {}
    rank: dict[str, int] = {}
    for line in out.splitlines():
        parts = line.strip().split()
        if len(parts) < 3 or len(parts[0]) < 8:
            continue
        try:
            addr = int(parts[0], 16)
        except ValueError:
            continue
        kind = parts[1]
        name = parts[-1]
        r = 2 if kind in "TDB" else (1 if kind in "tdb" else 0)
        if r == 0:
            continue
        if name not in m or r > rank.get(name, -1):
            m[name] = addr
            rank[name] = r
    return m


def append_tpad(data: bytearray, pe: dict, need: int) -> tuple[bytearray, dict, int]:
    assert pe["soh"] - (pe["opt"] + pe["optsz"] + pe["nsec"] * 40) >= 40
    fa = pe["fa"]
    new_sva = (pe["soi"] + pe["sa"] - 1) // pe["sa"] * pe["sa"]
    new_rsz = (need + fa - 1) // fa * fa
    new_rdo = (len(data) + fa - 1) // fa * fa
    if new_rdo > len(data):
        data.extend(b"\0" * (new_rdo - len(data)))
    data.extend(b"\0" * new_rsz)
    sh = pe["opt"] + pe["optsz"] + pe["nsec"] * 40
    data[sh : sh + 8] = b".tpad\0\0\0"
    struct.pack_into(
        "<IIIIIIHHI",
        data,
        sh + 8,
        need,
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
    new_soi = new_sva + ((need + pe["sa"] - 1) // pe["sa"] * pe["sa"])
    struct.pack_into("<I", data, pe["opt"] + 56, new_soi)
    pe = parse_pe(data)
    tramp_va = pe["ib"] + new_sva
    return data, pe, tramp_va


def main() -> None:
    assert sha12(SRC) == EXPECT_SRC, sha12(SRC)
    assert sha12(PROD) == EXPECT_PROD, sha12(PROD)
    assert sha12(CAVE) == EXPECT_PROD, sha12(CAVE)
    assert sha12(TIP) == EXPECT_TIP, sha12(TIP)
    assert OBJ.exists() and OBJ.stat().st_size > 1000, OBJ

    tmp = Path(r"C:\xlang_tmp\p1100\win_param_home_text.bin")
    tmp.parent.mkdir(parents=True, exist_ok=True)
    subprocess.check_call(
        ["objcopy", "-O", "binary", "-j", ".text", str(OBJ), str(tmp)]
    )
    text = bytearray(tmp.read_bytes())
    local: dict[str, int] = {}
    for line in subprocess.check_output(["nm", str(OBJ)], text=True).splitlines():
        parts = line.strip().split()
        if len(parts) >= 3 and parts[1] in ("T", "t"):
            local[parts[2]] = int(parts[0], 16)
    assert "pipeline_asm_emit_param_home_elf_c" in local
    assert "w1521_ph_copy_byref" in local
    assert "pipeline_asm_fill_param_slots" in local

    emit_off = local["pipeline_asm_emit_param_home_elf_c"]
    byref_off = local["w1521_ph_copy_byref"]
    emit_ta_old = bytes.fromhex("4c89c0488945d0b800000000")
    emit_ta_new = bytes.fromhex("488b4530488945d031c09090")
    assert text[emit_off + 0x28 : emit_off + 0x34] == emit_ta_old, text[
        emit_off + 0x28 : emit_off + 0x34
    ].hex()
    text[emit_off + 0x28 : emit_off + 0x34] = emit_ta_new
    clobber = emit_off + 0x7A4
    assert text[clobber - 7 : clobber] == bytes.fromhex("488b85b8fbffff"), text[
        clobber - 7 : clobber
    ].hex()
    assert text[clobber : clobber + 3] == bytes.fromhex("4989c0")
    text[clobber : clobber + 3] = bytes([0x90, 0x90, 0x90])
    assert text[byref_off + 0x28 : byref_off + 0x2B] == bytes.fromhex("4c89c0")
    text[byref_off + 0x28 : byref_off + 0x2B] = bytes.fromhex("4831c0")
    print("ABI_PATCH emit_ta+byref_slot_nop+byref_ta0 OK")

    rels: list[tuple[int, str]] = []
    for line in subprocess.check_output(
        ["objdump", "-r", str(OBJ)], text=True, errors="replace"
    ).splitlines():
        line = line.strip()
        if "IMAGE_REL_AMD64_REL32" not in line:
            continue
        parts = line.split()
        if len(parts) < 3:
            continue
        off = int(parts[0], 16)
        sym = parts[-1]
        rels.append((off, sym))

    dig_syms = nm_map(SRC)
    for must in (
        "pipeline_asm_emit_param_home_elf_c",
        "pipeline_asm_fill_param_slots",
    ):
        assert must in dig_syms, must

    data = bytearray(SRC.read_bytes())
    pe = parse_pe(data)
    data, pe, tramp_va = append_tpad(data, pe, len(text) + 64)
    tpad = pe["secs"][-1]
    assert tpad["name"].startswith(".tpad"), tpad["name"]
    base_off = tpad["rdo"]
    data[base_off : base_off + len(text)] = text

    def abs_va(sym: str) -> int:
        if sym in local:
            return tramp_va + local[sym]
        if sym in dig_syms:
            return dig_syms[sym]
        raise KeyError(sym)

    for off, sym in rels:
        P = tramp_va + off
        S = abs_va(sym)
        slot = base_off + off
        A = struct.unpack_from("<i", data, slot)[0]
        struct.pack_into("<i", data, slot, S + A - (P + 4))

    for dig_name, loc_name in (
        ("pipeline_asm_emit_param_home_elf_c", "pipeline_asm_emit_param_home_elf_c"),
        ("pipeline_asm_fill_param_slots", "pipeline_asm_fill_param_slots"),
    ):
        dva = dig_syms[dig_name]
        doff = va_off(pe, dva)
        tgt = tramp_va + local[loc_name]
        rel = tgt - (dva + 5)
        data[doff : doff + 5] = b"\xe9" + struct.pack("<i", rel)

    h = sha12(data)
    assert h not in BANNED, h
    OUT.write_bytes(data)
    tagged = DIGDIR / f"lab_CapSoftWin_tiphead_P1100_dig07_prefer_w1521_param_home_{h}.exe"
    tagged.write_bytes(data)
    assert sha12(PROD) == EXPECT_PROD
    assert sha12(CAVE) == EXPECT_PROD
    assert sha12(TIP) == EXPECT_TIP
    pe2 = parse_pe(data)
    off = va_off(pe2, dig_syms["pipeline_asm_emit_param_home_elf_c"])
    assert data[off] == 0xE9, data[off]
    print("OUT", OUT)
    print("TAGGED", tagged)
    print("SHA12", h)
    print("TPAD_VA", hex(tramp_va))
    print("HOLD SoftCap", EXPECT_PROD, "tiphead", EXPECT_TIP, "DIG07_SRC", EXPECT_SRC)
    print("P1100_DIG07_PLANT_OK")


if __name__ == "__main__":
    main()
