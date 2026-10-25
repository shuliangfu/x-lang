#!/usr/bin/env python3
"""10.22 Cap tip: bump method_sig frame 0xe60 -> 0xff0 in live products.

parser_asm_skip_one_trait_method_sig_into_c Cap tip prologue uses sub #0xe60
while emit temps write [x29,#0xe68..] and smash the caller LR (jump 0x1 /
EXC_BAD_ACCESS on tests/boundary/dyn_*_slice). Same under-budget class as
note743y.6.22 fill_nested. Recompiling pthin_skip_tl alone shrinks the body;
patch the live Cap tip product. PLATFORM: MACOS|DARWIN Cap tip.
"""
from __future__ import annotations

import re
import struct
import subprocess
import sys
from pathlib import Path

IMM_OLD, IMM_NEW = 0xE60, 0xFF0
SUB_OLD = 0xD1000000 | (IMM_OLD << 10) | (31 << 5) | 31
SUB_NEW = 0xD1000000 | (IMM_NEW << 10) | (31 << 5) | 31
ADD_OLD = 0x91000000 | (IMM_OLD << 10) | (31 << 5) | 31
ADD_NEW = 0x91000000 | (IMM_NEW << 10) | (31 << 5) | 31


def patch_one(path: Path) -> bool:
    if not path.is_file():
        return False
    data = bytearray(path.read_bytes())
    nm = subprocess.check_output(["nm", "-n", str(path)], text=True)
    syms = []
    for line in nm.splitlines():
        parts = line.split()
        if len(parts) >= 3 and parts[1] in ("T", "t"):
            syms.append((int(parts[0], 16), parts[2]))
    start = end = None
    for i, (a, n) in enumerate(syms):
        if n.endswith("parser_asm_skip_one_trait_method_sig_into_c"):
            start = a
            end = syms[i + 1][0] if i + 1 < len(syms) else a + 0x10000
            break
    if start is None:
        return False
    ot = subprocess.check_output(["otool", "-l", str(path)], text=True)
    m = re.search(
        r"sectname __text\n\s+segname __TEXT\n\s+addr 0x([0-9a-fA-F]+)\n"
        r"\s+size 0x([0-9a-fA-F]+)\n\s+offset (\d+)",
        ot,
    )
    if not m:
        return False
    addr, size, off = int(m.group(1), 16), int(m.group(2), 16), int(m.group(3))
    if not (addr <= start < addr + size):
        return False
    fs, fe = off + (start - addr), off + (end - addr)
    nsub = nadd = 0
    i = fs
    while i + 4 <= fe:
        w = struct.unpack_from("<I", data, i)[0]
        if w == SUB_OLD:
            struct.pack_into("<I", data, i, SUB_NEW)
            nsub += 1
        elif w == ADD_OLD:
            struct.pack_into("<I", data, i, ADD_NEW)
            nadd += 1
        i += 4
    if nsub < 1:
        return False
    path.write_bytes(data)
    sys.stderr.write(
        f"g05_cap_tip_method_sig_frame_pad: 0xe60->0xff0 in {path.name} "
        f"(sub={nsub} add={nadd})\n"
    )
    return True


def main() -> int:
    names = sys.argv[1:] or [
        "xlang",
        "xlang_asm",
        "xlang-c",
        "bootstrap_xlangc",
        "xlang.cap_g05_l2",
    ]
    any_ok = False
    for name in names:
        any_ok = patch_one(Path(name)) or any_ok
    if any_ok:
        subprocess.run(
            [
                "codesign",
                "-s",
                "-",
                "-f",
                "xlang",
                "xlang_asm",
                "xlang-c",
                "bootstrap_xlangc",
                "xlang.cap_g05_l2",
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
