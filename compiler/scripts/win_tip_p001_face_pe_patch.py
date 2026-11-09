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
    # DIG 2026-11-09 L2: Lexer.col product@+0x0c; tip advance/alpha used +0x10 (stack smash / bad col).
    ("lexer_advance_one", 0x82, "480510000000", "48050c000000"),

    ("lexer_next_body_into", 0x1774, "480510000000", "48050c000000"),
    # DIG 2026-11-09 IDENT expr: suffix_loop zero-init uses uninit [rbp-0x50] as i32[8]
    # base; residual often aliases Pos* -> zeroes working pos after step_kind (29->31->0).
    # INT lucked into a safe residual; IDENT smashed Pos -> tip Result+8=0 -> adv_semi kind=1.
    # Init -0x50 to unused frame scratch -0x2a00 before source_data (compress redundant mov).
    ("parser_asm_primary_suffix_loop_x_into_c", 0x2C0,
     "488b45e848898570feffff488b8570feffff4889c1",
     "488d8500d6ffff488945b0488b45e84889c1909090"),
    # DIG 2026-11-09: DOT compare used stale %ebx; reload peek kind from -0x70.
    ("parser_asm_primary_suffix_loop_x_into_c", 0x4A6,
     "488b4590489848898578ffffff",
     "488b5d9048899d78ffffff9090"),
    # DIG 2026-11-09: call-arg after peek COMMA/RPAREN used stale %ebx.
    ("parser_asm_primary_suffix_loop_x_into_c", 0x295A, "48894588", "4889c390"),
    ("parser_asm_primary_suffix_loop_x_into_c", 0xB6C, "48894588", "4889c390"),
    # field/other arg-loop site: keep kind in rbx and -0x78
    ("parser_asm_primary_suffix_loop_x_into_c", 0x20C6, "48894588488b5d88", "4889c34889458890"),
    # skip_ws: tip Lexer.col@+0x10 -> product @+0x0c (block comment / rv header)
    ("lexer_skip_whitespace_and_comments", 0x8E, "480510000000", "48050c000000"),
    ("lexer_skip_whitespace_and_comments", 0x9D, "480510000000", "48050c000000"),
    ("lexer_skip_whitespace_and_comments", 0x6CC, "480510000000", "48050c000000"),
    ("lexer_skip_whitespace_and_comments", 0x121D, "480510000000", "48050c000000"),
    ("lexer_skip_whitespace_and_comments", 0x122C, "480510000000", "48050c000000"),
    ("lexer_skip_whitespace_and_comments", 0x13F8, "480510000000", "48050c000000"),
    ("lexer_skip_whitespace_and_comments", 0x1407, "480510000000", "48050c000000"),
    ("lexer_skip_whitespace_and_comments", 0x1453, "480510000000", "48050c000000"),
    ("lexer_skip_whitespace_and_comments", 0x1462, "480510000000", "48050c000000"),
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
    kinds: dict[str, str] = {}
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 3 and parts[1] in "TtWw":
            name = parts[2]
            kind = parts[1]
            v = int(parts[0], 16)
            va = v if v > image_base else image_base + v
            # Prefer strong text (T/t) over weak (W/w) aliases.
            if name in kinds and kinds[name] in "Tt" and kind in "Ww":
                continue
            syms[name] = va
            kinds[name] = kind
    return syms




# DIG 2026-11-09f/g hello import-const: collect CONST ebx + STRING tok +
# validate hollow + modcollect Fat* ABI + bound_check 7th/8th args.
HELLO_IMPORT_PATCHES = [
    ("parser_asm_collect_imports_into_c", 0x374,
     "b80300000039c3", "8b5db083fb0390"),
    ("parser_asm_collect_imports_into_c", 0x45C, "4898", "89c3"),
    ("lexer_next_body_into", 0x62A, "48898550f2ffff", "488945b8909090"),
    ("lexer_next_body_into", 0x635, "480510000000", "48050c000000"),
    ("lexer_next_body_into", 0x63F, "48898548f2ffff", "488945b0909090"),
    ("lexer_next_body_into", 0x665, "48898558f2ffff", "488945a8909090"),
    ("lexer_next_body_into", 0x159D, "898308000000", "898304000000"),
    ("lexer_next_body_into", 0x15AB, "898310000000", "898308000000"),
    ("lexer_next_body_into", 0x15E8, "898330000000", "898328000000"),
    ("parser_asm_stretch_import_path_validate_c", 0x1A, "b800000000", "b801000000"),
    ("xlang_module_collect_imports_from_buf", 0x231,
     "488b85b0feffff4889c2488b85a8feffff4889c1488b8588feffff4989c0488b8568feffff4989c1488b8548feffff4889442420488b8528feffff4889442428",
     "488d8da8feffff488b9588feffff4c8b8568feffff4c8b8d48feffff488b8528feffff4889442420" + ("90" * 24)),
    ("xlang_generic_bound_check_into_c", 0x38,
     "b800000000488945a8b800000000488945a0",
     "488b4540488945c0488b4548488945b89090"),
]

