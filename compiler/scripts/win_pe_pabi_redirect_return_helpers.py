#!/usr/bin/env python3
# PLATFORM: WINDOWS leftover-PE hybrid only.
#
# After rest-first + pipeline_glue_standalone thin ld -r, thin mega / thin
# emit_block keep relative calls to thin (high-VA) helpers. PE first-wins does
# not rewrite those.
#
# Redirects thin→lower-VA rest:
#   Mega helpers: nso_at / get_return_at / body_ref_at
#   Wrapper: mega_body_c (WAVE290 void-main mov-imm-0 lives in leftover rest)
#   Emit-block AST faces: stmt_order kind/idx/count, if_cond/then/else, …
#
# Usage: win_pe_pabi_redirect_return_helpers.py <pe-or-coff-path>

from __future__ import annotations

import re
import struct
import subprocess
import sys

# Thin mega → rest WIN_LEFTOVER helpers.
MEGA_REDIRECT_SYMS = (
    "pipeline_asm_block_num_stmt_order_at",
    "pipeline_asm_get_return_expr_ref_at",
    "pipeline_asm_module_func_body_ref_at",
)

# Thin emit_block / emit_if / emit_while → rest W277 ast_* faces
# (high twin mis-reads kind / SAT Block.num_expr_stmts=0 skips `x=4`).
# PLATFORM: WINDOWS leftover-PE hybrid — G.7 complete of this redirect table.
EMIT_REDIRECT_SYMS = (
    "ast_ast_block_stmt_order_kind",
    "ast_ast_block_stmt_order_idx",
    "ast_ast_block_num_stmt_order",
    "ast_ast_block_num_if_stmts",
    "ast_ast_block_num_lets",
    "ast_ast_block_num_consts",
    "ast_ast_block_num_expr_stmts",
    "ast_ast_block_num_loops",
    "ast_ast_block_num_for_loops",
    "ast_ast_block_final_expr_ref",
    "ast_ast_block_expr_stmt_ref",
    "ast_pipeline_block_expr_stmt_ref",
    "pipeline_block_expr_stmt_ref",
    "ast_ast_block_while_cond_ref",
    "ast_ast_block_while_body_ref",
    "pipeline_block_while_cond_ref",
    "pipeline_block_while_body_ref",
    "ast_ast_block_for_init_ref",
    "ast_ast_block_for_cond_ref",
    "ast_ast_block_for_step_ref",
    "ast_ast_block_for_body_ref",
    # WAVE278 match sidecar (SAT emit_match intra SAT Expr.match_* → CG002).
    "pipeline_expr_match_matched_ref_at",
    "pipeline_expr_match_num_arms_at",
    "pipeline_expr_match_arm_is_wildcard",
    "pipeline_expr_match_arm_guard_ref",
    "pipeline_expr_match_arm_result_ref",
    "pipeline_expr_match_arm_is_enum_variant",
    "pipeline_expr_match_arm_variant_index",
    "pipeline_expr_match_arm_lit_val",
    "ast_pipeline_expr_match_matched_ref_at",
    "ast_pipeline_expr_match_num_arms_at",
    "ast_pipeline_expr_match_arm_is_wildcard",
    "ast_pipeline_expr_match_arm_guard_ref",
    "ast_pipeline_expr_match_arm_result_ref",
    "ast_pipeline_expr_match_arm_is_enum_variant",
    "ast_pipeline_expr_match_arm_variant_index",
    "ast_pipeline_expr_match_arm_lit_val",
    # WAVE278 ARRAY_LIT sidecar (SAT emit_array_lit intra SAT
    # array_lit_* → n_arr==0 lea-empty; INDEX assign already green).
    "pipeline_expr_array_lit_num_elems_at",
    "pipeline_expr_array_lit_elem_ref",
    "ast_pipeline_expr_array_lit_num_elems_at",
    "ast_pipeline_expr_array_lit_elem_ref",
    "pipeline_expr_index_base_ref",
    "pipeline_expr_index_index_ref",
    "ast_pipeline_expr_index_base_ref",
    "ast_pipeline_expr_index_index_ref",
    # WAVE278 STRUCT_LIT sidecar (SAT emit_struct_lit intra SAT
    # struct_lit_num_fields → n_fields==0 lea-empty; FIELD assign already
    # green). leftover rest WIN leftover FROM_X reads W278_Expr.
    "pipeline_expr_struct_lit_num_fields",
    "pipeline_expr_struct_lit_init_ref",
    "pipeline_expr_struct_lit_field_name_len",
    "pipeline_expr_struct_lit_field_name_into",
    "pipeline_expr_struct_lit_type_name_len",
    "pipeline_expr_struct_lit_type_name_into",
    "pipeline_expr_struct_lit_type_name_set",
    "ast_pipeline_expr_struct_lit_num_fields",
    "ast_pipeline_expr_struct_lit_init_ref",
    "ast_pipeline_expr_struct_lit_field_name_len",
    "ast_pipeline_expr_struct_lit_field_name_into",
    "ast_pipeline_expr_struct_lit_type_name_len",
    "ast_pipeline_expr_struct_lit_type_name_into",
    "ast_pipeline_expr_struct_lit_type_name_set",
    "pipeline_expr_kind_ord_at",
    "glue_struct_layout_compute_field_offset_c",
    "glue_struct_layout_index_by_type_name_c",
    "pipeline_module_num_struct_layouts_at",
    "pipeline_module_struct_layout_num_fields",
    # WAVE278 FIELD_ACCESS sidecar (SAT glue_field_access_call_base_rvalue
    # intra SAT field_access_base_ref → SAT Expr empty → UNHANDLED CG002
    # for bare STRUCT_LIT.field). leftover rest WAVE278 ALWAYS reads W278_Expr.
    "pipeline_expr_field_access_base_ref",
    "pipeline_expr_field_access_name_len",
    "pipeline_expr_field_access_name_into",
    "pipeline_expr_field_access_offset",
    "pipeline_expr_field_access_soa_stride",
    "ast_pipeline_expr_field_access_offset",
    "ast_pipeline_expr_field_access_is_enum_variant",
    "glue_arena_expr_at_ref",
    "pipeline_arena_expr_ptr",
    "pipeline_asm_ctx_layout",
    # WAVE277 let type + WAVE270 kind (SAT emit_block_inits intra SAT
    # let_type_ref → glue_block_let_is_fixed_array false → store ARRAY_LIT
    # pointer into the [N]T slot; INDEX then lea-slot).
    "pipeline_block_let_type_ref",
    "ast_pipeline_block_let_type_ref",
    "pipeline_type_kind_ord_at",
    "ast_pipeline_block_if_cond_ref",
    "ast_pipeline_block_if_then_body_ref",
    "ast_pipeline_block_if_else_body_ref",
    "ast_pipeline_block_let_init_ref",
    "ast_pipeline_block_const_init_ref",
    "pipeline_block_stmt_order_kind",
    "pipeline_block_stmt_order_idx",
    "glue_emit_block_final_expr_elf",
    # WAVE277 region sidecar (SAT emit_block intra SAT region_body →
    # SAT Block.num_regions=0 skips `unsafe { return *p }`; ADDR_OF of
    # VAR already lea'd). leftover rest WAVE277 ALWAYS reads W277_Region.
    # G.7 complete of this redirect table.
    "ast_ast_block_num_regions",
    "ast_ast_block_region_body_ref",
    "pipeline_block_region_body_ref",
    "pipeline_block_region_is_unsafe",
    "pipeline_block_region_with_arena_cap_ref",
    "ast_pipeline_block_region_body_ref",
    "ast_pipeline_block_num_regions",
    # wave223 leftover rest sret BSS (SAT emit_struct_lit intra SAT
    # sret_active_get BSS=0 → local dest, ignores caller rdi). leftover
    # rest mega_body + param_home write leftover rest cells; PE first-wins
    # does not rewrite SAT intra calls. G.7 complete of this redirect table.
    "pipeline_asm_emit_ctx_sret_active_get",
    "pipeline_asm_emit_ctx_sret_home_off_get",
    "pipeline_asm_emit_ctx_sret_ret_sz_get",
    # SAT emit_block_inits intra SAT emit_expr wrapper → SAT rec (local t)
    # → SAT remaining-wave emit_deref intra SAT unary_operand (SAT Expr
    # empty → op=0 → -1) → let-init DEREF `let y: i32 = *p` CG002
    # labels=1 patches=0. Contrast: `return *p` SAT emit_block UNDEFs
    # leftover rest rec first-wins (already green). PE first-wins does
    # not rewrite SAT intra. G.7 complete of this redirect table:
    # SAT emit_block_inits / SAT rec → leftover rest wrapper/rec/deref;
    # SAT remaining-wave deref → leftover rest WAVE278 unary_operand.
    # PLATFORM: WINDOWS leftover-PE hybrid / POSIX -E unchanged.
    "pipeline_asm_emit_expr_elf_c",
    "pipeline_asm_emit_expr_elf_rec",
    "pipeline_asm_emit_deref_elf_c",
    "pipeline_expr_unary_operand_ref_at",
    "ast_pipeline_expr_unary_operand_ref_at",
    # TYPE_FN STRUCT_LIT field: SAT emit_struct_lit intra SAT
    # field_store_sz (SAT type_kind miss → fsz==0 skip store). leftover
    # rest WIN leftover first-wins field_store_sz (WAVE270 kind + TYPE_FN=18
    # → 8). SAT load_byte_sz name-scan stole i32 width for field `f`.
    # WAVE278 resolved_type_ref first-wins so SAT load_byte_sz sees TYPE_FN.
    # PLATFORM: WINDOWS leftover-PE hybrid / POSIX -E unchanged.
    "glue_struct_lit_field_store_sz",
    "pipeline_expr_struct_lit_field_store_sz",
    "pipeline_expr_resolved_type_ref",
    "ast_pipeline_expr_resolved_type_ref",
    # ARRAY_LIT TYPE_FN: SAT emit_array_lit intra SAT elem_byte_sz
    # (kind miss → esz=4 `mov %eax` truncates PE fn ptr; INDEX loads 8).
    # leftover rest WIN leftover first-wins elem_byte_sz (TYPE_FN=18 / PTR=9 → 8).
    # PE first-wins does not rewrite SAT intra. G.7 complete of this table.
    # PLATFORM: WINDOWS leftover-PE hybrid / POSIX -E unchanged.
    "pipeline_asm_array_lit_elem_byte_sz_c",
    "pipeline_asm_array_lit_elem_type_ref",
    # Nested-block lets (unsafe region / if / while / for): SAT emit_block
    # formula num_locals-nlets + SAT let_name skip nlen==0. leftover rest
    # WIN leftover emit_block_body uses block_slot_get after fill walks
    # WAVE277 children. SAT emit_if intra SAT emit_block (PE first-wins
    # does not rewrite) — redirect SAT if/while/for → leftover rest body.
    # PLATFORM: WINDOWS leftover-PE hybrid / POSIX -E unchanged.
    "pipeline_asm_emit_block_body_sync_elf",
    "backend_emit_block_body_sync_elf",
    "pipeline_block_let_name_len",
    "pipeline_block_let_name_copy64",
    "glue_lazy_append_block_let_local",
    # TYPE_ARRAY formal E* (16B apply([foo, bar]) / [4]i32): SAT try_index
    # intra SAT enc_local (local t) needs_ptr_load=0 → lea 8B home as
    # payload (8B load_64 compensation; 16B dest pointer SEGV 139 /
    # garbage). leftover rest WIN leftover enc_local / needs_ptr_load /
    # is_indirect_array_slot load the T[N] pointer home. Do not leftover
    # rest T SAT try_index (SAT local t is the real body; leftover rest
    # remaining-wave stub -2 FROM_X ABSENT). PE first-wins does not
    # rewrite SAT intra. G.7 complete of this table.
    # PLATFORM: WINDOWS leftover-PE hybrid / POSIX -E unchanged.
    "glue_enc_local_slot_ptr_or_addr_elf_c",
    "glue_local_var_slot_needs_ptr_load_elf_c",
    "glue_emit_func_param_is_indirect_array_slot_c",
    # INDEX TYPE_SLICE store: SAT slice_from_array intra SAT durable
    # jmp-over text-embed parks const i32 in RX .text (`xs[0] = 9`
    # SEGV 139). leftover rest WIN leftover durable first-wins
    # SHN_COMMON BSS (writable). SAT durable is SAT local t — not
    # leftover rest T SAT global T. leftover rest remaining-wave
    # durable is #ifndef FROM_X ABSENT. PE first-wins does not
    # rewrite SAT intra. G.7 complete of this table.
    # PLATFORM: WINDOWS leftover-PE hybrid / POSIX -E unchanged.
    "glue_asm_emit_array_lit_durable_ptr_rax_elf_c",
    # CALL TYPE_SLICE let-init: SAT emit_block_inits intra SAT
    # glue_emit_struct_type_let_init intra SAT store_retval_pair
    # (local t) stores rax+rdx then reent deep-copy. SAT reent uses
    # 32-bit addl that truncates PE COMMON (`slice_call_let` SEGV 139).
    # leftover rest WIN leftover unique first-wins: store rax+rdx,
    # skip reent (payload is leftover rest durable COMMON). SAT
    # store_retval_pair is SAT local t — not leftover rest T SAT
    # global T. PE first-wins does not rewrite SAT intra. G.7
    # complete of this table.
    # PLATFORM: WINDOWS leftover-PE hybrid / POSIX -E unchanged.
    "glue_store_retval_pair_to_rbp_elf_c",
    # ARRAY_LIT TYPE_SLICE local `.length`: leftover-PE named lets
    # are positive product offsets ([rbp-off]). C fat MEMORY is
    # product home-8 (x86). leftover rest unique T win_glue polarity
    # first-wins so SAT slice_from_array / SAT length_to_rbx intra
    # SAT local t share FIELD / store_retval_pair / for_call_args
    # wrap. SAT length_off is SAT local t — not leftover rest T
    # SAT global T. leftover rest remaining-wave length_off is
    # #ifndef FROM_X ABSENT. Do not leftover rest T SAT
    # length_to_rbx / try_index / emit_assign / remaining-wave via
    # !FROM_X || WIN. SAT slice_from_array and SAT length_to_rbx
    # already EMIT_SCAN.
    # PLATFORM: WINDOWS leftover-PE hybrid / POSIX -E unchanged.
    "glue_slice_dual_gp_length_off_c",
    # TYPE_ARRAY DEREF let-init: SAT emit_block_inits intra SAT
    # glue_emit_fixed_array_type_let_init intra SAT store_fixed_array_field
    # (local t) CALL/INDEX E* only; DEREF=52 returns -2 → CG002
    # (`unsafe { let y: [2]i32 = *p }`). leftover rest unique T
    # first-wins FULL body + DEREF. PE first-wins does not rewrite
    # SAT intra. SAT store_fixed_array_field is SAT local t — not
    # leftover rest T SAT global T. Do not leftover rest T SAT
    # emit_block_inits. Do not leftover rest remaining-wave via
    # !FROM_X || WIN. G.7 complete of this table.
    # PLATFORM: WINDOWS leftover-PE hybrid / POSIX -E unchanged.
    "glue_emit_fixed_array_type_let_init_elf_c",
    "glue_struct_lit_store_fixed_array_field_elf_c",
    # TYPE_SLICE let-init INDEX / DEREF / VAR: SAT emit_block_inits
    # intra SAT slice_from_array (local t) ARRAY_LIT/VAR TYPE_ARRAY
    # wrap already GREEN; INDEX of TYPE_ARRAY of TYPE_SLICE, DEREF
    # of *[]T, and VAR of TYPE_SLICE returned 0 then store_rax only
    # (`slice_let_idx` / `addrof_deref_let` SEGV 139 /
    # `slice_var_let_len` RUN=127). leftover rest unique T
    # first-wins FULL body + INDEX TYPE_SLICE emit +
    # store_retval_pair + FIELD TYPE_SLICE lvalue qword-copy +
    # DEREF TYPE_SLICE emit + store_retval_pair + VAR TYPE_SLICE
    # fat copy (local win_glue / formal fat* C-order). SAT
    # slice_from_array is SAT local t — not leftover rest T SAT
    # global T. PE first-wins does not rewrite SAT intra. G.7
    # complete of this table. Do not leftover rest T SAT
    # emit_block_inits / try_index / struct_let_init.
    # PLATFORM: WINDOWS leftover-PE hybrid / POSIX -E unchanged.
    "glue_emit_slice_from_array_let_init_elf_c",
    # ADDR_OF INDEX of TYPE_ARRAY of TYPE_SLICE then INDEX of DEREF
    # `(*p)[1]`: SAT eff_addr_scaled intra SAT rvalue_slice_once
    # (local t, SAT egg misses DEREF=52) falls through SAT
    # length_to_rbx *(data+8) → panic 127. leftover rest unique T
    # FULL CALL/METHOD/INDEX/DEREF first-wins. SAT rvalue_slice_once
    # is SAT local t — not leftover rest T SAT global T. PE
    # first-wins does not rewrite SAT intra. G.7 complete of this
    # table. Do not leftover rest T SAT emit_index / length_to_rbx /
    # try_index. PLATFORM: WINDOWS leftover-PE hybrid / POSIX -E
    # unchanged.
    "glue_try_index_rvalue_slice_once_elf_c",
)

