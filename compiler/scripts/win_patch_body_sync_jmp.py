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

w1026: tip-compiled call_dispatch / enc_label publics first-win over Cap
residual `_impl` (or a later twin). Those fat .x bodies smash Win64 multi-arg
ABI and PE symbol values (2nd function Value=0; call reloc name truncated to
`t`). Cap residual `_impl` / later twin is correct. Patch earliest tip fat
entry to `jmp rel32` toward `_impl` (or the later twin). Do NOT swap in
backend_call_dispatch.o.bak (175735) — that cleared CG002 then SEGV/reloc
truncated at run. PLATFORM: WINDOWS tip bake stack.

w1027/w1028: Windows product uses host-cc thin trampolines
(seeds/backend_call_dispatch_win_thin_trampolines.c) so call-surface
fat→_impl jmp is OFF by default. Re-enable with XLANG_WIN_FORCE_CALL_PATCH=1.
enc_label / append_reloc dual-T patches remain. PLATFORM: WINDOWS.

Usage (from compiler/ after g05 link):
  python3 scripts/win_patch_body_sync_jmp.py [xlang.exe]

PLATFORM: WINDOWS — no-op if not PE or symbols missing.
"""
from __future__ import annotations

import os
import struct
import subprocess
import sys
from pathlib import Path

# w1026/w1027/w1028: tip fat public → Cap residual _impl (call / string surface).
# w1027: host-cc thin trampolines first-win on Windows (ensure_win_call_dispatch_host_thin).
# w1028: call-surface jmp is OFF by default (trampoline already forwards to _impl).
# Escape: XLANG_WIN_FORCE_CALL_PATCH=1 re-enables fat→_impl jmp if tip fat reappears.
# enc_label / append_reloc dual-T patches stay on. PLATFORM: WINDOWS.
_TIP_FAT_TO_IMPL: tuple[str, ...] = (
    "pipeline_asm_emit_call_elf_c",
    "pipeline_asm_emit_call_args_elf_c",
    "glue_asm_emit_call_with_cleanup",
    "glue_asm_emit_jmp_skip_string_then_lea",
    "glue_asm_emit_string_lit_ptr_rax_elf_c",
    "glue_emit_one_call_arg_elf_c",
    "glue_asm_string_lit_into",
    "glue_asm_try_emit_fmt_string_lit_import_call_elf_c",
    "glue_asm_enc_call_redirected",
    "glue_asm_build_call_export_sym_c",
)

# w1026: dual strong T — earliest tip fat → later Cap residual twin.
_TIP_FAT_EARLIEST_TO_LATER: tuple[str, ...] = (
    "arch_x86_64_enc_enc_label",
    "pipeline_elf_ctx_append_reloc",
)


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
    """Patch every weak entry to jmp the earliest strong T. Returns patch count."""
    if not strong or not weak:
        print(f"win_patch_body_sync_jmp: skip {name} (T/W missing)")
        return 0
    t_addr = min(strong)
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


def _patch_jmp(
    data: bytearray,
    secs: list[tuple[int, int, int, str]],
    name: str,
    src: int,
    dst: int,
) -> int:
    """Write `jmp rel32` at src toward dst. Returns 1 if bytes changed."""
    if src == dst:
        return 0
    off = _va_to_off(secs, src)
    want = bytes([0xE9]) + struct.pack("<i", dst - (src + 5))
    if data[off : off + 5] == want:
        print(f"win_patch_body_sync_jmp: {name} already patched @{src:#x}")
        return 0
    data[off : off + 5] = want
    print(f"win_patch_body_sync_jmp: {name} @{src:#x} -> @{dst:#x}")
    return 1


def _patch_tip_fat_to_impl(
    data: bytearray,
    secs: list[tuple[int, int, int, str]],
    syms: dict[str, list[tuple[int, str]]],
) -> int:
    """
    w1026: tip .x fat public first-wins over Cap residual `_impl`.
    Jump the earliest public T to `_impl`. PLATFORM: WINDOWS.

    w1028: OFF by default — host-cc thin trampolines already call `_impl`
    (w1027). Set XLANG_WIN_FORCE_CALL_PATCH=1 to re-enable. Legacy
    XLANG_WIN_SKIP_CALL_PATCH=1 still skips. enc_label dual-T stays on.
    """
    force = os.environ.get("XLANG_WIN_FORCE_CALL_PATCH", "") == "1"
    skip = os.environ.get("XLANG_WIN_SKIP_CALL_PATCH", "") == "1"
    if skip or not force:
        print(
            "win_patch_body_sync_jmp: skip call-surface fat→_impl "
            "(default off; XLANG_WIN_FORCE_CALL_PATCH=1 to enable)"
        )
        return 0
    patched = 0
    for base in _TIP_FAT_TO_IMPL:
        impl = base + "_impl"
        pub = [a for a, k in syms.get(base, []) if k == "T"]
        dsts = [a for a, k in syms.get(impl, []) if k == "T"]
        if not pub or not dsts:
            print(f"win_patch_body_sync_jmp: skip {base} (T/_impl missing)")
            continue
        patched += _patch_jmp(data, secs, base, min(pub), min(dsts))
    return patched


def _patch_tip_fat_earliest_to_later(
    data: bytearray,
    secs: list[tuple[int, int, int, str]],
    syms: dict[str, list[tuple[int, str]]],
) -> int:
    """
    w1026: dual strong T without `_impl` — earliest tip fat → later Cap twin.
    Opposite of bake_array fold (which keeps earliest). PLATFORM: WINDOWS.
    """
    patched = 0
    for name in _TIP_FAT_EARLIEST_TO_LATER:
        strong = sorted({a for a, k in syms.get(name, []) if k == "T"})
        if len(strong) < 2:
            print(f"win_patch_body_sync_jmp: skip {name} (need dual T)")
            continue
        patched += _patch_jmp(data, secs, name, strong[0], strong[1])
    return patched


def _patch_extra_t_to_primary(
    data: bytearray,
    secs: list[tuple[int, int, int, str]],
    name: str,
    strong: list[int],
) -> int:
    """
    When weaken left multiple T (objcopy miss), keep the earliest-VA T as tip
    (PE first-wins → tip linked first → usually lowest address) and jmp remaining
    T entries to it. PLATFORM: WINDOWS bake_array / INDEX tip duplicates.
    """
    if len(strong) < 2:
        return 0
    t_addr = min(strong)
    patched = 0
    for extra in strong:
        if extra == t_addr:
            continue
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
        # w1013/w1018 true-pack ARRAY i8 bake / INDEX load / assign / force_esz.
        # PLATFORM: WINDOWS.
        "pipe_modlet_bake_array_lit_elems_to_data",
        "pipeline_asm_index_elem_byte_sz_c",
        "glue_index_elem_byte_sz_from_type_ref_c",
        "pipeline_asm_index_elem_byte_sz",
        "pipeline_asm_emit_index_elf_c",
        "glue_emit_index_load_arms_elf_c",
        "glue_emit_assign_index_elf_c",
        "glue_array_lit_force_esz_from_elem_type_c",
        "pipeline_asm_array_lit_elem_byte_sz_c",
        "glue_fixed_array_total_bytes_c",
        # w1023 nested ARRAY_LIT local let-init. PLATFORM: WINDOWS.
        "pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32",
        "pipeline_asm_emit_vector_let_init_elf_c",
        # w1024 module VAR → local fixed-array let-init. PLATFORM: WINDOWS.
        "glue_emit_fixed_array_type_let_init_elf_c",
    )
    patched = 0
    # w1026: tip fat call / enc_label / reloc surface → Cap residual. Do this
    # before bake W→T folds so call_dispatch tip bodies do not stay first-wins.
    patched += _patch_tip_fat_to_impl(data, secs, syms)
    patched += _patch_tip_fat_earliest_to_later(data, secs, syms)
    for name in names:
        entries = syms.get(name, [])
        strong = [a for a, k in entries if k == "T"]
        weak = [a for a, k in entries if k == "W"]
        patched += _patch_w_to_t(data, secs, name, strong, weak)
        if name == "pipe_modlet_bake_array_lit_elems_to_data":
            # Only redirect leftovers when tip first-wins left W entries.
            # Without tip, egg has two strong T — do NOT jmp them into each
            # other (w1013 regression). PLATFORM: WINDOWS.
            if not weak:
                print(
                    "win_patch_body_sync_jmp: skip bake_array extra/cold (no W tip)"
                )
                continue
            patched += _patch_extra_t_to_primary(data, secs, name, strong)
            # Local cold entry (lowercase t) — same-TU e8 targets.
            cold_name = "pipe_modlet_bake_array_lit_elems_to_data_cold"
            cold = [a for a, k in syms.get(cold_name, []) if k in "Tt"]
            if strong and cold:
                t_addr = min(strong)
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
        elif len(strong) > 1 and (
            weak or name == "glue_emit_fixed_array_type_let_init_elf_c"
        ):
            # Tip + leftover T duplicates: fold extras to earliest T.
            # w1024: let_init tip may leave dual egg T with no W when
            # weaken misses one COMDAT — still jmp extras to tip.
            # PLATFORM: WINDOWS. bake_array keeps the no-W skip above.
            patched += _patch_extra_t_to_primary(data, secs, name, strong)
    if patched:
        exe.write_bytes(data)
    print(f"win_patch_body_sync_jmp: patched={patched}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
