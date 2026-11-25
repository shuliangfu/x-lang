#!/usr/bin/env python3
"""Darwin post-link: trampoline every local (t) symbol that also has a global (T)
definition to the global body. Ale/leftover locals otherwise win same-TU calls and
shadow tip-correct globals (e.g. pipeline_expr_kind_ord_at, win_emit_struct_lit_*).
Caller should codesign -f -s - afterward.
"""
from __future__ import annotations

import struct
import subprocess
import sys
from collections import defaultdict
from pathlib import Path


def text_map(path: Path):
    out = subprocess.check_output(["otool", "-l", str(path)], text=True).splitlines()
    addr = fileoff = None
    for i, l in enumerate(out):
        if "sectname __text" in l:
            for l2 in out[i : i + 12]:
                p = l2.split()
                if p and p[0] == "addr":
                    addr = int(p[-1], 16)
                if p and p[0] == "offset":
                    fileoff = int(p[-1])
            break
    if addr is None or fileoff is None:
        raise SystemExit(f"{path}: no __TEXT,__text")
    return addr, fileoff


def main() -> int:
    path = Path(sys.argv[1] if len(sys.argv) > 1 else "xlang")
    data = bytearray(path.read_bytes())
    text_addr, fileoff = text_map(path)
    d: dict[str, dict[str, int]] = defaultdict(dict)
    for line in subprocess.check_output(["nm", str(path)], text=True).splitlines():
        parts = line.split()
        if len(parts) < 3:
            continue
        a, kind, sym = int(parts[0], 16), parts[1], parts[2]
        if kind in ("t", "T"):
            d[sym][kind] = a
    n_ok = n_oor = 0
    for sym, kinds in d.items():
        if "t" not in kinds or "T" not in kinds:
            continue
        local, glob = kinds["t"], kinds["T"]
        if local == glob:
            continue
        imm = (glob - local) // 4
        if not (-(1 << 25) <= imm < (1 << 25)):
            n_oor += 1
            continue
        off = fileoff + (local - text_addr)
        insn = 0x14000000 | (imm & 0x03FFFFFF)
        struct.pack_into("<I", data, off, insn)
        n_ok += 1
    path.write_bytes(data)
    print(
        f"darwin_tramp_local_shadows_to_global: {path} patched {n_ok} t->T trampolines"
        + (f" (out_of_range={n_oor})" if n_oor else ""),
        file=sys.stderr,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
