// 3-argument folder used by Darwin and Windows module-array bakers.
// Ubuntu's runtime_pipeline_abi_modlet_thin.x keeps the 4-argument
// folder (it also returns the high half). Do not link this object on
// Linux: the symbol name matches, the ABI does not.
// PLATFORM: MACOS|DARWIN / WINDOWS. Do not PREFER this into
// runtime_pipeline_abi.o. Do not modify that object in place.
// Integer binops live in this function. Do not add a second
// pipe_modlet_fold_i32_binop. The Ubuntu thin keeps its own static
// helper because that helper stores through *i32, which this Darwin
// compiler lowers onto the local slot.

export extern "C" function pipeline_expr_as_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_as_target_type_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_int_val_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_binop_right_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_float_bits_lo_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_float_bits_hi_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

/**
 * Fold one module-array element into a single i32 word.
 * EXPR_LIT (ek 0) and EXPR_BOOL_LIT (ek 2) share int_val: true is 1
 * and false is 0. EXPR_NEG (ek 22) folds its operand with this function,
 * then negates that 32-bit word. ADD, SUB, MUL, shifts, and bitwise
 * ops (ek 4, 5, 6, 9..13) fold both children the same way.
 * DIV (7) and MOD (8) use the language operators. A zero divisor and
 * INT_MIN divided by -1 return 0, so the baker loud-fails.
 * lv + 2147483647 == -1 only for the most-negative i32.
 * Compile this file with XLANG_PREFER_ASM_O=1 so those operators do
 * not emit an xlang_panic_ reloc. The Windows compiler that compiles
 * it must already emit cqo before idiv. cltd leaves rdx wrong, and a
 * negative dividend then traps that process. A shift count outside
 * 0..31 returns 0.
 * EXPR_AS (ek 54) accepts TYPE_I32 (0), TYPE_BOOL (1), TYPE_U8 (2),
 * and TYPE_U32 (3). The baker peels esz bytes of this word, so a u8
 * cell keeps the low byte: (0 - 1) as u8 stores 255, 256 as u8 stores 0,
 * and 2 as bool stays 2. A FLOAT_LIT operand, or NEG of one FLOAT_LIT,
 * truncates toward zero into this i32 word: 1.9 as u8 stores 1,
 * 0.9 as u8 stores 0, and -1.9 as u8 stores 255. |x| >= 2^31 returns 0
 * except exactly -2^31. Inf and NaN return 0. Float binops stay
 * unfolded. A 64-bit target returns 0: this ABI has no high half.
 * Do not add pipe_modlet_fold_f64_elem_bits here.
 * @param arena *u8 — AST arena; null returns 0
 * @param eref i32 — expression ref; <= 0 returns 0
 * @param out_val *i32 — one i32 slot; null returns 0; written only on success
 * @return i32 — 1 when out_val holds the folded word, 0 when the expr is not folded
 * PLATFORM: MACOS|DARWIN / WINDOWS — strong definition. Darwin prepare's
 * branch reloc binds here over the weak gcc body. Windows egg and the
 * modlet extra only declare this name.
 */
