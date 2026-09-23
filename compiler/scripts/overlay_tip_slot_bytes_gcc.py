#!/usr/bin/env python3
"""Trampoline two Linux tip slot sizers to host-cc bodies.

PLATFORM: LINUX|UBUNTU x86_64. Tip `-backend asm` compiles
`pipe_local_slot_bytes_mod` (`sub $0x1038`) and
`glue_fixed_array_temp_bytes` (`sub $0x8a8`) with broken frames, so
`let buf: u8[4]` and `Option_ptr_u8` share a slot (option run=240).
Host cc of the authoritative `.x` thins returns the padded size
(option run=102).

The donor is an ET_REL `.o` (gcc -c, -fno-jump-tables). This script
copies those two text symbols into the existing inject PT_LOAD at
VA 0xA000000, applies PC32/PLT32/64 relocs against the tip symbol
table, and plants a 5-byte jmp at each tip entry.

A good prologue (endbr64 / small gcc frame) is left alone. An existing
jmp trampoline is left alone unless `--force` (one-shot replace of a
hand-planted warm blob). Darwin and Windows binaries are not inputs.
"""
import struct
import subprocess
import sys

FUNCS = ["pipe_local_slot_bytes_mod", "glue_fixed_array_temp_bytes"]
# sub $0x1038,%rsp / sub $0x8a8,%rsp immediates (REX.W opcode 81 /5).
BAD_SUBS = (b"\x81\xec\x38\x10\x00\x00", b"\x81\xec\xa8\x08\x00\x00")
INJECT_VA = 0xA000000

R_X86_64_64 = 1
R_X86_64_PC32 = 2
R_X86_64_PLT32 = 4
R_X86_64_32 = 10
R_X86_64_32S = 11


def tip_syms(path):
    found = {}
    for line in subprocess.check_output(["nm", path], text=True).splitlines():
        parts = line.split()
        if len(parts) >= 3 and parts[1] in "TtWwBbDdRrVv":
            found[parts[-1]] = int(parts[0], 16)
    return found


def parse_elf_rel(path):
    data = open(path, "rb").read()
    if data[:4] != b"\x7fELF":
        raise SystemExit(f"donor is not ELF: {path}")
    e_shoff = struct.unpack_from("<Q", data, 40)[0]
    e_shentsize = struct.unpack_from("<H", data, 58)[0]
    e_shnum = struct.unpack_from("<H", data, 60)[0]
    e_shstrndx = struct.unpack_from("<H", data, 62)[0]
    sections = []
    for i in range(e_shnum):
        off = e_shoff + i * e_shentsize
        unpacked = struct.unpack_from("<IIQQQQIIQQ", data, off)
        sections.append(
            {
                "name_off": unpacked[0],
                "type": unpacked[1],
                "offset": unpacked[4],
                "size": unpacked[5],
                "link": unpacked[6],
                "info": unpacked[7],
                "entsize": unpacked[9],
            }
        )
    strtab = data[
        sections[e_shstrndx]["offset"] : sections[e_shstrndx]["offset"]
        + sections[e_shstrndx]["size"]
    ]
    for sec in sections:
        end = strtab.find(b"\x00", sec["name_off"])
        sec["name"] = strtab[sec["name_off"] : end].decode()
    symtab_i = next(i for i, sec in enumerate(sections) if sec["type"] == 2)
    symtab = sections[symtab_i]
    strs = data[
        sections[symtab["link"]]["offset"] : sections[symtab["link"]]["offset"]
        + sections[symtab["link"]]["size"]
    ]
    syms = []
    count = symtab["size"] // symtab["entsize"]
    for i in range(count):
        off = symtab["offset"] + i * symtab["entsize"]
        st_name, _info, _other, st_shndx, st_value, st_size = struct.unpack_from(
            "<IBBHQQ", data, off
        )
        end = strs.find(b"\x00", st_name)
        syms.append(
            {
                "name": strs[st_name:end].decode(),
                "shndx": st_shndx,
                "value": st_value,
                "size": st_size,
            }
        )
    relas = []
    for sec in sections:
        if sec["type"] != 4:
            continue
        entries = []
        nent = sec["size"] // sec["entsize"]
        for i in range(nent):
            off = sec["offset"] + i * sec["entsize"]
            entries.append(struct.unpack_from("<QQq", data, off))
        relas.append({"info": sec["info"], "entries": entries})
    return data, sections, syms, relas


def program_headers(blob):
    e_phoff = struct.unpack_from("<Q", blob, 32)[0]
    e_phentsize = struct.unpack_from("<H", blob, 54)[0]
    e_phnum = struct.unpack_from("<H", blob, 56)[0]
    headers = []
    for i in range(e_phnum):
        off = e_phoff + i * e_phentsize
        p_type, _flags = struct.unpack_from("<II", blob, off)
        p_offset, p_vaddr, _paddr, p_filesz, _memsz, _align = struct.unpack_from(
            "<QQQQQQ", blob, off + 8
        )
        headers.append((p_type, p_offset, p_vaddr, p_filesz))
    return headers


def va_to_off(blob, va):
    for p_type, p_offset, p_vaddr, p_filesz in program_headers(blob):
        if p_type == 1 and p_vaddr <= va < p_vaddr + p_filesz:
            return p_offset + (va - p_vaddr)
    return None


def prologue_kind(blob, va):
    """bad = tip asm frame; tramp = already overlaid; good = host frame."""
    off = va_to_off(blob, va)
    if off is None:
        return "missing"
    window = bytes(blob[off : off + 24])
    if window[:1] == b"\xe9":
        return "tramp"
    for imm in BAD_SUBS:
        if imm in window:
            return "bad"
    return "good"


