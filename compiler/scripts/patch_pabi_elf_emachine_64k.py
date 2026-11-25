#!/usr/bin/env python3
"""Retarget inlined ELF e_machine stores in a copy of the pabi egg.

PLATFORM: LINUX. The frozen egg
build_asm/selfhost_pabi/pabi_alias.o stores e_machine and reloc_type
with add-immediate, not through pipe_elf_off_e_machine. Each copy of
pipeline_backend_asm_codegen_ast_to_elf_mega_body_c does this three
times (aarch64 183, riscv 243, x86_64 62). Dual-mega eggs therefore
have six of each; tip peel leaves a single mega and three of each.
The immediates are the 16384-layout offsets 17432600 and 17432604.
The strong 65536 overlay moves the getters to 43581464 and 43581468.
Leaving the adds behind makes the object writer read a zero slot
(EM: 0).

This script copies the egg and rewrites only those add immediates.
It does not rebuild the egg, does not edit the original file, and
does not touch the weak getters (mov-imm, not add). A count other
than three or six (matched on both sides), or a following store of
an unexpected value, fails closed so a changed egg cannot be linked
half-patched.

Usage: patch_pabi_elf_emachine_64k.py SRC DST
"""
import shutil
import sys
from collections import Counter

# add $imm32, %rax  followed by  mov $value, (%rax)
ADD_EM = bytes.fromhex("480518000a01")  # 17432600
ADD_REL = bytes.fromhex("48051c000a01")  # 17432604
NEW_EM = bytes.fromhex("480518009902")  # 43581464
NEW_REL = bytes.fromhex("48051c009902")  # 43581468
STORE = bytes.fromhex("c700")
EM_VALUES = {183, 243, 62}
REL_VALUES = {283, 32, 2}
# tip peel: one mega (3); dual-mega egg: two copies (6)
ALLOWED_COUNTS = {3, 6}
# Weak getters: mov $imm, %eax. Tip egg already carries the 64k imm;
# older dual-mega eggs still have the 16384 imm. Either proves the
# getter site is present and must stay (we only rewrite adds).
MOV_EM_16384 = bytes.fromhex("b818000a01")
MOV_EM_64K = bytes.fromhex("b818009902")


def stores(blob, add, allowed):
    """Return file offsets of add+store pairs whose immediate is allowed."""
    found = []
    start = 0
    while True:
        i = blob.find(add, start)
        if i < 0:
            break
        if blob[i + 6:i + 8] != STORE:
            raise SystemExit("add at %#x is not followed by mov $imm, (%%rax)" % i)
        value = int.from_bytes(blob[i + 8:i + 12], "little")
        if value not in allowed:
            raise SystemExit("add at %#x stores unexpected %d" % (i, value))
        found.append(i)
        start = i + 1
    return found


def main():
    if len(sys.argv) != 3:
        raise SystemExit("usage: patch_pabi_elf_emachine_64k.py SRC DST")
    src, dst = sys.argv[1], sys.argv[2]
    if src == dst:
        raise SystemExit("refusing to patch the egg in place")
    blob = open(src, "rb").read()
    em = stores(blob, ADD_EM, EM_VALUES)
    rel = stores(blob, ADD_REL, REL_VALUES)
    if len(em) != len(rel) or len(em) not in ALLOWED_COUNTS:
        raise SystemExit("want 3 or 6 matched e_machine/reloc adds, got %d and %d" % (
            len(em), len(rel)))
    # Each mega contributes the full triad once (N copies => N of each).
    em_vals = [int.from_bytes(blob[i + 8:i + 12], "little") for i in em]
    rel_vals = [int.from_bytes(blob[i + 8:i + 12], "little") for i in rel]
    copies = len(em) // 3
    if set(em_vals) != EM_VALUES or set(Counter(em_vals).values()) != {copies}:
        raise SystemExit("e_machine store triad incomplete")
    if set(rel_vals) != REL_VALUES or set(Counter(rel_vals).values()) != {copies}:
        raise SystemExit("reloc store triad incomplete")
    if blob.count(MOV_EM_16384) < 1 and blob.count(MOV_EM_64K) < 1:
        raise SystemExit("egg lost the weak e_machine getter")
    out = bytearray(blob)
    for i in em:
        out[i:i + 6] = NEW_EM
    for i in rel:
        out[i:i + 6] = NEW_REL
    if out.count(ADD_EM) or out.count(ADD_REL):
        raise SystemExit("old add immediates remain after patch")
    if out.count(NEW_EM) != len(em) or out.count(NEW_REL) != len(rel):
        raise SystemExit("new add count is not %d and %d" % (len(em), len(rel)))
    shutil.copyfile(src, dst)
    # Rewrite the copy only. The source inode stays the committed egg.
    with open(dst, "r+b") as f:
        f.write(out)
        f.truncate(len(out))
    print("patched %d e_machine and %d reloc stores -> %s" % (len(em), len(rel), dst))


if __name__ == "__main__":
    main()
