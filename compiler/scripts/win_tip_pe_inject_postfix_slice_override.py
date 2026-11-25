#!/usr/bin/env python3
"""PLATFORM: WINDOWS tip PE only — knife 11.63.

Inject host-gcc postfix_slice override into a new RX PE section (.c63slc)
and JMP __stale_parser_asm_parse_postfix_slice_x_into_c onto the tip-local
live. .text trailing cave exhausted after 11.62 PLACE5 (only 0x50 free).

Root: tip Prefer peel left the weak slot as e9→pipeline_type_init_slice_c
(wrong arity). Soft Cap Prefer has live into; tip has 8-byte miswired
thunk only. Soft Cap mix banned.
"""
from __future__ import annotations

import argparse
import struct
import subprocess
import sys
from pathlib import Path

STUB_SLICE = 0x1405C7B08  # __stale_parser_asm_parse_postfix_slice_x_into_c
SYM_LIVE = "parser_asm_parse_postfix_slice_x_into_c"
SYM_STALE = "__stale_parser_asm_parse_postfix_slice_x_into_c"
SEC_NAME = b".c63slc\0"  # 8 bytes
# IMAGE_SCN_CNT_CODE | MEM_EXECUTE | MEM_READ
SEC_CHARS = 0x60000020


def pe_sections(data: bytes):
    e_lfanew = struct.unpack_from("<I", data, 0x3C)[0]
    num_sec = struct.unpack_from("<H", data, e_lfanew + 6)[0]
    opt_size = struct.unpack_from("<H", data, e_lfanew + 20)[0]
    img_base = struct.unpack_from("<Q", data, e_lfanew + 24 + 24)[0]
    sec_off = e_lfanew + 24 + opt_size
    secs = []
    for i in range(num_sec):
        o = sec_off + i * 40
        name = data[o : o + 8].split(b"\0")[0].decode()
        vsz, va, rsz, ro = struct.unpack_from("<IIII", data, o + 8)
        secs.append({"name": name, "va": va, "vsz": vsz, "ro": ro, "rsz": rsz, "hdr": o})
    return e_lfanew, img_base, secs, sec_off, num_sec, opt_size


def va_to_off(img_base: int, secs, va: int) -> int:
    rva = va - img_base
    for s in secs:
        if s["va"] <= rva < s["va"] + max(s["vsz"], s["rsz"]):
            return s["ro"] + (rva - s["va"])
    raise ValueError(f"VA {hex(va)} not in sections")


def align_up(v: int, a: int) -> int:
    return (v + a - 1) & ~(a - 1)


def load_nm(exe: Path) -> dict[str, int]:
    out = subprocess.check_output(["nm", str(exe)], text=True, errors="replace")
    rank = {"T": 0, "W": 1, "t": 2, "w": 3}
    best: dict[str, tuple[int, int]] = {}
    for line in out.splitlines():
        parts = line.split()
        if len(parts) < 3:
            continue
        addr, kind, name = parts[0], parts[1], parts[2]
        if not all(c in "0123456789abcdefABCDEF" for c in addr):
            continue
        va = int(addr, 16)
        r = rank.get(kind, 9)
        if name not in best or r < best[name][0]:
            best[name] = (r, va)
    return {n: v for n, (_r, v) in best.items()}


def load_obj_nm(obj: Path) -> dict[str, int]:
    out = subprocess.check_output(["nm", str(obj)], text=True, errors="replace")
    syms: dict[str, int] = {}
    for line in out.splitlines():
        parts = line.split()
        if len(parts) < 3:
            continue
        addr, kind, name = parts[0], parts[1], parts[2]
        if kind in ("T", "t") and all(c in "0123456789abcdefABCDEF" for c in addr):
            syms[name] = int(addr, 16)
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
            or ":\\" in line
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


