#!/usr/bin/env python3
"""Retarget demoted typeck symbols to undefined globals for Cap tip soft winners.
PLATFORM: MACOS MH_OBJECT. Args: path to typeck_x.cap_repr_weak.o (already redefine-sym'd).
"""
import struct
import sys
from pathlib import Path

def main() -> int:
    if len(sys.argv) != 2:
        print("usage: g05_cap_tip_typeck_retarget.py <typeck_x.cap_repr_weak.o>", file=sys.stderr)
        return 2
    path = Path(sys.argv[1])
    data = bytearray(path.read_bytes())
    if data[:4] != b"\xcf\xfa\xed\xfe":
        print("not mach-o 64", file=sys.stderr)
        return 1
    _, _, _, filetype, ncmds, _, _, _ = struct.unpack_from("<IIIIIIII", data, 0)
    if filetype != 1:
        print("not MH_OBJECT", file=sys.stderr)
        return 1
    off = 32
    symtab_cmd_off = dysym_cmd_off = None
    symtab_off = nsyms = stroff = strsize = None
    text_reloff = text_nreloc = None
    sect_hdrs = []
    for _ in range(ncmds):
        cmd, cmdsize = struct.unpack_from("<II", data, off)
        if cmd == 0x19:
            nsects = struct.unpack_from("<I", data, off + 64)[0]
            so = off + 72
            for _s in range(nsects):
                sectname = bytes(data[so : so + 16].split(b"\0")[0])
                offset, _align, reloff, nreloc, _flags = struct.unpack_from("<IIIII", data, so + 48)
                sect_hdrs.append({"hdr": so, "offset": offset, "reloff": reloff})
                if sectname == b"__text":
                    text_reloff, text_nreloc = reloff, nreloc
                so += 80
        elif cmd == 0x2:
            symtab_cmd_off = off
            symtab_off, nsyms, stroff, strsize = struct.unpack_from("<IIII", data, off + 8)
        elif cmd == 0xB:
            dysym_cmd_off = off
        off += cmdsize
    demoted_of = {
        b"_typeck_call_arg_repr_compatible_ok": b"_typeck_call_arg_repr_compatible_ok__demoted",
        b"_typeck_get_dep_return_type_in_caller_arena": b"_typeck_get_dep_return_type_in_caller_arena__demoted",
        b"_typeck_type_refs_equal": b"_typeck_type_refs_equal__demoted",
        b"_typeck_field_unknown_hard_fail": b"_typeck_field_unknown_hard_fail__demoted",
        b"_typeck_check_expr_try_propagate": b"_typeck_check_expr_try_propagate__demoted",
    }
    demoted_names = set(demoted_of.values())
    targets = list(demoted_of.keys())
    dem_relocs = []
    for ri in range(text_nreloc):
        ro = text_reloff + ri * 8
        _addr, rest = struct.unpack_from("<iI", data, ro)
        r_symbolnum = rest & 0xFFFFFF
        r_extern = (rest >> 27) & 1
        if not r_extern:
            continue
        so = symtab_off + r_symbolnum * 16
        sx = struct.unpack_from("<I", data, so)[0]
        nm = bytes(data[stroff + sx :].split(b"\0")[0])
        if nm in demoted_names:
            dem_relocs.append((ro, rest, nm))
    strtab = bytearray(bytes(data[stroff : stroff + strsize]))
    u_indices = {}
    nlists = b""
    for t in targets:
        u_strx = len(strtab)
        strtab.extend(t + b"\0")
        u_indices[t] = nsyms + len(u_indices)
        nlists += struct.pack("<IBBHQ", u_strx, 0x01, 0, 0, 0)
    insert_at = stroff
    nlist_growth = len(nlists)
    new_data = bytearray(data[:insert_at]) + bytearray(nlists) + bytearray(strtab)
    if stroff + strsize < len(data):
        new_data += data[stroff + strsize :]
    struct.pack_into(
        "<IIII",
        new_data,
        symtab_cmd_off + 8,
        symtab_off,
        nsyms + len(targets),
        insert_at + nlist_growth,
        len(strtab),
    )
    if dysym_cmd_off is not None:
        _il, _nl, _ie, _ne, iundefsym, nundefsym = struct.unpack_from(
            "<IIIIII", new_data, dysym_cmd_off + 8
        )
        if iundefsym + nundefsym == nsyms:
            struct.pack_into("<I", new_data, dysym_cmd_off + 8 + 20, nundefsym + len(targets))
        else:
            struct.pack_into("<II", new_data, dysym_cmd_off + 8 + 16, nsyms, len(targets))
    for s in sect_hdrs:
        if s["offset"] >= insert_at:
            struct.pack_into("<I", new_data, s["hdr"] + 48, s["offset"] + nlist_growth)
        if s["reloff"] >= insert_at:
            struct.pack_into("<I", new_data, s["hdr"] + 56, s["reloff"] + nlist_growth)
    rev = {v: k for k, v in demoted_of.items()}
    for ro, rest, nm in dem_relocs:
        u_idx = u_indices[rev[nm]]
        struct.pack_into("<I", new_data, ro + 4, (rest & ~0xFFFFFF) | (u_idx & 0xFFFFFF))
    path.write_bytes(new_data)
    print(f"retarget OK patched={len(dem_relocs)} -> {path}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
