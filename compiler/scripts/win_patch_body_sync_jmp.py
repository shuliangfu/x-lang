#!/usr/bin/env python3
"""
Post-link PE patch: leftover body_sync entries jmp to the strong twin.

Root (w1010): Windows mega_body lives in the same egg runtime_pipeline_abi.o as
leftover body_sync. Same-TU REL32 keeps calling the leftover even when a strong
host-gcc twin is first-wins and leftover symbols are weakened. Strip-symbol is
refused while relocs name the symbol. Patching the leftover entry to
`jmp rel32` toward the strong T redirects mega without rewriting the egg TU.

Usage (from compiler/ after g05 link):
  python3 scripts/win_patch_body_sync_jmp.py [xlang.exe]

PLATFORM: WINDOWS — no-op if not PE or symbols missing.
"""
from __future__ import annotations

import struct
import subprocess
import sys
from pathlib import Path


def _nm(exe: Path) -> dict[str, list[tuple[int, str]]]:
    out = subprocess.check_output(["nm", str(exe)], text=True, errors="replace")
    syms: dict[str, list[tuple[int, str]]] = {}
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 3 and parts[1] in "TtWw":
            syms.setdefault(parts[2], []).append((int(parts[0], 16), parts[1]))
    return syms


def _sections(exe: Path) -> list[tuple[int, int, int, str]]:
    out = subprocess.check_output(["objdump", "-h", str(exe)], text=True, errors="replace")
    secs: list[tuple[int, int, int, str]] = []
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 6 and parts[0].isdigit():
            try:
                secs.append(
                    (int(parts[3], 16), int(parts[5], 16), int(parts[2], 16), parts[1])
                )
            except ValueError:
                continue
    return secs


def _va_to_off(secs: list[tuple[int, int, int, str]], va: int) -> int:
    for vma, foff, size, _name in secs:
        if vma <= va < vma + size:
            return foff + (va - vma)
    raise SystemExit(f"win_patch_body_sync_jmp: VA {va:#x} not in sections")


def main() -> int:
    exe = Path(sys.argv[1] if len(sys.argv) > 1 else "xlang.exe")
    if not exe.is_file():
        print(f"win_patch_body_sync_jmp: skip missing {exe}", file=sys.stderr)
        return 0
    # PE only — Mach-O/ELF tip objects do not need this.
    try:
        fmt = subprocess.check_output(["objdump", "-f", str(exe)], text=True, errors="replace")
    except Exception:
        return 0
    if "pei-x86-64" not in fmt and "pe-x86-64" not in fmt:
        return 0

    syms = _nm(exe)
    secs = _sections(exe)
    data = bytearray(exe.read_bytes())
    names = (
        "backend_emit_block_body_sync_elf",
        "pipeline_asm_emit_block_body_sync_elf",
    )
    patched = 0
    for name in names:
        entries = syms.get(name, [])
        strong = [a for a, k in entries if k == "T"]
        weak = [a for a, k in entries if k == "W"]
        if not strong or not weak:
            print(f"win_patch_body_sync_jmp: skip {name} (T/W missing)")
            continue
        t_addr = strong[0]
        w_addr = weak[0]
        # Already a jmp to strong?
        off = _va_to_off(secs, w_addr)
        disp = t_addr - (w_addr + 5)
        want = bytes([0xE9]) + struct.pack("<i", disp)
        if data[off : off + 5] == want:
            print(f"win_patch_body_sync_jmp: {name} already patched")
            continue
        data[off : off + 5] = want
        patched += 1
        print(f"win_patch_body_sync_jmp: {name} W={w_addr:#x} -> T={t_addr:#x}")
    if patched:
        exe.write_bytes(data)
    print(f"win_patch_body_sync_jmp: patched={patched}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
