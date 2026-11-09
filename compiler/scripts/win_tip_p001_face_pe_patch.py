#!/usr/bin/env python3
"""Win tip P001 face PE patches (symbol-relative).

Proven dig_min -E green on tip 9324542aa (2026-11-09):
  1. pthin_expr_unary_tramp_face+0xe3: pass entry *Lexer (not zeroed local)
  2. pthin_expr_binop_tramp_level+0xeb: same
  3. pthin_primary_face_primary+0x15e: same
  4. parser_asm_primary_literal_x_into_c+0x454: save step_kind in %ebx

PLATFORM: WINDOWS PE only. No-op on missing symbols (older tips).
"""
from __future__ import annotations
import struct
import subprocess
import sys
from pathlib import Path

PATCHES = [
    # (symbol, offset, old_hex, new_hex)
    ("pthin_expr_unary_tramp_face", 0xE3, "488d45b8", "488b45e8"),
    ("pthin_expr_binop_tramp_level", 0xEB, "488d45b0", "488b45e8"),
    ("pthin_primary_face_primary", 0x15E, "488d8500f6ffff", "488b45e8909090"),
    ("parser_asm_primary_literal_x_into_c", 0x454, "4898", "89c3"),
]


def pe_file_off(data: bytes, va: int) -> int:
    e_lfanew = struct.unpack_from("<I", data, 0x3C)[0]
    coff = e_lfanew + 4
    nsec = struct.unpack_from("<H", data, coff + 2)[0]
    opt_size = struct.unpack_from("<H", data, coff + 16)[0]
    opt = coff + 20
    magic = struct.unpack_from("<H", data, opt)[0]
    if magic != 0x20B:
        raise SystemExit(f"not PE32+: magic={magic:#x}")
    image_base = struct.unpack_from("<Q", data, opt + 24)[0]
    sec_off = opt + opt_size
    rva = va - image_base
    for i in range(nsec):
        off = sec_off + i * 40
        vsz, vaddr, rsz, raw = struct.unpack_from("<IIII", data, off + 8)
        if vaddr <= rva < vaddr + max(vsz, rsz):
            return raw + (rva - vaddr)
    raise SystemExit(f"VA {va:#x} not in any section")


def load_syms(exe: Path, image_base: int) -> dict[str, int]:
    out = subprocess.check_output(["nm", str(exe)], text=True, errors="replace")
    syms: dict[str, int] = {}
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 3 and parts[1] in "TtWw":
            v = int(parts[0], 16)
            syms[parts[2]] = v if v > image_base else image_base + v
    return syms


def main() -> int:
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]} <xlang.exe>", file=sys.stderr)
        return 2
    exe = Path(sys.argv[1])
    if not exe.is_file():
        print(f"missing {exe}", file=sys.stderr)
        return 1
    data = bytearray(exe.read_bytes())
    if data[:2] != b"MZ":
        print("not a PE (skip)", file=sys.stderr)
        return 0
    e_lfanew = struct.unpack_from("<I", data, 0x3C)[0]
    opt = e_lfanew + 4 + 20
    image_base = struct.unpack_from("<Q", data, opt + 24)[0]
    try:
        syms = load_syms(exe, image_base)
    except Exception as e:
        print(f"nm failed: {e}", file=sys.stderr)
        return 1
    applied = 0
    skipped = 0
    for name, off, old_h, new_h in PATCHES:
        if name not in syms:
            print(f"skip {name}: no symbol", file=sys.stderr)
            skipped += 1
            continue
        va = syms[name] + off
        foff = pe_file_off(bytes(data), va)
        old_b = bytes.fromhex(old_h)
        new_b = bytes.fromhex(new_h)
        cur = bytes(data[foff : foff + len(new_b)])
        if cur == new_b:
            print(f"ok {name}+{off:#x}: already patched", file=sys.stderr)
            skipped += 1
            continue
        if cur != old_b:
            # allow already-partial / tip drift
            print(
                f"FAIL {name}+{off:#x}: got {cur.hex()} want old {old_h} or new {new_h}",
                file=sys.stderr,
            )
            return 1
        data[foff : foff + len(new_b)] = new_b
        print(f"patch {name}+{off:#x}: {old_h} -> {new_h}", file=sys.stderr)
        applied += 1
    if applied:
        exe.write_bytes(data)
    print(f"win_tip_p001_face_pe_patch: applied={applied} skipped={skipped}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
