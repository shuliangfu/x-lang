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

w1027/w1028: call-surface fat→_impl jmp is OFF by default (w1521: Win
backend_call_dispatch.o uses the same full→thin tip ladder as POSIX; the
host-cc trampoline seed is gone). Re-enable with XLANG_WIN_FORCE_CALL_PATCH=1.
w1030: enc_label dual-T closed (authority only in enc_dispatch_thin; enc_c.x
no longer exports).
w1031: append_reloc dual-T closed (pabi_weak keeps earliest Cap EXTERNAL;
later tip-inject twin demoted STATIC via win_coff_keep_earliest_sym).
w1034: typed + absolute64 same demote; egg typed weakened when sidecar present.
PLATFORM: WINDOWS.

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
# w1030: enc_label removed from dual-T list (single T from enc_dispatch_thin).
# w1031: append_reloc removed (pabi_weak demotes later tip-inject twin).
# PLATFORM: WINDOWS.
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

# w1026 dual strong T table — enc_label (w1030) and append_reloc (w1031) closed.
# Empty: keep the helper for escape / future twins. PLATFORM: WINDOWS.
_TIP_FAT_EARLIEST_TO_LATER: tuple[str, ...] = ()

# w1497: names whose same-TU egg local (t) copy must jmp to the overlay T.
# PLATFORM: WINDOWS.
_STATIC_T_TO_OVERLAY: tuple[str, ...] = (
    "pipeline_asm_emit_param_home_elf_c",
    # w1499: 64-bit mul/mod/zero-check overlay (binop_wide.o).
    # w1546: f64×integer / f32↔f64 mixed arith, same object.
    "glue_emit_binop_mul_rax_rbx_elf_c",
    "pipeline_asm_emit_binop_mod_elf_c",
    "pipeline_asm_emit_divisor_zero_check_rbx_elf_c",
    "glue_emit_assign_rhs_mod_elf_c",
    "glue_try_emit_mixed_f32_f64_arith_elf_c",
    # w1501: module-let string pool baker overlay (modlet_strpool.o).
    "pipe_modlet_bake_string_lit_elem_to_data",
    # w1502: VAR assign gate overlay (assign_var_compound.o).
    "glue_emit_assign_var_elf_c",
    # w1510: STRUCT_LIT by-name field overlay (struct_lit_field.o).
    "pipeline_expr_struct_lit_field_offset_at",
    "pipeline_expr_struct_lit_field_type_ref_at",
    "glue_struct_lit_field_store_sz",
    # w1511: module-let scalar COMMON gate with f32 imm (modlet_float_imm.o).
    "pipe_modlet_scalar_init_common_imm",
    # w1521: >16B struct ABI (index_base_field.o, win_param_home.o, return_sret.o).
    "glue_emit_index_eff_addr_base_elf_c",
    "pipeline_asm_fill_param_slots",
    "pipeline_asm_emit_return_elf_impl",
    # w2060: widen_mixed arithmetic exports. demote-all-dual keeps the
    # cap-band external and leaves the earlier body as static t.
    # Same-TU relocs still enter that t, so fold it onto the overlay T
    # once the external has been weakened. glue_float_promote_src_ty_ref_c
    # has a single egg definition and stays out of this list.
    # PLATFORM: WINDOWS.
    "glue_emit_binop_add_rax_rbx_elf_c",
    "glue_emit_binop_sub_rbx_minus_rax_elf_c",
    "glue_emit_binop_sub_rax_minus_rbx_elf_c",
    # w2060: 9..16 named-field pair. The egg rec is dual T. demote keeps
    # the cap-band external and leaves the earlier body as static t.
    # Same-TU relocs still enter that t. Fold it onto the helpers T once
    # the external has been weakened. The private pair helper is not an
    # egg symbol and stays out of this list. PLATFORM: WINDOWS.
    "pipeline_asm_emit_expr_elf_rec",
    # w2060: store-retval pair. The egg copy is dual T. demote keeps the
    # cap-band external and leaves the earlier body as static t. Same-TU
    # relocs still enter that t. Fold it onto this thin once the external
    # has been weakened. The private cell loader is not an egg symbol and
    # stays out of this list. PLATFORM: WINDOWS.
    "glue_store_retval_pair_to_rbp_elf_c",
)

