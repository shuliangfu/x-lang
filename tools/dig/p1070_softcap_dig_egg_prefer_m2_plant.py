"""10.70 Soft Cap dig-egg SoftCap-green Prefer-M2 tip.x SoftCap ensure+fill+clamp.

Base Soft Cap dig5fwd lineage (c8b504c47818, size 8081687). Expand .text pad
(PAD_ADD), plant Prefer-M2 tip.x SoftCap ensure+fill on name-find miss then
clamp18 (|off|>0x1000→0x18). Dig-only Soft Cap dig egg — never Soft Cap/nail/9ecd.

Output name: lab_SoftCap_*_P1070_*.exe (Soft Cap dig egg, not CapSoftWin tiphead).
"""
from __future__ import annotations

import argparse
import hashlib
import shutil
import struct
from pathlib import Path

EXPECT_BASE = "c8b504c47818"
PAD_ADD = 0x100
HOOK = 0x140119338  # test eax after Prefer-M2 name-find in Soft Cap dig5fwd
CONT = 0x140119121  # continue emit_let after Prefer-M2
FIND = 0x1402b2c8f  # asm_ctx_local_find_offset
LAZY = 0x140248bcf  # T glue_lazy_append_block_let_local
BANNED = {
    "d8e2d409a140",  # PROD Soft Cap
    "a1491a74c08b",  # Cap soft tiphead dig SoftCap-green (lineage mismatch)
    "c8b504c47818",  # dig5fwd base
    "07eadd3fe8bf",
    "897255a95d2d",
    "9ecd26ea44ab",
}


def sha12(b: bytes | bytearray) -> str:
    return hashlib.sha256(bytes(b)).hexdigest()[:12]


def parse_pe(data: bytearray | bytes) -> dict:
    e = struct.unpack_from("<I", data, 0x3C)[0]
    coff = e + 4
    nsec = struct.unpack_from("<H", data, coff + 2)[0]
    optsz = struct.unpack_from("<H", data, coff + 16)[0]
    opt = coff + 20
    assert struct.unpack_from("<H", data, opt)[0] == 0x20B
    ib = struct.unpack_from("<Q", data, opt + 24)[0]
    sect_align = struct.unpack_from("<I", data, opt + 32)[0]
    file_align = struct.unpack_from("<I", data, opt + 36)[0]
    size_of_image = struct.unpack_from("<I", data, opt + 56)[0]
    sec = opt + optsz
    secs = []
    for i in range(nsec):
        o = sec + i * 40
        name = bytes(data[o : o + 8]).split(b"\0", 1)[0].decode("ascii", "replace")
        vsz, sva, rsz, rdo = struct.unpack_from("<IIII", data, o + 8)
        secs.append(
            {"i": i, "o": o, "name": name, "sva": sva, "rdo": rdo, "rsz": rsz, "vsz": vsz}
        )
    ptr_sym = struct.unpack_from("<I", data, coff + 8)[0]
    nsym = struct.unpack_from("<I", data, coff + 12)[0]
    return {
        "e": e,
        "coff": coff,
        "opt": opt,
        "optsz": optsz,
        "ib": ib,
        "sect_align": sect_align,
        "file_align": file_align,
        "size_of_image": size_of_image,
        "secs": secs,
        "ptr_sym": ptr_sym,
        "nsym": nsym,
        "dd_off": opt + 112,
    }


def va_off(data: bytes | bytearray, pe: dict, va: int):
    rva = va - pe["ib"]
    for s in pe["secs"]:
        if s["sva"] <= rva < s["sva"] + max(s["vsz"], s["rsz"]):
            return s["rdo"] + (rva - s["sva"]), s
    return None, None


def rel32(frm: int, to: int) -> int:
    return to - frm


