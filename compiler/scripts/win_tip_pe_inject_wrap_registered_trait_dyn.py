#!/usr/bin/env python3
"""PLATFORM: WINDOWS tip PE only — knife 11.67.

Plant living-aligned parser_asm_wrap_registered_trait_as_dyn twin into the
.text zero gap at 0x140647BB0 (between 11.60 allow_padding PLACE and 11.61
primary_array PLACE) and retarget the alloc_dyn trampoline at 0x1405C7B00
onto that cave.

Root: tip IDENT type-ref parse ends with an unconditional call through
0x1405C7B00 → alloc_dyn, stamping TYPE_DYN(17) on every named type including
user structs (Slot/Empty). Living wrap gates on xlang_skip_trait_is_registered_c;
tip left that helper unreferenced. Soft Cap Prefer keeps the trait gate
(nested check OK). Soft Cap mix banned — tip-only plant.

ABI of plant (matches call site / trampoline):
  rcx=arena, edx=named_tr, r8=name_scratch → eax=type_ref
"""
from __future__ import annotations

import argparse
import hashlib
import struct
import sys
from pathlib import Path

try:
    from keystone import Ks, KS_ARCH_X86, KS_MODE_64
except ImportError as e:  # pragma: no cover
    raise SystemExit("keystone-engine required: pip install keystone-engine") from e

CAVE = 0x140647BB0
TRAMP = 0x1405C7B00  # was E9 → alloc_dyn @ 0x1405C78D0
KIND_ORD = 0x1402A98F7  # pipeline_type_kind_ord_at
NAME_INTO = 0x1402A9187  # pipeline_type_named_name_into
TRAIT_REG = 0x140604513  # xlang_skip_trait_is_registered_c
ALLOC_DYN = 0x1405C78D0  # parser_asm_alloc_dyn_type_ref_into_c
TYPE_NAMED = 8
# Cave must end before primary_array PLACE at 0x140647C20
CAVE_LIMIT = 0x140647C20


def pe_meta(data: bytes):
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


def build_stub() -> bytes:
    asm = f"""
        push rbp
        mov rbp, rsp
        push rbx
        push rsi
        push rdi
        sub rsp, 0x28
        mov rbx, rcx
        mov esi, edx
        mov rdi, r8
        test rbx, rbx
        jz ret_named
        test esi, esi
        jle ret_named
        test rdi, rdi
        jz ret_named
        mov rcx, rbx
        mov edx, esi
        call {KIND_ORD}
        cmp eax, {TYPE_NAMED}
        jne ret_named
        mov rcx, rbx
        mov edx, esi
        mov r8, rdi
        call {NAME_INTO}
        test eax, eax
        jle ret_named
        mov edx, eax
        mov rcx, rdi
        call {TRAIT_REG}
        test eax, eax
        jz ret_named
        mov rcx, rbx
        mov edx, esi
        mov r8, rdi
        call {ALLOC_DYN}
        jmp done
    ret_named:
        mov eax, esi
    done:
        add rsp, 0x28
        pop rdi
        pop rsi
        pop rbx
        pop rbp
        ret
    """
    ks = Ks(KS_ARCH_X86, KS_MODE_64)
    encoding, _ = ks.asm(asm, CAVE)
    stub = bytes(encoding)
    if CAVE + len(stub) > CAVE_LIMIT:
        raise SystemExit(f"stub overflows cave: end={hex(CAVE+len(stub))} limit={hex(CAVE_LIMIT)}")
    return stub


def inject(pe_path: Path, dry_run: bool = False) -> str:
    raw = bytearray(pe_path.read_bytes())
    img_base, secs = pe_meta(bytes(raw))
    stub = build_stub()
    coff = va_to_off(img_base, secs, CAVE)
    existing = bytes(raw[coff : coff + len(stub)])
    if existing != stub and not all(b == 0 for b in existing):
        # idempotent re-plant over our own stub OK; refuse foreign bytes
        if existing[:1] not in (b"\x55",):  # push rbp = our plant
            raise SystemExit(f"cave not empty at {hex(CAVE)}: {existing[:16].hex()}")
    raw[coff : coff + len(stub)] = stub

    toff = va_to_off(img_base, secs, TRAMP)
    if raw[toff] != 0xE9:
        raise SystemExit(f"tramp @{hex(TRAMP)} not E9: {raw[toff]:02x}")
    rel = CAVE - (TRAMP + 5)
    struct.pack_into("<i", raw, toff + 1, rel)

    md5 = hashlib.md5(bytes(raw)).hexdigest()
    if not dry_run:
        pe_path.write_bytes(raw)
    print(f"planted wrap_registered_trait_dyn cave={hex(CAVE)} len={len(stub)} tramp→cave md5={md5}")
    return md5


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("pe", type=Path, help="path to tip xlang_asm.exe")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    if not args.pe.is_file():
        print(f"missing PE {args.pe}", file=sys.stderr)
        return 1
    inject(args.pe, dry_run=args.dry_run)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
