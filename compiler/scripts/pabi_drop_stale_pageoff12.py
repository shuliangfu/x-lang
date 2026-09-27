#!/usr/bin/env python3
"""Drop stale ARM64 page relocations from a Darwin Mach-O .o.

pipeline_asm_host_is_arm64_c must return an immediate (mov w0, #1; ret on
Darwin). An older BSS load left ARM64_RELOC_PAGE21 on that mov and
ARM64_RELOC_PAGEOFF12 on that ret. ld rejects PAGE21 unless the instruction
is ADRP, and PAGEOFF12 unless it is ADD, LDR, or STR.

Only those mismatched relocations are removed. Instruction bytes stay.
Idempotent. PLATFORM: MACOS|DARWIN.
"""
from __future__ import annotations

import struct
import sys
from pathlib import Path


def _u32(buf: bytes | bytearray, off: int) -> int:
    """Read a little-endian uint32 at off."""
    return struct.unpack_from("<I", buf, off)[0]


def _is_adrp(word: int) -> bool:
    """True when word is ADRP. Darwin ld accepts PAGE21 only on ADRP."""
    return (word & 0x9F000000) == 0x90000000


def _is_pageoff_insn(word: int) -> bool:
    """True when word is an ADD-immediate or an unsigned/unscaled LDR/STR.

    Those are the only opcodes Darwin ld accepts for ARM64_RELOC_PAGEOFF12.
    SUB, MOV, and RET are not.
    """
    # ADD (immediate), 32-bit or 64-bit. Bit 30 clear distinguishes ADD from SUB.
    if (word & 0x7F800000) == 0x11000000:
        return True
    # LDR/STR unsigned immediate (integer).
    if (word & 0x3B000000) == 0x39000000:
        return True
    # LDUR/STUR unscaled immediate.
    if (word & 0x3B200000) == 0x38000000:
        return True
    return False


def _stale_page_reloc(r_type: int, insn: int) -> bool:
    """True when this relocation type cannot apply to insn.

    Type 3 is ARM64_RELOC_PAGE21. Type 4 is ARM64_RELOC_PAGEOFF12.
    """
    if r_type == 3:
        return not _is_adrp(insn)
    if r_type == 4:
        return not _is_pageoff_insn(insn)
    return False


def drop_stale_pageoff12(path: Path) -> int:
    """Remove PAGE21/PAGEOFF12 relocs that do not sit on ADRP/ADD/LDR/STR.

    Compacts the relocation array in place and decrements nreloc. The file
    size does not change; the trailing unused reloc slot is left unread.
    Returns how many entries were removed.
    """
    data = bytearray(path.read_bytes())
    if _u32(data, 0) != 0xFEEDFACF:
        print(f"skip: not MH_MAGIC_64: {path}", file=sys.stderr)
        return 0
    ncmds = _u32(data, 16)
    off = 32
    text_hdr = None
    text_fileoff = 0
    text_size = 0
    reloff = 0
    nreloc = 0
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
                    text_hdr = so
                    text_size = struct.unpack_from("<Q", data, so + 40)[0]
                    text_fileoff = _u32(data, so + 48)
                    reloff = _u32(data, so + 56)
                    nreloc = _u32(data, so + 60)
                so += 80
        off += cmdsize
    if text_hdr is None or nreloc == 0:
        print(f"skip: no __text relocs: {path}", file=sys.stderr)
        return 0

    kept = bytearray()
    dropped = 0
    for i in range(nreloc):
        ro = reloff + i * 8
        r_addr, raw = struct.unpack_from("<iI", data, ro)
        r_type = (raw >> 28) & 0xF
        drop = False
        if r_type in (3, 4) and 0 <= r_addr <= text_size - 4:
            insn = _u32(data, text_fileoff + r_addr)
            drop = _stale_page_reloc(r_type, insn)
        if drop:
            dropped += 1
        else:
            kept += data[ro : ro + 8]
    if dropped == 0:
        print("stale page relocs: 0", file=sys.stderr)
        return 0
    # Write the compacted table over the old one. nreloc shrinks; file size stays.
    data[reloff : reloff + len(kept)] = kept
    struct.pack_into("<I", data, text_hdr + 60, nreloc - dropped)
    path.write_bytes(data)
    print(f"stale page relocs dropped: {dropped}", file=sys.stderr)
    return dropped


def main() -> int:
    """CLI: one Mach-O path. Exit 0 when the object is unchanged or healed."""
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]} <mach-o.o>", file=sys.stderr)
        return 2
    drop_stale_pageoff12(Path(sys.argv[1]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
