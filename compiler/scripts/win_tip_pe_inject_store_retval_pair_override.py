#!/usr/bin/env python3
"""PLATFORM: WINDOWS tip PE only — tip.x-faithful store_retval 9–16 dual-GP.

Inject .c79srvp. Soft Cap mega drops rdx for named 9..16; other sizes trampoline.
Compile seed with gcc -O2 (NOT -O0): -O0 rbp-frame object yields PE that SEGVs si.
to Soft Cap. Ban Soft Cap Prefer body copy.
"""
from __future__ import annotations

import argparse
import hashlib
import struct
import subprocess
import sys
from pathlib import Path

ORIG = 0x14012AE98
STEAL = 12
SEC_NAME = b".c79srvp"
SEC_CHARS = 0x60000020

TIP_SYMS = {
    "glue_type_size_simple": 0x1400F94C8,
    "glue_sysv_dual_gp_byte_size_c": 0x140295B57,
    "backend_enc_store_rax_to_rbp_arch": 0x14052967C,
    "backend_enc_store_rdx_to_rbp_arch": 0x14052B8B8,
}


def pe_sections(data: bytes):
    e_lfanew = struct.unpack_from("<I", data, 0x3C)[0]
    num_sec = struct.unpack_from("<H", data, e_lfanew + 6)[0]
    opt_size = struct.unpack_from("<H", data, e_lfanew + 20)[0]
    img_base = struct.unpack_from("<Q", data, e_lfanew + 24 + 24)[0]
    sec_off = e_lfanew + 24 + opt_size
    secs = []
    for i in range(num_sec):
        o = sec_off + i * 40
        name = data[o : o + 8].split(b"\0")[0].decode(errors="replace")
        vsz, va, rsz, ro = struct.unpack_from("<IIII", data, o + 8)
        secs.append({"name": name, "va": va, "vsz": vsz, "ro": ro, "rsz": rsz})
    return e_lfanew, img_base, secs, sec_off, num_sec, opt_size


def va_to_off(img_base: int, secs, va: int) -> int:
    rva = va - img_base
    for s in secs:
        if s["va"] <= rva < s["va"] + max(s["vsz"], s["rsz"]):
            return s["ro"] + (rva - s["va"])
    raise ValueError(f"VA {va:#x} not in sections")


def align_up(v: int, a: int) -> int:
    return (v + a - 1) & ~(a - 1)


def load_obj_nm(obj: Path) -> dict[str, int]:
    out = subprocess.check_output(["nm", str(obj)], text=True, errors="replace")
    syms: dict[str, int] = {}
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 3 and parts[1] in ("T", "t") and all(
            c in "0123456789abcdefABCDEF" for c in parts[0]
        ):
            syms[parts[2]] = int(parts[0], 16)
    return syms


