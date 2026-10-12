// Thin pure: assign /= float peer (f64 divsd / f32 divss) (wave474).
// G.7: part of glue_emit_assign_rhs_div_elf_c.
// wave474: no-local; tip U=4/4. PRODUCT inject: LINUX PREFER (stamp w474); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_binop_operand_is_scalar_f32_elf_c(arena: *u8, ctx: *u8, expr_ref: i32): i32;
export extern function glue_binop_operand_is_scalar_f64_elf_c(arena: *u8, ctx: *u8, expr_ref: i32): i32;
export extern function backend_enc_divsd_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_divss_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32;

/**
 * Float /= path — ta in {0,1} and both scalar f64 → divsd; both f32 → divss.
 * @return i32 — 0 ok; -3 not float path
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_rhs_div_float_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (ta != 0) {
      if (ta != 1) {
        return 0 - 3;
      }
    }
    if (glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) != 0) {
      if (glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref) != 0) {
        return backend_enc_divsd_rax_rbx_arch(elf_ctx, ta);
      }
    }
    if (glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) != 0) {
      if (glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref) != 0) {
        return backend_enc_divss_rax_rbx_arch(elf_ctx, ta);
      }
    }
    return 0 - 3;
  }
}
