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
// 0, one recursion walks a chain of negation and bitwise not from the
// inside out. The core may be a VAR, a FIELD, or a lane scalar binop
// of kinds 4..13 (mod, shifts, and, or, xor). Kind 23 uses the
// existing not encoder. A signed i32 lane is then sign-extended,
// because lane div is a 64-bit sdiv and a 32-bit not zeros the high
// half. A u32 lane stays zero-extended. Kind 22 uses neg w0 and then
// the same sign-extend as before. Kind 24, kind 51, and an i32 INT_LIT
// stay on emit_expr. A transparent block, a nested block, and
// unsafe { e } are one recursion over the existing
// glue_expr_block_transparent_value_ref_at. The lane op then sees the
// inner value. A block that has lets is not peeled. An INDEX with an
// integer-literal index loads one lane from the base frame. Nested
// indexes are that same recursion. The stride is the existing index
// element size. A non-literal index stays on emit_expr. The 128 stop
// is only for a chain that does not end. This file then matches the old
// body. Do not add a second divss.
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
export extern function backend_enc_not_eax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_lane_shr_is_arith(
  arena: *u8, ctx: *u8, left_ref: i32, right_ref: i32
): i32;
export extern function glue_expr_block_transparent_value_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_index_elem_byte_sz_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_int_val_at(arena: *u8, expr_ref: i32): i32;

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
 * Replace a transparent block chain with its value expr.
 * @param arena *u8 — expression arena. Null returns expr_ref.
 * @param expr_ref i32 — current expr. Not positive returns expr_ref.
 * @param budget i32 — blocks still allowed. The first call passes 128.
 *   Zero returns expr_ref without reading. That stop is only for a
 *   chain that does not end. Every shorter nest is this one function.
 * @return i32 — the expr under every transparent `{ e }` and
 *   `unsafe { e }`, or expr_ref when the node is not one of those.
 * One call asks the existing glue_expr_block_transparent_value_ref_at
 * and recurses on that inner expr. This does not walk lets, loops, or
 * statement counts itself. A block with lets makes that helper return
 * 0, so this returns the block unchanged. PLATFORM: SHARED.
 */
function lane_operand_unwrap_block(arena: *u8, expr_ref: i32, budget: i32): i32 {
  let inner: i32 = 0;
  if (budget <= 0) {
    return expr_ref;
  }
  if (arena == (0 as *u8)) {
    return expr_ref;
  }
  if (expr_ref <= 0) {
    return expr_ref;
  }
  unsafe {
    inner = glue_expr_block_transparent_value_ref_at(arena, expr_ref);
  }
  if (inner <= 0) {
    return expr_ref;
  }
  return lane_operand_unwrap_block(arena, inner, budget - 1);
}

/**
 * Frame offset of one lane of an indexed vector.
 * @param arena *u8 — expression arena. Null returns -1.
 * @param ctx *u8 — asm ctx. Null returns -1.
 * @param expr_ref i32 — INDEX, or the VAR / FIELD base under one.
 *   Not positive returns -1.
 * @param lane i32 — lane inside the indexed element. Negative returns -1.
 *   A recursive call on the base passes 0.
 * @param esz i32 — lane bytes. Not positive returns -1. A recursive
 *   call on the base passes the element stride instead.
 * @param ta i32 — 1 arm64, else x86. Arm64 adds the lane. x86 subtracts.
 * @param budget i32 — indexes still allowed. The first call passes 128.
 *   Zero returns -1 without reading. That stop is only for a chain
 *   that does not end. Every shorter nest is this one function.
 * @return i32 — rbp offset of the lane, or -1 when the home is missing,
 *   the index is not an integer literal, or the base is not a VAR,
 *   FIELD, or another such INDEX.
 * One call peels one INDEX. The element stride is the existing
 * pipeline_asm_index_elem_byte_sz_c. The literal value is the existing
 * pipeline_expr_int_val_at. The base home is this function again.
 * A FIELD base uses the existing glue_vector_var_lane_stack_off_elf_c
 * and does not walk fields here. A negative offset is no home, same
 * as the field loader. PLATFORM: SHARED.
 */
