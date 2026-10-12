#!/usr/bin/env python3
"""Alias the egg skip_heavy body and undefine its link name.

PLATFORM: LINUX. The frozen egg defines asm_skip_heavy_module_func_body
as a weak function and calls it through R_X86_64_PLT32 from inside the
same object. A later strong definition does not intercept those calls
while this symbol stays defined. objcopy --redefine-sym would rename
the calls too, so they would skip a wrapper.

This script copies SRC to DST. It adds
asm_skip_heavy_module_func_body_egg at the same .text offset, then
marks the original symbol undefined and global. The twelve call sites
still name asm_skip_heavy_module_func_body and resolve to the thin
prefix. The thin calls the _egg alias for the unchanged dispatcher.

It does not rebuild the egg and does not edit SRC. src==dst fails
closed. The original symbol must be one weak function, and DST must
keep exactly twelve relocations against that name.

Usage: g05_pabi_skip_heavy_egg_alias.py SRC DST
"""
import os
import struct
import subprocess
import sys

NAME = "asm_skip_heavy_module_func_body"
EGG = "asm_skip_heavy_module_func_body_egg"
RELOCS = 12
# STB_WEAK | STT_FUNC in the low nibble / high nibble of st_info.
WEAK_FUNC = 0x22
GLOBAL_FUNC = 0x12


def fail(msg):
    """Exit 1. Messages go to stderr so a sourcing script stays eval-safe."""
    sys.stderr.write("g05_pabi_skip_heavy_egg_alias: %s\n" % msg)
    sys.exit(1)


def shdrs(data):
    """Return (e_shoff, e_shentsize, e_shnum, e_shstrndx, reader)."""
    if data[:4] != b"\x7fELF" or data[4] != 2 or data[5] != 1:
        fail("not a little-endian ELF64 object")
    e_shoff = struct.unpack_from("<Q", data, 40)[0]
    e_shentsize = struct.unpack_from("<H", data, 58)[0]
    e_shnum = struct.unpack_from("<H", data, 60)[0]
    e_shstrndx = struct.unpack_from("<H", data, 62)[0]
    if e_shentsize < 64:
        fail("short section header")

    def one(i):
        off = e_shoff + i * e_shentsize
        return struct.unpack_from("<IIQQQQIIQQ", data, off)

    return one, e_shnum, e_shstrndx


def section_name(data, one, e_shstrndx, name_off):
    shstr = one(e_shstrndx)
    start = shstr[4] + name_off
    end = data.index(0, start)
    return bytes(data[start:end]).decode()


def symtab(data):
    """Return symtab header, strtab header, and the name of each symbol."""
    one, e_shnum, e_shstrndx = shdrs(data)
    sym = None
    for i in range(e_shnum):
        hdr = one(i)
        if section_name(data, one, e_shstrndx, hdr[0]) == ".symtab":
            sym = hdr
            break
    if sym is None:
        fail("no symtab")
    return one, sym, one(sym[6])


def symbol_name(data, str_off, st_name):
    start = str_off + st_name
    end = data.index(0, start)
    return bytes(data[start:end]).decode()


def find_symbol(data, want):
    """Return (file_offset, st_value, st_size, st_info, st_shndx), or None."""
    _one, sym, strtab = symtab(data)
    sym_off, sym_size, entsize = sym[4], sym[5], sym[9]
    if entsize != 24:
        fail("symtab entry size is %s" % entsize)
    str_off = strtab[4]
    found = None
    for i in range(sym_size // entsize):
        off = sym_off + i * entsize
        st_name, st_info, _other, st_shndx, st_value, st_size = struct.unpack_from(
            "<IBBHQQ", data, off)
        if symbol_name(data, str_off, st_name) == want:
            if found is not None:
                fail("duplicate symbol %s" % want)
            found = (off, st_value, st_size, st_info, st_shndx)
    return found


def reloc_count(path, name):
    """Count objdump relocation rows whose symbol is exactly name."""
    out = subprocess.check_output(["objdump", "-r", path], text=True, errors="replace")
    n = 0
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 3 and parts[2].split("-")[0] == name:
            n += 1
    return n


def nm_row(path, name):
    """Return the nm type letter and value text for an exact symbol name."""
    out = subprocess.check_output(["nm", path], text=True, errors="replace")
    hit = None
    for line in out.splitlines():
        parts = line.split()
        if parts and parts[-1] == name:
            if hit is not None:
                fail("nm duplicate %s in %s" % (name, path))
            hit = parts
    if hit is None:
        fail("nm missing %s in %s" % (name, path))
    # Defined: value type name. Undefined: type name, or spaces then type name.
    if len(hit) == 2:
        return hit[0], ""
    return hit[-2], hit[0]


def main():
    if len(sys.argv) != 3:
        fail("usage: g05_pabi_skip_heavy_egg_alias.py SRC DST")
    src = os.path.abspath(sys.argv[1])
    dst = os.path.abspath(sys.argv[2])
    if src == dst or (os.path.exists(dst) and os.path.samefile(src, dst)):
        fail("src and dst are the same file")
    if not os.path.isfile(src):
        fail("missing %s" % src)
    before = open(src, "rb").read()
    found = find_symbol(bytearray(before), NAME)
    if found is None:
        fail("missing symbol %s" % NAME)
    _off, value, size, info, shndx = found
    if info != WEAK_FUNC or shndx == 0 or size <= 0 or value == 0:
        fail("want one defined weak function, got info=%s shndx=%s size=%s value=%s" % (
            hex(info), shndx, size, hex(value)))
    if reloc_count(src, NAME) != RELOCS:
        fail("SRC relocation count for %s is not %s" % (NAME, RELOCS))
    if find_symbol(bytearray(before), EGG) is not None:
        fail("SRC already defines %s" % EGG)

    os.makedirs(os.path.dirname(dst) or ".", exist_ok=True)
    added = dst + ".addsym"
    spec = "%s=.text:0x%x,global,function" % (EGG, value)
    subprocess.check_call(
        ["objcopy", "--add-symbol", spec, src, added],
        stdout=subprocess.DEVNULL)
    data = bytearray(open(added, "rb").read())
    found = find_symbol(data, NAME)
    if found is None:
        fail("add-symbol dropped %s" % NAME)
    off, _value, _size, info, shndx = found
    if info != WEAK_FUNC or shndx == 0:
        fail("add-symbol disturbed %s" % NAME)
    # Elf64_Sym: name, info, other, shndx, value, size. Keep the name.
    st_name = struct.unpack_from("<I", data, off)[0]
    st_other = data[off + 5]
    struct.pack_into("<IBBHQQ", data, off, st_name, GLOBAL_FUNC, st_other, 0, 0, 0)
    tmp = dst + ".tmp"
    with open(tmp, "wb") as fh:
        fh.write(data)
    os.replace(tmp, dst)
    os.remove(added)

    if open(src, "rb").read() != before:
        fail("SRC changed")
    letter, _val = nm_row(dst, NAME)
    if letter != "U":
        fail("DST %s is %s, want U" % (NAME, letter))
    egg_letter, egg_val = nm_row(dst, EGG)
    if egg_letter != "T" or int(egg_val, 16) != value:
        fail("DST alias is %s %s, want T 0x%x" % (egg_letter, egg_val, value))
    if reloc_count(dst, NAME) != RELOCS:
        fail("DST relocation count changed")
    if reloc_count(dst, EGG) != 0:
        fail("call sites followed the alias")


if __name__ == "__main__":
    main()
