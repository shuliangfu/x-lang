#!/usr/bin/env python3
"""PLATFORM: WINDOWS tip PE — Soft Cap ADD/SUB maybe_sxt Win64 ABI fix.

Soft Cap mega glue_emit_binop_add/sub_rax_rbx call glue_binop_maybe_sxt_i32_result_elf_c
with SysV-ish marshal (r8/r9 overwritten to elf/ta; no stack 5th/6th). Win64 Soft Cap
maybe_sxt reads elf@home+0x30 → garbage (0x40) → pipe_load SEGV (opt BUILD139) on
return VAR+VAR ADD/SUB in tests/option/main.x.

Tip-faithful: maybe_sxt(arena, ctx, left, right, elf_ctx, ta) Win64.
Ban Soft Cap Prefer body; ban Soft Cap +8 polarity.
Apply on PE that still has virgin Soft Cap call sites (e.g. 173da .c79srvp).
"""
from __future__ import annotations

import argparse
import hashlib
import struct
import sys
from pathlib import Path

ADD_START, ADD_CALL = 0x14012FD0C, 0x14012FD90
SUB_START, SUB_CALL = 0x14013015E, 0x1401301E2
MAYBE_SXT = 0x14026AEEC


def pe_sections(data: bytes):
    e_lfanew = struct.unpack_from("<I", data, 0x3C)[0]
    num_sec = struct.unpack_from("<H", data, e_lfanew + 6)[0]
    opt_size = struct.unpack_from("<H", data, e_lfanew + 20)[0]
    img_base = struct.unpack_from("<Q", data, e_lfanew + 24 + 24)[0]
    sec_off = e_lfanew + 24 + opt_size
    secs = []
    for i in range(num_sec):
        o = sec_off + i * 40
        name = data[o : o + 8].split(b"\0")[0].decode(errors="replace")
        vsz, va, rsz, ro = struct.unpack_from("<IIII", data, o + 8)
        secs.append({"name": name, "va": va, "vsz": vsz, "ro": ro, "rsz": rsz})
    return img_base, secs


def va_to_off(img_base: int, secs, va: int) -> int:
    rva = va - img_base
    for s in secs:
        if s["va"] <= rva < s["va"] + max(s["vsz"], s["rsz"]):
            return s["ro"] + (rva - s["va"])
    raise ValueError(hex(va))


def win64_stub() -> bytes:
    return bytes.fromhex(
        "488b4df0"
        "488b55e0"
        "448b45d8"
        "448b4dd0"
        "488b45e8"
        "4889442420"
        "8b45c8"
        "89442428"
    )


def patch_site(data: bytearray, img_base, secs, start_va: int, call_va: int, label: str) -> None:
    stub = win64_stub()
    span = call_va - start_va
    if len(stub) > span:
        raise SystemExit(f"{label}: stub too long")
    coff = va_to_off(img_base, secs, call_va)
    if data[coff] not in (0xE8, 0xE9):
        raise SystemExit(f"{label}: no call at {call_va:#x}")
    rel = struct.unpack_from("<i", data, coff + 1)[0]
    dest = call_va + 5 + rel
    if dest != MAYBE_SXT:
        raise SystemExit(f"{label}: call dest {dest:#x} != maybe_sxt")
    soff = va_to_off(img_base, secs, start_va)
    data[soff : soff + span] = stub + (b"\x90" * (span - len(stub)))
    print(f"{label}: patched {start_va:#x}..{call_va:#x}")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("exe")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    exe = Path(args.exe)
    data = bytearray(exe.read_bytes())
    img_base, secs = pe_sections(data)
    if args.dry_run:
        print("dry-run ok")
        return 0
    patch_site(data, img_base, secs, ADD_START, ADD_CALL, "add")
    patch_site(data, img_base, secs, SUB_START, SUB_CALL, "sub")
    exe.write_bytes(data)
    print("sha16", hashlib.sha256(data).hexdigest()[:16])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