def read_obj_text_relocs(obj_path: Path):
    text = subprocess.check_output(
        ["objdump", "-s", "-j", ".text", str(obj_path)], text=True, errors="replace"
    )
    blob = bytearray()
    for line in text.splitlines():
        line = line.strip()
        if (
            not line
            or "Contents" in line
            or line.startswith(".text")
            or "file format" in line
            or line.endswith(".o:")
        ):
            continue
        parts = line.split()
        if not parts:
            continue
        try:
            off = int(parts[0], 16)
        except ValueError:
            continue
        hexbytes: list[int] = []
        for p in parts[1:]:
            if len(p) == 8 and all(c in "0123456789abcdefABCDEF" for c in p):
                for i in range(0, 8, 2):
                    hexbytes.append(int(p[i : i + 2], 16))
            else:
                break
        while len(blob) < off:
            blob.append(0)
        blob[off : off + len(hexbytes)] = bytes(hexbytes)
    rel_out = subprocess.check_output(
        ["objdump", "-r", "-j", ".text", str(obj_path)], text=True, errors="replace"
    )
    relocs: list[tuple[int, str]] = []
    for line in rel_out.splitlines():
        line = line.strip()
        if "IMAGE_REL_AMD64_REL32" not in line:
            continue
        parts = line.split()
        relocs.append((int(parts[0], 16), parts[2]))
    return bytes(blob), relocs


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("exe")
    ap.add_argument("obj")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    exe = Path(args.exe)
    obj = Path(args.obj)
    obj_syms = load_obj_nm(obj)
    live = obj_syms.get("glue_store_retval_pair_to_rbp_elf_c")
    if live is None:
        print("obj missing glue_store_retval_pair_to_rbp_elf_c", file=sys.stderr)
        return 2
    text, relocs = read_obj_text_relocs(obj)
    data = bytearray(exe.read_bytes())
    e_lfanew, img_base, secs, sec_off, num_sec, opt_size = pe_sections(data)
    sect_align = struct.unpack_from("<I", data, e_lfanew + 24 + 32)[0]
    file_align = struct.unpack_from("<I", data, e_lfanew + 24 + 36)[0]
    size_of_image_off = e_lfanew + 24 + 56
    size_of_image = struct.unpack_from("<I", data, size_of_image_off)[0]
    if any(s["name"].startswith(".c79srvp") for s in secs):
        print("refuse: .c79srvp already present", file=sys.stderr)
        return 2
    orig_off = va_to_off(img_base, secs, ORIG)
    stolen = bytes(data[orig_off : orig_off + STEAL])
    expect = bytes.fromhex("554889e5534881ec68130000")
    if stolen != expect:
        print(f"refuse: unexpected orig bytes {stolen.hex()}", file=sys.stderr)
        return 2
    if data[orig_off] == 0xE9:
        print("refuse: orig already JMP'd", file=sys.stderr)
        return 2

    tramp_len = STEAL + 5
    last = max(secs, key=lambda s: s["va"] + max(s["vsz"], s["rsz"]))
    new_va = align_up(last["va"] + max(last["vsz"], last["rsz"]), sect_align)
    place_va = img_base + new_va
    tramp_va = place_va
    live_va = place_va + tramp_len + live

    tramp = bytearray(stolen)
    tramp.append(0xE9)
    tramp.extend(struct.pack("<i", (ORIG + STEAL) - (tramp_va + STEAL + 5)))

    buf = bytearray(text)
    tip_map = dict(TIP_SYMS)
    tip_map["glue_store_retval_pair_to_rbp_elf_c__orig"] = tramp_va
    for off, sym in relocs:
        if sym not in tip_map:
            print(f"missing tip VA for {sym}", file=sys.stderr)
            return 2
        P = place_va + tramp_len + off + 4
        addend = struct.unpack_from("<i", buf, off)[0]
        struct.pack_into("<i", buf, off, tip_map[sym] + addend - P)

    payload_body = bytes(tramp) + bytes(buf)
    raw_size = align_up(len(payload_body), file_align)
    new_ro = align_up(len(data), file_align)

    if args.dry_run:
        print(f"dry-run ok tramp={tramp_va:#x} live={live_va:#x}")
        return 0

    if len(data) < new_ro:
        data.extend(b"\x00" * (new_ro - len(data)))
    payload = payload_body + b"\x00" * (raw_size - len(payload_body))
    data.extend(payload)
    hdr = sec_off + num_sec * 40
    if hdr + 40 > secs[0]["ro"]:
        print("no room for section header", file=sys.stderr)
        return 2
    name = SEC_NAME + b"\x00" * (8 - len(SEC_NAME))
    data[hdr : hdr + 8] = name
    struct.pack_into("<IIII", data, hdr + 8, len(payload_body), new_va, raw_size, new_ro)
    struct.pack_into("<II", data, hdr + 24, 0, 0)
    struct.pack_into("<HH", data, hdr + 32, 0, 0)
    struct.pack_into("<I", data, hdr + 36, SEC_CHARS)
    struct.pack_into("<H", data, e_lfanew + 6, num_sec + 1)
    new_soi = align_up(
        max(size_of_image, new_va + max(len(payload_body), raw_size)), sect_align
    )
    struct.pack_into("<I", data, size_of_image_off, new_soi)

    e_lfanew, img_base, secs, _, _, _ = pe_sections(data)
    orig_off = va_to_off(img_base, secs, ORIG)
    data[orig_off] = 0xE9
    struct.pack_into("<i", data, orig_off + 1, live_va - (ORIG + 5))
    for i in range(5, STEAL):
        data[orig_off + i] = 0x90

    exe.write_bytes(data)
    print(f"JMP {ORIG:#x} -> {live_va:#x} (tramp {tramp_va:#x}); .c79srvp dual-GP band")
    print("sha16", hashlib.sha256(data).hexdigest()[:16])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