#[no_mangle]
export function pipe_modlet_array_lit_elem_const_val(arena: *u8, eref: i32, out_val: *i32): i32 {
  let ek: i32 = 0;
  let op: i32 = 0;
  let v: i32 = 0;
  let tgt: i32 = 0;
  let tk: i32 = 0;
  let left: i32 = 0;
  let right: i32 = 0;
  let lv: i32 = 0;
  let rv: i32 = 0;
  let result: i32 = 0;
  let ok: i32 = 0;
  let flo: i32 = 0;
  let fhi: i32 = 0;
  let exp: i32 = 0;
  let e: i32 = 0;
  let hi_sig: i32 = 0;
  let sh: i32 = 0;
  let rsh: i32 = 0;
  let top: i32 = 0;
  let neg: i32 = 0;
  let opek: i32 = 0;
  let mag: i32 = 0;
  let fref: i32 = 0;
  if (arena == 0 as *u8 || eref <= 0 || out_val == 0 as *i32) {
    return 0;
  }
  unsafe {
    ek = pipeline_expr_kind_ord_at(arena, eref);
  }
  // LIT and BOOL_LIT. One store, then success.
  if (ek == 0 || ek == 2) {
    unsafe {
      v = pipeline_expr_int_val_at(arena, eref);
    }
    // Index store through *i32 is lowered to the local slot on this
    // Darwin compiler. pipe_store_i32_le is the existing byte store.
    unsafe {
      pipe_store_i32_le(out_val as *u8, 0, v);
    }
    return 1;
  }
  // NEG of any child this function can fold. The negate stays 32-bit.
  if (ek == 22) {
    unsafe {
      op = pipeline_expr_unary_operand_ref_at(arena, eref);
    }
    if (op <= 0) {
      return 0;
    }
    if (pipe_modlet_array_lit_elem_const_val(arena, op, out_val) == 0) {
      return 0;
    }
    unsafe {
      v = pipe_load_i32_le(out_val as *u8, 0);
    }
    unsafe {
      pipe_store_i32_le(out_val as *u8, 0, 0 - v);
    }
    return 1;
  }
  // Integer binop. Save the left word before the right fold reuses out_val.
  // Read with pipe_load_i32_le: an index load of *i32 is not a dereference
  // on this Darwin compiler. DIV, MOD, and a shift count outside
  // 0..31 return 0 without storing, so the baker loud-fails.
  if (ek >= 4 && ek <= 13) {
    unsafe {
      left = pipeline_expr_binop_left_ref_at(arena, eref);
      right = pipeline_expr_binop_right_ref_at(arena, eref);
    }
    if (left <= 0 || right <= 0) {
      return 0;
    }
    if (pipe_modlet_array_lit_elem_const_val(arena, left, out_val) == 0) {
      return 0;
    }
    unsafe {
      lv = pipe_load_i32_le(out_val as *u8, 0);
    }
    if (pipe_modlet_array_lit_elem_const_val(arena, right, out_val) == 0) {
      return 0;
    }
    unsafe {
      rv = pipe_load_i32_le(out_val as *u8, 0);
    }
    ok = 0;
    if (ek == 4) {
      result = lv + rv;
      ok = 1;
    }
    if (ek == 5) {
      result = lv - rv;
      ok = 1;
    }
    if (ek == 6) {
      result = lv * rv;
      ok = 1;
    }
    // EXPR_DIV=7 and EXPR_MOD=8. Zero and INT_MIN/-1 are not constants.
    // The language operators are compiled into this function, so the
    // Windows compiler must emit cqo before the 64-bit idiv.
    if (ek == 7 || ek == 8) {
      if (rv == 0) {
        return 0;
      }
      if (rv == (0 - 1)) {
        if (lv + 2147483647 == (0 - 1)) {
          return 0;
        }
      }
      if (ek == 7) {
        result = lv / rv;
      }
      if (ek == 8) {
        result = lv % rv;
      }
      ok = 1;
    }
    if (ek == 9 || ek == 10) {
      if (rv < 0 || rv >= 32) {
        return 0;
      }
      if (ek == 9) {
        result = lv << rv;
      }
      if (ek == 10) {
        result = lv >> rv;
      }
      ok = 1;
    }
    if (ek == 11) {
      result = lv & rv;
      ok = 1;
    }
    if (ek == 12) {
      result = lv | rv;
      ok = 1;
    }
    if (ek == 13) {
      result = lv ^ rv;
      ok = 1;
    }
    if (ok == 0) {
      return 0;
    }
    unsafe {
      pipe_store_i32_le(out_val as *u8, 0, result);
    }
    return 1;
  }
  // AS. 32-bit targets only. An integer operand is already in out_val.
  // A float literal is truncated below. The baker peels the bytes.
  if (ek == 54) {
    unsafe {
      op = pipeline_expr_as_operand_ref_at(arena, eref);
    }
    unsafe {
      tgt = pipeline_expr_as_target_type_ref_at(arena, eref);
    }
    if (op <= 0 || tgt <= 0) {
      return 0;
    }
    unsafe {
      tk = pipeline_type_kind_ord_at(arena, tgt);
    }
    if (tk != 0 && tk != 1 && tk != 2 && tk != 3) {
      return 0;
    }
    if (pipe_modlet_array_lit_elem_const_val(arena, op, out_val) != 0) {
      return 1;
    }
    // Not an integer. A bare FLOAT_LIT, or NEG of one FLOAT_LIT,
    // truncates toward zero. The bit readers are the existing AST
    // accessors. Float ADD/SUB/MUL/DIV stay 0: this function does not
    // grow a second float folder. 64-bit targets already returned 0.
    unsafe {
      opek = pipeline_expr_kind_ord_at(arena, op);
    }
    fref = op;
    neg = 0;
    if (opek == 22) {
      unsafe {
        fref = pipeline_expr_unary_operand_ref_at(arena, op);
      }
      if (fref <= 0) {
        return 0;
      }
      unsafe {
        opek = pipeline_expr_kind_ord_at(arena, fref);
      }
      neg = 1;
    }
    if (opek != 1) {
      return 0;
    }
    unsafe {
      flo = pipeline_expr_float_bits_lo_at(arena, fref);
      fhi = pipeline_expr_float_bits_hi_at(arena, fref);
    }
    // NEG flips only the IEEE sign bit. Clearing it is a mask. Setting
    // it is OR with the sign bit. That is XOR of bit 31, with no add.
    if (neg != 0) {
      if (fhi < 0) {
        fhi = fhi & 2147483647;
      } else {
        fhi = fhi | (0 - 2147483647 - 1);
      }
    }
    // Biased exponent is bits 20..30. An arithmetic shift of a negative
    // high half still leaves those 11 bits after the mask.
    exp = (fhi >> 20) & 2047;
    // Inf / NaN. cvttsd2si would yield the indefinite integer.
    if (exp == 2047) {
      return 0;
    }
    // |x| < 1, including zero and subnormals, truncates to 0.
    if (exp < 1023) {
      unsafe {
        pipe_store_i32_le(out_val as *u8, 0, 0);
      }
      return 1;
    }
    e = exp - 1023;
    // |x| >= 2^32 does not fit in i32.
    if (e > 31) {
      return 0;
    }
    // Binade [2^31, 2^32). Only exactly -2^31 fits in signed i32.
    if (e == 31) {
      if (fhi >= 0) {
        return 0;
      }
      if ((fhi & 1048575) != 0 || flo != 0) {
        return 0;
      }
      unsafe {
        pipe_store_i32_le(out_val as *u8, 0, 0 - 2147483647 - 1);
      }
      return 1;
    }
    // Implicit 1 plus the top 20 fraction bits. This word is positive
    // and at most 0x1fffff.
    hi_sig = (1 << 20) | (fhi & 1048575);
    if (e <= 20) {
      // Fraction below 2^0 lives in the low word and in the bits this
      // shift drops. 1.9 has unbiased exponent 0, so the result is 1.
      mag = hi_sig >> (20 - e);
    } else {
      // Unbiased 21..30. Left-shift the high significand, then OR the
      // top (e-20) bits of the low word. Those low bits are a logical
      // shift: an arithmetic >> of a negative low word would sign-extend.
      sh = e - 20;
      rsh = 32 - sh;
      top = 0;
      mag = flo;
      if (mag < 0) {
        mag = mag & 2147483647;
        top = 1 << (31 - rsh);
      }
      mag = (mag >> rsh) | top;
      mag = (hi_sig << sh) | mag;
    }
    if (fhi < 0) {
      mag = 0 - mag;
    }
    unsafe {
      pipe_store_i32_le(out_val as *u8, 0, mag);
    }
    return 1;
  }
  return 0;
}
