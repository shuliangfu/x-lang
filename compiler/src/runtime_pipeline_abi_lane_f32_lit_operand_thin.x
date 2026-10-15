// Live body of glue_emit_vector_operand_lane_elf_c.
// The copy in runtime_pipeline_abi.x is an extern. pabi_weak still has
// the old strong definition and is weakened at link. That copy emits a
// FLOAT_LIT through pipeline_asm_emit_expr, which moves the f64 bits
// into x0. The low half of f64 4.0 and f64 2.0 is 0, so an f32 lane
// div of those literals stored 0. When the f32-literal gate is set,
// a FLOAT_LIT, or one or two EXPR_NEG of one, at lane size 4 is narrowed
// with the existing glue_ieee_f64_bits_to_f32_bits and moved as imm32.
// Two EXPR_NEG of that literal cancel the sign xor. A third NEG
// returns 0. The gate stays 0 for i32 lanes, and this file then
// matches the old body. Do not add a second divss. PLATFORM: SHARED.

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
export extern function backend_enc_mov_imm32_to_rbx_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_xor_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;

/**
 * Flip bit 31 of the f32 lane already in rax.
 * @param elf_ctx *u8 — emit buffer. The caller has just filled rax.
 * @param ta i32 — 1 arm64, else x86.
 * @return i32 — 0 when rax holds the flipped lane, -1 when an encode fails.
 * The immediate is the same host constant the FLOAT_LIT peel xors into
 * the f64 high half. rbx is scratch. PLATFORM: SHARED.
 */
