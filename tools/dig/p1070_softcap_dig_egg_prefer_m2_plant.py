"""10.70 Soft Cap dig-egg SoftCap-green Prefer-M2 tip.x SoftCap ensure+fill+clamp.

Base Soft Cap dig5fwd lineage (c8b504c47818, size 8081687). Append RX .tpad
section (mid-file .text expand AVs on this PE); plant Prefer-M2 tip.x SoftCap
ensure+fill on name-find miss then clamp18 (|off|>0x1000→0x18).

Dig-only Soft Cap dig egg — never Soft Cap/nail/9ecd.
Output: lab_SoftCap_*_P1070_*.exe (Soft Cap dig egg, not CapSoftWin tiphead).
"""
from __future__ import annotations

import argparse
import hashlib
import shutil
import struct
from pathlib import Path

EXPECT_BASE = "c8b504c47818"
HOOK = 0x140119338
CONT = 0x140119121
FIND = 0x1402b2c8f
LAZY = 0x140248bcf
BANNED = {
    "d8e2d409a140",
    "a1491a74c08b",
    "c8b504c47818",
    "07eadd3fe8bf",
    "897255a95d2d",
    "9ecd26ea44ab",
    "44273d092947",  # mid-file expand AV plant
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
        "ptr_sym": struct.unpack_from("<I", data, coff + 8)[0],
    }


def va_off(pe: dict, va: int) -> int:
    rva = va - pe["ib"]
    for s in pe["secs"]:
        if s["sva"] <= rva < s["sva"] + max(s["vsz"], s["rsz"]):
            return s["rdo"] + (rva - s["sva"])
    raise KeyError(hex(va))


def rel32(frm: int, to: int) -> int:
    return to - frm


def build_tramp(tramp_va: int) -> bytes:
    tramp = bytearray()

    def here() -> int:
        return tramp_va + len(tramp)

    tramp += b"\x85\xc0"
    jns_at = len(tramp)
    tramp += b"\x79\x00"
    tramp += b"\x4c\x8b\x94\x24\x00\x01\x00\x00"
    tramp += b"\x44\x8b\x9c\x24\x08\x01\x00\x00"
    tramp += b"\x48\x83\xec\x30"
    tramp += b"\x4c\x89\x54\x24\x20"
    tramp += b"\x44\x89\x5c\x24\x28"
    tramp += b"\x48\x89\xd9"
    tramp += b"\x4c\x89\xea"
    tramp += b"\x41\x89\xf0"
    tramp += b"\x41\x89\xf9"
    c1 = here()
    tramp += b"\xe8" + struct.pack("<i", rel32(c1 + 5, LAZY))
    tramp += b"\x44\x8b\x44\x24\x28"
    tramp += b"\x48\x8b\x54\x24\x20"
    tramp += b"\x4c\x89\xe9"
    c2 = here()
    tramp += b"\xe8" + struct.pack("<i", rel32(c2 + 5, FIND))
    tramp += b"\x48\x83\xc4\x30"
    got = len(tramp)
    tramp[jns_at + 1] = (got - (jns_at + 2)) & 0xFF
    tramp += b"\x85\xc0"
    tramp += b"\x0f\x49\xe8"
    tramp += b"\x89\xe8"
    tramp += b"\x99"
    tramp += b"\x31\xd0\x29\xd0"
    tramp += b"\x3d\x00\x10\x00\x00"
    jbe_at = len(tramp)
    tramp += b"\x76\x00"
    tramp += b"\xbd\x18\x00\x00\x00"
    tramp[jbe_at + 1] = (len(tramp) - (jbe_at + 2)) & 0xFF
    jv = here()
    tramp += b"\xe9" + struct.pack("<i", rel32(jv + 5, CONT))
    return bytes(tramp)


def append_tpad(data: bytearray, pe: dict, vsz: int = 0x100) -> tuple[bytearray, dict, int]:
    """Append RX .tpad section at SizeOfImage. Mid-file .text expand AVs on dig5fwd."""
    assert pe["soh"] - (pe["opt"] + pe["optsz"] + pe["nsec"] * 40) >= 40
    new_sva = pe["soi"]
    new_rsz = pe["fa"]
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
    pe = parse_pe(data)
    data, pe, tramp_va = append_tpad(data, pe)
    tramp = build_tramp(tramp_va)
    assert len(tramp) <= 0x100, len(tramp)
    off_t = va_off(pe, tramp_va)
    assert data[off_t : off_t + len(tramp)] == b"\x00" * len(tramp)
    data[off_t : off_t + len(tramp)] = tramp
    off_h = va_off(pe, HOOK)
    pre = bytes(data[off_h : off_h + 10])
    assert pre == bytes.fromhex("85c00f49e8e9dffdffff"), pre.hex()
    data[off_h : off_h + 10] = (
        b"\xe9" + struct.pack("<i", tramp_va - (HOOK + 5)) + b"\x90" * 5
    )
    h = sha12(data)
    size = len(data)
    assert h not in BANNED, h
    assert size <= 10_000_000
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
