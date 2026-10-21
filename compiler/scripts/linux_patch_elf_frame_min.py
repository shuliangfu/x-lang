#!/usr/bin/env python3
# linux_patch_elf_frame_min.py — note743y.5
# Egg (bootstrap_xlangc) undercounts prologue frame vs rbp homes for large
# nested-block functions. Tip cannot compile those .x (XT001), so sidecars
# fall back to egg and ship undersized frames → tip-cold L2 SEGV/CG002.
# After egg (or any) emit, enlarge `sub $imm,%rsp` when max -N(%rbp) > imm.
# PLATFORM: LINUX x86_64 ELF .o only. No-op if objdump missing or no shortfall.
from __future__ import annotations

import re
import subprocess
import sys


def patch_obj(path: str, dry: bool = False) -> int:
    try:
        data = bytearray(open(path, "rb").read())
    except OSError as e:
        print(f"SKIP {path}: {e}", file=sys.stderr)
        return 0
    try:
        dis2 = subprocess.check_output(
            ["objdump", "-d", "--file-offsets", path],
            text=True,
            errors="replace",
        )
    except (OSError, subprocess.CalledProcessError) as e:
        print(f"SKIP {path}: objdump {e}", file=sys.stderr)
        return 0
    parts = re.split(
        r"(?m)^([0-9a-f]+) <([^>]+)> \(File Offset: 0x([0-9a-f]+)\):", dis2
    )
    patched = 0
    i = 1
    while i + 3 < len(parts):
        name, foff, body = parts[i + 1], int(parts[i + 2], 16), parts[i + 3]
        i += 4
        homes = [int(m, 16) for m in re.findall(r"-0x([0-9a-f]+)\(%rbp\)", body)]
        if not homes:
            continue
        mh = max(homes)
        m = re.search(r"sub\s+\$0x([0-9a-f]+),%rsp", body)
        if not m:
            continue
        imm = int(m.group(1), 16)
        if mh <= imm + 0x20:
            continue
        new_imm = (mh + 0x100 + 0xF) & ~0xF
        # Skip absurd homes (misparse) or frames needing chkstk (>32KiB).
        if new_imm > 0x8000 or (new_imm - imm) > 0x6000:
            print(f"SKIP {path}::{name}: grow {hex(imm)}->{hex(new_imm)} too large")
            continue
        old = bytes([0x48, 0x81, 0xEC]) + imm.to_bytes(4, "little")
        rel = bytes(data[foff : foff + 64]).find(old)
        if rel < 0:
            print(
                f"SKIP {path}::{name}: imm={hex(imm)} home={hex(mh)} pattern miss",
                file=sys.stderr,
            )
            continue
        if not dry:
            data[foff + rel + 3 : foff + rel + 7] = new_imm.to_bytes(4, "little")
        print(f"PATCH {path}::{name}: {hex(imm)}->{hex(new_imm)} (home {hex(mh)})")
        patched += 1
    if not dry and patched:
        open(path, "wb").write(data)
    return patched


# Critical egg-built / tip-peel objs known to undercount on tip-cold (note743y.5).
DEFAULT_OBJS = [
    "build_asm/selfhost_pabi/one.o",
    "src/asm/backend_call_dispatch.o",
    "build_asm/selfhost_pabi/emit_expr_elf_fast_mega.o",
    "build_asm/selfhost_pabi/return_sret.o",
    "build_asm/selfhost_pabi/body_sync_let_order.o",
    # egg alias blob: struct_lit / local_var_slot (note743y.5 si SEGV)
    "build_asm/selfhost_pabi/pabi_alias.skip_egg.o",
    "build_asm/selfhost_pabi/fixed_array_let_init_module_var.o",
]


def main() -> int:
    dry = "--dry" in sys.argv
    paths = [a for a in sys.argv[1:] if not a.startswith("--")]
    if not paths:
        paths = list(DEFAULT_OBJS)
    total = 0
    for p in paths:
        total += patch_obj(p, dry=dry)
    print(f"linux_patch_elf_frame_min: total_patched={total}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
