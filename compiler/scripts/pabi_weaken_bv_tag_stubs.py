#!/usr/bin/env python3
"""Class BV: set N_WEAK_DEF on leftover Cap-stubbed token/typekind tags."""
from __future__ import annotations
import struct
import sys
from pathlib import Path

N_WEAK_DEF = 0x0080
TARGETS = {b"_pipeline_token_kind_variant_tag", b"_pipeline_asm_typekind_variant_tag"}

def main() -> int:
    path = Path(sys.argv[1] if len(sys.argv) > 1 else "src/runtime_pipeline_abi.o")
    data = bytearray(path.read_bytes())
    if struct.unpack_from("<I", data, 0)[0] != 0xFEEDFACF:
        print("skip: not macho64", file=sys.stderr)
        return 0
    ncmds = struct.unpack_from("<I", data, 16)[0]
    off = 32
    symtab = None
    for _ in range(ncmds):
        cmd, cmdsize = struct.unpack_from("<II", data, off)
        if cmd == 2:
            symoff, nsyms, stroff, strsize = struct.unpack_from("<IIII", data, off + 8)
            symtab = (symoff, nsyms, stroff, strsize)
        off += cmdsize
    if not symtab:
        return 0
    symoff, nsyms, stroff, strsize = symtab
    blob = bytes(data[stroff : stroff + strsize])
    hit = 0
    for i in range(nsyms):
        o = symoff + i * 16
        strx, typ, sect, desc, val = struct.unpack_from("<IBBHQ", data, o)
        end = blob.find(b"\0", strx)
        name = blob[strx:end]
        if name in TARGETS and (desc & N_WEAK_DEF) == 0:
            desc |= N_WEAK_DEF
            struct.pack_into("<IBBHQ", data, o, strx, typ, sect, desc, val)
            hit += 1
    path.write_bytes(data)
    print(f"OK weaken {hit} symbols in {path}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
