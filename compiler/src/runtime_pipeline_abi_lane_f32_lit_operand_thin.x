// Live body of glue_emit_vector_operand_lane_elf_c.
// The copy in runtime_pipeline_abi.x is an extern. pabi_weak still has
// the old strong definition and is weakened at link. That copy emits a
// FLOAT_LIT through pipeline_asm_emit_expr, which moves the f64 bits
// into x0. The low half of f64 4.0 and f64 2.0 is 0, so an f32 lane
// div of those literals stored 0. When the f32-literal gate is set,
// a FLOAT_LIT, or a chain of EXPR_NEG over one, at lane size 4 is
// narrowed with the existing glue_ieee_f64_bits_to_f32_bits and moved
// as imm32. The same peel covers a VAR, a FIELD, and add/sub/mul/div.
// An odd count xors the f32 sign. One peel handles every depth. The
// 128 stop is only for a chain that does not end. When the gate stays
// 0, the same peel loads the i32 lane, uses neg w0 on an odd count,
// then sign-extends. Lane div is a 64-bit sdiv, and a 32-bit neg
// zeros the high half. An i32 INT_LIT chain stays on emit_expr. This
// file then matches the old body. Do not add a second divss.
// PLATFORM: SHARED.

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
export extern function backend_enc_neg_eax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx: *u8, ta: i32): i32;

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
 * Count a leading EXPR_NEG chain.
 * @param arena *u8 — expression arena.
 * @param expr_ref i32 — current expr. Not positive returns 0.
 * @param budget i32 — peels still allowed. The first call passes 128.
 *   Zero stops without reading another node. That stop is only for a
 *   chain that does not end. Every shorter nest is this one function.
 * @return i32 — how many kind-22 nodes were peeled, or -1 when a NEG
 *   has no operand.
 * One call peels one NEG and recurses on that operand. The lane sign
 * is this count modulo 2. Kind 23 is not kind 22 and stops the count.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function lane_f32_neg_depth(arena: *u8, expr_ref: i32, budget: i32): i32 {
  let ko: i32 = 0;
  let op: i32 = 0;
  let n: i32 = 0;
  if (budget <= 0 || expr_ref <= 0) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  if (ko != 22) {
    return 0;
  }
  unsafe {
    op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  }
  if (op <= 0) {
    return 0 - 1;
  }
  n = lane_f32_neg_depth(arena, op, budget - 1);
  if (n < 0) {
    return n;
  }
  return n + 1;
}

/**
 * Expr under n leading EXPR_NEG nodes.
 * @param arena *u8 — expression arena.
 * @param expr_ref i32 — outer expr.
 * @param n i32 — peels from lane_f32_neg_depth. Zero returns expr_ref.
 * @return i32 — the core expr, or 0 when an operand is missing.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function lane_f32_neg_core(arena: *u8, expr_ref: i32, n: i32): i32 {
  let op: i32 = 0;
  if (n <= 0) {
    return expr_ref;
  }
  if (expr_ref <= 0) {
    return 0;
  }
  unsafe {
    op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  }
  if (op <= 0) {
    return 0;
  }
  return lane_f32_neg_core(arena, op, n - 1);
}

/**
 * True when a NEG count leaves the f32 sign set.
 * @param n i32 — peel count. Zero is even.
 * @return i32 — 1 when n is odd, 0 when n is even.
 * PLATFORM: SHARED.
 */
function lane_f32_neg_is_odd(n: i32): i32 {
  let q: i32 = 0;
  q = n / 2;
  q = q * 2;
  if (n != q) {
    return 1;
  }
  return 0;
}

