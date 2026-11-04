#!/usr/bin/env python3
"""PLATFORM: WINDOWS tip PE only — win_tip_l2_product_matrix_5_5 / f32 grain.

Patch smash glue_store_retval_pair_to_rbp_elf_c prologue so local -0x30(%rbp)
holds the real 5th-arg slot_off from [rbp+0x30], not a duplicate of elf_ctx (r8).

Root: tip PE smash store_retval ignored stack slot_off and used elf_ctx±8 as the
frame offset → torn rbp disp (48 89 85 c0 XX XX XX) → f32_f64 SEGV. Soft Cap
Prefer encoder F10 clamp masked the same egg; tip-only fix reads the ABI arg.

Pre:  4c 89 c0 48 89 45 d0   mov r8,rax; mov [rbp-0x30],rax
Post: 8b 45 30 48 89 45 d0   mov eax,[rbp+0x30]; mov [rbp-0x30],rax

Soft Cap G05 / Prefer body copy banned. No force-push.
"""
from __future__ import annotations

import argparse
import hashlib
import struct
import sys
from pathlib import Path

STUB_VA = 0x14012AEC0  # smash store_retval after ty_ref save; r8 duplicate site
OLD = bytes.fromhex("4c89c0488945d0")
NEW = bytes.fromhex("8b4530488945d0")


def pe_sections(data: bytes):
    e_lfanew = struct.unpack_from("<I", data, 0x3C)[0]
    num_sec = struct.unpack_from("<H", data, e_lfanew + 6)[0]
    opt_size = struct.unpack_from("<H", data, e_lfanew + 20)[0]
    img_base = struct.unpack_from("<Q", data, e_lfanew + 24 + 24)[0]
    sec_off = e_lfanew + 24 + opt_size
    secs = []
    for i in range(num_sec):
        o = sec_off + i * 40
        name = data[o : o + 8].split(b"\0")[0]
        vsz, va, rsz, ro = struct.unpack_from("<IIII", data, o + 8)
        secs.append({"name": name, "va": va, "vsz": vsz, "ro": ro, "rsz": rsz})
    return img_base, secs


def va_to_off(img_base: int, secs, va: int) -> int:
    rva = va - img_base
    for s in secs:
        if s["va"] <= rva < s["va"] + max(s["vsz"], s["rsz"]):
            return s["ro"] + (rva - s["va"])
    raise SystemExit(f"VA {va:#x} not in sections")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("exe")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    path = Path(args.exe)
    data = bytearray(path.read_bytes())
    img_base, secs = pe_sections(data)
    off = va_to_off(img_base, secs, STUB_VA)
    cur = bytes(data[off : off + 7])
    if cur == NEW:
        print(f"already patched at {STUB_VA:#x} off={off:#x}")
        print("sha16", hashlib.sha256(data).hexdigest()[:16])
        return 0
    if cur != OLD:
        print(f"refuse: unexpected bytes {cur.hex()} at {STUB_VA:#x}", file=sys.stderr)
        return 2
    print(f"patch {STUB_VA:#x} off={off:#x}: {OLD.hex()} -> {NEW.hex()}")
    if args.dry_run:
        return 0
    data[off : off + 7] = NEW
    path.write_bytes(data)
    print("sha16", hashlib.sha256(data).hexdigest()[:16])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
