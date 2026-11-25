// Thin pure: assign /= arm — float peer then signed/unsigned div (wave448/w474; 10.56).
// G.7: part of glue_emit_assign_rhs_to_rax_elf_c.
// wave474: gate+float split (monolith empty .o). Tip U=3/3.
//   PRODUCT inject: Darwin/Windows assign-var overlay; Linux PREFER (stamp w474).
// 10.56: u64/u32/… /= must emit udiv (arm64) / div (x86), not sdiv/idiv.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_assign_rhs_div_float_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx: *u8, ctx: *u8, ta: i32): i32;
export extern function glue_binop_operand_is_unsigned_elf_c(arena: *u8, ctx: *u8, left_ref: i32, right_ref: i32): i32;
export extern function backend_enc_div_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_idiv_rbx_arch(elf_ctx: *u8, ta: i32): i32;

/**
 * Compound /= arm — try float div; else zero-check + unsigned or signed div.
 * wave474: no-local — float via peer 0 cascade; no `let x=call()`.
 * 10.56: unsigned operands use backend_enc_div_rbx_arch (arm64 udiv).
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_rhs_div_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (glue_emit_assign_rhs_div_float_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta) == 0) {
      return 0;
    }
    if (pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta) != 0) {
      return 0 - 1;
    }
    if (glue_binop_operand_is_unsigned_elf_c(arena, ctx, left_ref, right_ref) != 0) {
      return backend_enc_div_rbx_arch(elf_ctx, ta);
    }
    return backend_enc_idiv_rbx_arch(elf_ctx, ta);
  }
}
