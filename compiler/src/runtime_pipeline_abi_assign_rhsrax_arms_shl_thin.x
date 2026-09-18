// Thin pure: assign <<= arm (wave448/w474).
// G.7: part of glue_emit_assign_rhs_to_rax_elf_c.
// wave474: no-local tip U=5/5. PRODUCT inject: LINUX PREFER (stamp w474); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_binop_var_slot_cache_clear(): void;
export extern function backend_enc_mov_rbx_to_ecx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_binop_operand_is_64bit_elf_c(arena: *u8, ctx: *u8, left_ref: i32, right_ref: i32): i32;
export extern function backend_enc_shl_cl_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_shl_cl_eax_arch(elf_ctx: *u8, ta: i32): i32;

/**
 * Compound <<= arm — clear cache; rbx→ecx; shl cl rax/eax by width.
 * wave474: no-local — ban `let rc=call()` / `let is_64bit=call()`.
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_rhs_shl_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    glue_binop_var_slot_cache_clear();
    if (backend_enc_mov_rbx_to_ecx_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, 0) != 0) {
      return backend_enc_shl_cl_rax_arch(elf_ctx, ta);
    }
    return backend_enc_shl_cl_eax_arch(elf_ctx, ta);
  }
}