# Functions whose call sites we rewrite (thin text → rest callees).
EMIT_SCAN_FUNCS = (
    ("pipeline_asm_emit_block_body_sync_elf", 0x6000),
    ("backend_emit_block_body_sync_elf", 0x8000),
    ("pipeline_asm_emit_block_if_stmt_elf", 0x2000),
    ("pipeline_asm_fill_local_slots", 0x800),
    ("asm_ctx_fill_locals_block_tree", 0x400),
    ("asm_ctx_ensure_block_locals", 0x400),
    ("glue_emit_block_final_expr_elf", 0x400),
    ("glue_block_stmt_order_has_return", 0x400),
    ("backend_emit_while_loop_elf_sync", 0x2000),
    ("backend_emit_for_loop_elf_sync", 0x2000),
    ("backend_emit_loop_body_content_elf_sync", 0x800),
    ("pipeline_asm_emit_match_elf_c", 0x2000),
    ("pipeline_asm_emit_array_lit_elf_c", 0x200),
    ("pipeline_asm_emit_array_lit_force_esz_elf_c", 0x4000),
    ("glue_asm_emit_array_lit_durable_ptr_rax_elf_c", 0x4000),
    ("glue_array_lit_emit_scalar_elem_to_rax_elf_c", 0x400),
    # TYPE_SLICE let-init: SAT slice_from_array intra SAT durable
    # (local t text-embed). leftover rest WIN leftover durable is
    # COMMON BSS. Scan SAT local t so PE first-wins leftover rest T.
    # Do not leftover rest T SAT emit_assign / try_index.
    # PLATFORM: WINDOWS leftover-PE hybrid / POSIX -E unchanged.
    ("glue_emit_slice_from_array_let_init_elf_c", 0x800),
    ("pipeline_asm_emit_array_lit_flat_elf_c", 0x2000),
    ("glue_emit_fixed_array_type_let_init_elf_c", 0x800),
    ("glue_struct_lit_store_fixed_array_field_elf_c", 0x2000),
    ("pipeline_asm_emit_index_elf_c", 0x1000),
    ("glue_emit_index_eff_addr_scaled_elf_c", 0x2000),
    # ADDR_OF INDEX of [2][]i32 then (*p)[1]: SAT emit_index intra SAT
    # rvalue_slice_once (egg misses DEREF=52). Scan SAT local t so PE
    # first-wins leftover rest unique T. Do not leftover rest T SAT
    # emit_index / try_index / length_to_rbx.
    # PLATFORM: WINDOWS leftover-PE hybrid / POSIX -E unchanged.
    ("glue_try_index_rvalue_slice_once_elf_c", 0x800),
    # INDEX TYPE_SLICE formal bounds: SAT emit_index intra SAT
    # length_to_rbx intra SAT needs_ptr_load (local t return 0) treats
    # 8B fat* home as 16B dual-GP so length loads saved rbx
    # (param_home+8) → panic 127 (`i32one_var` / `xs[1]`). leftover rest
    # WIN leftover needs_ptr_load tk==11 → 1 (fat*+8). leftover rest
    # remaining-wave length_to_rbx is #ifndef FROM_X ABSENT (SAT local t
    # is the body) — do not leftover rest T SAT length / try_index /
    # remaining-wave via !FROM_X || WIN. SAT try_index already scanned
    # (eff-addr load fat* already green). PE first-wins does not rewrite
    # SAT intra. G.7 complete of this table.
    # PLATFORM: WINDOWS leftover-PE hybrid / POSIX -E unchanged.
    ("glue_emit_slice_length_to_rbx_elf_c", 0x800),
    ("glue_try_index_var_or_field_base_to_rax_elf_c", 0x800),
    ("glue_enc_local_slot_ptr_or_addr_elf_c", 0x200),
    ("glue_local_var_slot_needs_ptr_load_elf_c", 0x400),
    ("pipeline_asm_emit_block_inits_elf_c", 0x3000),
    ("pipeline_asm_emit_expr_elf_rec", 0x2000),
    ("pipeline_asm_emit_deref_elf_c", 0x400),
    ("glue_block_let_is_fixed_array_type", 0x200),
    ("glue_type_is_fixed_array", 0x400),
    ("pipeline_asm_emit_struct_lit_elf_c", 0x200),
    ("pipeline_asm_emit_struct_lit_fields_elf_c", 0x4000),
    ("pipeline_asm_emit_struct_let_init_elf_c", 0x200),
    ("glue_emit_struct_type_let_init_elf_c", 0x2000),
    ("glue_struct_lit_field_store_sz", 0x400),
    ("pipeline_expr_struct_lit_field_offset_at", 0x400),
    ("pipeline_expr_struct_lit_field_type_ref_at", 0x400),
    ("pipeline_expr_struct_lit_value_bytes", 0x400),
    ("pipeline_expr_struct_lit_field_store_sz", 0x200),
    ("glue_field_access_call_base_rvalue_elf_c", 0x2000),
    ("pipeline_asm_emit_field_access_elf_fast_c", 0x2000),
    ("pipeline_asm_emit_var_field_access_elf_c", 0x800),
    ("pipeline_expr_field_access_layout_offset", 0x400),
    ("pipeline_expr_field_access_load_byte_sz", 0x400),
    ("glue_field_access_effective_offset_c", 0x200),
)