def expand_text(data: bytearray, pe: dict, pad_add: int) -> tuple[bytearray, dict, int]:
    text = [s for s in pe["secs"] if s["name"] == ".text"][0]
    insert_at = text["rdo"] + text["rsz"]
    # Soft Cap dig egg SoftCap-green Prefer-M2: virt room to .data must fit pad
    others = sorted(
        [s for s in pe["secs"] if s["sva"] > text["sva"]], key=lambda s: s["sva"]
    )
    if others:
        next_sva = others[0]["sva"]
        assert text["sva"] + text["vsz"] + pad_add <= next_sva, (
            hex(text["sva"] + text["vsz"] + pad_add),
            hex(next_sva),
        )

    struct.pack_into("<I", data, text["o"] + 8, text["vsz"] + pad_add)
    struct.pack_into("<I", data, text["o"] + 16, text["rsz"] + pad_add)
    for s in pe["secs"]:
        if s["rdo"] > text["rdo"]:
            struct.pack_into("<I", data, s["o"] + 20, s["rdo"] + pad_add)
    if pe["ptr_sym"] >= insert_at:
        struct.pack_into("<I", data, pe["coff"] + 8, pe["ptr_sym"] + pad_add)

    # security / debug file-offset dig dirs (dig3g class)
    dd = pe["dd_off"]
    sec_rva, sec_sz = struct.unpack_from("<II", data, dd + 4 * 8)
    if sec_sz and sec_rva >= insert_at:
        struct.pack_into("<I", data, dd + 4 * 8, sec_rva + pad_add)
    dbg_rva, dbg_sz = struct.unpack_from("<II", data, dd + 6 * 8)
    if dbg_sz and dbg_rva:
        # map dbg_rva via pre-insert sections
        for s in pe["secs"]:
            if s["sva"] <= dbg_rva < s["sva"] + max(s["vsz"], s["rsz"]):
                dbg_file = s["rdo"] + (dbg_rva - s["sva"])
                break
        else:
            dbg_file = None
        if dbg_file is not None:
            # after insert, entries with PointerToRawData >= insert_at shift
            n_entries = max(1, dbg_sz // 28)
            for i in range(n_entries):
                ent = dbg_file + i * 28
                if ent + 28 > len(data):
                    break
                ptr = struct.unpack_from("<I", data, ent + 24)[0]
                if ptr >= insert_at:
                    struct.pack_into("<I", data, ent + 24, ptr + pad_add)

    data = bytearray(data[:insert_at] + (b"\x00" * pad_add) + data[insert_at:])
    pe2 = parse_pe(data)
    text2 = [s for s in pe2["secs"] if s["name"] == ".text"][0]
    # dig3g: pad_va = ib + sva + (rsz - PAD_ADD) after expand
    pad_va = pe2["ib"] + text2["sva"] + (text2["rsz"] - pad_add)
    return data, pe2, pad_va


def build_tramp(tramp_va: int) -> bytes:
    tramp = bytearray()

    def here() -> int:
        return tramp_va + len(tramp)

    # Soft Cap dig egg SoftCap-green Prefer-M2 tip.x SoftCap ensure+fill+clamp
    tramp += b"\x85\xc0"  # test eax,eax
    jns_at = len(tramp)
    tramp += b"\x79\x00"  # jns .got

    tramp += b"\x4c\x8b\x94\x24\x00\x01\x00\x00"  # mov r10,[rsp+0x100] name
    tramp += b"\x44\x8b\x9c\x24\x08\x01\x00\x00"  # mov r11d,[rsp+0x108] llen
    tramp += b"\x48\x83\xec\x30"  # sub rsp,0x30
    tramp += b"\x4c\x89\x54\x24\x20"  # mov [rsp+0x20],r10
    tramp += b"\x44\x89\x5c\x24\x28"  # mov [rsp+0x28],r11d
    tramp += b"\x48\x89\xd9"  # mov rcx,rbx arena
    tramp += b"\x4c\x89\xea"  # mov rdx,r13 ctx
    tramp += b"\x41\x89\xf0"  # mov r8d,esi block
    tramp += b"\x41\x89\xf9"  # mov r9d,edi idx
    c1 = here()
    tramp += b"\xe8" + struct.pack("<i", rel32(c1 + 5, LAZY))
    tramp += b"\x44\x8b\x44\x24\x28"  # mov r8d,[rsp+0x28]
    tramp += b"\x48\x8b\x54\x24\x20"  # mov rdx,[rsp+0x20]
    tramp += b"\x4c\x89\xe9"  # mov rcx,r13
    c2 = here()
    tramp += b"\xe8" + struct.pack("<i", rel32(c2 + 5, FIND))
    tramp += b"\x48\x83\xc4\x30"  # add rsp,0x30

    got = len(tramp)
    tramp[jns_at + 1] = (got - (jns_at + 2)) & 0xFF
    tramp += b"\x85\xc0"  # test eax,eax
    tramp += b"\x0f\x49\xe8"  # cmovns ebp,eax
    # Prefer-M2 tip.x SoftCap clamp18
    tramp += b"\x89\xe8"  # mov eax,ebp
    tramp += b"\x99"  # cdq
    tramp += b"\x31\xd0\x29\xd0"  # abs
    tramp += b"\x3d\x00\x10\x00\x00"  # cmp eax,0x1000
    jbe_at = len(tramp)
    tramp += b"\x76\x00"
    tramp += b"\xbd\x18\x00\x00\x00"  # mov ebp,0x18
    cont = len(tramp)
    tramp[jbe_at + 1] = (cont - (jbe_at + 2)) & 0xFF
    jv = here()
    tramp += b"\xe9" + struct.pack("<i", rel32(jv + 5, CONT))
    return bytes(tramp)


def plant(src: Path, out_dir: Path) -> tuple[str, int, Path]:
    data = bytearray(src.read_bytes())
    assert sha12(data) == EXPECT_BASE, sha12(data)
    pe = parse_pe(data)
    data, pe, pad_va = expand_text(data, pe, PAD_ADD)
    tramp = build_tramp(pad_va)
    assert len(tramp) <= PAD_ADD, len(tramp)

    off_t, _ = va_off(data, pe, pad_va)
    assert off_t is not None, hex(pad_va)
    slot = bytes(data[off_t : off_t + len(tramp)])
    assert slot == b"\x00" * len(tramp), slot[:16].hex()
    data[off_t : off_t + len(tramp)] = tramp

    off_h, _ = va_off(data, pe, HOOK)
    pre = bytes(data[off_h : off_h + 10])
    assert pre == bytes.fromhex("85c00f49e8e9dffdffff"), pre.hex()
    hook = b"\xe9" + struct.pack("<i", rel32(HOOK + 5, pad_va)) + b"\x90" * 5
    assert len(hook) == 10
    data[off_h : off_h + 10] = hook

    h = sha12(data)
    size = len(data)
    assert h not in BANNED, h
    assert size <= 10_000_000
    # Soft Cap dig egg SoftCap-green Prefer-M2 size class (~8081687 + PAD_ADD)
    assert 8081687 <= size <= 8081687 + 0x1000, size

    out_dir.mkdir(parents=True, exist_ok=True)
    out = out_dir / "lab_SoftCap_dig5fwd_preferM2_ensurefill_clamp_P1070.exe"
    out.write_bytes(data)
    tagged = out_dir / f"lab_SoftCap_dig5fwd_preferM2_ensurefill_clamp_P1070_{h}.exe"
    shutil.copy2(out, tagged)
    return h, size, tagged


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--src",
        type=Path,
        default=Path("/tmp/p1064_TYPE628_nt628tramp_v2_rev_dig4slit_dig5fwd.exe"),
    )
    ap.add_argument("--out-dir", type=Path, default=Path("/tmp/p1070"))
    args = ap.parse_args()
    h, size, tagged = plant(args.src, args.out_dir)
    print(f"SOFTCAP_DIG_EGG_PLANTED sha12={h} size={size} path={tagged}")


if __name__ == "__main__":
    main()