function lane_indexed_lane_off(
  arena: *u8, ctx: *u8, expr_ref: i32, lane: i32, esz: i32, ta: i32, budget: i32
): i32 {
  let ko: i32 = 0;
  let cur: i32 = 0;
  let off: i32 = 0;
  let base_ref: i32 = 0;
  let idx_ref: i32 = 0;
  let elem_sz: i32 = 0;
  let imm: i32 = 0;
  let base_off: i32 = 0;
  if (budget <= 0) {
    return 0 - 1;
  }
  if (arena == (0 as *u8)) {
    return 0 - 1;
  }
  if (ctx == (0 as *u8)) {
    return 0 - 1;
  }
  if (expr_ref <= 0) {
    return 0 - 1;
  }
  if (lane < 0) {
    return 0 - 1;
  }
  if (esz <= 0) {
    return 0 - 1;
  }
  cur = lane_operand_unwrap_block(arena, expr_ref, budget);
  if (cur <= 0) {
    return 0 - 1;
  }
  if (cur != expr_ref) {
    return lane_indexed_lane_off(arena, ctx, cur, lane, esz, ta, budget - 1);
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  if (ko == 3) {
    unsafe {
      off = glue_asm_local_var_stack_off_scoped(arena, ctx, expr_ref);
    }
    if (off < 0) {
      return 0 - 1;
    }
    if (ta == 1) {
      return off + lane * esz;
    }
    return off - lane * esz;
  }
  if (ko == 44) {
    unsafe {
      return glue_vector_var_lane_stack_off_elf_c(arena, ctx, expr_ref, lane, esz, ta);
    }
  }
  if (ko != 47) {
    return 0 - 1;
  }
  unsafe {
    base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
    idx_ref = pipeline_expr_index_index_ref(arena, expr_ref);
    elem_sz = pipeline_asm_index_elem_byte_sz_c(arena, expr_ref);
  }
  if (base_ref <= 0) {
    return 0 - 1;
  }
  if (idx_ref <= 0) {
    return 0 - 1;
  }
  if (elem_sz <= 0) {
    return 0 - 1;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, idx_ref);
  }
  if (ko != 0) {
    return 0 - 1;
  }
  unsafe {
    imm = pipeline_expr_int_val_at(arena, idx_ref);
  }
  // Lane 0 of the base is the start of this array. This level then
  // adds the literal element and the caller's lane. PLATFORM: SHARED.
  base_off = lane_indexed_lane_off(arena, ctx, base_ref, 0, elem_sz, ta, budget - 1);
  if (base_off < 0) {
    return 0 - 1;
  }
  if (ta == 1) {
    return base_off + imm * elem_sz + lane * esz;
  }
  return base_off - imm * elem_sz - lane * esz;
}

/**
 * Load one lane of an indexed vector into rax.
 * @param arena *u8 — expression arena.
 * @param elf_ctx *u8 — emit buffer.
 * @param expr_ref i32 — INDEX expr.
 * @param lane i32 — lane index.
 * @param esz i32 — lane bytes.
 * @param ctx *u8 — asm ctx.
 * @param ta i32 — 1 arm64, else x86.
 * @return i32 — 0 when rax holds the lane, the load encoder result
 *   when the encode fails, -2 when lane_indexed_lane_off has no home.
 * The offset already includes lane polarity. This load does not add
 * lane * esz again. PLATFORM: SHARED.
 */
function lane_load_indexed_lane(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, lane: i32, esz: i32, ctx: *u8, ta: i32
): i32 {
  let off: i32 = 0;
  off = lane_indexed_lane_off(arena, ctx, expr_ref, lane, esz, ta, 128);
  if (off < 0) {
    return 0 - 2;
  }
  unsafe {
    return backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, off, esz, ta);
  }
}

/**
 * Emit a NEG chain's core lane into rax.
 * @param arena *u8 — expression arena.
 * @param elf_ctx *u8 — emit buffer.
 * @param expr_ref i32 — outer EXPR_NEG, or a transparent block around one.
 * @param lane i32 — lane index.
 * @param esz i32 — lane bytes.
 * @param ctx *u8 — asm ctx.
 * @param ta i32 — 1 arm64, else x86.
 * @param budget i32 — nodes still allowed. The first call passes 128.
 *   Zero returns -2 without reading. That stop is only for a chain
 *   that does not end.
 * @return i32 — 0 when rax holds the lane, -1 when a load or encode
 *   fails, -2 when this chain is not a VAR, FIELD, or add/sub/mul/div.
 *   A missing field home and a chain that does not end also return -2.
 * The peel is lane_f32_neg_depth. An odd count xors the f32 sign.
 * A transparent block around this node, or under the negation chain,
 * is the same lane_operand_unwrap_block recursion. A negation inside
 * that block is this function again, then this chain's sign is applied.
 * Kinds 8..13 and kind 23 return -2 so the caller falls through.
 * PLATFORM: SHARED.
 */
