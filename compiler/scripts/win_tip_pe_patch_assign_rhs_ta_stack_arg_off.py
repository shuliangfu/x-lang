#!/usr/bin/env python3
"""PE-patch Win tip assign-rhs 7th stack-arg displacement (DIG 2026-11-10).

Root cause in tip pipeline_glue_emit_assign_rhs_to_rax_elf_c @ 0x14004fcfc
(3592B; next is pipeline_asm_emit_assign_elf_c @ 0x140050b04).

After the first-segment two PEs (const_val jmp + bake_array Win64 slots),
modlet_prepare returns 0, but mega_body still returns -1. The unique post-
prepare fail is backend_emit_block_body_sync_elf for w1545_pend_rcx_emit
(block_ref=148, the 23rd function). w1010_body_sync_level emits the body;
the first statement after the early-return if is the ASSIGN
  d = 0 - w1545_pend_off[0]
(kind 28). assign_T calls this 7-arg rhs-to-rax helper. The helper then
calls emit_expr on the SUB RHS with a garbage ta.

The 7-arg Win64 caller (assign_T) correctly places:
  5th @ [rsp+0x20], 6th ctx @ [rsp+0x28], 7th ta @ [rsp+0x30]
which the callee sees after `push rbp; mov rbp,rsp` as
  [rbp+0x30], [rbp+0x38], [rbp+0x40].

Tip prologue already loads 5th/6th from the Win64 slots, but loads the
7th (ta, an i32, cdqe into [rbp-0x40]) from [rbp+0x10] (SysV 7th, which
on Win64 is the unsaved rcx home = arena). emit_expr / binop_sub /
emit_index / glue_emit_index_eff_addr_scaled_elf_c then see ta=arena
and return -1. Min repro: `let d: i32 = 0; d = 0 - a[0];` with a
module `i32[1]` (a let-init of the same sub, without statement ASSIGN,
stays green).

Patch (same 4-byte length, function window only, one site):
  mov rax,[rbp+0x10] -> [rbp+0x40]

Idempotent. Apply after the first-segment two trial PEs (and after
call_args_elf_slot on tip-aside install). Do not land on live tip-aside
until backend_call_dispatch.x writes real 64 86 COFF.
PLATFORM: WINDOWS|X86_64 tip PE only. Soft Cap / tiphead HOLD.
"""
from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

FUNC_LO = 0x14004FCFC  # pipeline_glue_emit_assign_rhs_to_rax_elf_c
FUNC_HI = 0x140050B04  # next: pipeline_asm_emit_assign_elf_c
PATCH_VA = 0x14004FD55  # the unique wrong 7th-arg load
# mov rax,[rbp+0x30]; cdqe; mov [rbp-0x30],rax;
# mov rax,[rbp+0x38];       mov [rbp-0x38],rax;
CTX_BEFORE = bytes.fromhex("488b45304898488945d0488b4538488945c8")
# mov rax,[rbp+0x10]; cdqe; mov [rbp-0x40],rax;
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
        print(f"OK already assign-rhs-ta-stack-arg-off in {path}")
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
        print("DRY-RUN would patch pipeline_glue_emit_assign_rhs_to_rax_elf_c:")
        print(f"  0x{PATCH_VA:x}  mov rax,[rbp+0x10]->[rbp+0x40] (ta)")
        return 0
    data[patch_fo : patch_fo + len(NEW)] = NEW
    path.write_bytes(data)
    print(f"PATCHED assign-rhs 7th stack arg ta -> [rbp+0x40] in {path}")
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
