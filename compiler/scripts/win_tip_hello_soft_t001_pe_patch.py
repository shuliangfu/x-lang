#!/usr/bin/env python3
"""Win tip PE patches: clear hello soft T001 (panic ebx + if/else ebx).

Root causes (same class as fields-peek / Ident-kind — peek_kind result left in
%eax while the compare still reads stale %ebx):

1) parser_asm_primary_panic_x_into_c: after peek for LPAREN / RPAREN, cltq left
   %ebx holding TOKEN_PANIC (12). `panic()` / `return panic()` then skipped the
   paren arm, left `()` in the stream, and dropped the enclosing function from
   funcs[] — so core/result expect_or_panic vanished and hello printed soft
   "cannot resolve expect_or_panic()".

2) parser_asm_parse_if_stmt_x_into_c: after peek for TOKEN_ELSE / TOKEN_IF, the
   same stale-%ebx compare skipped a real `else { ... }` arm. Functions whose
   bodies need if/else (notably std.io.read_ptr.io_read_ptr_slice) were dropped
   → hello soft T001 "no impl for type with method io_read_ptr_slice".

Patch: replace the two-byte `cltq` (48 98) immediately after those peeks with
`mov %eax, %ebx` (89 c3) so the following cmp uses the fresh kind.

Proven 2026-11-10 on live_shift (post structlit/Ident-kind/prefer-ctx priors):
  hello -L -E ×5 EXIT0, 0× T001, no AV; backend/win32/result/t_imp_be/
  t_cfg_ssw/t_g1/float/*u8/f("hi") EXIT0.

PLATFORM: WINDOWS PE only. Soft Cap / tiphead HOLD — do not rebuild tip L4.
"""
from __future__ import annotations

import struct
import subprocess
import sys
from pathlib import Path

# (symbol, offset, old_hex, new_hex)
PATCHES = [
    # primary_panic: LPAREN peek, empty-RPAREN peek, post-expr RPAREN peek
    ("parser_asm_primary_panic_x_into_c", 0x201, "4898", "89c3"),
    ("parser_asm_primary_panic_x_into_c", 0x27C, "4898", "89c3"),
    ("parser_asm_primary_panic_x_into_c", 0x3B8, "4898", "89c3"),
    # if_stmt: TOKEN_ELSE peek, post-else TOKEN_IF peek (LBRACE arm uses same ebx)
    ("parser_asm_parse_if_stmt_x_into_c", 0x5FB, "4898", "89c3"),
    ("parser_asm_parse_if_stmt_x_into_c", 0x676, "4898", "89c3"),
]


def pe_image_base(data: bytes) -> int:
    e_lfanew = struct.unpack_from("<I", data, 0x3C)[0]
    opt = e_lfanew + 24
    magic = struct.unpack_from("<H", data, opt)[0]
    if magic != 0x20B:
        raise SystemExit(f"not PE32+: magic={magic:#x}")
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
    applied = skipped = 0
    for sym, offset, old_h, new_h in PATCHES:
        if sym not in syms:
            print(f"SKIP missing symbol {sym}")
            skipped += 1
            continue
        va = syms[sym] + offset
        off = va_to_off(data, va, image_base)
        old_b, new_b = bytes.fromhex(old_h), bytes.fromhex(new_h)
        cur = bytes(data[off : off + len(old_b)])
        if cur == new_b:
            print(f"OK already {sym}+{offset:#x}")
            applied += 1
            continue
        if cur != old_b:
            print(f"SKIP mismatch {sym}+{offset:#x}: have {cur.hex()} want {old_h}")
            skipped += 1
            continue
        print(f"PATCH {sym}+{offset:#x} {old_h} -> {new_h}")
        if not dry:
            data[off : off + len(new_b)] = new_b
        applied += 1
    if not dry and applied:
        exe.write_bytes(data)
        print(f"wrote {exe} ({applied} sites, {skipped} skipped)")
    else:
        print(f"dry={dry} applied={applied} skipped={skipped}")
    return 0 if skipped == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