function lane_f32_xor_sign_rax(elf_ctx: *u8, ta: i32): i32 {
  let rc: i32 = 0;
  unsafe {
    rc = backend_enc_mov_imm32_to_rbx_arch(elf_ctx, 0 - 2147483647 - 1, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_xor_rbx_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * Load one VAR lane into rax.
 * @param arena *u8 — expression arena.
 * @param elf_ctx *u8 — emit buffer.
 * @param var_ref i32 — VAR expr. A missing frame home returns -1.
 * @param lane i32 — lane index.
 * @param esz i32 — lane bytes.
 * @param ctx *u8 — asm ctx.
 * @param ta i32 — 1 arm64, else x86. Arm64 lane slots grow up from rbp.
 * @return i32 — the load encoder result, or -1 when the home is missing.
 * PLATFORM: SHARED.
 */
function lane_f32_load_var_lane(
  arena: *u8, elf_ctx: *u8, var_ref: i32, lane: i32, esz: i32, ctx: *u8, ta: i32
): i32 {
  let off: i32 = 0;
  unsafe {
    off = glue_asm_local_var_stack_off_scoped(arena, ctx, var_ref);
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

/**
 * Load one FIELD lane into rax.
 * @param arena *u8 — expression arena.
 * @param elf_ctx *u8 — emit buffer.
 * @param field_ref i32 — FIELD expr. No frame home returns -2.
 * @param lane i32 — lane index.
 * @param esz i32 — lane bytes.
 * @param ctx *u8 — asm ctx.
 * @param ta i32 — 1 arm64, else x86. The field helper already applies
 *   lane polarity, so this load does not add lane * esz again.
 * @return i32 — 0 when rax holds the lane, -1 when the load encode
 *   fails, -2 when the field has no frame home.
 * PLATFORM: SHARED.
 */
function lane_f32_load_field_lane(
  arena: *u8, elf_ctx: *u8, field_ref: i32, lane: i32, esz: i32, ctx: *u8, ta: i32
): i32 {
  let off: i32 = 0;
  unsafe {
    off = glue_vector_var_lane_stack_off_elf_c(arena, ctx, field_ref, lane, esz, ta);
  }
  if (off < 0) {
    return 0 - 2;
  }
  unsafe {
    return backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, off, esz, ta);
  }
}

/**
 * Move one f32 lane immediate for a FLOAT_LIT, or one or two NEG of one.
 * @param arena *u8 — expression arena. Null is not a literal.
 * @param elf_ctx *u8 — emit buffer.
 * @param expr_ref i32 — operand expr.
 * @param ta i32 — 1 arm64, else x86.
 * @return i32 — 1 when w0 holds the f32 bits, 0 when this is not that
 *   shape, -1 when the move fails.
 * The f64 sign bit is xored into the high half before the existing
 * narrow, so one NEG of 4.0 stays negative. Two EXPR_NEG cancel that
 * xor. A third NEG returns 0. Kind 23 does not enter.
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
    // -(-4.0) is kind 22 of kind 22. One peel left the f64 bits, and
    // the low half of f64 4.0 is 0. Two sign flips cancel. A third
    // NEG is not a FLOAT_LIT and returns 0 below. Kind 23 does not
    // enter. PLATFORM: SHARED.
    if (ko == 22) {
      unsafe {
        op = pipeline_expr_unary_operand_ref_at(arena, op);
      }
      if (op <= 0) {
        return 0;
      }
      unsafe {
        ko = pipeline_expr_kind_ord_at(arena, op);
      }
      neg = 0;
    }
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
 * One EXPR_NEG of add, sub, mul, div, a VAR, or a FIELD emits that
 * lane, then xors the f32 sign bit. Two EXPR_NEG of a VAR load that
 * lane and do not xor: the two sign flips cancel. A second NEG of a
 * FIELD or a binop, and kind 23, stay on emit_expr. PLATFORM: SHARED.
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
  // Gate is 1 for an f32 dest on add, sub, mul, div, and compare.
  // A 4-byte FLOAT_LIT is then the f32 pattern, not the f64 bits.
  // i32 lanes skip this.
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
      // -(4.0 / 2.0) is kind 22 of kind 7. -a / 2.0 is kind 22 of a
      // VAR. -h.v / 2.0 is kind 22 of a FIELD. -(-a) / 2.0 is kind 22
      // of kind 22 of a VAR. The literal peel returns 0, so the outer
      // div saw f64 bits and the lane was not the f32 quotient. One
      // NEG emits the inner lane, then xors the f32 sign bit. Two NEG
      // of a VAR load that lane and do not xor. A second NEG of a
      // FIELD stays out. Kind 23 and kinds 8..13 do not enter.
      // i32 leaves the gate at 0. PLATFORM: SHARED.
      if (ko == 22) {
        unsafe {
          elem_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
        }
        if (elem_ref > 0) {
          unsafe {
            lit = pipeline_expr_kind_ord_at(arena, elem_ref);
          }
          rc = 0;
          if (lit == 4) {
            rc = 1;
          }
          if (lit == 5) {
            rc = 1;
          }
          if (lit == 6) {
            rc = 1;
          }
          if (lit == 7) {
            rc = 1;
          }
          if (rc != 0) {
            unsafe {
              left_ref = pipeline_expr_binop_left_ref_at(arena, elem_ref);
              right_ref = pipeline_expr_binop_right_ref_at(arena, elem_ref);
            }
            unsafe {
              rc = glue_emit_vector_lane_scalar_binop_elf_c(
                arena, elf_ctx, lit, left_ref, right_ref, lane, esz, ctx, ta);
            }
            if (rc != 0) {
              return 0 - 1;
            }
            return lane_f32_xor_sign_rax(elf_ctx, ta);
          }
          // -a is kind 22 of kind 3. Load that VAR lane, then the
          // same sign xor. PLATFORM: SHARED.
          if (lit == 3) {
            rc = lane_f32_load_var_lane(
              arena, elf_ctx, elem_ref, lane, esz, ctx, ta);
            if (rc != 0) {
              return 0 - 1;
            }
            return lane_f32_xor_sign_rax(elf_ctx, ta);
          }
          // -h.v is kind 22 of kind 44. No frame home is -2 and falls
          // through, the same as a bare field. A second NEG is not
          // kind 44. PLATFORM: SHARED.
          if (lit == 44) {
            rc = lane_f32_load_field_lane(
              arena, elf_ctx, elem_ref, lane, esz, ctx, ta);
            if (rc == (0 - 2)) {
              rc = 0;
            } else {
              if (rc != 0) {
                return 0 - 1;
              }
              return lane_f32_xor_sign_rax(elf_ctx, ta);
            }
          }
          // -(-a) is kind 22 of kind 22 of kind 3. Two sign flips
          // cancel, so rax keeps the VAR lane and this does not xor.
          // A missing home is -1. A FIELD under this peel is not
          // kind 3. A third NEG is not kind 3. PLATFORM: SHARED.
          if (lit == 22) {
            unsafe {
              left_ref = pipeline_expr_unary_operand_ref_at(arena, elem_ref);
            }
            if (left_ref > 0) {
              unsafe {
                rc = pipeline_expr_kind_ord_at(arena, left_ref);
              }
              if (rc == 3) {
                rc = lane_f32_load_var_lane(
                  arena, elf_ctx, left_ref, lane, esz, ctx, ta);
                if (rc != 0) {
                  return 0 - 1;
                }
                return 0;
              }
            }
          }
        }
      }
    }
  }
  if (ko == 3) {
    return lane_f32_load_var_lane(arena, elf_ctx, expr_ref, lane, esz, ctx, ta);
  }
  // FIELD=44. The helper's offset already includes lane polarity.
  // -2 means no frame home and falls through. PLATFORM: SHARED.
  if (ko == 44) {
    rc = lane_f32_load_field_lane(arena, elf_ctx, expr_ref, lane, esz, ctx, ta);
    if (rc != (0 - 2)) {
      return rc;
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
