#!/usr/bin/env python3
"""Patch Darwin pabi_weak mega_body e_machine off 0x10a -> 0x299.

knife 254 / 9.2: tip pipe_elf_off_e_machine is 0x2990018. Clean pabi_weak
still stores at stale 0x10a0018. redefine-sym renames same-TU callers; this
in-place movk patch keeps the call name. PLATFORM: MACOS tip cold.
"""
import struct
import sys

def main():
    if len(sys.argv) != 2:
        sys.stderr.write("usage: pabi_patch_emachine_off_10a_to_299.py OBJ\n")
        return 2
    path = sys.argv[1]
    data = bytearray(open(path, "rb").read())
    old_imm, new_imm = 0x10A, 0x299
    n = 0
    for rd in range(32):
        old = struct.pack("<I", 0xF2A00000 | (old_imm << 5) | rd)
        new = struct.pack("<I", 0xF2A00000 | (new_imm << 5) | rd)
        start = 0
        while True:
            i = data.find(old, start)
            if i < 0:
                break
            data[i:i + 4] = new
            n += 1
            start = i + 4
    if n:
        open(path, "wb").write(data)
        sys.stderr.write(
            "g05_relink_env: patched pabi_weak mega e_machine off 0x10a->0x299 (%d insn)\n" % n
        )
    return 0

if __name__ == "__main__":
    sys.exit(main())
