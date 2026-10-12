// Thin pure: VAR store retval pair (generic dual-GP / struct) (wave473).
// G.7: part of glue_emit_assign_var_store_elf_c (peer-flat).
// wave473: no-local tip U=5/5. PRODUCT inject: LINUX PREFER (stamp w473); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_store_retval_pair_to_rbp_elf_c(m: *u8, arena: *u8, elf_ctx: *u8, ty_ref: i32, slot_off: i32, ta: i32, init_ref: i32, ctx: *u8): i32;
export extern function glue_emit_module_from_ctx(ctx: *u8): *u8;
export extern function glue_binop_var_slot_cache_kill_def_at_slot(off: i32): void;

/**
 * VAR store_pair — glue_store_retval_pair_to_rbp then kill slot cache.
 * wave473: no-local — module/decl/off via re-call (no let-bound call).
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_var_store_pair_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (glue_store_retval_pair_to_rbp_elf_c(glue_emit_module_from_ctx(ctx), arena, elf_ctx, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref), glue_var_expr_stack_off_elf_c(arena, ctx, left_ref), ta, right_ref, ctx) != 0) {
      return 0 - 1;
    }
    glue_binop_var_slot_cache_kill_def_at_slot(glue_var_expr_stack_off_elf_c(arena, ctx, left_ref));
    return 0;
  }
}
