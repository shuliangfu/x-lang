// Thin pure: FIELD VAR-root struct dual-GP store (wave475).
// G.7: part of glue_emit_assign_field_var_struct_pair_elf_c (peer-flat).
// wave475: no-local tip U=3/3. PRODUCT inject: LINUX PREFER (stamp w475); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_module_from_ctx(ctx: *u8): *u8;
export extern function glue_emit_assign_rhs_to_rax_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_store_retval_pair_to_rbp_elf_c(m: *u8, arena: *u8, elf_ctx: *u8, ty_ref: i32, slot_off: i32, ta: i32, init_ref: i32, ctx: *u8): i32;

/**
 * Struct pair store — rhs→rax then store_retval_pair_to_rbp.
 * @return i32 — 0 ok; -1 err
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_field_var_struct_store_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, ltr: i32, off: i32): i32 {
  unsafe {
    if (glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) != 0) {
      return 0 - 1;
    }
    if (glue_store_retval_pair_to_rbp_elf_c(glue_emit_module_from_ctx(ctx), arena, elf_ctx, ltr, off, ta, right_ref, ctx) != 0) {
      return 0 - 1;
    }
    return 0;
  }
}