# Thin wrapper intra-calls thin mega_body (PE first-wins does not rewrite).
# Leftover rest WAVE290 ALWAYS has the Zig-like void-main `mov imm 0` gate
# (rkind==16 && i==main_func_index); thin mega_body does not.
# PLATFORM: WINDOWS leftover-PE hybrid / POSIX -E unchanged.
WRAPPER_REDIRECT_SYMS = (
    "pipeline_backend_asm_codegen_ast_to_elf_mega_body_c",
)
WRAPPER_SCAN_FUNCS = (
    ("pipeline_backend_asm_codegen_ast_to_elf_c", 0x400),
)


def nm_t_addrs(path: str, sym: str) -> list[int]:
    out = subprocess.check_output(["nm", path], text=True, errors="replace")
    addrs: list[int] = []
    for line in out.splitlines():
        p = line.split()
        if len(p) >= 3 and p[1] in ("T", "t") and p[2] == sym:
            addrs.append(int(p[0], 16))
    return sorted(addrs)


def pe_sections(data: bytearray) -> tuple[int, list[tuple[int, int, int, int]]]:
    e_lfanew = struct.unpack_from("<I", data, 0x3C)[0]
    num_sections = struct.unpack_from("<H", data, e_lfanew + 6)[0]
    opt_size = struct.unpack_from("<H", data, e_lfanew + 20)[0]
    opt_off = e_lfanew + 24
    magic = struct.unpack_from("<H", data, opt_off)[0]
    if magic == 0x20B:
        image_base = struct.unpack_from("<Q", data, opt_off + 24)[0]
    else:
        image_base = struct.unpack_from("<I", data, opt_off + 28)[0]
    sec_off = opt_off + opt_size
    sections: list[tuple[int, int, int, int]] = []
    for i in range(num_sections):
        off = sec_off + i * 40
        vsize, va, rawsize, rawptr = struct.unpack_from("<IIII", data, off + 8)
        sections.append((va, rawptr, rawsize, vsize))
    return image_base, sections


