// Thin pure: assign %= arm (wave448/w474).
// G.7: part of glue_emit_assign_rhs_to_rax_elf_c.
// wave474: no-local tip U=2/2. PRODUCT inject: LINUX PREFER (stamp w474); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx: *u8, ctx: *u8, ta: i32): i32;
export extern function backend_enc_rem_mod_arch(elf_ctx: *u8, ta: i32): i32;

/**
 * Compound %= arm — zero-check then rem/mod.
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_rhs_mod_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta) != 0) {
      return 0 - 1;
    }
    return backend_enc_rem_mod_arch(elf_ctx, ta);
  }
}
