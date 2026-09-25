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
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
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
 * and 2 as bool stays 2. A float operand truncates toward zero into
 * this i32 word. The float tree may be a FLOAT_LIT, NEG, or
 * ADD/SUB/MUL/DIV of those, up to 8 stack frames. 1.9 as u8 stores 1,
 * 0.9 as u8 stores 0, -1.9 as u8 stores 255, and (0.0 - 1.9) as i32
 * stores -1. Each binop copies the IEEE halves into a host f64 with
 * memcpy, applies the language operator, and copies the bits back.
 * That is the same host-float operator the Ubuntu 4-arg folder uses.
 * It stays inside this function: this ABI has no high-half out
 * parameter, so there is no second float folder.
 * Do not add pipe_modlet_fold_f64_elem_bits.
 * |x| >= 2^32 returns 0. Exact -2^31 returns 1. Inf and NaN return 0,
 * so (1.0 / 0.0) as i32 stays unfolded. Float MOD stays unfolded.
 * An f32-typed binop is not rounded back to f32 before the trunc.
 * TYPE_U64, TYPE_I64, TYPE_USIZE, and TYPE_ISIZE (kinds 4..7) store
 * this same i32 word. Return 1 means the baker sign-fills the high
 * half. A positive trunc in [2^31, 2^32) does not fit that fill: the
 * low word has bit 31 set and the high half is 0, so this function
 * returns 2. 2147483648.0 as i64 is that case. (0 - 1) as i64 stays
 * return 1. Exactly -2^31 stays return 1. |x| >= 2^32 stays 0.
 * 2147483648.0 as i32 stays 0: it does not fit in signed i32.
 * @param arena *u8 — AST arena; null returns 0
 * @param eref i32 — expression ref; <= 0 returns 0
 * @param out_val *i32 — one i32 slot; null returns 0; written only on success
 * @return i32 — 1 sign-fill, 2 zero high half, 0 not folded
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
  let mag: i32 = 0;
  let got: i32 = 0;
  let sp: i32 = 0;
  let guard: i32 = 0;
  let si: i32 = 0;
  let pi: i32 = 0;
  let step: i32 = 0;
  let pstep: i32 = 0;
  let sek: i32 = 0;
  let sref: i32 = 0;
  let child: i32 = 0;
  let llo: i32 = 0;
  let lhi: i32 = 0;
  let rlo: i32 = 0;
  let rhi: i32 = 0;
  let stk_ref: i32[8] = [];
  let stk_step: i32[8] = [];
  let stk_ek: i32[8] = [];
  let stk_aux: i32[8] = [];
  let stk_lo: i32[8] = [];
  let stk_hi: i32[8] = [];
  let lp: i32[2] = [];
  let rp: i32[2] = [];
  let oparts: i32[2] = [];
  let av: f64 = 0.0;
  let bv: f64 = 0.0;
  let fr: f64 = 0.0;
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
  // AS. Kinds 0..3 are 32-bit cells. Kinds 4..7 are 64-bit cells:
  // the word below is the low half, and the baker sign-fills the rest.
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
    // 0 i32, 1 bool, 2 u8, 3 u32, 4 u64, 5 i64, 6 usize, 7 isize.
    // f32 (14) and f64 (15) stay unfolded: this word is an integer.
    if (tk != 0 && tk != 1 && tk != 2 && tk != 3 && tk != 4 && tk != 5 && tk != 6 && tk != 7) {
      return 0;
    }
    // A child return of 2 is a zero high half. A narrower cast of that
    // word is an i32, so the baker must sign-fill it. A 64-bit cast
    // keeps the zero high half.
    ok = pipe_modlet_array_lit_elem_const_val(arena, op, out_val);
    if (ok == 1) {
      return 1;
    }
    if (ok == 2) {
      if (tk == 4 || tk == 5 || tk == 6 || tk == 7) {
        return 2;
      }
      return 1;
    }
    // Not an integer. Evaluate a float tree into flo/fhi, then truncate.
    // Frames: 0 enter, 1 left or unary child is on the stack, 2 value
    // is ready, 3 binop left bits sit in this frame and the right child
    // is on the stack. Eight frames cover the probe trees. A deeper
    // tree, a float MOD, or a non-float node returns 0. Host f64 is the
    // operator. The bits never go through a second function.
    got = 0;
    sp = 0;
    guard = 0;
    stk_ref[0] = op;
    stk_step[0] = 0;
    sp = 1;
    while (sp > 0) {
      guard = guard + 1;
      if (guard > 48) {
        sp = 0;
      }
      if (sp > 0) {
        si = sp - 1;
        step = stk_step[si];
        if (step == 0) {
          sref = stk_ref[si];
          unsafe {
            sek = pipeline_expr_kind_ord_at(arena, sref);
          }
          stk_ek[si] = sek;
          if (sek == 1) {
            unsafe {
              stk_lo[si] = pipeline_expr_float_bits_lo_at(arena, sref);
              stk_hi[si] = pipeline_expr_float_bits_hi_at(arena, sref);
            }
            stk_step[si] = 2;
          } else {
            if (sek == 22) {
              unsafe {
                child = pipeline_expr_unary_operand_ref_at(arena, sref);
              }
              if (child <= 0 || sp >= 8) {
                sp = 0;
              } else {
                stk_step[si] = 1;
                stk_ref[sp] = child;
                stk_step[sp] = 0;
                sp = sp + 1;
              }
            } else {
              if (sek == 4 || sek == 5 || sek == 6 || sek == 7) {
                unsafe {
                  left = pipeline_expr_binop_left_ref_at(arena, sref);
                  right = pipeline_expr_binop_right_ref_at(arena, sref);
                }
                if (left <= 0 || right <= 0 || sp >= 8) {
                  sp = 0;
                } else {
                  stk_aux[si] = right;
                  stk_step[si] = 1;
                  stk_ref[sp] = left;
                  stk_step[sp] = 0;
                  sp = sp + 1;
                }
              } else {
                sp = 0;
              }
            }
          }
        } else {
          if (step == 2) {
            if (si == 0) {
              flo = stk_lo[0];
              fhi = stk_hi[0];
              got = 1;
              sp = 0;
            } else {
              pi = si - 1;
              pstep = stk_step[pi];
              sek = stk_ek[pi];
              if (pstep == 1 && sek == 22) {
                // NEG flips only the IEEE sign bit.
                stk_lo[pi] = stk_lo[si];
                if (stk_hi[si] < 0) {
                  stk_hi[pi] = stk_hi[si] & 2147483647;
                } else {
                  stk_hi[pi] = stk_hi[si] | (0 - 2147483647 - 1);
                }
                stk_step[pi] = 2;
                sp = si;
              } else {
                if (pstep == 1 && (sek == 4 || sek == 5 || sek == 6 || sek == 7)) {
                  stk_lo[pi] = stk_lo[si];
                  stk_hi[pi] = stk_hi[si];
                  stk_step[pi] = 3;
                  sp = si;
                  stk_ref[sp] = stk_aux[pi];
                  stk_step[sp] = 0;
                  sp = sp + 1;
                } else {
                  if (pstep == 3 && (sek == 4 || sek == 5 || sek == 6 || sek == 7)) {
                    llo = stk_lo[pi];
                    lhi = stk_hi[pi];
                    rlo = stk_lo[si];
                    rhi = stk_hi[si];
                    lp[0] = llo;
                    lp[1] = lhi;
                    rp[0] = rlo;
                    rp[1] = rhi;
                    // Same bit copy as glue_ieee_f64_bits_to_f32_bits.
                    unsafe {
                      memcpy((&av) as *u8, (&(lp[0])) as *u8, 8 as usize);
                      memcpy((&bv) as *u8, (&(rp[0])) as *u8, 8 as usize);
                    }
                    // Separate ifs, not an else chain. The compiler that
                    // emits this function clobbers the divisor register in
                    // the compare and then drops the reload on an else
                    // arm, so fdiv would use the kind code as the divisor.
                    // Each arm below reloads both halves after its compare.
                    // EXPR_DIV of zero stays IEEE infinity.
                    if (sek == 4) {
                      fr = av + bv;
                    }
                    if (sek == 5) {
                      fr = av - bv;
                    }
                    if (sek == 6) {
                      fr = av * bv;
                    }
                    if (sek == 7) {
                      fr = av / bv;
                    }
                    unsafe {
                      memcpy((&(oparts[0])) as *u8, (&fr) as *u8, 8 as usize);
                    }
                    stk_lo[pi] = oparts[0];
                    stk_hi[pi] = oparts[1];
                    stk_step[pi] = 2;
                    sp = si;
                  } else {
                    sp = 0;
                  }
                }
              }
            }
          } else {
            sp = 0;
          }
        }
      }
    }
    if (got == 0) {
      return 0;
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
    // |x| >= 2^32 needs a high half this single word cannot carry.
    if (e > 31) {
      return 0;
    }
    // Negative binade (-2^32, -2^31]. Only exact -2^31 is the sign
    // fill of i32 0x80000000. Anything more negative has a low word
    // that is not that fill.
    if (e == 31 && fhi < 0) {
      if ((fhi & 1048575) != 0 || flo != 0) {
        return 0;
      }
      unsafe {
        pipe_store_i32_le(out_val as *u8, 0, 0 - 2147483647 - 1);
      }
      return 1;
    }
    // Positive [2^31, 2^32). The low word has bit 31 set and the high
    // half is 0. i32, bool, and u8 do not accept that magnitude.
    // u32 would fit, but this wave only claims the 64-bit targets.
    // Each shift stays inside a positive i32. Bit 31 is ORed in last.
    if (e == 31) {
      if (tk != 4 && tk != 5 && tk != 6 && tk != 7) {
        return 0;
      }
      hi_sig = (1 << 20) | (fhi & 1048575);
      rsh = 21;
      top = 0;
      mag = flo;
      if (mag < 0) {
        mag = mag & 2147483647;
        top = 1 << 10;
      }
      mag = (mag >> rsh) | top;
      mag = mag | ((hi_sig & 2047) << 11);
      mag = mag | (((hi_sig >> 11) & 511) << 22);
      mag = mag | (0 - 2147483647 - 1);
      unsafe {
        pipe_store_i32_le(out_val as *u8, 0, mag);
      }
      return 2;
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