def coff_sections(data: bytearray) -> tuple[int, list[tuple[int, int, int, int]]]:
    num_sections = struct.unpack_from("<H", data, 2)[0]
    opt_size = struct.unpack_from("<H", data, 16)[0]
    sec_off = 20 + opt_size
    sections: list[tuple[int, int, int, int]] = []
    for i in range(num_sections):
        off = sec_off + i * 40
        vsize, va, rawsize, rawptr = struct.unpack_from("<IIII", data, off + 8)
        sections.append((va, rawptr, rawsize, vsize))
    return 0, sections


def va_to_off(
    image_base: int,
    sections: list[tuple[int, int, int, int]],
    va: int,
) -> int:
    for sec_va, rawptr, rawsize, vsize in sections:
        base_va = sec_va if sec_va >= image_base else image_base + sec_va
        if base_va <= va < base_va + max(rawsize, vsize):
            return rawptr + (va - base_va)
    raise SystemExit(f"VA 0x{va:x} not mapped in {sys.argv[1]}")


def objdump_range(path: str, start: int, size: int) -> str:
    return subprocess.check_output(
        [
            "objdump",
            "-d",
            f"--start-address=0x{start:x}",
            f"--stop-address=0x{start + size:x}",
            path,
        ],
        text=True,
        errors="replace",
    )


