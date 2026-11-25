#!/usr/bin/env python3
"""PLATFORM: WINDOWS tip PE only — knife 11.59.

Inject host-gcc named_type_x override into tip .text cave (after 11.55
paren+ident PLACE+0x340) and JMP __stale_parser_asm_parse_named_type_x_into_c
onto it. Grow .text RawSize into the existing VA gap before .data (≤0x600);
no Soft Cap mix.
"""
from __future__ import annotations

import argparse
import struct
import subprocess
import sys
from pathlib import Path

# After 11.55 payload (last_nz 0x340 @ PLACE 0x1406474C0)
PLACE_VA = 0x140647800
GROW = 0x600  # fits VA gap .text→.data (0x600); must not overlap .data VA
STUB_NAMED = 0x1405CA248  # __stale_parser_asm_parse_named_type_x_into_c
SYM_LIVE = "parser_asm_parse_named_type_x_into_c"
# tip nm string-table broken after prior grow — prefer bak for U resolve
DEFAULT_NM_EXE = None


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
    data_sec = next((s for s in secs if s["name"] == ".data"), None)
    old_rsz = text["rsz"]
    new_rsz = old_rsz + grow
    new_vsz = max(text["vsz"], new_rsz)
    if data_sec is not None and text["va"] + new_vsz > data_sec["va"]:
        # clamp VirtualSize to gap before .data; RawSize may still grow in file
        max_vsz = data_sec["va"] - text["va"]
        if max_vsz < text["vsz"]:
            raise SystemExit(f"no VA room before .data (vsz={text['vsz']:#x} data={data_sec['va']:#x})")
        new_vsz = max_vsz
        print(f"clamp VirtualSize to VA gap -> {new_vsz:#x}")
    insert_at = text["ro"] + old_rsz
    data[insert_at:insert_at] = b"\x00" * grow
    struct.pack_into("<I", data, text["hdr"] + 16, new_rsz)
    struct.pack_into("<I", data, text["hdr"] + 8, new_vsz)
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
    ap.add_argument("obj")
    ap.add_argument("--nm-exe", default=None, help="PE for symbol resolve (bak if tip nm broken)")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    exe = Path(args.exe)
    obj = Path(args.obj)
    nm_path = Path(args.nm_exe) if args.nm_exe else exe
    syms = load_nm(nm_path)
    obj_syms = load_obj_nm(obj)
    text, relocs = read_obj_text_relocs(obj)
    print(f"obj .text len={len(text):#x} relocs={len(relocs)}")
    live_off = obj_syms.get(SYM_LIVE)
    if live_off is None:
        print(f"obj missing {SYM_LIVE}", file=sys.stderr)
        return 2
    # available: from PLACE_VA to .data VA
    data = bytearray(exe.read_bytes())
    e_lfanew, img_base, secs = pe_sections(data)
    text_sec = secs[0]
    data_sec = next(s for s in secs if s["name"] == ".data")
    max_end_va = img_base + data_sec["va"]
    need_end_va = PLACE_VA + len(text)
    if need_end_va > max_end_va:
        print(
            f"obj too large for VA gap: need end {need_end_va:#x} > data {max_end_va:#x} "
            f"(len={len(text):#x})",
            file=sys.stderr,
        )
        return 2
    need_end_off = (PLACE_VA - img_base) - text_sec["va"] + len(text)
    if text_sec["rsz"] < need_end_off:
        grow = ((need_end_off - text_sec["rsz"] + 0x1FF) // 0x200) * 0x200
        grow = max(grow, GROW)
        # don't grow past VA gap for VirtualSize clamp path
        grow_text(data, e_lfanew, secs, grow)
        e_lfanew, img_base, secs = pe_sections(data)
        text_sec = secs[0]
    elif text_sec["vsz"] < need_end_off:
        new_vsz = max(text_sec["vsz"], need_end_off)
        if img_base + text_sec["va"] + new_vsz > max_end_va:
            new_vsz = data_sec["va"] - text_sec["va"]
        struct.pack_into("<I", data, text_sec["hdr"] + 8, new_vsz)
        text_sec["vsz"] = new_vsz
        print(f"bump .text VirtualSize -> {new_vsz:#x}")
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
    if args.dry_run:
        print(f"dry-run ok; live_off={live_off:#x} place={PLACE_VA:#x}")
        return 0
    data[place_off : place_off + len(buf)] = buf
    stub = syms.get("__stale_parser_asm_parse_named_type_x_into_c", STUB_NAMED)
    patch_jmp(data, img_base, secs, stub, PLACE_VA + live_off)
    exe.write_bytes(data)
    print(f"injected {len(text):#x} bytes at {PLACE_VA:#x} (live +{live_off:#x})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