/**
 * Move one f32 lane immediate for a FLOAT_LIT, or a NEG chain over one.
 * @param arena *u8 — expression arena. Null is not a literal.
 * @param elf_ctx *u8 — emit buffer.
 * @param expr_ref i32 — operand expr.
 * @param ta i32 — 1 arm64, else x86.
 * @return i32 — 1 when w0 holds the f32 bits, 0 when this is not that
 *   shape, -1 when the move fails.
 * The f64 sign bit is xored into the high half before the existing
 * narrow when the peel count is odd. A VAR, a FIELD, a binop, or kind
 * 23 is not kind 1. A chain that does not end within 128 peels leaves
 * the core as kind 22 and returns 0.
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
  let n: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || expr_ref <= 0) {
    return 0;
  }
  // One recursive peel. The core must be a FLOAT_LIT. PLATFORM: SHARED.
  n = lane_f32_neg_depth(arena, expr_ref, 128);
  if (n < 0) {
    return 0;
  }
  op = lane_f32_neg_core(arena, expr_ref, n);
  if (op <= 0) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, op);
  }
  if (ko != 1) {
    return 0;
  }
  neg = lane_f32_neg_is_odd(n);
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
 * Emit a NEG chain's core lane into rax.
 * @param arena *u8 — expression arena.
 * @param elf_ctx *u8 — emit buffer.
 * @param expr_ref i32 — outer EXPR_NEG.
 * @param lane i32 — lane index.
 * @param esz i32 — lane bytes.
 * @param ctx *u8 — asm ctx.
 * @param ta i32 — 1 arm64, else x86.
 * @return i32 — 0 when rax holds the lane, -1 when a load or encode
 *   fails, -2 when this chain is not a VAR, FIELD, or add/sub/mul/div.
 *   A missing field home and a chain that does not end also return -2.
 * The peel is lane_f32_neg_depth. An odd count xors the f32 sign.
 * Kinds 8..13 and kind 23 return -2 so the caller falls through.
 * PLATFORM: SHARED.
 */