function lane_f32_emit_neg_core(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, lane: i32, esz: i32, ctx: *u8, ta: i32,
  budget: i32
): i32 {
  let n: i32 = 0;
  let core: i32 = 0;
  let peeled: i32 = 0;
  let cur: i32 = 0;
  let ko: i32 = 0;
  let rc: i32 = 0;
  let left_ref: i32 = 0;
  let right_ref: i32 = 0;
  let odd: i32 = 0;
  if (budget <= 0) {
    return 0 - 2;
  }
  cur = lane_operand_unwrap_block(arena, expr_ref, budget);
  if (cur <= 0) {
    return 0 - 2;
  }
  if (cur != expr_ref) {
    return lane_f32_emit_neg_core(
      arena, elf_ctx, cur, lane, esz, ctx, ta, budget - 1);
  }
  n = lane_f32_neg_depth(arena, expr_ref, budget);
  if (n <= 0) {
    return 0 - 2;
  }
  core = lane_f32_neg_core(arena, expr_ref, n);
  if (core <= 0) {
    return 0 - 2;
  }
  odd = lane_f32_neg_is_odd(n);
  // The value under the negation may itself be { e } or unsafe { e }.
  // A negation inside that block is this function again. The sign of
  // this chain is applied after that, because the two counts add.
  // PLATFORM: SHARED.
  peeled = lane_operand_unwrap_block(arena, core, budget);
  if (peeled <= 0) {
    return 0 - 2;
  }
  if (peeled != core) {
    unsafe {
      ko = pipeline_expr_kind_ord_at(arena, peeled);
    }
    if (ko == 22) {
      rc = lane_f32_emit_neg_core(
        arena, elf_ctx, peeled, lane, esz, ctx, ta, budget - 1);
      if (rc != 0) {
        return rc;
      }
      if (odd != 0) {
        return lane_f32_xor_sign_rax(elf_ctx, ta);
      }
      return 0;
    }
    core = peeled;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, core);
  }
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
  // INDEX=47. No literal home is -2 and falls through. PLATFORM: SHARED.
  if (ko == 47) {
    rc = lane_load_indexed_lane(arena, elf_ctx, core, lane, esz, ctx, ta);
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
 * 1 when a bitwise complement of this lane must sign-extend.
 * @param arena *u8 — expression arena. Null returns 0.
 * @param ctx *u8 — asm ctx. Forwarded to the signed-lane helper.
 * @param expr_ref i32 — current expr. Not positive returns 0.
 * @param budget i32 — nodes still allowed. The first call passes 128.
 *   Zero returns 0 without reading. That stop is only for a chain
 *   that does not end.
 * @return i32 — 1 when the lane is a signed i32, 0 otherwise.
 * One call asks the existing pipeline_lane_shr_is_arith. A transparent
 * block is replaced first by lane_operand_unwrap_block, so the sign
 * is the inner value's sign. A negation or a bitwise not has often no
 * resolved type, so a 0 walks to the operand and asks again. A lane
 * binop walks to its left. Kind 51 does not. A u32 name stays 0, so
 * the complement is left zero-extended. This does not copy the
 * spelling test. PLATFORM: SHARED.
 */
function lane_i32_not_is_signed(arena: *u8, ctx: *u8, expr_ref: i32, budget: i32): i32 {
  let ko: i32 = 0;
  let op: i32 = 0;
  let signed_lane: i32 = 0;
  let left_ref: i32 = 0;
  let arith: i32 = 0;
  let step: i32 = 0;
  let cur: i32 = 0;
  if (budget <= 0) {
    return 0;
  }
  if (arena == (0 as *u8)) {
    return 0;
  }
  if (expr_ref <= 0) {
    return 0;
  }
  cur = lane_operand_unwrap_block(arena, expr_ref, budget);
  if (cur <= 0) {
    return 0;
  }
  if (cur != expr_ref) {
    return lane_i32_not_is_signed(arena, ctx, cur, budget - 1);
  }
  unsafe {
    signed_lane = pipeline_lane_shr_is_arith(arena, ctx, expr_ref, 0);
  }
  if (signed_lane != 0) {
    return 1;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  if (ko == 22) {
    step = 1;
  }
  if (ko == 23) {
    step = 1;
  }
  if (step != 0) {
    unsafe {
      op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    }
    if (op <= 0) {
      return 0;
    }
    return lane_i32_not_is_signed(arena, ctx, op, budget - 1);
  }
  arith = 0;
  unsafe {
    arith = glue_is_vector_lane_scalar_binop_ko(ko);
  }
  if (ko == 51) {
    arith = 0;
  }
  if (arith != 0) {
    unsafe {
      left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    }
    if (left_ref <= 0) {
      return 0;
    }
    return lane_i32_not_is_signed(arena, ctx, left_ref, budget - 1);
  }
  return 0;
}

/**
 * Emit one i32 negation or bitwise-not chain into rax.
 * @param arena *u8 — expression arena.
 * @param elf_ctx *u8 — emit buffer.
 * @param expr_ref i32 — current expr. The first call is the outer
 *   kind 22 or kind 23.
 * @param lane i32 — lane index.
 * @param esz i32 — lane bytes. Caller passes 4.
 * @param ctx *u8 — asm ctx.
 * @param ta i32 — 1 arm64, else x86.
 * @param budget i32 — nodes still allowed. The first call passes 128.
 *   Zero returns -2 without reading. That stop is only for a chain
 *   that does not end.
 * @return i32 — 0 when rax holds the lane, -1 when a load or encode
 *   fails, -2 when the core is not a VAR, FIELD, or a lane scalar
 *   binop of kinds 4..13. An INT_LIT core returns -2 so the existing
 *   literal path stays. A missing field home returns -2. Kind 24
 *   returns -2.
 * One call peels one node and recurses on its operand, then applies
 * this node on the way out. A transparent block is not a negation or
 * a complement: lane_operand_unwrap_block replaces it, then this walk
 * continues on the inner value. A block with lets stays, and this
 * returns -2. Negation and bitwise not do not commute, so the walk
 * does not count them apart. Kind 23 emits the existing not encoder.
 * A signed i32 complement is then sign-extended: mvn w0 zeros the
 * high half, and the lane div is sdiv x0. A u32 complement is not
 * sign-extended. Kind 22 emits neg w0 and then the existing
 * sign-extend, matching the previous odd negation. Kinds 4..13 use
 * the existing lane binop. Kind 51 is not applied. This is not the
 * f32 sign-bit xor. The f32 gate must be 0 here. PLATFORM: SHARED.
 */
function lane_i32_emit_neg_core(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, lane: i32, esz: i32, ctx: *u8, ta: i32,
  budget: i32
): i32 {
  let ko: i32 = 0;
  let op: i32 = 0;
  let rc: i32 = 0;
  let left_ref: i32 = 0;
  let right_ref: i32 = 0;
  let arith: i32 = 0;
  let step: i32 = 0;
  let signed_lane: i32 = 0;
  let cur: i32 = 0;
  if (budget <= 0) {
    return 0 - 2;
  }
  if (expr_ref <= 0) {
    return 0 - 2;
  }
  cur = lane_operand_unwrap_block(arena, expr_ref, budget);
  if (cur <= 0) {
    return 0 - 2;
  }
  if (cur != expr_ref) {
    return lane_i32_emit_neg_core(
      arena, elf_ctx, cur, lane, esz, ctx, ta, budget - 1);
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  if (ko == 22) {
    step = 22;
  }
  if (ko == 23) {
    step = 23;
  }
  if (step != 0) {
    unsafe {
      op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    }
    if (op <= 0) {
      return 0 - 1;
    }
    rc = lane_i32_emit_neg_core(
      arena, elf_ctx, op, lane, esz, ctx, ta, budget - 1);
    if (rc != 0) {
      return rc;
    }
    if (step == 23) {
      // mvn w0 zeros the high half. Sign-extend only a signed i32
      // so u32 ~4 / 2 stays the zero-extended quotient.
      // PLATFORM: SHARED.
      unsafe {
        rc = backend_enc_not_eax_arch(elf_ctx, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      signed_lane = lane_i32_not_is_signed(arena, ctx, expr_ref, 128);
      if (signed_lane != 0) {
        unsafe {
          return glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx, ta);
        }
      }
      return 0;
    }
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
  if (ko == 3) {
    rc = lane_f32_load_var_lane(arena, elf_ctx, expr_ref, lane, esz, ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
  if (ko == 44) {
    rc = lane_f32_load_field_lane(arena, elf_ctx, expr_ref, lane, esz, ctx, ta);
    if (rc == (0 - 2)) {
      return 0 - 2;
    }
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
  // INDEX=47. A non-literal index is -2 and keeps emit_expr.
  // PLATFORM: SHARED.
  if (ko == 47) {
    rc = lane_load_indexed_lane(arena, elf_ctx, expr_ref, lane, esz, ctx, ta);
    if (rc == (0 - 2)) {
      return 0 - 2;
    }
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
  // Kinds 4..13, including mod, shifts, and, or, xor. Kind 51 stays
  // out. INT_LIT and kind 24 return -2. PLATFORM: SHARED.
  arith = 0;
  unsafe {
    arith = glue_is_vector_lane_scalar_binop_ko(ko);
  }
  if (ko == 51) {
    arith = 0;
  }
  if (arith == 0) {
    return 0 - 2;
  }
  unsafe {
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
  }
  unsafe {
    rc = glue_emit_vector_lane_scalar_binop_elf_c(
      arena, elf_ctx, ko, left_ref, right_ref, lane, esz, ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
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
 * A chain of negation or bitwise not over a VAR, a FIELD, or a lane
 * scalar binop (kinds 4..13) is one recursion. A transparent block
 * around that operand is lane_operand_unwrap_block, then this function
 * again on the inner value, so `{ e }`, nested blocks, and unsafe { e }
 * share the arms below. A block with lets is not peeled. When the f32
 * gate is set, an odd negation count xors the f32 sign and kinds 8..13
 * stay out of that xor. When the gate is 0, each negation is neg w0
 * then a sign-extend, and each bitwise not uses the existing not
 * encoder. A signed i32 complement is sign-extended so the 64-bit lane
 * div sees it. A u32 complement is not. A FLOAT_LIT chain is the
 * literal peel above. An i32 INT_LIT chain stays on emit_expr. Kind 24
 * and a chain that does not end stay on emit_expr. PLATFORM: SHARED.
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
  let cur: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || expr_ref <= 0 || lane < 0) {
    return 0 - 1;
  }
  // One recursion. The helper already stripped every transparent
  // block, so this tail call sees the inner kind. PLATFORM: SHARED.
  cur = lane_operand_unwrap_block(arena, expr_ref, 128);
  if (cur <= 0) {
    return 0 - 1;
  }
  if (cur != expr_ref) {
    return glue_emit_vector_operand_lane_elf_c(
      arena, elf_ctx, cur, lane, esz, ctx, ta);
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
          arena, elf_ctx, expr_ref, lane, esz, ctx, ta, 128);
        if (rc != (0 - 2)) {
          return rc;
        }
      }
    }
  }
  // i32 lane. The f32 gate stays 0, so the sign-xor peel did not run.
  // One recursion walks kind 22 and kind 23 from the inside out.
  // Kind 22 is neg w0 then sign-extend. Kind 23 is the existing not
  // encoder, then a sign-extend only for a signed i32 lane. Kind 51,
  // kind 24, and an INT_LIT core return -2 and keep the existing path.
  // PLATFORM: SHARED.
  if (ko == 22) {
    if (esz == 4) {
      unsafe {
        lit = glue_lane_f32_lit_dest_get();
      }
      if (lit == 0) {
        rc = lane_i32_emit_neg_core(
          arena, elf_ctx, expr_ref, lane, esz, ctx, ta, 128);
        if (rc != (0 - 2)) {
          return rc;
        }
      }
    }
  }
  if (ko == 23) {
    if (esz == 4) {
      unsafe {
        lit = glue_lane_f32_lit_dest_get();
      }
      if (lit == 0) {
        rc = lane_i32_emit_neg_core(
          arena, elf_ctx, expr_ref, lane, esz, ctx, ta, 128);
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
  // INDEX=47. The offset already includes the lane. No literal home
  // falls through. PLATFORM: SHARED.
  if (ko == 47) {
    rc = lane_load_indexed_lane(arena, elf_ctx, expr_ref, lane, esz, ctx, ta);
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
