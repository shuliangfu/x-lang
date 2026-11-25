#!/usr/bin/env python3
"""PLATFORM: WINDOWS tip PE only — knife 11.55.

Inject host-gcc paren+ident stale_primary overrides into tip .text cave
and JMP the weak stubs onto them. Grow .text RawSize (+0x400) and shift
later PointerToRawData when the cave past VirtualSize is too small.
No Soft Cap mix.
"""
from __future__ import annotations

import argparse
import struct
import subprocess
import sys
from pathlib import Path

PLACE_VA = 0x1406474C0
GROW = 0x400
STUB_PAREN = 0x1405E4D40
STUB_IDENT = 0x1405E329C


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
    return e_lfanew, img_base, secs


def va_to_off(img_base: int, secs, va: int) -> int:
    rva = va - img_base
    for s in secs:
        if s["va"] <= rva < s["va"] + max(s["vsz"], s["rsz"]):
            return s["ro"] + (rva - s["va"])
    raise ValueError(f"VA {hex(va)} not in sections")


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


def grow_text(data: bytearray, e_lfanew: int, secs, grow: int) -> None:
    text = secs[0]
    assert text["name"] == ".text"
    old_rsz = text["rsz"]
    new_rsz = old_rsz + grow
    # insert zero bytes at end of .text raw
    insert_at = text["ro"] + old_rsz
    data[insert_at:insert_at] = b"\x00" * grow
    struct.pack_into("<I", data, text["hdr"] + 16, new_rsz)  # SizeOfRawData
    new_vsz = max(text["vsz"], new_rsz)
    struct.pack_into("<I", data, text["hdr"] + 8, new_vsz)  # VirtualSize
    text["rsz"] = new_rsz
    text["vsz"] = new_vsz
    for s in secs[1:]:
        if s["rsz"] == 0 and s["ro"] == 0:
            continue
        if s["ro"] >= insert_at:
            s["ro"] += grow
            struct.pack_into("<I", data, s["hdr"] + 20, s["ro"])
    print(f"grow .text RawSize {old_rsz:#x} -> {new_rsz:#x}; VirtualSize -> {new_vsz:#x}")


def patch_jmp(data: bytearray, img_base: int, secs, stub_va: int, target_va: int) -> None:
    soff = va_to_off(img_base, secs, stub_va)
    data[soff] = 0xE9
    struct.pack_into("<i", data, soff + 1, target_va - (stub_va + 5))
    data[soff + 5 : soff + 8] = b"\x90\x90\x90"
    print(f"JMP {stub_va:#x} -> {target_va:#x}")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("exe")
    ap.add_argument("obj", help="host-gcc -Os .o with paren+ident overrides")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    exe = Path(args.exe)
    obj = Path(args.obj)
    syms = load_nm(exe)
    obj_syms = load_obj_nm(obj)
    text, relocs = read_obj_text_relocs(obj)
    print(f"obj .text len={len(text):#x} relocs={len(relocs)}")
    if len(text) > GROW:
        print(f"obj too large for grow cave {GROW:#x}: {len(text):#x}", file=sys.stderr)
        return 2
    ident_off = obj_syms.get("__stale_prim_parser_asm_primary_ident_x_into_c")
    if ident_off is None:
        print("obj missing ident override symbol", file=sys.stderr)
        return 2
    data = bytearray(exe.read_bytes())
    e_lfanew, img_base, secs = pe_sections(data)
    text_sec = secs[0]
    assert text_sec["name"] == ".text"
    # need PLACE_VA mapped inside .text raw after grow
    need_end = (PLACE_VA - img_base) - text_sec["va"] + max(len(text), GROW)
    if text_sec["rsz"] < need_end or text_sec["vsz"] < need_end:
        if text_sec["rsz"] < need_end:
            grow_text(data, e_lfanew, secs, GROW)
            # refresh after grow (headers updated in secs)
        else:
            new_vsz = max(text_sec["vsz"], need_end, text_sec["rsz"])
            struct.pack_into("<I", data, text_sec["hdr"] + 8, new_vsz)
            text_sec["vsz"] = new_vsz
            print(f"bump .text VirtualSize -> {new_vsz:#x}")
    # re-read sections after possible grow
    e_lfanew, img_base, secs = pe_sections(data)
    place_off = va_to_off(img_base, secs, PLACE_VA)
    buf = bytearray(text)
    for off, sym in relocs:
        if sym not in syms:
            print(f"missing symbol {sym}", file=sys.stderr)
            return 2
        target = syms[sym]
        P = PLACE_VA + off + 4
        addend = struct.unpack_from("<i", buf, off)[0]
        struct.pack_into("<i", buf, off, target + addend - P)
    if len(buf) < GROW:
        buf.extend(b"\xcc" * (GROW - len(buf)))
    if args.dry_run:
        print(f"dry-run ok; ident_off={ident_off:#x}")
        return 0
    data[place_off : place_off + len(buf)] = buf
    paren_stub = syms.get("__stale_prim_parser_asm_primary_paren_x_into_c", STUB_PAREN)
    ident_stub = syms.get("__stale_prim_parser_asm_primary_ident_x_into_c", STUB_IDENT)
    patch_jmp(data, img_base, secs, paren_stub, PLACE_VA)
    patch_jmp(data, img_base, secs, ident_stub, PLACE_VA + ident_off)
    exe.write_bytes(data)
    print(f"injected {len(text):#x} bytes at {PLACE_VA:#x} (ident +{ident_off:#x})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
