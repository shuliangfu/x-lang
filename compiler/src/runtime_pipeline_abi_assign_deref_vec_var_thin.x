// Thin pure: DEREF vector VAR memcpy dest-in-rbx (wave441).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx: *u8, dest_off: i32, nbytes: i32, ta: i32): i32;

/**
 * DEREF SIMD dest from VAR rhs via lea+memcpy dest-in-rbx.
 * Preconditions: dest already in rbx; nbytes/rko from caller.
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_deref_vec_var_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, rko_pre: i32, nbytes: i32): i32 {
  unsafe {
    let var_off: i32 = 0;
    let rc: i32 = 0;
    if (nbytes < 8) {
      return 0 - 3;
    }
    if (rko_pre != 3) {
      return 0 - 3;
    }
    var_off = glue_var_expr_stack_off_elf_c(arena, ctx, right_ref);
    if (var_off < 0) {
      return 0 - 3;
    }
    rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, var_off, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, nbytes, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
}