function lane_f32_emit_neg_core(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, lane: i32, esz: i32, ctx: *u8, ta: i32
): i32 {
  let n: i32 = 0;
  let core: i32 = 0;
  let ko: i32 = 0;
  let rc: i32 = 0;
  let left_ref: i32 = 0;
  let right_ref: i32 = 0;
  let odd: i32 = 0;
  n = lane_f32_neg_depth(arena, expr_ref, 128);
  if (n <= 0) {
    return 0 - 2;
  }
  core = lane_f32_neg_core(arena, expr_ref, n);
  if (core <= 0) {
    return 0 - 2;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, core);
  }
  odd = lane_f32_neg_is_odd(n);
  if (ko == 3) {
    rc = lane_f32_load_var_lane(arena, elf_ctx, core, lane, esz, ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    if (odd != 0) {
      return lane_f32_xor_sign_rax(elf_ctx, ta);
    }
    return 0;
  }
  // No frame home is -2 and falls through. PLATFORM: SHARED.
  if (ko == 44) {
    rc = lane_f32_load_field_lane(arena, elf_ctx, core, lane, esz, ctx, ta);
    if (rc == (0 - 2)) {
      return 0 - 2;
    }
    if (rc != 0) {
      return 0 - 1;
    }
    if (odd != 0) {
      return lane_f32_xor_sign_rax(elf_ctx, ta);
    }
    return 0;
  }
  // Kinds 8..13 are not 4..7. Kind 23 does not enter. PLATFORM: SHARED.
  rc = 0;
  if (ko == 4) {
    rc = 1;
  }
  if (ko == 5) {
    rc = 1;
  }
  if (ko == 6) {
    rc = 1;
  }
  if (ko == 7) {
    rc = 1;
  }
  if (rc == 0) {
    return 0 - 2;
  }
  unsafe {
    left_ref = pipeline_expr_binop_left_ref_at(arena, core);
    right_ref = pipeline_expr_binop_right_ref_at(arena, core);
  }
  unsafe {
    rc = glue_emit_vector_lane_scalar_binop_elf_c(
      arena, elf_ctx, ko, left_ref, right_ref, lane, esz, ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  if (odd != 0) {
    return lane_f32_xor_sign_rax(elf_ctx, ta);
  }
  return 0;
}

/**
 * Emit an i32 NEG chain's core lane into rax, then neg w0 if odd.
 * @param arena *u8 — expression arena.
 * @param elf_ctx *u8 — emit buffer.
 * @param expr_ref i32 — outer EXPR_NEG.
 * @param lane i32 — lane index.
 * @param esz i32 — lane bytes. Caller passes 4.
 * @param ctx *u8 — asm ctx.
 * @param ta i32 — 1 arm64, else x86.
 * @return i32 — 0 when rax holds the lane, -1 when a load or encode
 *   fails, -2 when the core is not a VAR, FIELD, or add/sub/mul/div.
 *   An INT_LIT core returns -2 so the existing literal path stays.
 *   A missing field home returns -2.
 * The peel is the same lane_f32_neg_depth used for f32. An odd count
 * emits neg w0 and then glue_enc_sxt_i32_result_to_rax_elf_c. Lane div
 * is 64-bit sdiv, and a 32-bit neg zeros the high half of x0. An even
 * count is the loaded lane with no extra extend. This is not the f32
 * sign-bit xor. The f32 gate must be 0 here. Kind 23 and kinds 8..13
 * return -2. PLATFORM: SHARED.
 */
function lane_i32_emit_neg_core(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, lane: i32, esz: i32, ctx: *u8, ta: i32
): i32 {
  let n: i32 = 0;
  let core: i32 = 0;
  let ko: i32 = 0;
  let rc: i32 = 0;
  let left_ref: i32 = 0;
  let right_ref: i32 = 0;
  let odd: i32 = 0;
  let arith: i32 = 0;
  n = lane_f32_neg_depth(arena, expr_ref, 128);
  if (n <= 0) {
    return 0 - 2;
  }
  core = lane_f32_neg_core(arena, expr_ref, n);
  if (core <= 0) {
    return 0 - 2;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, core);
  }
  odd = lane_f32_neg_is_odd(n);
  if (ko == 3) {
    rc = lane_f32_load_var_lane(arena, elf_ctx, core, lane, esz, ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
  } else {
    if (ko == 44) {
      rc = lane_f32_load_field_lane(arena, elf_ctx, core, lane, esz, ctx, ta);
      if (rc == (0 - 2)) {
        return 0 - 2;
      }
      if (rc != 0) {
        return 0 - 1;
      }
    } else {
      // Kinds 8..13 and an INT_LIT stay out. PLATFORM: SHARED.
      arith = 0;
      if (ko == 4) {
        arith = 1;
      }
      if (ko == 5) {
        arith = 1;
      }
      if (ko == 6) {
        arith = 1;
      }
      if (ko == 7) {
        arith = 1;
      }
      if (arith == 0) {
        return 0 - 2;
      }
      unsafe {
        left_ref = pipeline_expr_binop_left_ref_at(arena, core);
        right_ref = pipeline_expr_binop_right_ref_at(arena, core);
      }
      unsafe {
        rc = glue_emit_vector_lane_scalar_binop_elf_c(
          arena, elf_ctx, ko, left_ref, right_ref, lane, esz, ctx, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
    }
  }
  if (odd != 0) {
    // neg w0 zeros the high half. The following lane div is sdiv x0.
    // Sign-extend so a negative lane stays negative. PLATFORM: SHARED.
    unsafe {
      rc = backend_enc_neg_eax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      return glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx, ta);
    }
  }
  return 0;
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
 * A chain of EXPR_NEG over a VAR, a FIELD, or add/sub/mul/div is one
 * peel. When the f32 gate is set, an odd count xors the f32 sign.
 * When the gate is 0, an odd count is neg w0 then a sign-extend
 * on that i32 lane, so the 64-bit lane div sees a signed i32.
 * A FLOAT_LIT chain is the literal peel above. An i32 INT_LIT chain
 * stays on emit_expr. Kind 23, kinds 8..13, and a chain that does not
 * end stay on emit_expr. PLATFORM: SHARED.
 */
#[no_mangle]
export function glue_emit_vector_operand_lane_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, lane: i32, esz: i32, ctx: *u8, ta: i32
): i32 {
  let ko: i32 = 0;
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
      // One recursive peel. An odd count xors the f32 sign.
      // -2 falls through: no field home, kind 23, kinds 8..13, or a
      // chain that does not end. i32 leaves the gate at 0.
      // PLATFORM: SHARED.
      if (ko == 22) {
        rc = lane_f32_emit_neg_core(
          arena, elf_ctx, expr_ref, lane, esz, ctx, ta);
        if (rc != (0 - 2)) {
          return rc;
        }
      }
    }
  }
  // i32 lane. The f32 gate stays 0, so the sign-xor peel did not run.
  // Same NEG recursion. An odd count is neg w0 then sign-extend.
  // An INT_LIT core returns -2 and keeps the existing literal path.
  // PLATFORM: SHARED.
  if (ko == 22) {
    if (esz == 4) {
      unsafe {
        lit = glue_lane_f32_lit_dest_get();
      }
      if (lit == 0) {
        rc = lane_i32_emit_neg_core(
          arena, elf_ctx, expr_ref, lane, esz, ctx, ta);
        if (rc != (0 - 2)) {
          return rc;
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
