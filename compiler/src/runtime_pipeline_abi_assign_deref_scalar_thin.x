// Thin pure: DEREF scalar leaf (wave441 peer).
// G.7: match mega / assign_deref dispatcher peer arm.
// wave449: LINUX PREFER tip pure-asm (product si green).
// wave534 Soft Cap: tipU heal — pipe-cell mid `rc/tr/store_sz=call()`;
//   compare via `if (pipe_load…)`; stamp w534 HARD BAN PREFER
//   (keep prior PREFER leftover).
// wave598: leftover PREFER scalar smashes the caller frame (gdb: after
//   scalar returns, peel/gate epilogue pop %rbx with rbp=1 / unwind 0x9).
//   LINUX -E replace leftover T (real emit body). HARD BAN PREFER.
//   MACOS keep Darwin overlay (already compiles `*p=`).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_assign_rhs_to_rax_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function glue_index_elem_byte_sz_from_type_ref_c(arena: *u8, tr: i32): i32;
export extern function backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx: *u8, elem_sz: i32, ta: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

/**
 * DEREF scalar push/pop + store through *p.
 * Soft Cap tipU: extern call as arg to pipe_store; branch on pipe_load.
 * @return i32 — 0 ok; -1 err
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_deref_scalar_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  let cell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&cell[0], 0, glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta));
    if (pipe_load_i32_le(&cell[0], 0) != 0) { return 0 - 1; }
    pipe_store_i32_le(&cell[0], 0, backend_enc_push_rax_arch(elf_ctx, ta));
    if (pipe_load_i32_le(&cell[0], 0) != 0) { return 0 - 1; }
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta));
    if (pipe_load_i32_le(&cell[0], 0) != 0) { return 0 - 1; }
    pipe_store_i32_le(&cell[0], 0, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
    if (pipe_load_i32_le(&cell[0], 0) != 0) { return 0 - 1; }
    pipe_store_i32_le(&cell[0], 0, backend_enc_pop_rax_arch(elf_ctx, ta));
    if (pipe_load_i32_le(&cell[0], 0) != 0) { return 0 - 1; }
    /* type width via call-as-arg; default 4 when <=0. */
    pipe_store_i32_le(&cell[0], 0, glue_index_elem_byte_sz_from_type_ref_c(arena, pipeline_expr_resolved_type_ref(arena, left_ref)));
    if (pipe_load_i32_le(&cell[0], 0) <= 0) {
      pipe_store_i32_le(&cell[0], 0, 4);
    }
    return backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, pipe_load_i32_le(&cell[0], 0), ta);
  }
}
