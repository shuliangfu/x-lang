#!/usr/bin/env python3
"""Win tip PE bundle: proven hello zero-T001 patches (replay on live tip).

Covers digs that cleared hello -L -E to EXIT0 / 0x T001 on
xlang.exe.live_shift (md5 1da0458220a56e71259f4a9b294886fe), beyond the
panic/else-only knife 4d6774c6e:

  - cfg Token field displaces in lexer_try_cfg_attr_into
  - get_dep alt path NOP
  - merge_dep_struct_layouts branch NOP / bound tweak
  - prefer-ctx: check_call_arity + check_call_arg_types je->jmp
  - Ident-kind ebx reload in type_ref_impl
  - struct lit field_value / append stubs + fields-peek ebx
  - panic() / if-else ebx peeks (also in win_tip_hello_soft_t001_pe_patch.py)

NOT included (unproven): overload first_idx->j2.

Struct-lit stub bodies embed tip-relative E8/E9 displacements; they only
apply when the old bytes match this tip layout (safe no-op otherwise).

PLATFORM: WINDOWS PE. Soft Cap / tiphead HOLD — replay on tip-aside / live
tip; do not treat as a tip L4 source rebuild.
"""
from __future__ import annotations

import struct
import subprocess
import sys
from pathlib import Path

# (symbol, offset, old_hex, new_hex, note)
PATCHES = [
    # --- cfg Token displaces (line/col/ival/... @ Token+4..) ---
    (
        "lexer_try_cfg_attr_into",
        0xB27,
        "08000000488b45b848985b53898310000000488b459048985b5348898318",
        "04000000488b45b848985b53898308000000488b459048985b5348898310",
        "cfg Token offs 8/16/24 -> 4/8/16",
    ),
    (
        "lexer_try_cfg_attr_into",
        0xB57,
        "20000000b8000000005b5348898328000000b8000000005b53898330",
        "18000000b8000000005b5348898320000000b8000000005b53898328",
        "cfg Token offs 32/40/48 -> 24/32/40",
    ),
    # --- get_dep alt NOP ---
    (
        "typeck_get_dep_return_type_in_caller_arena_i32_i32_ASTArena_ptr_PipelineDepCtx_ptr_reti32",
        0x95,
        "488b45d8488945f8",
        "9090909090909090",
        "get_dep alt mov NOP",
    ),
    # --- merge ---
    (
        "typeck_merge_dep_struct_layouts_into_entry",
        0x165,
        "0e837dc0007e08488b4588488945f048837de8007508",
        "1d837dc0007e17488b4588488945f048837de8009090",
        "merge bound + jne NOP",
    ),
    # --- prefer-ctx ---
    ("typeck_check_call_arity", 0x2DC, "74", "eb", "prefer-ctx arity je->jmp"),
    ("typeck_check_call_arg_types", 0x145, "74", "eb", "prefer-ctx arg_types je->jmp"),
    # --- Ident-kind ---
    (
        "parser_asm_parse_type_ref_impl_x_into_c",
        0x5BD,
        "7e",
        "79",
        "Ident-kind je retarget into cave",
    ),
    (
        "parser_asm_parse_type_ref_impl_x_into_c",
        0x63A,
        "e900000000",
        "488b5db090",
        "Ident-kind cave mov ebx,[rbp-0x50]",
    ),
    # --- struct lit stubs + fields-peek (layout-tied) ---
    (
        "parser_asm_struct_lit_append_field_src_c",
        0x4,
        "534881ec880800004889c8488945f04889d0488945e84c89c0488945e04c89c8488945d8488b4530488945d0488b4538488945c848b8ffffffffffffffff488d65f85b5dc3000000554889e5534881ec880800004889c8488945f04889d0488945e84c89c0488945e04c89c8488945d8488b4530488945d048b8ffffffffffffffff488d65f85b5dc3000000",
        "4883ec3048894df8488955f04c894de04c89c1e8e8300200480345e04989c0488b4df88b55f0448b4d30488b45384889442420e8bcf5d0ffc9c39090909090909090909090909090488d45b031c94889084889480848894810488b4df0488b55e84c8b45e04989c1e843d2ffff488d4db0488b55e84c8b45d84c8b4dd0e88ad5ffff31c0ffc0488b5df8c9c3",
        "append_field stub -> real thin body",
    ),
    (
        "parser_asm_struct_lit_parse_field_value_c",
        0x30,
        "b800000000488d65f85b5dc30000000000000000",
        "e987ffffff909090909090909090909090909090",
        "field_value stub -> jmp body in shorthand slot",
    ),
    (
        "parser_asm_parse_struct_lit_fields_x_into_c",
        0x628,
        "4898",
        "89c3",
        "fields-peek cltq->mov ebx,eax",
    ),
    # --- soft T001 (also win_tip_hello_soft_t001_pe_patch.py) ---
    ("parser_asm_primary_panic_x_into_c", 0x201, "4898", "89c3", "panic LPAREN ebx"),
    ("parser_asm_primary_panic_x_into_c", 0x27C, "4898", "89c3", "panic RPAREN ebx"),
    ("parser_asm_primary_panic_x_into_c", 0x3B8, "4898", "89c3", "panic post-expr RPAREN ebx"),
    ("parser_asm_parse_if_stmt_x_into_c", 0x5FB, "4898", "89c3", "else TOKEN_ELSE ebx"),
    ("parser_asm_parse_if_stmt_x_into_c", 0x676, "4898", "89c3", "else TOKEN_IF ebx"),
]


