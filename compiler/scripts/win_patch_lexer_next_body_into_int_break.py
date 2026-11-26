#!/usr/bin/env python3
"""Retarget typool lexer_next_body_into int-digit `else { break; }` + INT emit.

typool compiles the number-span while in lexer_next_body_into:

    while (l.pos < data.length) {
        if (lexer_is_digit(data[l.pos])) { accumulate; advance; }
        else if (lexer_is_digit_sep(data, l.pos, 0)) { advance '_'; }
        else { break; }
    }
    // then emit TOKEN_INT via huge-frame Token at -0xdd0

The typool-wrong `else { break; }` is a jmp back to the while head
(same class as skip_ws / skip_comment). s243 retargeted that jmp past
the continue trampoline (`after = break+10`). On tip PE that landing
is the while-exit merge that STILL has `pos < len` true when breaking
on `;`, so control falls into sibling float/hex arms and never reaches
the decimal `mov $0x50` INT emit — next_body advances past the digit
but leaves tok.kind=0 (DIG s246: `return 7;` → one_fn fail → nf=0).

s246 Soft Cap (PLATFORM: WINDOWS|X86_64):
  1) Retarget each else-break to the lea -0xdd0 that seeds the next
     `mov $0x50` INT emit in the same face (skip the merge fall-through).
  2) After that mov $0x50, typool copies write_tok_into from the wrong
     huge-frame slot -0x310 (kind stays 0 even when -0xdd0 has kind=80 /
     ival). Patch those `lea -0x310(%rbp)` to `lea -0xdd0(%rbp)`.
     Authority: runtime_pipeline_abi_lexer_emit_int_token_thin.c comments;
     host-cc twin remains available for a later from_body_into cave.

Idempotent. Refuses compiler/xlang_asm.exe. Soft Cap / tiphead HOLD.
"""
from __future__ import annotations

import argparse
import struct
import subprocess
import sys
from pathlib import Path


# After typool's call lexer_is_digit_sep (cltq; add $0x20,%rsp; test;
# setne; movzbl; test; je +0x3d). The je target is the typool-wrong break.
POST_CALL = bytes.fromhex("48984883c42085c00f95c00fb6c085c00f843d000000")
MOV_IMM50 = bytes.fromhex("b850000000")  # mov $0x50,%eax  (TOKEN_INT)
LEA_DD0 = bytes.fromhex("488d8530f2ffff")  # lea -0xdd0(%rbp),%rax
LEA_310 = bytes.fromhex("488d85f0fcffff")  # lea -0x310(%rbp),%rax


def pe_va_to_off(data: bytes, va: int) -> tuple[int, int]:
    e_lfanew = struct.unpack_from("<I", data, 0x3C)[0]
    coff = e_lfanew + 4
    nsec = struct.unpack_from("<H", data, coff + 2)[0]
    optsz = struct.unpack_from("<H", data, coff + 16)[0]
    magic = struct.unpack_from("<H", data, coff + 20)[0]
    if magic == 0x20B:
        image_base = struct.unpack_from("<Q", data, coff + 20 + 24)[0]
    else:
        image_base = struct.unpack_from("<I", data, coff + 20 + 28)[0]
    sec_off = coff + 20 + optsz
    rva = va - image_base
    for i in range(nsec):
        o = sec_off + i * 40
        vsz, va_s, rawsz, rawptr = struct.unpack_from("<IIII", data, o + 8)
        if va_s <= rva < va_s + max(vsz, rawsz):
            return rawptr + (rva - va_s), image_base
    raise SystemExit(f"VA 0x{va:x} not mapped")


def is_official_product(path: Path) -> bool:
    parts = [p.lower() for p in path.resolve().parts]
    return path.name.lower() == "xlang_asm.exe" and "compiler" in parts


def nm_text_addrs(exe: Path, name: str) -> list[int]:
    out = subprocess.check_output(["nm", str(exe)], text=True, errors="replace")
    addrs: list[int] = []
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 3 and parts[-1] == name and parts[1] in "TtWw":
            addrs.append(int(parts[0], 16))
    return sorted(set(addrs))


def find_mov50_vas(data: bytes, face_va: int, face_off: int, window: int) -> list[int]:
    blob = bytes(data[face_off : face_off + window])
    out: list[int] = []
    start = 0
    while True:
        i = blob.find(MOV_IMM50, start)
        if i < 0:
            break
        out.append(face_va + i)
        start = i + 1
    return out


