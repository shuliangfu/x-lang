#!/usr/bin/env python3
"""PE-patch Win tip post_parse reading a compact DriverCompileState (DIG 2026-11-10).

Root cause in driver_run_compiler_full_x_post_parse_impl_c (tip-aside PE):
parse_argv writes the official inline-buffer layout

  path_buf@0 (512), path_len@512, out_path_buf@516, out_path_len@1028,
  use_asm_backend@1032, target_arch@1036, target_buf@1040, target_len@1552,
  opt_level_buf@1556, opt_level_len@1564, use_lto@1568,
  backend_asm_explicit@1572, use_freestanding@1576

but post_parse_impl adds compact pointer-layout displacements (0x10/0x18/0x20/…).
Reading out_path_len at +0x18 and use_asm at +0x20 therefore samples bytes of
path_buf:

- short path (e.g. src/runtime_io_abi.x, len=20): those slots are 0, so
  use_asm looks false and the function takes emit-C — C on stdout, no COFF,
  even though `-backend asm -c -o` was parsed (out_len@1028 and use_asm@1032
  are already correct).
- longer path (min_assign absolute, hello, …): ASCII at +0x20 is nonzero, so
  asm is selected, but out_ptr is path_buf+0x10 (e.g. `_step5/min_assign.x`).
  The backend then ld's that garbage path: SEGV without gdb, BLD001 under gdb.

Not an argv-consumption miss: `-backend asm` / `-o` are stored at the official
offsets. The dispatch function just looks in the wrong place.

Patch: 14 in-place `add rax, imm32` immediates (already 6-byte encodings
`48 05 xx xx xx xx`, each preceded by `mov rax, [rbp-0x10]`), remap to the
official field offsets. Idempotent. Apply after assign_eq_stale_ebx.
PLATFORM: WINDOWS|X86_64 tip PE only. Soft Cap / tiphead HOLD.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

FUNC_LO = 0x1401ED2CC  # driver_run_compiler_full_x_post_parse_impl_c
FUNC_HI = 0x1401ED698  # next function
# mov rax, qword ptr [rbp-0x10]
LEA_STATE = bytes.fromhex("488b45f0")
# add rax, imm32
ADD_RAX = bytes.fromhex("4805")

# compact tip imm -> official field offset
IMM_MAP = {
    0x10: 0x204,  # out_path_buf
    0x18: 0x404,  # out_path_len
    0x20: 0x408,  # use_asm_backend
    0x30: 0x410,  # target_buf
    0x38: 0x610,  # target_len
    0x40: 0x614,  # opt_level_buf
    0x50: 0x620,  # use_lto
    0x58: 0x624,  # backend_asm_explicit
    0x60: 0x628,  # use_freestanding
}
# how many sites of each compact imm must exist in the function
EXPECTED_COUNTS = {
    0x10: 1,
    0x18: 2,
    0x20: 3,
    0x30: 1,
    0x38: 1,
    0x40: 1,
    0x50: 1,
    0x58: 3,
    0x60: 1,
}


def pe_meta(data: bytearray):
    import struct

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


def sites_in_func(data: bytearray, lo: int, hi: int):
    """Yield (file_off, va, old_imm) for state-add sites (already NEW or OLD)."""
    import struct

    needle = LEA_STATE + ADD_RAX
    i = lo
    while True:
        j = data.find(needle, i, hi)
        if j < 0:
            break
        imm = struct.unpack_from("<I", data, j + len(needle))[0]
        va_imm_ok = imm in IMM_MAP or imm in IMM_MAP.values()
        if va_imm_ok:
            yield j, imm
        i = j + 1


def patch(path: Path, dry_run: bool) -> int:
    import struct
    from collections import Counter

    data = bytearray(path.read_bytes())
    ib, secs = pe_meta(data)
    lo = fo_for(ib, secs, FUNC_LO)
    hi = fo_for(ib, secs, FUNC_HI)
    found = list(sites_in_func(data, lo, hi))
    if not found:
        print("FAIL no state-add sites in post_parse window", file=sys.stderr)
        return 2
    old_or_new = []
    for off, imm in found:
        if imm in IMM_MAP:
            old_or_new.append(("OLD", off, imm, IMM_MAP[imm]))
        elif imm in set(IMM_MAP.values()):
            # already patched: map back for count check
            old_or_new.append(("NEW", off, imm, imm))
        else:
            print(f"FAIL unexpected imm 0x{imm:x} at file+{off:#x}", file=sys.stderr)
            return 2
    # count by the compact key
    rev = {v: k for k, v in IMM_MAP.items()}
    keys = []
    for kind, off, imm, new in old_or_new:
        key = imm if kind == "OLD" else rev[imm]
        keys.append(key)
    got_counts = Counter(keys)
    if dict(got_counts) != EXPECTED_COUNTS:
        print(f"FAIL site counts {dict(got_counts)} != {EXPECTED_COUNTS}", file=sys.stderr)
        return 2
    n_old = sum(1 for k, _, _, _ in old_or_new if k == "OLD")
    n_new = sum(1 for k, _, _, _ in old_or_new if k == "NEW")
    if n_old and n_new:
        print("FAIL mixed OLD/NEW sites; refuse partial patch", file=sys.stderr)
        return 2
    if n_old == 0:
        print(f"OK already post-parse-state-off ({n_new} sites) in {path}")
        return 0
    if dry_run:
        print(f"DRY-RUN would patch {n_old} post-parse state displacements:")
        for kind, off, imm, new in old_or_new:
            va = FUNC_LO + (off - lo)
            print(f"  0x{va:x}  add rax,0x{imm:x}  ->  add rax,0x{new:x}")
        return 0
    for kind, off, imm, new in old_or_new:
        struct.pack_into("<I", data, off + len(LEA_STATE) + len(ADD_RAX), new)
    path.write_bytes(data)
    print(f"PATCHED {n_old} post-parse state displacements in {path}")
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