# DIG 2026-11-09 block-comment depth: loop read -0x40 never set; use global nest
BLKDEPTH_PATCHES = [
    ("lexer_skip_whitespace_and_comments", 0x727,
     "488d1d8670d609488903", "8945c04889058370d609"),
    ("lexer_skip_whitespace_and_comments", 0x759,
     "488b45c048984889c3", "8b055570d60989c390"),
    ("lexer_skip_whitespace_and_comments", 0x1030,
     "488b45c048984889c3", "8b057e67d60989c390"),
]


# DIG 2026-11-09c float no-exp emit: write_tok source -0x9a8 -> -0xe08
FLOAT_SLOT_PATCHES = [
    ("lexer_next_body_into", 0x5916, "488d8558f6ffff", "488d85f8f1ffff"),
    ("lexer_next_body_into", 0x5927, "488d8558f6ffff", "488d85f8f1ffff"),
    ("lexer_next_body_into", 0x593e, "488d8558f6ffff", "488d85f8f1ffff"),
    ("lexer_next_body_into", 0x5955, "488d8558f6ffff", "488d85f8f1ffff"),
    ("lexer_next_body_into", 0x596c, "488d8558f6ffff", "488d85f8f1ffff"),
    ("lexer_next_body_into", 0x5983, "488d8558f6ffff", "488d85f8f1ffff"),
]


def _i32(x: int) -> bytes:
    return struct.pack("<i", x)


def apply_blkdepth_rip(data: bytearray, syms: dict[str, int], image_base: int) -> tuple[int, int]:
    """Rewrite block-comment nest PE using live RIP (cold tip drift-safe).

    DIG: tip loop read -0x40 never set; use .bss nest global instead.
    Site+0x727 stores nest; +0x759/+0x1030 load nest. RIP displ changes per tip.
    """
    name = "lexer_skip_whitespace_and_comments"
    if name not in syms:
        print(f"skip {name}: no symbol", file=sys.stderr)
        return 0, 1
    base = syms[name]
    applied = skipped = 0

    off727 = 0x727
    va727 = base + off727
    f727 = pe_file_off(bytes(data), va727)
    cur727 = bytes(data[f727 : f727 + 10])
    new727_prefix = bytes.fromhex("8945c0488905")
    if cur727.startswith(new727_prefix) and len(cur727) == 10:
        print(f"ok {name}+{off727:#x}: already patched", file=sys.stderr)
        skipped += 1
        displ = struct.unpack_from("<i", cur727, 6)[0]
        nest_va = va727 + 10 + displ
    elif cur727[:3] == bytes.fromhex("488d1d") and cur727[7:10] == bytes.fromhex("488903"):
        displ = struct.unpack_from("<i", cur727, 3)[0]
        nest_va = va727 + 7 + displ
        new_displ = nest_va - (va727 + 10)
        newb = new727_prefix + _i32(new_displ)
        data[f727 : f727 + 10] = newb
        print(f"patch {name}+{off727:#x}: blkdepth store rip -> nest@{nest_va:#x}", file=sys.stderr)
        applied += 1
    else:
        print(f"FAIL {name}+{off727:#x}: got {cur727.hex()} (blkdepth store)", file=sys.stderr)
        raise SystemExit(1)

    for off, tag in ((0x759, "loadA"), (0x1030, "loadB")):
        va = base + off
        foff = pe_file_off(bytes(data), va)
        cur = bytes(data[foff : foff + 9])
        if cur[:2] == bytes.fromhex("8b05") and cur[6:9] == bytes.fromhex("89c390"):
            print(f"ok {name}+{off:#x}: already patched", file=sys.stderr)
            skipped += 1
            continue
        old = bytes.fromhex("488b45c048984889c3")
        if cur != old:
            print(f"FAIL {name}+{off:#x}: got {cur.hex()} want {old.hex()} (blkdepth {tag})", file=sys.stderr)
            raise SystemExit(1)
        new_displ = nest_va - (va + 6)
        newb = bytes.fromhex("8b05") + _i32(new_displ) + bytes.fromhex("89c390")
        data[foff : foff + 9] = newb
        print(f"patch {name}+{off:#x}: blkdepth {tag} rip -> nest@{nest_va:#x}", file=sys.stderr)
        applied += 1
    return applied, skipped


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
    try:
        a, s = apply_blkdepth_rip(data, syms, image_base)
        applied += a
        skipped += s
    except SystemExit:
        return 1
    all_patches = PATCHES + HELLO_IMPORT_PATCHES + FLOAT_SLOT_PATCHES
    for name, off, old_h, new_h in all_patches:
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
