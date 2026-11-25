#!/usr/bin/env python3
"""PE-patch Win tip glue_emit_struct_type_let_init_elf_c 7th Win64 slot.

The strong T body (0x1400492dc) is 7-arg:
  (arena, elf_ctx, init_ref, ctx, ta, let_ty_ref, stack_slot_off)

Prologue already loads 5th/6th from Win64 [rbp+0x30]/[rbp+0x38], but
loads 7th stack_slot_off from SysV [rbp+0x10] (the rcx home, which is
the arena pointer). That pointer is then passed as slot_off into
glue_store_retval_pair_to_rbp_elf_c, and backend_enc_store_rax_to_rbp
encodes disp = -offset, so product .text gets torn [rbp+ptr] stores
(formal L4 @ 163487f7a step7: all 5 matrix probes BUILD FAIL rc=139;
driver_env_nonnull+39 mov %rax, 0x58639810(%rbp); load uses a real
slot). The 50 unique huge displacements are tip's runtime pointers
(arena / heap) at compile time, stable within a session, changing
across runs (minimal t_env.x repro encoded a different pointer).

Patch:
  0x140049335  488b4510 -> 488b4540   stack_slot_off  [rbp+0x40]

Only this one load in the prologue; afterwards only the local at
[rbp-0x40] is forwarded as the 5th arg to store_retval_pair.
Idempotent. Refuse mixed. Do not reuse the older store_retval_slot_off
script (VA 0x14012AEC0 is not this image).

L4 apply order: after if_stmt_elseif_7th_slot.
PLATFORM: WINDOWS|X86_64 tip PE only. Soft Cap / tiphead HOLD.
"""
from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

FUNC_LO = 0x1400492DC
FUNC_HI = 0x14004F400
# 5th/6th already correct:
#   mov rax,[rbp+0x30]; cdqe; mov [rbp-0x30],rax;
#   mov rax,[rbp+0x38]; cdqe; mov [rbp-0x38],rax
CTX_BEFORE = bytes.fromhex("488b45304898488945d0488b45384898488945c8")
SITE = 0x140049335
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
    lo = fo_for(ib, secs, FUNC_LO)
    hi = fo_for(ib, secs, FUNC_HI)
    if not (lo <= site_fo < hi):
        print(f"FAIL site 0x{SITE:x} outside function window", file=sys.stderr)
        return 2
    before = bytes(data[site_fo - len(CTX_BEFORE) : site_fo])
    if before != CTX_BEFORE:
        print("FAIL CTX_BEFORE mismatch at struct_let_init 7th", file=sys.stderr)
        return 2
    cur = bytes(data[site_fo : site_fo + len(OLD)])
    if cur == NEW:
        print(f"OK already struct_let_init 7th Win64 slot in {path}")
        return 0
    if cur != OLD:
        print(f"FAIL mixed/unexpected at 0x{SITE:x}: {cur.hex()}", file=sys.stderr)
        return 2
    if dry_run:
        print(f"DRY-RUN would patch 0x{SITE:x} [rbp+0x10] -> [rbp+0x40]")
        return 0
    data[site_fo : site_fo + len(NEW)] = NEW
    path.write_bytes(data)
    print(f"PATCHED 1 struct_let_init 7th Win64 slot @ 0x{SITE:x} in {path}")
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