# w1504 (10.30): egg copies of the i32 literal probe skip the wide check, so
# `a + 20000000000` loaded `mov $0xa817c800,%ebx` (low 32 bits). Fold every
# entry (T and same-TU t) onto the checked twin with the same signature
# (arena, expr_ref, out_imm) -> 1 only for an i32-fit INT/BOOL literal.
# PLATFORM: WINDOWS.
_ALIAS_TO_CHECKED: tuple[tuple[str, str], ...] = (
    ("pipeline_asm_expr_lit_i32_at_c", "pipeline_asm_cmp_expr_lit_i32_at"),
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
    XLANG_WIN_SKIP_CALL_PATCH=1 still skips. w1030: enc_label dual-T closed.
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


# w1486: binop VAR-slot cache. w1521 (10.57): the egg also carries two copies
# of the sret emit-ctx accessors (t + T, each with its own static). mega_body
# sets active/ret_sz/home_off through the t copy while the param_home /
# return_sret overlays read the T copy, so the callee never saw sret on Win
# (rcx taken as arg0, return did not copy to the hidden dest). Fold t onto T
# so there is one sret state. PLATFORM: WINDOWS.
_STATIC_STATE_FOLD_PREFIXES: tuple[str, ...] = (
    "glue_binop_var_slot_cache_",
    "pipeline_asm_emit_ctx_sret_",
)


def _patch_cache_static_to_global(
    data: bytearray,
    secs: list[tuple[int, int, int, str]],
    syms: dict[str, list[tuple[int, str]]],
) -> int:
    """
    w1486: egg carries two binop VAR-slot caches — static wave210 copies (t,
    g_wave210_var_*) and global T copies (g_var_cache_*). Different egg
    glue_try_binop_load_operand copies call different sets, and the
    block-entry cache clear overlay can only reach the global T. Fold every
    static t entry onto its global T twin so there is one cache state.
    PLATFORM: WINDOWS.
    """
    patched = 0
    for name in sorted(syms):
        if not name.startswith(_STATIC_STATE_FOLD_PREFIXES):
            continue
        entries = syms[name]
        strong = [a for a, k in entries if k == "T"]
        local = [a for a, k in entries if k == "t"]
        if len(strong) != 1 or not local:
            continue
        for a in local:
            patched += _patch_jmp(data, secs, name + "(t)", a, strong[0])
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
        # w1032: leaf scratch floor skip overlay. PLATFORM: WINDOWS.
        "pipeline_asm_compute_frame_size_c",
        # w1041: call_spill (n+1)*8 overlay. PLATFORM: WINDOWS.
        "glue_asm_sum_block_call_spill_bytes",
        # w1487: egg tail-jmp peer → off overlay (return 0). PLATFORM: WINDOWS.
        "w499_mega_try_tail_jmp",
        # w1497: param_home canonicalize overlay. PLATFORM: WINDOWS.
        "pipeline_asm_emit_param_home_elf_c",
        # w1499: 64-bit mul/mod/zero-check overlay. PLATFORM: WINDOWS.
        # w1546: f64×integer / f32↔f64 mixed arith, same object.
        "glue_emit_binop_mul_rax_rbx_elf_c",
        "pipeline_asm_emit_binop_mod_elf_c",
        "pipeline_asm_emit_divisor_zero_check_rbx_elf_c",
        "glue_emit_assign_rhs_mod_elf_c",
        "glue_try_emit_mixed_f32_f64_arith_elf_c",
        # w1501: module-let string pool baker overlay. PLATFORM: WINDOWS.
        "pipe_modlet_bake_string_lit_elem_to_data",
        # w1502: VAR assign gate overlay. PLATFORM: WINDOWS.
        "glue_emit_assign_var_elf_c",
        # w1510: STRUCT_LIT by-name field overlay. PLATFORM: WINDOWS.
        "pipeline_expr_struct_lit_field_offset_at",
        "pipeline_expr_struct_lit_field_type_ref_at",
        "glue_struct_lit_field_store_sz",
        # w1511: module-let f32 imm COMMON gate overlay. PLATFORM: WINDOWS.
        "pipe_modlet_scalar_init_common_imm",
        # w1521: >16B struct ABI overlays. PLATFORM: WINDOWS.
        "glue_emit_index_eff_addr_base_elf_c",
        "pipeline_asm_fill_param_slots",
        "pipeline_asm_emit_return_elf_impl",
        # w2055: enum ns tag / cmp rhs tag thin (egg 32-byte base_buf).
        # PLATFORM: WINDOWS.
        "pipeline_expr_enum_namespace_field_tag",
        "pipeline_asm_cmp_enum_rhs_tag_c",
        # w2055: assign thin (egg deref assign stores rax only).
        # PLATFORM: WINDOWS.
        "pipeline_asm_emit_assign_elf_c",
        # w2055: w156 guard thin (egg INDEX assign-address cache hit).
        # PLATFORM: WINDOWS.
        "glue_index_assign_addr_cache_hit",
        "glue_emit_struct_type_let_init_elf_c",
        # w2060: call-arg packer thin (egg for_call_args predates the
        # fixed-array FIELD decay fix). PLATFORM: WINDOWS.
        "pipeline_asm_emit_expr_elf_for_call_args",
        # w2060: collect-imports thin. The egg T calls lexer_init; after
        # weaken, same-TU relocs still enter that body, so fold W onto the
        # tip T. Not a local-t name. PLATFORM: WINDOWS.
        "xlang_module_collect_imports_from_buf",
        # w2060: mixed-width add/sub and f32 promote. The three arithmetic
        # exports are dual T; demote keeps the cap-band external, and the
        # relink weaken turns that external into W. glue_float_promote is
        # a single W. The static twins are folded above. PLATFORM: WINDOWS.
        "glue_emit_binop_add_rax_rbx_elf_c",
        "glue_emit_binop_sub_rbx_minus_rax_elf_c",
        "glue_emit_binop_sub_rax_minus_rbx_elf_c",
        "glue_float_promote_src_ty_ref_c",
        # w2060: helpers expr rec. The cap-band egg copy becomes W after
        # weaken and still calls fast with one qword. Fold that W onto the
        # helpers T. The static twin is folded above. PLATFORM: WINDOWS.
        "pipeline_asm_emit_expr_elf_rec",
        # w2060: store-retval pair. The cap-band egg copy becomes W after
        # weaken and still copies only CALL, METHOD, and INDEX. Fold that W
        # onto this thin. The static twin is folded above. The private cell
        # loader stays out of this list. PLATFORM: WINDOWS.
        "glue_store_retval_pair_to_rbp_elf_c",
        # w2060: named-field aggregate load. The egg copy is one T, not a
        # static twin, so it stays out of _STATIC_T_TO_OVERLAY. It returns
        # 0 before sizing when no call argument is active. Three same-TU
        # calls enter that entry. After weaken, fold that W onto this thin.
        # The filename-prefixed cell loaders are not egg symbols and stay
        # out of this list. PLATFORM: WINDOWS.
        "glue_field_call_arg_try_load_agg_from_rax_elf_c",
        # w1486: backend_emit_block_body_sync_elf cache-clear overlay is
        # already listed first (W→T). PLATFORM: WINDOWS.
    )
    patched = 0
    # w1026: tip fat call / enc_label / reloc surface → Cap residual. Do this
    # before bake W→T folds so call_dispatch tip bodies do not stay first-wins.
    patched += _patch_tip_fat_to_impl(data, secs, syms)
    patched += _patch_tip_fat_earliest_to_later(data, secs, syms)
    # w1486: single binop VAR-slot cache (static t → global T). PLATFORM: WINDOWS.
    patched += _patch_cache_static_to_global(data, secs, syms)
    # w1497: egg mega_body calls the same-TU local (t) leftover-PE
    # param_home; fold it onto the overlay T only when the egg T was
    # weakened (W present), i.e. the overlay is linked. PLATFORM: WINDOWS.
    for _ln in _STATIC_T_TO_OVERLAY:
        _ents = syms.get(_ln, [])
        _st = [a for a, k in _ents if k == "T"]
        _wk = [a for a, k in _ents if k == "W"]
        _lc = [a for a, k in _ents if k == "t"]
        if len(_st) != 1 or not _wk or not _lc:
            print(f"win_patch_body_sync_jmp: skip {_ln}(t) (overlay not linked)")
            continue
        for _a in _lc:
            patched += _patch_jmp(data, secs, _ln + "(t)", _a, _st[0])
    # w1504: unchecked i32 literal probe → checked twin. PLATFORM: WINDOWS.
    for _src, _dst in _ALIAS_TO_CHECKED:
        _dt = [a for a, k in syms.get(_dst, []) if k == "T"]
        _se = [a for a, k in syms.get(_src, []) if k in "Tt"]
        if len(_dt) != 1 or not _se:
            print(f"win_patch_body_sync_jmp: skip {_src} (checked twin missing)")
            continue
        for _a in _se:
            patched += _patch_jmp(data, secs, _src + "->" + _dst, _a, _dt[0])
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
    # w2060: module INDEX cold lea. The egg defines only a local
    # pipe_modlet_lea_named_binding_addr_to_rax_cold, so the W gate above
    # never sees this name. The tip thin is one strong T that calls
    # pipe_modlet_lea_named_binding_addr_to_rax (the live table). Fold
    # every local t onto that T. Skip when that T is missing or not unique.
    # PLATFORM: WINDOWS.
    _lea_cold = "pipe_modlet_lea_named_binding_addr_to_rax_cold"
    _lea_ents = syms.get(_lea_cold, [])
    _lea_t = [a for a, k in _lea_ents if k == "T"]
    _lea_loc = [a for a, k in _lea_ents if k == "t"]
    if len(_lea_t) == 1 and _lea_loc:
        for _a in _lea_loc:
            patched += _patch_jmp(data, secs, _lea_cold + "(t)", _a, _lea_t[0])
    else:
        print(
            f"win_patch_body_sync_jmp: skip {_lea_cold}(t) (overlay not linked)"
        )
    if patched:
        exe.write_bytes(data)
    print(f"win_patch_body_sync_jmp: patched={patched}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
