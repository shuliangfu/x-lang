// Live body of glue_emit_vector_operand_lane_elf_c.
// The copy in runtime_pipeline_abi.x is an extern. pabi_weak still has
// the old strong definition and is weakened at link. That copy emits a
// FLOAT_LIT through pipeline_asm_emit_expr, which moves the f64 bits
// into x0. The low half of f64 4.0 and f64 2.0 is 0, so an f32 lane
// div of those literals stored 0. When the f32-literal gate is set,
// a FLOAT_LIT (or one EXPR_NEG of one) at lane size 4 is narrowed
// with the existing glue_ieee_f64_bits_to_f32_bits and moved as imm32.
// The gate stays 0 for i32 lanes, and this file then matches the old
// body. Do not add a second divss. PLATFORM: SHARED.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_float_bits_lo_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_float_bits_hi_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, lane: i32): i32;
export extern function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_right_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_ieee_f64_bits_to_f32_bits(lo: i32, hi: i32): i32;
export extern function glue_lane_f32_lit_dest_get(): i32;
export extern function glue_asm_local_var_stack_off_scoped(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_vector_var_lane_stack_off_elf_c(
  arena: *u8, ctx: *u8, var_expr_ref: i32, lane: i32, esz: i32, ta: i32
): i32;
export extern function glue_is_vector_lane_scalar_binop_ko(ko: i32): i32;
export extern function glue_emit_vector_lane_scalar_binop_elf_c(
  arena: *u8, elf_ctx: *u8, binop_ko: i32, left_ref: i32, right_ref: i32,
  lane: i32, esz: i32, ctx: *u8, ta: i32
): i32;
export extern function pipeline_asm_emit_expr_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32
): i32;
export extern function backend_enc_load_rbp_lane_to_rax_arch(
  elf_ctx: *u8, offset: i32, esz: i32, ta: i32
): i32;
export extern function backend_enc_mov_imm32_to_w0_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;

/**
 * Move one f32 lane immediate for a FLOAT_LIT, or one NEG of one.
 * @param arena *u8 — expression arena. Null is not a literal.
 * @param elf_ctx *u8 — emit buffer.
 * @param expr_ref i32 — operand expr.
 * @param ta i32 — 1 arm64, else x86.
 * @return i32 — 1 when w0 holds the f32 bits, 0 when this is not that
 *   shape, -1 when the move fails.
 * The f64 sign bit is xored into the high half before the existing
 * narrow, so -4.0 stays negative. Kind 23 does not enter.
 * PLATFORM: SHARED.
 */
function lane_f32_emit_lit_lane(arena: *u8, elf_ctx: *u8, expr_ref: i32, ta: i32): i32 {
  let ko: i32 = 0;
  let op: i32 = 0;
  let neg: i32 = 0;
  let lo: i32 = 0;
  let hi: i32 = 0;
  let bits: i32 = 0;
  let rc: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || expr_ref <= 0) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  op = expr_ref;
  if (ko == 22) {
    unsafe {
      op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    }
    if (op <= 0) {
      return 0;
    }
    unsafe {
      ko = pipeline_expr_kind_ord_at(arena, op);
    }
    neg = 1;
  }
  if (ko != 1) {
    return 0;
  }
  unsafe {
    lo = pipeline_expr_float_bits_lo_at(arena, op);
    hi = pipeline_expr_float_bits_hi_at(arena, op);
  }
  if (neg != 0) {
    // f64 sign bit. 0x80000000 does not fit in a positive i32 literal.
    hi = hi ^ (0 - 2147483647 - 1);
  }
  unsafe {
    bits = glue_ieee_f64_bits_to_f32_bits(lo, hi);
    rc = backend_enc_mov_imm32_to_w0_arch(elf_ctx, bits, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 1;
}

/**
 * Emit one vector operand lane into rax.
 * @param arena *u8 — expression arena. Null returns -1.
 * @param elf_ctx *u8 — emit buffer. Null returns -1.
 * @param expr_ref i32 — operand. Not positive returns -1.
 * @param lane i32 — lane index. Negative returns -1.
 * @param esz i32 — lane bytes. A FLOAT_LIT narrows only when this is 4
 *   and the f32-literal gate is set.
 * @param ctx *u8 — asm ctx. Null returns -1.
 * @param ta i32 — 1 arm64, else x86. Arm64 lane slots grow up from rbp.
 * @return i32 — 0 when rax holds the lane, -1 on failure.
 * VAR, FIELD, ARRAY_LIT, and nested binop match the previous body.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function glue_emit_vector_operand_lane_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, lane: i32, esz: i32, ctx: *u8, ta: i32
): i32 {
  let ko: i32 = 0;
  let off: i32 = 0;
  let elem_ref: i32 = 0;
  let left_ref: i32 = 0;
  let right_ref: i32 = 0;
  let rc: i32 = 0;
  let lit: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || expr_ref <= 0 || lane < 0) {
    return 0 - 1;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  // Gate is 1 only for f32 add, sub, mul, and div. A 4-byte FLOAT_LIT
  // is then the f32 pattern, not the f64 bits. i32 lanes skip this.
  // PLATFORM: SHARED.
  if (esz == 4) {
    unsafe {
      lit = glue_lane_f32_lit_dest_get();
    }
    if (lit != 0) {
      lit = lane_f32_emit_lit_lane(arena, elf_ctx, expr_ref, ta);
      if (lit == 1) {
        return 0;
      }
      if (lit < 0) {
        return 0 - 1;
      }
    }
  }
  if (ko == 3) {
    unsafe {
      off = glue_asm_local_var_stack_off_scoped(arena, ctx, expr_ref);
    }
    if (off < 0) {
      return 0 - 1;
    }
    if (ta == 1) {
      unsafe {
        return backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, off + lane * esz, esz, ta);
      }
    }
    unsafe {
      return backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, off - lane * esz, esz, ta);
    }
  }
  // FIELD=44. off already includes lane polarity.
  if (ko == 44) {
    unsafe {
      off = glue_vector_var_lane_stack_off_elf_c(arena, ctx, expr_ref, lane, esz, ta);
    }
    if (off >= 0) {
      unsafe {
        return backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, off, esz, ta);
      }
    }
  }
  if (ko == 46) {
    unsafe {
      elem_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, lane);
    }
    if (elem_ref == 0) {
      unsafe {
        return backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta);
      }
    }
    if (esz == 4) {
      unsafe {
        lit = glue_lane_f32_lit_dest_get();
      }
      if (lit != 0) {
        lit = lane_f32_emit_lit_lane(arena, elf_ctx, elem_ref, ta);
        if (lit == 1) {
          return 0;
        }
        if (lit < 0) {
          return 0 - 1;
        }
      }
    }
    unsafe {
      return pipeline_asm_emit_expr_elf_c(arena, elf_ctx, elem_ref, ctx, ta);
    }
  }
  unsafe {
    rc = glue_is_vector_lane_scalar_binop_ko(ko);
  }
  if (rc != 0) {
    unsafe {
      left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
      right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    }
    unsafe {
      return glue_emit_vector_lane_scalar_binop_elf_c(
        arena, elf_ctx, ko, left_ref, right_ref, lane, esz, ctx, ta);
    }
  }
  unsafe {
    return pipeline_asm_emit_expr_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  }
}
