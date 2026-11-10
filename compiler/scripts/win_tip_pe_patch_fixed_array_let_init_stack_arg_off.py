#!/usr/bin/env python3
"""PE-patch Win tip glue_emit_fixed_array_type_let_init_elf_c 7th Win64 slot (DIG 2026-11-10).

The strong T body (0x140069680, both W copies jmp here) is 7-arg:
  (arena, elf_ctx, init_ref, ctx, ta, type_ref, stack_slot_off)

Prologue stores rcx/rdx/r8/r9 into locals, not into the rcx home.
It already loads 5th/6th from Win64 [rbp+0x30]/[rbp+0x38], but loads
7th stack_slot_off from SysV [rbp+0x10] (uninitialized rcx home).
That garbage slot is later passed to glue_struct_lit_store_fixed_array_field_elf_c
(itself already Win64-correct). This is the local/stack fixed-array let-init
path (`let kind: u8[16] = [];`), not the landed top-level bake_array knife
on pipe_modlet_bake_array_lit_elems_to_data.

Patch:
  0x1400696be  488b4510 -> 488b4540   stack_slot_off  [rbp+0x40]

Only this one load in the function; afterwards only the local at [rbp-0x40]
is used. Idempotent. Refuse mixed.

PLATFORM: WINDOWS|X86_64 tip PE only. Soft Cap / tiphead HOLD.
"""
from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

FUNC_LO = 0x140069680
# 5th/6th already correct:
#   mov rax,[rbp+0x30]; cdqe; mov [rbp-0x30],rax;
#   mov rax,[rbp+0x38]; cdqe; mov [rbp-0x38],rax
CTX_BEFORE = bytes.fromhex("488b45304898488945d0488b45384898488945c8")
SITE = 0x1400696BE
OLD = bytes.fromhex("488b45104898488945c0")
NEW = bytes.fromhex("488b45404898488945c0")


def pe_meta(data: bytearray):
    e = struct.unpack_from("<I", data, 0x3C)[0]
    ns = struct.unpack_from("<H", data, e + 6)[0]
    osize = struct.unpack_from("<H", data, e + 20)[0]
    ib = struct.unpack_from("<Q", data, e + 24 + 24)[0]
    so = e + 24 + osize
    secs = []
    for i in range(ns):
        o = so + i * 40
        vs, va, rs, rp = struct.unpack_from("<IIII", data, o + 8)
        secs.append({"va": va, "vsz": vs, "rsz": rs, "rp": rp})
    return ib, secs


def fo_for(ib: int, secs, va: int) -> int:
    rva = va - ib
    for s in secs:
        if s["va"] <= rva < s["va"] + max(s["vsz"], s["rsz"]):
            return s["rp"] + (rva - s["va"])
    raise SystemExit(f"VA 0x{va:x} not mapped")


def patch(path: Path, dry_run: bool) -> int:
    data = bytearray(path.read_bytes())
    ib, secs = pe_meta(data)
    site_fo = fo_for(ib, secs, SITE)
    before = bytes(data[site_fo - len(CTX_BEFORE) : site_fo])
    if before != CTX_BEFORE:
        print("FAIL CTX_BEFORE mismatch at fixed_array_let_init 7th", file=sys.stderr)
        return 2
    cur = bytes(data[site_fo : site_fo + len(OLD)])
    if cur == NEW:
        print(f"OK already fixed_array_let_init 7th Win64 slot in {path}")
        return 0
    if cur != OLD:
        print(f"FAIL mixed/unexpected at 0x{SITE:x}: {cur.hex()}", file=sys.stderr)
        return 2
    if dry_run:
        print(f"DRY-RUN would patch 0x{SITE:x} [rbp+0x10] -> [rbp+0x40]")
        return 0
    data[site_fo : site_fo + len(NEW)] = NEW
    path.write_bytes(data)
    print(f"PATCHED fixed_array_let_init 7th Win64 slot in {path}")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("pe")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    return patch(Path(args.pe), args.dry_run)


if __name__ == "__main__":
    sys.exit(main())
