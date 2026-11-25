#!/usr/bin/env python3
"""PLATFORM: WINDOWS tip PE only — knife 11.55.
Inject host-gcc stale_primary paren(-only) override into tip .text tail cave
and JMP __stale_prim_parser_asm_primary_paren_x_into_c onto it.
Bump .text VirtualSize so the cave is mapped. No Soft Cap mix.
"""
from __future__ import annotations
import argparse, struct, subprocess, sys
from pathlib import Path

PLACE_VA = 0x1406474C0  # .text raw tail zeros (was past VirtualSize)
STUB_PAREN = 0x1405E4D40  # __stale_prim_parser_asm_primary_paren_x_into_c


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


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("exe")
    ap.add_argument("obj")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    exe = Path(args.exe)
    obj = Path(args.obj)
    syms = load_nm(exe)
    text, relocs = read_obj_text_relocs(obj)
    print(f"obj .text len={len(text):#x} relocs={len(relocs)}")
    if len(text) > 0x140:
        print(f"obj too large for cave 0x140: {len(text):#x}", file=sys.stderr)
        return 2
    data = bytearray(exe.read_bytes())
    e_lfanew, img_base, secs = pe_sections(data)
    text_sec = secs[0]
    assert text_sec["name"] == ".text"
    # bump VirtualSize to cover cave (RawSize already 0x646600)
    new_vsz = max(text_sec["vsz"], text_sec["rsz"])
    if new_vsz != text_sec["vsz"]:
        struct.pack_into("<I", data, text_sec["hdr"] + 8, new_vsz)
        print(f"bump .text VirtualSize {text_sec['vsz']:#x} -> {new_vsz:#x}")
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
    # pad to cave
    if len(buf) < 0x140:
        buf.extend(b"\xcc" * (0x140 - len(buf)))
    if args.dry_run:
        print("dry-run ok")
        return 0
    data[place_off : place_off + len(buf)] = buf
    # JMP stub -> PLACE
    stub = syms.get("__stale_prim_parser_asm_primary_paren_x_into_c", STUB_PAREN)
    soff = va_to_off(img_base, secs, stub)
    data[soff] = 0xE9
    struct.pack_into("<i", data, soff + 1, PLACE_VA - (stub + 5))
    # clear leftover stub bytes 5..7
    data[soff + 5 : soff + 8] = b"\x90\x90\x90"
    print(f"JMP {stub:#x} -> {PLACE_VA:#x}")
    exe.write_bytes(data)
    print(f"injected {len(text):#x} bytes at {PLACE_VA:#x}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