def classify(tip_path):
    tip_map = tip_syms(tip_path)
    tip = bytearray(open(tip_path, "rb").read())
    kinds = {}
    for name in FUNCS:
        if name not in tip_map:
            raise SystemExit(f"tip missing {name}")
        kinds[name] = prologue_kind(tip, tip_map[name])
        print(f"prologue {name} {kinds[name]}")
    return tip_map, tip, kinds


def needs_overlay(kinds, force):
    if force:
        return any(k != "good" for k in kinds.values())
    return any(k == "bad" for k in kinds.values())


def main():
    force = "--force" in sys.argv[1:]
    probe = "--probe" in sys.argv[1:]
    args = [a for a in sys.argv[1:] if a not in ("--force", "--probe")]
    if probe:
        if len(args) != 1:
            raise SystemExit(f"usage: {sys.argv[0]} --probe TIP")
        _tip_map, _tip, kinds = classify(args[0])
        if needs_overlay(kinds, force):
            print("probe: overlay")
            return
        print("probe: skip")
        raise SystemExit(2)
    if len(args) != 3:
        raise SystemExit(f"usage: {sys.argv[0]} [--force] TIP DONOR.o OUT")
    tip_path, donor_path, out_path = args
    tip_map, tip, kinds = classify(tip_path)
    if not needs_overlay(kinds, force):
        print("skip: tip slot_bytes frames already host or trampolined")
        if out_path != tip_path:
            open(out_path, "wb").write(tip)
        return
    if any(k == "missing" for k in kinds.values()):
        raise SystemExit("tip symbol VA not in a PT_LOAD")
    inj = None
    for p_type, p_offset, p_vaddr, p_filesz in program_headers(tip):
        if p_type == 1 and p_vaddr == INJECT_VA:
            inj = (p_offset, p_vaddr, p_filesz)
            break
    if inj is None:
        raise SystemExit("tip has no inject PT_LOAD at VA 0xA000000")
    inj_off, inj_va, _inj_fsz = inj
    donor, _sections, donor_syms, donor_relas = parse_elf_rel(donor_path)
    by_name = {s["name"]: s for s in donor_syms if s["name"]}
    cursor = INJECT_VA + 0x9000
    while tip[inj_off + (cursor - inj_va) : inj_off + (cursor - inj_va) + 64] != b"\x00" * 64:
        cursor += 0x40
        if cursor >= inj_va + 0x20000:
            raise SystemExit("inject PT_LOAD has no 64-byte hole")
    print(f"cursor {cursor:#x}")
    placed = {}
    for name in FUNCS:
        sym = by_name.get(name)
        if sym is None or sym["size"] <= 0:
            raise SystemExit(f"donor missing text {name}")
        cursor = (cursor + 15) & ~15
        placed[name] = cursor
        print(f"place {name} sz={sym['size']:#x} -> {cursor:#x}")
        cursor += sym["size"] + 16

    def resolve_sym(sym_idx):
        sym = donor_syms[sym_idx]
        name = sym["name"]
        if name in placed:
            return placed[name]
        if name in tip_map:
            return tip_map[name]
        raise KeyError(name or f"shndx={sym['shndx']}")

    for name in FUNCS:
        sym = by_name[name]
        shndx = sym["shndx"]
        soff = sym["value"]
        size = sym["size"]
        sec = _sections[shndx]
        body = bytearray(donor[sec["offset"] + soff : sec["offset"] + soff + size])
        dest_va = placed[name]
        for rela in donor_relas:
            if rela["info"] != shndx:
                continue
            for r_offset, r_info, r_addend in rela["entries"]:
                if not (soff <= r_offset < soff + size):
                    continue
                loc = r_offset - soff
                r_sym = r_info >> 32
                r_type = r_info & 0xFFFFFFFF
                try:
                    tgt = resolve_sym(r_sym)
                except KeyError as exc:
                    sy = donor_syms[r_sym]
                    raise SystemExit(
                        f"FAIL {name}+{loc:#x} type={r_type} name={sy['name']!r}"
                    ) from exc
                place = dest_va + loc
                if r_type in (R_X86_64_PLT32, R_X86_64_PC32):
                    struct.pack_into("<I", body, loc, (tgt + r_addend - place) & 0xFFFFFFFF)
                elif r_type == R_X86_64_64:
                    struct.pack_into("<Q", body, loc, (tgt + r_addend) & 0xFFFFFFFFFFFFFFFF)
                elif r_type in (R_X86_64_32, R_X86_64_32S):
                    raise SystemExit(
                        f"absolute rodata reloc at {name}+{loc:#x}; rebuild donor with -fno-jump-tables"
                    )
                else:
                    raise SystemExit(f"unsupported reloc {r_type} at {name}+{loc:#x}")
        file_off = inj_off + (dest_va - inj_va)
        tip[file_off : file_off + size] = body
        print(f"wrote {name} @ {dest_va:#x}")
    for name in FUNCS:
        tip_va = tip_map[name]
        tgt = placed[name]
        file_off = va_to_off(tip, tip_va)
        rel = tgt - (tip_va + 5)
        tip[file_off] = 0xE9
        struct.pack_into("<i", tip, file_off + 1, rel)
        print(f"tramp {name} {tip_va:#x} -> {tgt:#x}")
    open(out_path, "wb").write(tip)
    print(f"OK {out_path}")


if __name__ == "__main__":
    main()
