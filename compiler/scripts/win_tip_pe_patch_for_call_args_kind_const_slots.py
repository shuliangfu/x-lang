#!/usr/bin/env python3
"""PE-patch Win tip for_call_args kind/type constant slots (DIG 2026-11-10).

pipeline_asm_emit_expr_elf_for_call_args (0x1400413f0) already has the
landed call_args_elf_slot stub: elf is copied to [rbp-0x38] and a jmp
skips the frame-pad zero (and the original kind/type let-inits).

Those original inits all stored to [rbp-0x18] (8-bit, the old elf slot)
and are never read. The body loads twelve distinct uninitialized
[rbp-0x44f8..0x4550] slots (never stored in the live range). Left at 0
they equal EXPR_LIT / TYPE_I32, so an integer-literal call arg takes the
FIELD/INDEX/ARRAY arms and pipeline_asm_emit_lvalue_eff_addr_elf_c
returns -1 (rio CALL 211 arg 213).

This patch keeps the elf copy, then writes the twelve source constants
to the slots the body actually loads, and jumps to the existing
APPLY_LO 0x140042028. Idempotent. Apply only on a work copy that already
has call_args_elf_slot (+ later knives). Do not land alone.

PLATFORM: WINDOWS|X86_64 tip PE only. Soft Cap / tiphead HOLD.
"""
from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

FUNC_LO = 0x1400413F0
STUB_COPY_VA = 0x14004143F  # mov rax,[rbp-0x18]; mov [rbp-0x38],rax
STUB_JMP_VA = 0x140041447
APPLY_LO = 0x140042028
# 8-byte elf copy that call_args_elf_slot already wrote
CTX_BEFORE = bytes.fromhex("488b45e8488945c8")
# existing jmp APPLY_LO
JMP_OLD = bytes.fromhex("e9dc0b0000")

# (imm, disp) declaration order / consecutive +8 slots
CONSTS = [
    (1, 0x44F8),
    (3, 0x4500),
    (44, 0x4508),
    (46, 0x4510),
    (47, 0x4518),
    (48, 0x4520),
    (49, 0x4528),
    (9, 0x4530),
    (10, 0x4538),
    (11, 0x4540),
    (14, 0x4548),
    (1024, 0x4550),
]


def _init_blob() -> bytes:
    parts = []
    for imm, disp in CONSTS:
        parts.append(b"\xb8" + struct.pack("<I", imm))          # mov eax, imm
        parts.append(b"\x48\x89\x85" + struct.pack("<i", -disp))  # mov [rbp-disp], rax
    return b"".join(parts)


INIT = _init_blob()
# jmp APPLY_LO is appended after INIT; rel depends on start VA = STUB_JMP_VA


def _jmp_to_apply(from_va: int) -> bytes:
    rel = APPLY_LO - (from_va + 5)
    return b"\xe9" + struct.pack("<i", rel)


NEW_TAIL = INIT + _jmp_to_apply(STUB_JMP_VA + len(INIT))
# total overwrites starting at STUB_JMP_VA


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
    copy_fo = fo_for(ib, secs, STUB_COPY_VA)
    jmp_fo = fo_for(ib, secs, STUB_JMP_VA)
    if bytes(data[copy_fo : copy_fo + 8]) != CTX_BEFORE:
        print("FAIL CTX_BEFORE: call_args_elf_slot elf-copy stub not present", file=sys.stderr)
        return 2
    tail = bytes(data[jmp_fo : jmp_fo + len(NEW_TAIL)])
    if tail == NEW_TAIL:
        print(f"OK already for-call-args kind/type const slots in {path}")
        return 0
    if bytes(data[jmp_fo : jmp_fo + 5]) != JMP_OLD and tail[:5] != JMP_OLD:
        # mixed or unexpected
        print(
            f"FAIL unexpected bytes at stub jmp 0x{STUB_JMP_VA:x}: {bytes(data[jmp_fo:jmp_fo+12]).hex()}",
            file=sys.stderr,
        )
        return 2
    if dry_run:
        print("DRY-RUN would write 12 kind/type consts at "
              f"0x{STUB_JMP_VA:x} then jmp 0x{APPLY_LO:x} ({len(NEW_TAIL)}B)")
        for imm, disp in CONSTS:
            print(f"  mov eax,{imm}; mov [rbp-{disp:#x}], rax")
        return 0
    data[jmp_fo : jmp_fo + len(NEW_TAIL)] = NEW_TAIL
    path.write_bytes(data)
    print(f"PATCHED for-call-args kind/type const slots ({len(NEW_TAIL)}B) in {path}")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("pe")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    return patch(Path(args.pe), args.dry_run)


if __name__ == "__main__":
    sys.exit(main())