def collect_rest_thin(path: str, syms: tuple[str, ...]) -> dict[str, tuple[int, int]]:
    """Map sym → (rest_low_va, thin_high_va) when ≥2 T defs exist."""
    out: dict[str, tuple[int, int]] = {}
    for sym in syms:
        addrs = nm_t_addrs(path, sym)
        if len(addrs) < 2:
            continue
        out[sym] = (addrs[0], addrs[-1])
    return out


def patch_calls_in_range(
    path: str,
    start: int,
    size: int,
    rest_of: dict[str, int],
    sym_alt: str,
    patches: list[tuple[int, int, str]],
) -> None:
    dis = objdump_range(path, start, size)
    for line in dis.splitlines():
        m = re.search(
            rf"^\s*([0-9a-f]+):.*\bcall\s+([0-9a-f]+)\s+<({sym_alt})>",
            line,
        )
        if not m:
            continue
        call_va = int(m.group(1), 16)
        cur = int(m.group(2), 16)
        name = m.group(3)
        if name not in rest_of:
            continue
        if cur != rest_of[name]:
            patches.append((call_va, rest_of[name], name))


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: win_pe_pabi_redirect_return_helpers.py <path>", file=sys.stderr)
        return 2
    path = sys.argv[1]

    megas = nm_t_addrs(path, "pipeline_backend_asm_codegen_ast_to_elf_mega_body_c")
    get_ret = nm_t_addrs(path, "pipeline_backend_get_return_expr_ref")
    get_at = nm_t_addrs(path, "pipeline_backend_get_return_expr_ref_at")

    mega_map = collect_rest_thin(path, MEGA_REDIRECT_SYMS)
    emit_map = collect_rest_thin(path, EMIT_REDIRECT_SYMS)
    wrap_map = collect_rest_thin(path, WRAPPER_REDIRECT_SYMS)

    rest_of: dict[str, int] = {s: pair[0] for s, pair in mega_map.items()}
    rest_of.update({s: pair[0] for s, pair in emit_map.items()})
    rest_of.update({s: pair[0] for s, pair in wrap_map.items()})

    if not rest_of:
        print("win_pe_pabi_redirect: no twin symbols to redirect")
        return 0

    patches: list[tuple[int, int, str]] = []

    # 0) Thin wrapper → rest mega_body (void-main mov-imm-0)
    if wrap_map:
        rest_wrap = {s: pair[0] for s, pair in wrap_map.items()}
        wrap_alt = "|".join(re.escape(s) for s in wrap_map)
        for fname, span in WRAPPER_SCAN_FUNCS:
            addrs = nm_t_addrs(path, fname)
            for start in addrs:
                patch_calls_in_range(path, start, span, rest_wrap, wrap_alt, patches)

    # 1) Thin mega → rest helpers
    if len(megas) >= 2 and mega_map:
        thin_mega = megas[-1]
        sym_alt = "|".join(re.escape(s) for s in mega_map)
        patch_calls_in_range(path, thin_mega, 0x2000, rest_of, sym_alt, patches)

    # Thin get_return_at wrapper → rest get_return
    if len(get_ret) >= 2 and len(get_at) >= 2:
        our_ret = get_ret[0]
        thin_at = get_at[-1]
        dis2 = objdump_range(path, thin_at, 0xA0)
        for line in dis2.splitlines():
            m = re.search(
                r"^\s*([0-9a-f]+):.*\bcall\s+([0-9a-f]+)\s+<pipeline_backend_get_return_expr_ref>",
                line,
            )
            if m and int(m.group(2), 16) != our_ret:
                patches.append((int(m.group(1), 16), our_ret, "get_return"))

    # 2) Thin emit_block / emit_if → rest ast_* faces
    if emit_map:
        sym_alt = "|".join(re.escape(s) for s in emit_map)
        for fname, span in EMIT_SCAN_FUNCS:
            addrs = nm_t_addrs(path, fname)
            if not addrs:
                continue
            # Prefer the definition that still calls thin (usually highest / only).
            for start in addrs:
                patch_calls_in_range(path, start, span, rest_of, sym_alt, patches)

    # Dedup identical call sites
    seen: set[int] = set()
    uniq: list[tuple[int, int, str]] = []
    for call_va, tgt, name in patches:
        if call_va in seen:
            continue
        seen.add(call_va)
        uniq.append((call_va, tgt, name))
    patches = uniq

    if not patches:
        print("win_pe_pabi_redirect: no thin→rest call sites (already redirected?)")
        return 0

    with open(path, "rb") as f:
        data = bytearray(f.read())

    if data[:2] == b"MZ":
        image_base, sections = pe_sections(data)
    else:
        image_base, sections = coff_sections(data)

    for call_va, tgt, name in patches:
        off = va_to_off(image_base, sections, call_va)
        if data[off] != 0xE8:
            print(f"win_pe_pabi_redirect: expected call at 0x{call_va:x} ({name})", file=sys.stderr)
            return 1
        struct.pack_into("<i", data, off + 1, tgt - (call_va + 5))

    with open(path, "wb") as f:
        f.write(data)

    print(f"win_pe_pabi_redirect: patched {len(patches)} calls in {path}")
    for call_va, tgt, name in patches:
        print(f"  0x{call_va:x} -> 0x{tgt:x} ({name})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