def emit_lea_before_mov50(data: bytes, mov_va: int) -> int | None:
    """Return VA of lea -0xdd0 immediately before mov $0x50, if present."""
    off, _ = pe_va_to_off(data, mov_va)
    pre = bytes(data[off - 0x20 : off])
    j = pre.rfind(LEA_DD0)
    if j < 0:
        return None
    return mov_va - 0x20 + j


def find_sites(
    data: bytearray, exe: Path
) -> list[tuple[int, int, int, int, bytes, int | None]]:
    """Return (break_va, break_off, old_target, new_target, insn, mov50_va|None)."""
    addrs = nm_text_addrs(exe, "lexer_next_body_into")
    if not addrs:
        raise SystemExit("missing lexer_next_body_into")
    print("SYM lexer_next_body_into", [hex(a) for a in addrs])
    hits: list[tuple[int, int, int, int, bytes, int | None]] = []
    window = 0x8000
    for va in addrs:
        off, _image_base = pe_va_to_off(data, va)
        movs = find_mov50_vas(data, va, off, window)
        blob = bytes(data[off : off + window])
        start = 0
        while True:
            i = blob.find(POST_CALL, start)
            if i < 0:
                break
            je_off = off + i + (len(POST_CALL) - 6)
            je_va = va + (je_off - off)
            disp = struct.unpack_from("<i", data, je_off + 2)[0]
            break_va = je_va + 6 + disp
            break_off, _ = pe_va_to_off(data, break_va)
            insn = bytes(data[break_off : break_off + 5])
            if insn[0] != 0xE9:
                print(f"SKIP not jmp face={hex(va)} break={hex(break_va)} {insn.hex()}")
                start = i + 1
                continue
            rel = struct.unpack_from("<i", insn, 1)[0]
            old_target = break_va + 5 + rel
            # Prefer INT emit lea; else legacy skip-continue trampoline.
            nxt = [m for m in movs if m > break_va]
            mov50 = nxt[0] if nxt else None
            if mov50 is not None:
                emit = emit_lea_before_mov50(data, mov50)
                new_target = emit if emit is not None else mov50
            else:
                new_target = break_va + 10
            print(
                f"HIT face={hex(va)} je={hex(je_va)} break={hex(break_va)} "
                f"insn={insn.hex()} old={hex(old_target)} new={hex(new_target)} "
                f"mov50={hex(mov50) if mov50 else None}"
            )
            hits.append((break_va, break_off, old_target, new_target, insn, mov50))
            start = i + 1
    return hits


def patch_lea310_after_mov50(data: bytearray, mov50_va: int) -> int:
    """Rewrite lea -0x310(%rbp) → lea -0xdd0(%rbp) in the write_tok copy window."""
    off, _ = pe_va_to_off(data, mov50_va)
    n = 0
    # Field copies + call write_tok sit within ~0x200 of mov $0x50.
    for j in range(0, 0x200 - 7):
        abs_off = off + j
        if bytes(data[abs_off : abs_off + 7]) == LEA_310:
            data[abs_off : abs_off + 7] = LEA_DD0
            n += 1
    if n:
        print(f"LEA310→DD0 mov50={hex(mov50_va)} n={n}")
    return n


def patch_hits(
    data: bytearray, hits: list[tuple[int, int, int, int, bytes, int | None]]
) -> int:
    n = 0
    patched_movs: set[int] = set()
    for break_va, break_off, _old, new_target, insn, mov50 in hits:
        new_rel = new_target - (break_va + 5)
        new = bytes([0xE9]) + struct.pack("<i", new_rel)
        if insn != new:
            print(f"PATCH {hex(break_va)} {insn.hex()} -> {new.hex()} jmp {hex(new_target)}")
            data[break_off : break_off + 5] = new
            n += 1
        else:
            print(f"ALREADY {hex(break_va)} {insn.hex()}")
        if mov50 is not None and mov50 not in patched_movs:
            n += patch_lea310_after_mov50(data, mov50)
            patched_movs.add(mov50)
    return n


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("exe", type=Path)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    exe = args.exe
    if is_official_product(exe):
        raise SystemExit(f"refusing official product: {exe}")
    data = bytearray(exe.read_bytes())
    hits = find_sites(data, exe)
    print("HITS", len(hits))
    if not hits:
        raise SystemExit("no typool int-digit else-break sites")
    if args.dry_run:
        return 0
    n = patch_hits(data, hits)
    if n:
        exe.write_bytes(data)
    print(f"PATCHED {n} ops / {len(hits)} break sites")
    return 0


if __name__ == "__main__":
    sys.exit(main())
