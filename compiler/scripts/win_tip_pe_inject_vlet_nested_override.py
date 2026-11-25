#!/usr/bin/env python3
"""
PLATFORM: WINDOWS tip PE only — knife 11.48.

Inject host-gcc seeds/vector_let_init_nested_override.c .text into tip PE
at the dead tip egg vlet_scalar_one VA, resolve REL32 against tip symbols,
and JMP the tip vector_let_init entry points (short / mangled / stubdead)
onto the override export.

Root: tip egg many-arg ABI scrambles vlet_nested_body→vlet_scalar_one
(call site overwrites r8/r9; callee never loads stack homes). Host-gcc
override uses true MSVC and inlines the scalar loop (no tip scalar_one).

Do NOT Soft Cap G05 mix tip; do NOT raise tiphead/钉/Soft Cap.
"""
from __future__ import annotations

import argparse
import struct
import subprocess
import sys
from pathlib import Path


PLACE_VA = 0x14013AC24  # tip egg vlet_scalar_one (replaced)
EXPORT_OFF = 0x4A0  # pipeline_asm_emit_vector_let_init_elf_c in -O2 .o

JMP_FROM = (
    0x14013BE8C,  # short T
    0x140138D60,  # mangled T
    0x140138C90,  # stubdead T
)


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
        secs.append({"name": name, "va": va, "vsz": vsz, "ro": ro, "rsz": rsz})
    return img_base, secs


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
    ap.add_argument("exe", nargs="?", default="xlang_asm.exe")
    ap.add_argument("obj", nargs="?", default="vlet_ov.o")
    args = ap.parse_args()
    exe = Path(args.exe)
    obj = Path(args.obj)
    if not exe.is_file() or not obj.is_file():
        print(f"missing {exe} or {obj}", file=sys.stderr)
        return 2

    syms = load_nm(exe)
    text, relocs = read_obj_text_relocs(obj)
    if len(text) < EXPORT_OFF + 5:
        print(f"obj .text too small: {len(text):#x}", file=sys.stderr)
        return 2

    data = bytearray(exe.read_bytes())
    img_base, secs = pe_sections(data)
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

    data[place_off : place_off + len(buf)] = buf
    export_va = PLACE_VA + EXPORT_OFF

    def patch_jmp(from_va: int, to_va: int) -> None:
        off = va_to_off(img_base, secs, from_va)
        data[off] = 0xE9
        struct.pack_into("<i", data, off + 1, to_va - (from_va + 5))
        print(f"JMP {from_va:#x} -> {to_va:#x}")

    for va in JMP_FROM:
        patch_jmp(va, export_va)

    # Cap residual W twin if distinct
    for line in subprocess.check_output(["nm", str(exe)], text=True, errors="replace").splitlines():
        parts = line.split()
        if (
            len(parts) >= 3
            and parts[1] == "W"
            and parts[2]
            == "pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32"
        ):
            wva = int(parts[0], 16)
            if wva not in JMP_FROM and wva != export_va:
                patch_jmp(wva, export_va)

    exe.write_bytes(data)
    print(f"injected {len(buf):#x} bytes at {PLACE_VA:#x}; export {export_va:#x}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
