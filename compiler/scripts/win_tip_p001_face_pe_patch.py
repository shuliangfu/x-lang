#!/usr/bin/env python3
"""Win tip P001 face PE patches (symbol-relative).

Proven dig_min -E green on tip 9324542aa (2026-11-09):
  1. pthin_expr_unary_tramp_face+0xe3: pass entry *Lexer (not zeroed local)
  2. pthin_expr_binop_tramp_level+0xeb: same
  3. pthin_primary_face_primary+0x15e: same
  4. parser_asm_primary_literal_x_into_c+0x454: save step_kind in %ebx
  5. lexer_next_body_into+0x1aeb: write_ident &out.tok out+8 → out+16

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
    # DIG 2026-11-09: tip computes &out.tok as out+8; product tok@+16.
    # Without this, write_ident smashes next_lex and parser still sees kind=1.
    ("lexer_next_body_into", 0x1AEB, "480508000000", "480510000000"),
    # DIG 2026-11-09 INT decimal: tip-stride stores at -0xe08 → natural Token;
    # write_tok was packing from empty -0x3b8. Point rdx at build slot -0xe08.
    ("lexer_next_body_into", 0x2933, "898308000000", "898304000000"),  # line @8→@4
    ("lexer_next_body_into", 0x2944, "898310000000", "898308000000"),  # col @0x10→@8
    ("lexer_next_body_into", 0x2953, "48898318000000", "48898310000000"),  # ival @0x18→@0x10
    ("lexer_next_body_into", 0x2966, "48898320000000", "48898318000000"),  # float @0x20→@0x18
    ("lexer_next_body_into", 0x2974, "48898328000000", "48898320000000"),  # ident @0x28→@0x20
    ("lexer_next_body_into", 0x2982, "898330000000", "898328000000"),  # ilen @0x30→@0x28
    ("lexer_next_body_into", 0x2A56, "488d8550ebffff", "488d85f8f1ffff"),  # write_tok src -0x14b0→-0xe08
    # Second INT emit (dig_min hits this): pack was -0x338 empty; same naturalize.
    ("lexer_next_body_into", 0x6E73, "898308000000", "898304000000"),
    ("lexer_next_body_into", 0x6E84, "898310000000", "898308000000"),
    ("lexer_next_body_into", 0x6E93, "48898318000000", "48898310000000"),
    ("lexer_next_body_into", 0x6EA6, "48898320000000", "48898318000000"),
    ("lexer_next_body_into", 0x6EB4, "48898328000000", "48898320000000"),
    ("lexer_next_body_into", 0x6EC2, "898330000000", "898328000000"),
    ("lexer_next_body_into", 0x6F96, "488d8568e3ffff", "488d85f8f1ffff"),  # -0x1c98→-0xe08
    # decimal loop d-spill: digit at -0x18 but loads used -0x1800 (→ ival=-8)
    ("lexer_next_body_into", 0x4840, "488b8500e8ffff", "488b85e8ffffff"),
    ("lexer_next_body_into", 0x4864, "488b8500e8ffff", "488b85e8ffffff"),
    # digit entry: Lexer.col tip@+0x10 OOB → product @+0x0c
    ("lexer_next_body_into", 0x1C61, "480510000000", "48050c000000"),
    # INT emit line/col from digit-entry saves -0xdb0/-0xdb8 (not never-written -0x2e8/-0x2f0)
    ("lexer_next_body_into", 0x6E68, "488b8518fdffff", "488b8550f2ffff"),
    ("lexer_next_body_into", 0x6E79, "488b8510fdffff", "488b8548f2ffff"),
    # DIG 2026-11-09: tip leaves %rbx stale; kind/arena arrive in %rcx.
    # SCALAR first null-check and ORD_C kind==0x3c compare both read %ebx.
    ("parser_asm_parse_builtin_scalar_type_x_into_c", 0x0C, "4889c8488945f0", "4889cb48895df0"),
    ("parser_asm_type_ref_builtin_kind_ord_c", 0x0C, "4889c8488945f0", "4889cb48895df0"),
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
