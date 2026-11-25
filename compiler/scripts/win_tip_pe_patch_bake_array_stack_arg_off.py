#!/usr/bin/env python3
"""PE-patch Win tip bake_array 7th/8th stack-arg displacements (DIG 2026-11-10).

Root cause in tip pipe_modlet_bake_array_lit_elems_to_data @ 0x14007acc0
(the live body; the two W copies are `jmp` trampolines to it):

backend_call_dispatch.x typeck is green (418 funcs, not extern-only).
asm_asm_codegen_elf_o returns -1 before coff_write because
pipeline_asm_modlet_prepare_and_emit_elf_c fails while baking the first
non-empty top-level ARRAY_LIT (e.g. `i32[1] = [0]`) into .data.

The 8-arg Win64 caller (prepare_T) correctly places:
  5th data_base @ [rsp+0x20], 6th base_off @ [rsp+0x28],
  7th span_bytes @ [rsp+0x30], 8th m @ [rsp+0x38]
which the callee sees after `push rbp; mov rbp,rsp` as
  [rbp+0x30], [rbp+0x38], [rbp+0x40], [rbp+0x48].

Tip prologue already loads 5th/6th from the Win64 slots, but loads
7th/8th from [rbp+0x10]/[rbp+0x18] (SysV 7th/8th, which on Win64 are
the unsaved rcx/rdx homes). span becomes the arena pointer and m
becomes stack garbage; pabi_bake_elems_one then returns -1.

Patch (same 4-byte length, function window only):
  mov rax,[rbp+0x10] -> [rbp+0x40]
  mov rax,[rbp+0x18] -> [rbp+0x48]

Idempotent. Apply after call_args_elf_slot on tip-aside install.
PLATFORM: WINDOWS|X86_64 tip PE only. Soft Cap / tiphead HOLD.
"""
from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

FUNC_LO = 0x14007ACC0  # live pipe_modlet_bake_array_lit_elems_to_data
FUNC_HI = 0x14007B520  # next: pipe_modlet_bake_struct_lit_to_data
PATCH_VA = 0x14007AD00  # first wrong load (7th/8th pair)
# mov rax,[rbp+0x30]; cdqe; mov [rbp-0x30],rax;
# mov rax,[rbp+0x38]; cdqe; mov [rbp-0x38],rax;
CTX_BEFORE = bytes.fromhex("488b45304898488945d0488b45384898488945c8")
# mov rax,[rbp+0x10]; cdqe; mov [rbp-0x40],rax;
# mov rax,[rbp+0x18];       mov [rbp-0x48],rax;
OLD = bytes.fromhex("488b45104898488945c0488b4518488945b8")
NEW = bytes.fromhex("488b45404898488945c0488b4548488945b8")


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
    func_fo = fo_for(ib, secs, FUNC_LO)
    hi_fo = fo_for(ib, secs, FUNC_HI)
    patch_fo = fo_for(ib, secs, PATCH_VA)
    if not (func_fo <= patch_fo < hi_fo):
        print("FAIL patch VA outside function window", file=sys.stderr)
        return 2
    before = bytes(data[patch_fo - len(CTX_BEFORE) : patch_fo])
    if before != CTX_BEFORE:
        print("FAIL CTX_BEFORE mismatch", file=sys.stderr)
        return 2
    head = bytes(data[patch_fo : patch_fo + len(OLD)])
    body = bytes(data[func_fo:hi_fo])
    n_old = body.count(OLD)
    n_new = body.count(NEW)
    if head == NEW and n_new == 1 and n_old == 0:
        print(f"OK already bake-array-stack-arg-off in {path}")
        return 0
    if not (head == OLD and n_old == 1 and n_new == 0):
        print(
            "FAIL mixed/unexpected state: "
            f"head_old={head == OLD} head_new={head == NEW} "
            f"old/new counts={n_old}/{n_new}; refuse partial patch",
            file=sys.stderr,
        )
        return 2
    if dry_run:
        print("DRY-RUN would patch pipe_modlet_bake_array_lit_elems_to_data:")
        print(f"  0x{PATCH_VA:x}  mov rax,[rbp+0x10]->[rbp+0x40] (span_bytes)")
        print(f"  0x{PATCH_VA + 10:x}  mov rax,[rbp+0x18]->[rbp+0x48] (m)")
        return 0
    data[patch_fo : patch_fo + len(NEW)] = NEW
    path.write_bytes(data)
    print(f"PATCHED bake-array 7th/8th stack args -> [rbp+0x40]/[rbp+0x48] in {path}")
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