def pe_image_base(data: bytes) -> int:
    e_lfanew = struct.unpack_from("<I", data, 0x3C)[0]
    opt = e_lfanew + 24
    if struct.unpack_from("<H", data, opt)[0] != 0x20B:
        raise SystemExit("not PE32+")
    return struct.unpack_from("<Q", data, opt + 24)[0]


def va_to_off(data: bytes, va: int, image_base: int) -> int:
    e_lfanew = struct.unpack_from("<I", data, 0x3C)[0]
    nsec = struct.unpack_from("<H", data, e_lfanew + 6)[0]
    opt_size = struct.unpack_from("<H", data, e_lfanew + 20)[0]
    sec_off = e_lfanew + 24 + opt_size
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
            name, kind = parts[2], parts[1]
            v = int(parts[0], 16)
            va = v if v > image_base else image_base + v
            if name in kinds and kinds[name] in "Tt" and kind in "Ww":
                continue
            syms[name] = va
            kinds[name] = kind
    return syms


def main() -> int:
    if len(sys.argv) < 2:
        print(f"usage: {sys.argv[0]} <xlang.exe> [--dry-run]", file=sys.stderr)
        return 2
    exe = Path(sys.argv[1])
    dry = "--dry-run" in sys.argv[2:]
    data = bytearray(exe.read_bytes())
    image_base = pe_image_base(data)
    syms = load_syms(exe, image_base)
    ok = skipped = mismatched = 0
    for sym, offset, old_h, new_h, note in PATCHES:
        if sym not in syms:
            print(f"SKIP missing {sym} ({note})")
            skipped += 1
            continue
        va = syms[sym] + offset
        off = va_to_off(data, va, image_base)
        old_b, new_b = bytes.fromhex(old_h), bytes.fromhex(new_h)
        cur = bytes(data[off : off + len(old_b)])
        if cur == new_b:
            print(f"OK already {sym}+{offset:#x} ({note})")
            ok += 1
            continue
        if cur != old_b:
            print(
                f"SKIP mismatch {sym}+{offset:#x} ({note}): "
                f"have {cur.hex()[:32]}… want {old_h[:32]}…"
            )
            mismatched += 1
            continue
        print(f"PATCH {sym}+{offset:#x} ({note})")
        if not dry:
            data[off : off + len(new_b)] = new_b
        ok += 1
    if not dry and ok:
        exe.write_bytes(data)
        print(f"wrote {exe}")
    print(f"dry={dry} ok={ok} skipped_missing={skipped} mismatched={mismatched}")
    # mismatch on layout-tied stubs is OK on foreign tips; missing symbols is not
    return 0 if skipped == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