def patch_jmp(data: bytearray, stub_va: int, target_va: int, stub_off: int) -> None:
    data[stub_off] = 0xE9
    struct.pack_into("<i", data, stub_off + 1, target_va - (stub_va + 5))
    data[stub_off + 5 : stub_off + 8] = b"\x90\x90\x90"
    print(f"JMP {stub_va:#x} -> {target_va:#x}")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("exe")
    ap.add_argument("obj")
    ap.add_argument("--nm-exe", default=None)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    exe = Path(args.exe)
    obj = Path(args.obj)
    nm_path = Path(args.nm_exe) if args.nm_exe else exe
    syms = load_nm(nm_path)
    obj_syms = load_obj_nm(obj)
    text, relocs = read_obj_text_relocs(obj)
    print(f"obj .text len={len(text):#x} relocs={len(relocs)}")
    live = obj_syms.get(SYM_LIVE)
    if live is None:
        print(f"obj missing live {SYM_LIVE}", file=sys.stderr)
        return 2

    data = bytearray(exe.read_bytes())
    e_lfanew, img_base, secs, sec_off, num_sec, opt_size = pe_sections(data)
    sect_align = struct.unpack_from("<I", data, e_lfanew + 24 + 32)[0]
    file_align = struct.unpack_from("<I", data, e_lfanew + 24 + 36)[0]
    size_of_image_off = e_lfanew + 24 + 56
    size_of_image = struct.unpack_from("<I", data, size_of_image_off)[0]

    # header room
    first_ro = secs[0]["ro"]
    header_end = sec_off + num_sec * 40
    if header_end + 40 > first_ro:
        print(f"no room for section header ({header_end:#x}+40 > {first_ro:#x})", file=sys.stderr)
        return 2
    # refuse if section already present
    if any(s["name"] == ".c63slc" for s in secs):
        print("refuse: .c63slc already present", file=sys.stderr)
        return 2

    last = max(secs, key=lambda s: s["va"] + max(s["vsz"], s["rsz"]))
    new_va = align_up(last["va"] + max(last["vsz"], last["rsz"]), sect_align)
    raw_size = align_up(len(text), file_align)
    new_ro = align_up(len(data), file_align)
    place_va = img_base + new_va
    print(f"new section VA={new_va:#x} PLACE={place_va:#x} raw={raw_size:#x} ro={new_ro:#x}")

    buf = bytearray(text)
    for off, sym in relocs:
        if sym not in syms:
            print(f"missing symbol {sym}", file=sys.stderr)
            return 2
        target = syms[sym]
        P = place_va + off + 4
        addend = struct.unpack_from("<i", buf, off)[0]
        struct.pack_into("<i", buf, off, target + addend - P)

    if args.dry_run:
        print(f"dry-run ok; live+{live:#x} place={place_va:#x}")
        return 0

    # pad file to new_ro
    if len(data) < new_ro:
        data.extend(b"\x00" * (new_ro - len(data)))
    payload = bytes(buf) + b"\x00" * (raw_size - len(buf))
    data.extend(payload)

    # section header
    hdr = sec_off + num_sec * 40
    data[hdr : hdr + 8] = SEC_NAME
    struct.pack_into("<IIII", data, hdr + 8, len(text), new_va, raw_size, new_ro)
    struct.pack_into("<II", data, hdr + 24, 0, 0)  # relocs, linenumbers
    struct.pack_into("<HH", data, hdr + 32, 0, 0)
    struct.pack_into("<I", data, hdr + 36, SEC_CHARS)
    struct.pack_into("<H", data, e_lfanew + 6, num_sec + 1)

    new_soi = align_up(new_va + max(len(text), raw_size), sect_align)
    if new_soi < size_of_image:
        new_soi = size_of_image
    # must cover new section
    new_soi = align_up(new_va + max(len(text), raw_size), sect_align)
    struct.pack_into("<I", data, size_of_image_off, new_soi)

    # refresh secs for stub patch
    e_lfanew, img_base, secs, _, _, _ = pe_sections(data)
    stub_va = syms.get(SYM_STALE, STUB_SLICE)
    stub_off = va_to_off(img_base, secs, stub_va)
    # safety: stub must still be e9 or prior miswire
    if data[stub_off] not in (0xE9, 0x90):
        print(f"refuse: stub {stub_va:#x} not e9/nop (got {data[stub_off]:#x})", file=sys.stderr)
        return 2
    patch_jmp(data, stub_va, place_va + live, stub_off)
    exe.write_bytes(data)
    print(f"injected {len(text):#x} bytes at {place_va:#x} (.c63slc)")
    print(f"  postfix_slice live +{live:#x}; SizeOfImage={new_soi:#x}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
