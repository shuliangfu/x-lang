// Thin pure: VAR store slice dual-GP (rax+rdx length) (wave473).
// G.7: part of glue_emit_assign_var_store_elf_c (peer-flat).
// wave473: no-local tip U=5/5. PRODUCT inject: LINUX PREFER (stamp w473); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_store_rdx_to_rbp_arch(elf_ctx: *u8, slot_off: i32, ta: i32): i32;
export extern function glue_slice_dual_gp_length_off_c(off: i32, ta: i32): i32;
export extern function glue_binop_var_slot_cache_kill_def_at_slot(off: i32): void;

/**
 * VAR store_slice — store rax to slot; rdx to dual-GP length off; kill cache.
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_var_store_slice_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_var_expr_stack_off_elf_c(arena, ctx, left_ref), ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_store_rdx_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(glue_var_expr_stack_off_elf_c(arena, ctx, left_ref), ta), ta) != 0) {
      return 0 - 1;
    }
    glue_binop_var_slot_cache_kill_def_at_slot(glue_var_expr_stack_off_elf_c(arena, ctx, left_ref));
    return 0;
  }
}
