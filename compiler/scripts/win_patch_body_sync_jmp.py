#!/usr/bin/env python3
"""
Post-link PE patch: leftover body_sync / emit_let_init / bake_array jmp to tip.

Root (w1010): Windows mega_body lives in the same egg runtime_pipeline_abi.o as
leftover body_sync (and tip emit_let_init). Same-TU REL32 keeps calling the
leftover even when a strong host-gcc twin is first-wins and leftover symbols are
weakened. Strip-symbol is refused while relocs name the symbol. Patching the
leftover entry to `jmp rel32` toward the strong T redirects mega without
rewriting the egg TU.

Also patches glue_block_body_emit_let_init: tip stack u8[256] vn smash breaks
f32 lets; host-gcc BSS twin is first-wins T but same-TU callers still hit W.

w1013: pipe_modlet_bake_array_lit_elems_to_data — egg has local e8 to Cap
residual bake; tip bake_elems first-wins T + weaken leftover; jmp W→T so
named i8 ARRAY packs at esz=1. Also patches *_cold local entry if present.

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


def _patch_w_to_t(
    data: bytearray,
    secs: list[tuple[int, int, int, str]],
    name: str,
    strong: list[int],
    weak: list[int],
) -> int:
    """Patch every weak entry to jmp the first strong T. Returns patch count."""
    if not strong or not weak:
        print(f"win_patch_body_sync_jmp: skip {name} (T/W missing)")
        return 0
    t_addr = strong[0]
    patched = 0
    for w_addr in weak:
        off = _va_to_off(secs, w_addr)
        disp = t_addr - (w_addr + 5)
        want = bytes([0xE9]) + struct.pack("<i", disp)
        if data[off : off + 5] == want:
            print(f"win_patch_body_sync_jmp: {name} already patched @{w_addr:#x}")
            continue
        data[off : off + 5] = want
        patched += 1
        print(f"win_patch_body_sync_jmp: {name} W={w_addr:#x} -> T={t_addr:#x}")
    return patched


def _patch_extra_t_to_primary(
    data: bytearray,
    secs: list[tuple[int, int, int, str]],
    name: str,
    strong: list[int],
) -> int:
    """
    When weaken left multiple T (objcopy miss), keep the first T as tip and
    jmp remaining T entries to it. PLATFORM: WINDOWS bake_array duplicates.
    """
    if len(strong) < 2:
        return 0
    t_addr = strong[0]
    patched = 0
    for extra in strong[1:]:
        off = _va_to_off(secs, extra)
        disp = t_addr - (extra + 5)
        want = bytes([0xE9]) + struct.pack("<i", disp)
        if data[off : off + 5] == want:
            continue
        data[off : off + 5] = want
        patched += 1
        print(f"win_patch_body_sync_jmp: {name} extraT={extra:#x} -> T={t_addr:#x}")
    return patched


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
        "glue_block_body_emit_let_init",
        # w1013 true-pack ARRAY i8 bake / INDEX load / assign. PLATFORM: WINDOWS.
        "pipe_modlet_bake_array_lit_elems_to_data",
        "glue_emit_assign_index_elf_c",
        "glue_emit_index_load_arms_elf_c",
        "pipeline_asm_emit_index_elf_c",
    )
    patched = 0
    for name in names:
        entries = syms.get(name, [])
        strong = [a for a, k in entries if k == "T"]
        weak = [a for a, k in entries if k == "W"]
        patched += _patch_w_to_t(data, secs, name, strong, weak)
        if name == "pipe_modlet_bake_array_lit_elems_to_data":
            patched += _patch_extra_t_to_primary(data, secs, name, strong)
            # Local cold entry (lowercase t) — same-TU e8 targets.
            cold_name = "pipe_modlet_bake_array_lit_elems_to_data_cold"
            cold = [a for a, k in syms.get(cold_name, []) if k in "Tt"]
            if strong and cold:
                t_addr = strong[0]
                for c_addr in cold:
                    off = _va_to_off(secs, c_addr)
                    disp = t_addr - (c_addr + 5)
                    want = bytes([0xE9]) + struct.pack("<i", disp)
                    if data[off : off + 5] == want:
                        continue
                    data[off : off + 5] = want
                    patched += 1
                    print(
                        f"win_patch_body_sync_jmp: {cold_name} t={c_addr:#x} -> T={t_addr:#x}"
                    )
        elif name in (
            "glue_emit_assign_index_elf_c",
            "glue_emit_index_load_arms_elf_c",
            "pipeline_asm_emit_index_elf_c",
        ):
            patched += _patch_extra_t_to_primary(data, secs, name, strong)
    if patched:
        exe.write_bytes(data)
    print(f"win_patch_body_sync_jmp: patched={patched}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
