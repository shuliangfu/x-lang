#!/usr/bin/env python3
"""Heal implicit-int truncation of pointer returns in a Darwin arm64 .o.

w1485: the leftover gcc runtime_pipeline_abi.o calls
pipeline_asm_emit_module_ref_c (returns Module*) without a prototype in
scope, so clang treats the result as int and emits `bl; sxtw xD, w0`.
Heap addresses on Darwin arm64 are above 4 GiB, so the module pointer
loses its high word. pipeline_asm_emit_expr_elf_fast then passes it to
asm_module_top_level_const_lit_i32, which faults (EXC_BAD_ACCESS) on the
first read. Every `.x` that reads a file-level let/const in a function
body hits this path, and g05 pure-asm fell back to host cc for 15
pthin sources without saying so.

For each BRANCH26 relocation whose external symbol is a known pointer
returner, when the following instruction is `sxtw xD, w0` it becomes
`mov xD, x0`. Nothing else changes. Idempotent. PLATFORM: MACOS|DARWIN.
"""
from __future__ import annotations

import struct
import sys
from pathlib import Path

PTR_RET_SYMS = {b"_pipeline_asm_emit_module_ref_c"}


def _u32(buf: bytes | bytearray, off: int) -> int:
    """Read a little-endian uint32 at off."""
    return struct.unpack_from("<I", buf, off)[0]


def heal(path: Path) -> int:
    """Rewrite `sxtw xD, w0` after calls to PTR_RET_SYMS. Returns the count."""
    data = bytearray(path.read_bytes())
    if _u32(data, 0) != 0xFEEDFACF:
        print(f"skip: not MH_MAGIC_64: {path}", file=sys.stderr)
        return 0
    ncmds = _u32(data, 16)
    off = 32
    texts = []
    symoff = nsyms = stroff = 0
    for _ in range(ncmds):
        cmd = _u32(data, off)
        cmdsize = _u32(data, off + 4)
        if cmd == 0x19:  # LC_SEGMENT_64
            nsects = _u32(data, off + 64)
            so = off + 72
            for _s in range(nsects):
                name = bytes(data[so : so + 16]).split(b"\0", 1)[0]
                seg = bytes(data[so + 16 : so + 32]).split(b"\0", 1)[0]
                if name == b"__text" and seg == b"__TEXT":
                    size = struct.unpack_from("<Q", data, so + 40)[0]
                    texts.append((size, _u32(data, so + 48), _u32(data, so + 56), _u32(data, so + 60)))
                so += 80
        elif cmd == 0x2:  # LC_SYMTAB
            symoff, nsyms, stroff = _u32(data, off + 8), _u32(data, off + 12), _u32(data, off + 16)
        off += cmdsize
    if not texts or nsyms == 0:
        print(f"skip: no __text/symtab: {path}", file=sys.stderr)
        return 0

    def sym_name(idx: int) -> bytes:
        strx = _u32(data, symoff + idx * 16)
        end = data.index(b"\0", stroff + strx)
        return bytes(data[stroff + strx : end])

    healed = 0
    for size, fileoff, reloff, nreloc in texts:
        for i in range(nreloc):
            r_addr, raw = struct.unpack_from("<iI", data, reloff + i * 8)
            r_sym = raw & 0xFFFFFF
            r_extern = (raw >> 27) & 1
            r_type = (raw >> 28) & 0xF
            if r_type != 2 or not r_extern or r_sym >= nsyms:
                continue
            if not (0 <= r_addr <= size - 8):
                continue
            if sym_name(r_sym) not in PTR_RET_SYMS:
                continue
            nxt = fileoff + r_addr + 4
            insn = _u32(data, nxt)
            if (insn & 0xFFFFFFE0) == 0x93407C00:  # sxtw xD, w0
                struct.pack_into("<I", data, nxt, 0xAA0003E0 | (insn & 0x1F))  # mov xD, x0
                healed += 1
    if healed:
        path.write_bytes(data)
    print(f"ptr-return sxtw healed: {healed}", file=sys.stderr)
    return healed


def main() -> int:
    """CLI: one or more Mach-O paths. Exit 0 whether or not anything changed."""
    if len(sys.argv) < 2:
        print(f"usage: {sys.argv[0]} <mach-o.o>...", file=sys.stderr)
        return 2
    for p in sys.argv[1:]:
        heal(Path(p))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
