// Thin pure: VAR finish — RHS→rax + float promote/demote → store (wave473).
// G.7: part of glue_emit_assign_var_elf_c (peer-flat).
// wave473: no-local tip U=6/6. PRODUCT inject: LINUX PREFER (stamp w473); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_assign_rhs_to_rax_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_float_promote_src_ty_ref_c(arena: *u8, right_ref: i32): i32;
export extern function glue_maybe_promote_f32_to_f64_rax_elf_c(arena: *u8, elf_ctx: *u8, ltr: i32, rty: i32, ta: i32): i32;
export extern function glue_maybe_demote_f64_to_f32_eax_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, ltr: i32, right_ref: i32, ta: i32): i32;
export extern function glue_emit_assign_var_store_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;

/**
 * VAR finish — emit RHS to rax, optional f32↔f64 convert, then store peer.
 * wave473: no-local — decl/src ty via re-call; no else-nest (store owns kinds).
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_var_finish_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) != 0) {
      return 0 - 1;
    }
    if (glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref), glue_float_promote_src_ty_ref_c(arena, right_ref), ta) != 0) {
      return 0 - 1;
    }
    if (glue_maybe_demote_f64_to_f32_eax_elf_c(arena, elf_ctx, ctx, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref), right_ref, ta) != 0) {
      return 0 - 1;
    }
    return glue_emit_assign_var_store_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  }
}
