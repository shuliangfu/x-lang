#!/usr/bin/env python3
"""PE-patch Win tip pipe_modlet_array_lit_elem_const_val ret0 stub (DIG 2026-11-10).

Root cause for backend_call_dispatch.x CG002 (418 funcs, typeck green,
not extern-only): asm_asm_codegen_elf_o returns -1 in
pipeline_asm_modlet_prepare_and_emit_elf_c while baking the first
non-empty top-level ARRAY_LIT (min repro: `let a: i32[1] = [0];`) into
.data. pabi_bake_elems_one_poke calls pipe_modlet_array_lit_elem_const_val
and treats rc==0 as loud-fail.

The exported T at 0x14047624c is a 3-byte `xor eax,eax; ret` stub in the
ret0 island (same class as the nearby runtime_pipeline_elf_ctx_diag_note
stub — diagnostic residual, not this knife). The real fold lives at
pipe_modlet_array_lit_elem_const_val_cold @ 0x1400edd71 (ek==0 INT_LIT
writes out_val and returns 1). Nine E8 call sites go to the stub;
the cold body already has its internal recursive calls.

Patch: at the T stub, a 5-byte rel32 jmp to cold. The 2 extra bytes
overwrite unlabelled ret0 padding before driver_lib_roots_from_key
@ 0x140476273, which is left intact.

Idempotent. Apply after call_args_elf_slot on tip-aside install.
PLATFORM: WINDOWS|X86_64 tip PE only. Soft Cap / tiphead HOLD.
"""
from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

STUB_VA = 0x14047624C  # T pipe_modlet_array_lit_elem_const_val
COLD_VA = 0x1400EDD71  # t pipe_modlet_array_lit_elem_const_val_cold
NEXT_VA = 0x140476273  # T driver_lib_roots_from_key (must stay)
# vlet_lane_cmp_ko and neighbours are also ret0 stubs
CTX_BEFORE = bytes.fromhex("31c0c331c0c331c0c331c0c3")
# xor eax,eax; ret; xor eax,eax   (2 bytes into unlabelled padding)
OLD = bytes.fromhex("31c0c331c0")
REL = COLD_VA - (STUB_VA + 5)  # -0x3884e0
NEW = b"\xe9" + struct.pack("<i", REL)  # e9207bc7ff
COLD_PROLOGUE = bytes.fromhex("554889e54881ec90000000")  # push rbp; mov rbp,rsp; sub rsp,0x90
NEXT_OLD = bytes.fromhex("31c0c3")


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
    stub_fo = fo_for(ib, secs, STUB_VA)
    cold_fo = fo_for(ib, secs, COLD_VA)
    next_fo = fo_for(ib, secs, NEXT_VA)
    if bytes(data[cold_fo : cold_fo + len(COLD_PROLOGUE)]) != COLD_PROLOGUE:
        print("FAIL cold const_val prologue mismatch; refuse", file=sys.stderr)
        return 2
    if bytes(data[next_fo : next_fo + len(NEXT_OLD)]) != NEXT_OLD:
        print("FAIL next symbol driver_lib_roots_from_key clobbered; refuse", file=sys.stderr)
        return 2
    before = bytes(data[stub_fo - len(CTX_BEFORE) : stub_fo])
    if before != CTX_BEFORE:
        print("FAIL CTX_BEFORE mismatch", file=sys.stderr)
        return 2
    head = bytes(data[stub_fo : stub_fo + len(OLD)])
    if head == NEW:
        print(f"OK already modlet-elem-const-val-jmp in {path}")
        return 0
    if head != OLD:
        print(f"FAIL unexpected stub bytes {head.hex()}; refuse", file=sys.stderr)
        return 2
    if dry_run:
        print("DRY-RUN would patch pipe_modlet_array_lit_elem_const_val:")
        print(f"  0x{STUB_VA:x}  xor eax,eax; ret  -> jmp 0x{COLD_VA:x} (cold fold)")
        return 0
    data[stub_fo : stub_fo + len(NEW)] = NEW
    # next official symbol still intact
    if bytes(data[next_fo : next_fo + len(NEXT_OLD)]) != NEXT_OLD:
        print("FAIL would clobber driver_lib_roots_from_key; refuse", file=sys.stderr)
        return 2
    path.write_bytes(data)
    print(f"PATCHED const_val stub -> jmp cold 0x{COLD_VA:x} in {path}")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("exe", type=Path)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    if not args.exe.is_file():
        print(f"FAIL missing {args.exe}", file=sys.stderr)
        return 2
    return patch(args.exe, args.dry_run)


if __name__ == "__main__":
    sys.exit(main())
