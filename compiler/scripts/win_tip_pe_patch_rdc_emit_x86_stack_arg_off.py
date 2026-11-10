#!/usr/bin/env python3
"""PE-patch Win tip rdc_emit_x86 7th/8th/9th Win64 slots (DIG 2026-11-10).

pipeline_rdc_emit_x86 (0x14002ff4c, 11364B) is 9-arg:
  (elf, home, len_off, esz, skip_lbl, skip_len, rest_lbl, rest_len, mname)

Prologue already loads 5th/6th from Win64 [rbp+0x30]/[rbp+0x38], but
loads 7th/8th/9th from SysV [rbp+0x10]/[rbp+0x18]/[rbp+0x20] (rcx/rdx/r8
homes). The malloc call then passes len_off as the name pointer
(0x20 on the official-leaf ebb-42 path) and pipeline_elf_ctx_append_reloc
SEGVs on name[0]. Only these three loads in the function; afterwards
only the five locals are used.

Patch (CTX_BEFORE is the correct 5th/6th Win64 loads):
  0x14002ffa7  488b4510 -> 488b4540   rest_lbl  [rbp+0x40]
  0x14002ffaf  488b4518 -> 488b4548   rest_len  [rbp+0x48]
  0x14002ffb9  488b4520 -> 488b4550   mname     [rbp+0x50]

Idempotent. Refuse mixed. This is NOT the rio for_call_args window.
Trial on a work copy only; do not land alone.

PLATFORM: WINDOWS|X86_64 tip PE only. Soft Cap / tiphead HOLD.
"""
from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

FUNC_LO = 0x14002FF4C
# 5th/6th already correct: mov rax,[rbp+0x30]; mov [rbp-0x30],rax;
# mov rax,[rbp+0x38]; cdqe; mov [rbp-0x38],rax
CTX_BEFORE = bytes.fromhex("488b4530488945d0488b45384898488945c8")
SITE = 0x14002FFA7
OLD = bytes.fromhex("488b4510488945c0488b45184898488945b8488b4520488945b0")
NEW = bytes.fromhex("488b4540488945c0488b45484898488945b8488b4550488945b0")


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
        print("FAIL CTX_BEFORE mismatch at rdc_emit_x86 7/8/9", file=sys.stderr)
        return 2
    cur = bytes(data[site_fo : site_fo + len(OLD)])
    if cur == NEW:
        print(f"OK already rdc_emit_x86 7/8/9 Win64 slots in {path}")
        return 0
    if cur != OLD:
        print(f"FAIL mixed/unexpected at 0x{SITE:x}: {cur.hex()}", file=sys.stderr)
        return 2
    if dry_run:
        print(f"DRY-RUN would patch 0x{SITE:x} [rbp+0x10/18/20] -> [rbp+0x40/48/50]")
        return 0
    data[site_fo : site_fo + len(NEW)] = NEW
    path.write_bytes(data)
    print(f"PATCHED rdc_emit_x86 7/8/9 Win64 slots in {path}")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("pe")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    return patch(Path(args.pe), args.dry_run)


if __name__ == "__main__":
    sys.exit(main())
