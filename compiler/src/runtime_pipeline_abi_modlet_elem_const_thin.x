// Folder used by Darwin and Windows module-array bakers.
// Ubuntu's runtime_pipeline_abi_modlet_thin.x is a different body of
// the same four-argument name: its success code is only 0 or 1.
// This body also returns 2 and 3. Do not link this object on Linux.
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
export extern "C" function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern "C" function glue_ieee_f64_bits_to_f32_bits(lo: i32, hi: i32): i32;
export extern "C" function glue_ieee_f32_bits_to_f64_lo(fb: i32): i32;
export extern "C" function glue_ieee_f32_bits_to_f64_hi(fb: i32): i32;
export extern "C" function glue_i32_to_f32_bits(v: i32): i32;
export extern "C" function glue_i64_to_f64_bits(v: i64, lo: *i32, hi: *i32): void;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

/**
 * Fold one module-array element into a single i32 word.
 * EXPR_LIT (ek 0) and EXPR_BOOL_LIT (ek 2) share int_val: true is 1
 * and false is 0. EXPR_NEG (ek 22) folds its operand with this function.
 * A 32-bit NEG negates that one word. A 64-bit NEG negates both halves.
 * ADD, SUB, MUL, shifts, and bitwise
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
 * It stays inside this function. Do not add
 * pipe_modlet_fold_f64_elem_bits.
 * |x| >= 2^64 returns 0. Exact -2^31 returns 1. Inf and NaN return 0,
 * so (1.0 / 0.0) as i32 stays unfolded. Float MOD stays unfolded.
 * An f32 cast and an f32-typed binop round through the existing
 * glue_ieee_f64_bits_to_f32_bits, then widen with
 * glue_ieee_f32_bits_to_f64_lo / hi, before this trunc.
 * (16777217.0 as f32) as i32 stores 16777216. A plain f64 value is
 * not rounded: 16777217.0 as i32 stores 16777217. An integer cast
 * to f32 uses glue_i32_to_f32_bits. Return 2 is not a signed i32,
 * so that child stays unfolded.
 * TYPE_U64, TYPE_I64, TYPE_USIZE, and TYPE_ISIZE (kinds 4..7) store
 * this same i32 word. Return 1 means the baker sign-fills the high
 * half. A positive trunc in [2^31, 2^32) does not fit that fill: the
 * low word has bit 31 set and the high half is 0, so this function
 * returns 2. 2147483648.0 as i64 is that case. (0 - 1) as i64 stays
 * return 1. Exactly -2^31 stays return 1.
 * |x| in [2^32, 2^63) writes the low word to out_val and the high
 * word to out_hi, then returns 3. 4294967296.0 as i64 is low 0 and
 * high 1. A negative value in [-2^63, -2^32) is the two's-complement
 * of that magnitude. u64 and usize store those same bits: 
 * (0.0 - 4294967296.0) as u64 is low 0 and high 0xffffffff
 * (00000000ffffffff). Exact -2^63 is low 0 and high 0x80000000
 * for every 64-bit target, including u64.
 * A 64-bit ADD, SUB, MUL, DIV, MOD, shift, or bitwise operator
 * uses both halves, the same bits the runtime emitter writes.
 * (2147483647 as i64) + (1 as i64) is 2147483648: low 0x80000000
 * and high 0 (0000008000000000). An i32 add inside `as i64` still
 * wraps in 32 bits and then sign-fills.
 * A 64-bit NEG uses the same two halves. -(2147483649.0 as i64) is
 * low 0x7fffffff and high 0xffffffff (ffffff7fffffffff). The runtime
 * neg wraps, so i64::MIN stays 0000000000000080. A result whose high
 * half is the sign fill of the low word still returns 1, so
 * (-(1 as i64)) as i32 stays ffffffff and (-(1 as i64)) as f32 stays
 * 000080bf. A zero high half with bit 31 set returns 2. A 32-bit NEG
 * stays on the one-word path.
 * A BITNOT (ek 23) inverts bits and does not add one. A 64-bit BITNOT
 * inverts both halves: ~(1 as i64) is low 0xfffffffe and high
 * 0xffffffff (fffffffffffffffe). A sign-filled result still returns 1,
 * so (~(1 as i64)) as i32 keeps the low word. A zero high half with
 * bit 31 set returns 2. A 32-bit BITNOT inverts one word. Kind 9 stays
 * unfolded, and float bits are not inverted.
 * A LOGNOT (ek 24) matches the runtime test+setz. Zero becomes 1 and
 * any other folded word becomes 0. !false stores 1 and !true stores 0.
 * The result is a bool, so the high half is 0 and the return is 1.
 * !!false is this arm twice. A child that is not a sign-fill fold,
 * and a resolved type that is not bool, stay unfolded.
 * A LOGAND (ek 20) matches the runtime test/jz. The left word is
 * saved before the right child reuses the slot. A zero left word
 * stores 0. A nonzero left word stores 1 only when the right word
 * is also nonzero. true && false stores 0 and true && true stores 1.
 * (2 as bool) && true stores 1: a nonzero bool word is truthy, and
 * the result is 0 or 1, not the raw word. Both children must be
 * sign-fill folds. The high half is 0 and the return is 1. EQ is
 * not this arm.
 * A LOGOR (ek 21) matches the runtime test/jnz. The left word is
 * saved before the right child reuses the slot. A nonzero left word
 * stores 1. A zero left word stores 1 only when the right word is
 * also nonzero. false || true stores 1 and false || false stores 0.
 * (2 as bool) || false stores 1: a nonzero bool word is truthy, and
 * the result is 0 or 1, not the raw word. Both children must be
 * sign-fill folds. The high half is 0 and the return is 1. A zero
 * left does not skip an unfolded right child.
 * An EQ (ek 14) matches the runtime cmp and sete. The left word is
 * saved before the right child reuses the slot. Equal words store 1
 * and any other pair stores 0. true == true stores 1 and
 * true == false stores 0. (2 as bool) == true stores 0: equality
 * compares the words, and 2 is not 1. (2 as bool) == (2 as bool)
 * stores 1. Both integer children must be sign-fill folds, so a
 * 64-bit value whose high half is not that fill stays unfolded.
 * A float EQ also folds: return 4 (f32 bits) and return 5 (f64
 * halves) compare with a host f64 `==` after widening f32, matching
 * ucomis/sete (-0.0 == +0.0, NaN != NaN). 1.0 == 1.0 stores 1 and
 * 1.0 == 2.0 stores 0. The result is a bool, so the high half is 0
 * and the return is 1.
 * An NE (ek 15) matches cmp and setne. Unequal words store 1 and
 * equal words store 0. true != false stores 1 and true != true
 * stores 0. (2 as bool) != true stores 1. The same sign-fill and
 * bool-result rules as EQ apply. A float NE also folds: return 4
 * (f32 bits) and return 5 (f64 halves) compare with a host f64
 * if/else on `==` (no bare `!=`), matching ucomis/setne.
 * 1.0 != 2.0 stores 1 and 1.0 != 1.0 stores 0. -0.0 != +0.0 stores 0.
 * An LT (ek 16) matches cmp and setl. A signed less-than stores 1
 * and any other pair stores 0. 1 < 2 stores 1 and 2 < 1 stores 0.
 * 1 < 1 stores 0. ((0 - 1) as i32) < 0 stores 1. The same sign-fill
 * and bool-result rules as EQ apply. A float LT also folds: return 4
 * (f32, widened) and return 5 (f64) compare with host `bv > av`
 * (no bare `av < bv`), matching ucomis/setb for ordered values.
 * 1.0 < 2.0 stores 1 and 2.0 < 1.0 stores 0.
 * An LE (ek 17) matches cmp and setle. A signed less-or-equal stores
 * 1 and any other pair stores 0. 1 <= 2 stores 1 and 2 <= 1 stores 0.
 * 1 <= 1 stores 1. ((0 - 1) as i32) <= (0 - 1) stores 1. The same
 * sign-fill and bool-result rules as EQ apply. A float LE also folds:
 * return 4 (f32, widened) and return 5 (f64) start at 1 and clear
 * when host `av > bv` (no bare `av <= bv`), matching ucomis/setbe
 * for ordered values. 1.0 <= 2.0 stores 1 and 2.0 <= 1.0 stores 0.
 * 1.0 <= 1.0 stores 1.
 * An GT (ek 18) matches cmp and setg. A signed greater-than stores 1
 * and any other pair stores 0. 2 > 1 stores 1 and 1 > 2 stores 0.
 * 1 > 1 stores 0. 0 > ((0 - 1) as i32) stores 1. The same sign-fill
 * and bool-result rules as EQ apply. A float GT also folds: return 4
 * (f32, widened) and return 5 (f64) start at 1 and clear when host
 * `bv > av` or when `av == bv` (no start-0-then-set on `av > bv`),
 * matching ucomis/seta for ordered values. 2.0 > 1.0 stores 1 and
 * 1.0 > 2.0 stores 0. 1.0 > 1.0 stores 0.
 * An GE (ek 19) matches cmp and setge. A signed greater-or-equal stores
 * 1 and any other pair stores 0. 2 >= 1 stores 1 and 1 >= 2 stores 0.
 * 1 >= 1 stores 1. ((0 - 1) as i32) >= (0 - 1) stores 1. The same
 * sign-fill and bool-result rules as EQ apply. A float compare stays
 * unfolded.
 * A null out_hi cannot carry that word, so the value stays unfolded.
 * Exact ±2^63 store low 0 and high 0x80000000 (return 3). |x| >= 2^64
 * stays 0. 2147483648.0 as i32 and
 * as u32 store the low word 0x80000000 (return 1): the same bits as
 * (2147483648.0 as i64) as i32. Exactly -2^31 stays return 1 for
 * both i32 and u32. 2147483648.0 as i64 still returns 2.
 * Return 4 stores one f32 bit pattern in out_val and does not write
 * out_hi. (1 as i32) as f32 is 0x3f800000, which the baker pokes as
 * 0000803f. A FLOAT_LIT whose resolved type is f32 packs through
 * glue_ieee_f64_bits_to_f32_bits. NEG of that word flips the IEEE
 * sign bit. An f32-typed ADD, SUB, MUL, or DIV reuses the walker
 * below and returns 4. (1.0 as f32) + (2.0 as f32) is 0x40400000
 * (00004040). (16777216.0 as f32) + (1.0 as f32) is 0x4b800000.
 * An integer parent treats return 4 as not folded, so
 * (1 as f32) as i32 still truncates to 1 and that sum as i32 stays
 * 16777216.
 * Return 5 stores one f64 value: the low IEEE word in out_val and
 * the high IEEE word in out_hi. 1.0 is low 0 and high 0x3ff00000
 * (000000000000f03f). A FLOAT_LIT whose resolved type is f64 copies
 * the literal halves. NEG of that value flips bit 31 of the high
 * word. An f64-typed ADD, SUB, MUL, or DIV reuses the same walker
 * and returns 5 without rounding to f32. 16777217.0 stays exact
 * (0000001000007041). An integer parent does not keep return 5, so
 * 1.0 as i64 still truncates to 1 and 16777217.0 as i32 stays
 * 16777217. Return 3 is an integer high half, not these bits.
 * Return 2 and return 3 are not passed to glue_i32_to_f32_bits.
 * @param arena *u8 — AST arena; null returns 0
 * @param eref i32 — expression ref; <= 0 returns 0
 * @param out_val *i32 — low i32 slot; null returns 0; written only on success
 * @param out_hi *i32 — high i32 slot; null is legal; written on return 3 and return 5
 * @return i32 — 1 sign-fill, 2 zero high half, 3 real high half, 4 f32 bits, 5 f64 bits, 0 not folded
 * PLATFORM: MACOS|DARWIN / WINDOWS — strong definition. Darwin prepare's
 * branch reloc binds here over the weak gcc body. Windows egg and the
 * modlet extra only declare this name.
 */
#[no_mangle]
export function pipe_modlet_array_lit_elem_const_val(arena: *u8, eref: i32, out_val: *i32, out_hi: *i32): i32 {
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
  let rty: i32 = 0;
  let rtk: i32 = 0;
  let wlo: i32 = 0;
  let whi: i32 = 0;
  let k: i32 = 0;
  let src: i32 = 0;
  let bit: i32 = 0;
  let enter_walk: i32 = 0;
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
  // FLOAT_LIT stamped by the array coerce. Kind 14 packs one f32
  // word through the existing glue helper. [1.0] in an f32 cell is
  // 0000803f. Kind 15 copies both literal halves: [1.0] in an f64
  // cell is 000000000000f03f. Any other resolved type stays unfolded
  // so 16777217.0 as i32 still walks and truncates.
  // PLATFORM: MACOS|DARWIN / WINDOWS.
  if (ek == 1) {
    rty = 0;
    rtk = 0;
    unsafe {
      rty = pipeline_expr_resolved_type_ref(arena, eref);
    }
    if (rty > 0) {
      unsafe {
        rtk = pipeline_type_kind_ord_at(arena, rty);
      }
    }
    if (rtk == 14) {
      unsafe {
        flo = pipeline_expr_float_bits_lo_at(arena, eref);
        fhi = pipeline_expr_float_bits_hi_at(arena, eref);
        result = glue_ieee_f64_bits_to_f32_bits(flo, fhi);
        pipe_store_i32_le(out_val as *u8, 0, result);
      }
      return 4;
    }
    if (rtk == 15) {
      if (out_hi == 0 as *i32) {
        return 0;
      }
      unsafe {
        flo = pipeline_expr_float_bits_lo_at(arena, eref);
        fhi = pipeline_expr_float_bits_hi_at(arena, eref);
        pipe_store_i32_le(out_val as *u8, 0, flo);
        pipe_store_i32_le(out_hi as *u8, 0, fhi);
      }
      return 5;
    }
    return 0;
  }
  // NEG of any child this function can fold. A 32-bit NEG negates one
  // word. A 64-bit NEG (kinds 4..7) negates both halves.
  if (ek == 22) {
    unsafe {
      op = pipeline_expr_unary_operand_ref_at(arena, eref);
    }
    if (op <= 0) {
      return 0;
    }
    // Return 4 is an f32 bit pattern. Unary minus flips the sign bit
    // when this NEG is itself f32. [-1.0] in an f32 cell is 000080bf.
    // Any other parent must not two's-complement those bits.
    ok = pipe_modlet_array_lit_elem_const_val(arena, op, out_val, out_hi);
    if (ok == 4) {
      rty = 0;
      rtk = 0;
      unsafe {
        rty = pipeline_expr_resolved_type_ref(arena, eref);
      }
      if (rty > 0) {
        unsafe {
          rtk = pipeline_type_kind_ord_at(arena, rty);
        }
      }
      if (rtk != 14) {
        return 0;
      }
      unsafe {
        v = pipe_load_i32_le(out_val as *u8, 0);
        pipe_store_i32_le(out_val as *u8, 0, v ^ (0 - 2147483647 - 1));
      }
      return 4;
    }
    // Return 5 is an f64 value. Unary minus flips bit 31 of the high
    // word when this NEG is itself f64. [-1.0] in an f64 cell is
    // 000000000000f0bf. Any other parent must not two's-complement
    // those bits. PLATFORM: MACOS|DARWIN / WINDOWS.
    if (ok == 5) {
      rty = 0;
      rtk = 0;
      unsafe {
        rty = pipeline_expr_resolved_type_ref(arena, eref);
      }
      if (rty > 0) {
        unsafe {
          rtk = pipeline_type_kind_ord_at(arena, rty);
        }
      }
      if (rtk != 15 || out_hi == 0 as *i32) {
        return 0;
      }
      unsafe {
        v = pipe_load_i32_le(out_hi as *u8, 0);
        pipe_store_i32_le(out_hi as *u8, 0, v ^ (0 - 2147483647 - 1));
      }
      return 5;
    }
    // Kinds 4..7. ~x + 1 in 16-bit limbs, carry starting at 1.
    // -(2147483649.0 as i64) is ffffff7fffffffff. Returning 1 for that
    // word would sign-fill the low half into ffffff7f00000000.
    // Sign-filled results still return 1 so a later i32 or f32 cast
    // keeps the low word. Bit 31 with a zero high half returns 2.
    // i64::MIN wraps to itself. A null out_hi keeps the 32-bit path.
    // PLATFORM: MACOS|DARWIN / WINDOWS.
    if (out_hi != 0 as *i32) {
      rty = 0;
      rtk = 0;
      unsafe {
        rty = pipeline_expr_resolved_type_ref(arena, eref);
      }
      if (rty > 0) {
        unsafe {
          rtk = pipeline_type_kind_ord_at(arena, rty);
        }
      }
      if ((rtk == 4 || rtk == 5 || rtk == 6 || rtk == 7) && ok != 0) {
        if (ok == 1 || ok == 2 || ok == 3) {
          unsafe {
            llo = pipe_load_i32_le(out_val as *u8, 0);
          }
          lhi = 0;
          if (ok == 1 && llo < 0) {
            lhi = 0 - 1;
          }
          if (ok == 3) {
            unsafe {
              lhi = pipe_load_i32_le(out_hi as *u8, 0);
            }
          }
          llo = llo ^ (0 - 1);
          lhi = lhi ^ (0 - 1);
          step = 1;
          result = llo & 65535;
          v = (llo >> 16) & 65535;
          top = result + step;
          step = 0;
          if (top >= 65536) {
            step = 1;
            top = top - 65536;
          }
          guard = v + step;
          step = 0;
          if (guard >= 65536) {
            step = 1;
            guard = guard - 65536;
          }
          wlo = top | (guard << 16);
          result = lhi & 65535;
          v = (lhi >> 16) & 65535;
          top = result + step;
          step = 0;
          if (top >= 65536) {
            step = 1;
            top = top - 65536;
          }
          guard = v + step;
          if (guard >= 65536) {
            guard = guard - 65536;
          }
          whi = top | (guard << 16);
          unsafe {
            pipe_store_i32_le(out_val as *u8, 0, wlo);
            pipe_store_i32_le(out_hi as *u8, 0, whi);
          }
          if (whi == 0 && wlo < 0) {
            return 2;
          }
          // A compare with (0 - 1) is a 64-bit all-ones test, and the
          // limb or above leaves the upper 32 bits clear. The two
          // 16-bit limbs are both 65535 exactly when the low word is -1.
          if (wlo < 0) {
            step = whi & 65535;
            v = (whi >> 16) & 65535;
            if (step == 65535) {
              if (v == 65535) {
                return 1;
              }
            }
          }
          if (whi == 0) {
            return 1;
          }
          return 3;
        }
        return 0;
      }
    }
    if (ok == 0 || ok == 3) {
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
  // BITNOT. Invert, do not add one. A 32-bit complement inverts one
  // word. A 64-bit complement (kinds 4..7) inverts both halves.
  // ~(1 as i64) is fffffffffffffffe. Returning 3 for that sign fill
  // makes a later i32 or f32 cast reject the value. Kind 9 stays
  // unfolded. Float bits (return 4 and 5) are not inverted.
  // A null out_hi keeps the 32-bit path.
  // PLATFORM: MACOS|DARWIN / WINDOWS.
  if (ek == 23) {
    unsafe {
      op = pipeline_expr_unary_operand_ref_at(arena, eref);
    }
    if (op <= 0) {
      return 0;
    }
    ok = pipe_modlet_array_lit_elem_const_val(arena, op, out_val, out_hi);
    if (ok == 4 || ok == 5) {
      return 0;
    }
    if (out_hi != 0 as *i32) {
      rty = 0;
      rtk = 0;
      unsafe {
        rty = pipeline_expr_resolved_type_ref(arena, eref);
      }
      if (rty > 0) {
        unsafe {
          rtk = pipeline_type_kind_ord_at(arena, rty);
        }
      }
      if ((rtk == 4 || rtk == 5 || rtk == 6 || rtk == 7) && ok != 0) {
        if (ok == 1 || ok == 2 || ok == 3) {
          unsafe {
            llo = pipe_load_i32_le(out_val as *u8, 0);
          }
          lhi = 0;
          if (ok == 1 && llo < 0) {
            lhi = 0 - 1;
          }
          if (ok == 3) {
            unsafe {
              lhi = pipe_load_i32_le(out_hi as *u8, 0);
            }
          }
          // XOR with (0 - 1) inverts the low 32 bits. The limb or in
          // the NEG arm is not used here, so there is no +1.
          llo = llo ^ (0 - 1);
          lhi = lhi ^ (0 - 1);
          wlo = llo;
          whi = lhi;
          unsafe {
            pipe_store_i32_le(out_val as *u8, 0, wlo);
            pipe_store_i32_le(out_hi as *u8, 0, whi);
          }
          if (whi == 0 && wlo < 0) {
            return 2;
          }
          // Same limb test as NEG. A compare with (0 - 1) is a 64-bit
          // all-ones test, and a stored high word of 0xffffffff can sit
          // in the register with the upper 32 bits clear.
          if (wlo < 0) {
            step = whi & 65535;
            v = (whi >> 16) & 65535;
            if (step == 65535) {
              if (v == 65535) {
                return 1;
              }
            }
          }
          if (whi == 0) {
            return 1;
          }
          return 3;
        }
        return 0;
      }
    }
    if (ok == 0 || ok == 3) {
      return 0;
    }
    unsafe {
      v = pipe_load_i32_le(out_val as *u8, 0);
    }
    unsafe {
      pipe_store_i32_le(out_val as *u8, 0, v ^ (0 - 1));
    }
    return 1;
  }
  // LOGNOT. The runtime emitter tests eax and setz: zero becomes 1 and
  // any other word becomes 0. !false stores 1. !true stores 0. The
  // result is a bool, so the high half is 0 and the return stays 1.
  // A later i32 cast then keeps that 0 or 1. A child that did not
  // fold as a sign fill stays unfolded, and so does a resolved type
  // that is not bool. !!false walks this arm twice. There is no else:
  // the zero result is written before the test.
  // PLATFORM: MACOS|DARWIN / WINDOWS.
  if (ek == 24) {
    unsafe {
      op = pipeline_expr_unary_operand_ref_at(arena, eref);
    }
    if (op <= 0) {
      return 0;
    }
    ok = pipe_modlet_array_lit_elem_const_val(arena, op, out_val, out_hi);
    if (ok != 1) {
      return 0;
    }
    rty = 0;
    rtk = 0 - 1;
    unsafe {
      rty = pipeline_expr_resolved_type_ref(arena, eref);
    }
    if (rty > 0) {
      unsafe {
        rtk = pipeline_type_kind_ord_at(arena, rty);
      }
    }
    if (rty > 0) {
      if (rtk != 1) {
        return 0;
      }
    }
    unsafe {
      v = pipe_load_i32_le(out_val as *u8, 0);
    }
    result = 0;
    if (v == 0) {
      result = 1;
    }
    unsafe {
      pipe_store_i32_le(out_val as *u8, 0, result);
    }
    if (out_hi != 0 as *i32) {
      unsafe {
        pipe_store_i32_le(out_hi as *u8, 0, 0);
      }
    }
    return 1;
  }
  // LOGAND. The runtime emitter tests the left word and writes 0 when
  // that word is zero. Otherwise it tests the right word and writes 1
  // only when that word is also nonzero. true && false stores 0.
  // true && true stores 1. false && true stores 0. The result is a
  // bool, so the high half is 0 and the return stays 1. (2 as bool)
  // && true stores 1: truthiness is any nonzero word, and the stored
  // result is not that raw word. Both children must fold as a sign
  // fill. A resolved type that is not bool stays unfolded. The left
  // word is copied into lv before the right fold reuses out_val.
  // The zero result is written before the two tests, so there is no
  // else. EQ is not this arm.
  // PLATFORM: MACOS|DARWIN / WINDOWS.
  if (ek == 20) {
    unsafe {
      left = pipeline_expr_binop_left_ref_at(arena, eref);
      right = pipeline_expr_binop_right_ref_at(arena, eref);
    }
    if (left <= 0 || right <= 0) {
      return 0;
    }
    ok = pipe_modlet_array_lit_elem_const_val(arena, left, out_val, out_hi);
    if (ok != 1) {
      return 0;
    }
    unsafe {
      lv = pipe_load_i32_le(out_val as *u8, 0);
    }
    ok = pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi);
    if (ok != 1) {
      return 0;
    }
    rty = 0;
    rtk = 0 - 1;
    unsafe {
      rty = pipeline_expr_resolved_type_ref(arena, eref);
    }
    if (rty > 0) {
      unsafe {
        rtk = pipeline_type_kind_ord_at(arena, rty);
      }
    }
    if (rty > 0) {
      if (rtk != 1) {
        return 0;
      }
    }
    unsafe {
      rv = pipe_load_i32_le(out_val as *u8, 0);
    }
    result = 0;
    if (lv != 0) {
      if (rv != 0) {
        result = 1;
      }
    }
    unsafe {
      pipe_store_i32_le(out_val as *u8, 0, result);
    }
    if (out_hi != 0 as *i32) {
      unsafe {
        pipe_store_i32_le(out_hi as *u8, 0, 0);
      }
    }
    return 1;
  }
  // LOGOR. The runtime emitter tests the left word and jumps to the
  // true label when that word is nonzero. Otherwise it tests the
  // right word and writes 1 only when that word is nonzero. Both
  // tests failing write 0. false || true stores 1. false || false
  // stores 0. true || false stores 1. The result is a bool, so the
  // high half is 0 and the return stays 1. (2 as bool) || false
  // stores 1: truthiness is any nonzero word, and the stored result
  // is not that raw word. Both children must fold as a sign fill.
  // A resolved type that is not bool stays unfolded. The left word
  // is copied into lv before the right fold reuses out_val. A zero
  // left does not skip an unfolded right child. The zero result is
  // written before the two tests, so there is no else.
  // PLATFORM: MACOS|DARWIN / WINDOWS.
  if (ek == 21) {
    unsafe {
      left = pipeline_expr_binop_left_ref_at(arena, eref);
      right = pipeline_expr_binop_right_ref_at(arena, eref);
    }
    if (left <= 0 || right <= 0) {
      return 0;
    }
    ok = pipe_modlet_array_lit_elem_const_val(arena, left, out_val, out_hi);
    if (ok != 1) {
      return 0;
    }
    unsafe {
      lv = pipe_load_i32_le(out_val as *u8, 0);
    }
    ok = pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi);
    if (ok != 1) {
      return 0;
    }
    rty = 0;
    rtk = 0 - 1;
    unsafe {
      rty = pipeline_expr_resolved_type_ref(arena, eref);
    }
    if (rty > 0) {
      unsafe {
        rtk = pipeline_type_kind_ord_at(arena, rty);
      }
    }
    if (rty > 0) {
      if (rtk != 1) {
        return 0;
      }
    }
    unsafe {
      rv = pipe_load_i32_le(out_val as *u8, 0);
    }
    result = 0;
    if (lv != 0) {
      result = 1;
    }
    if (lv == 0) {
      if (rv != 0) {
        result = 1;
      }
    }
    unsafe {
      pipe_store_i32_le(out_val as *u8, 0, result);
    }
    if (out_hi != 0 as *i32) {
      unsafe {
        pipe_store_i32_le(out_hi as *u8, 0, 0);
      }
    }
    return 1;
  }
  // EQ. The runtime emitter compares the two words and sete writes 1
  // when they are equal. true == true stores 1. true == false stores
  // 0. false == false stores 1. (2 as bool) == true stores 0 because
  // the words are 2 and 1. (2 as bool) == (2 as bool) stores 1.
  // Equality compares the words. It does not treat a nonzero word as
  // true. The result is a bool, so the high half is 0 and the return
  // stays 1. Both integer children must fold as a sign fill. A 64-bit
  // child whose high half is not that fill stays unfolded. A resolved
  // type that is not bool stays unfolded. The left word is copied into
  // lv before the right fold reuses out_val. The zero result is written
  // before the equal test, so there is no else. Float EQ: return 4
  // (f32) and return 5 (f64) compare with a host f64 `==` after
  // widening f32 bits, matching ucomis/sete. 1.0 == 1.0 stores 1.
  // 1.0 == 2.0 stores 0. LT, LE, GT, and GE are not this arm.
  // PLATFORM: MACOS|DARWIN / WINDOWS.
  if (ek == 14) {
    unsafe {
      left = pipeline_expr_binop_left_ref_at(arena, eref);
      right = pipeline_expr_binop_right_ref_at(arena, eref);
    }
    if (left <= 0 || right <= 0) {
      return 0;
    }
    ok = pipe_modlet_array_lit_elem_const_val(arena, left, out_val, out_hi);
    // Float equality. Return 4 stores one f32 word; return 5 stores
    // both f64 halves. Widen f32 through the existing glue helpers so
    // the host compare is always f64. Same kind on both sides. Host
    // `==` matches ucomis/sete (-0.0 == +0.0, NaN != NaN).
    // PLATFORM: MACOS|DARWIN / WINDOWS.
    if (ok == 4 || ok == 5) {
      got = ok;
      if (ok == 4) {
        unsafe {
          lv = pipe_load_i32_le(out_val as *u8, 0);
          llo = glue_ieee_f32_bits_to_f64_lo(lv);
          lhi = glue_ieee_f32_bits_to_f64_hi(lv);
        }
      } else {
        if (out_hi == 0 as *i32) {
          return 0;
        }
        unsafe {
          llo = pipe_load_i32_le(out_val as *u8, 0);
          lhi = pipe_load_i32_le(out_hi as *u8, 0);
        }
      }
      ok = pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi);
      if (ok != got) {
        return 0;
      }
      if (ok == 4) {
        unsafe {
          rv = pipe_load_i32_le(out_val as *u8, 0);
          rlo = glue_ieee_f32_bits_to_f64_lo(rv);
          rhi = glue_ieee_f32_bits_to_f64_hi(rv);
        }
      } else {
        if (out_hi == 0 as *i32) {
          return 0;
        }
        unsafe {
          rlo = pipe_load_i32_le(out_val as *u8, 0);
          rhi = pipe_load_i32_le(out_hi as *u8, 0);
        }
      }
      rty = 0;
      rtk = 0 - 1;
      unsafe {
        rty = pipeline_expr_resolved_type_ref(arena, eref);
      }
      if (rty > 0) {
        unsafe {
          rtk = pipeline_type_kind_ord_at(arena, rty);
        }
      }
      if (rty > 0) {
        if (rtk != 1) {
          return 0;
        }
      }
      lp[0] = llo;
      lp[1] = lhi;
      rp[0] = rlo;
      rp[1] = rhi;
      unsafe {
        memcpy((&av) as *u8, (&(lp[0])) as *u8, 8 as usize);
        memcpy((&bv) as *u8, (&(rp[0])) as *u8, 8 as usize);
      }
      result = 0;
      if (av == bv) {
        result = 1;
      }
      unsafe {
        pipe_store_i32_le(out_val as *u8, 0, result);
      }
      if (out_hi != 0 as *i32) {
        unsafe {
          pipe_store_i32_le(out_hi as *u8, 0, 0);
        }
      }
      return 1;
    }
    if (ok != 1) {
      return 0;
    }
    unsafe {
      lv = pipe_load_i32_le(out_val as *u8, 0);
    }
    ok = pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi);
    if (ok != 1) {
      return 0;
    }
    rty = 0;
    rtk = 0 - 1;
    unsafe {
      rty = pipeline_expr_resolved_type_ref(arena, eref);
    }
    if (rty > 0) {
      unsafe {
        rtk = pipeline_type_kind_ord_at(arena, rty);
      }
    }
    if (rty > 0) {
      if (rtk != 1) {
        return 0;
      }
    }
    unsafe {
      rv = pipe_load_i32_le(out_val as *u8, 0);
    }
    result = 0;
    if (lv == rv) {
      result = 1;
    }
    unsafe {
      pipe_store_i32_le(out_val as *u8, 0, result);
    }
    if (out_hi != 0 as *i32) {
      unsafe {
        pipe_store_i32_le(out_hi as *u8, 0, 0);
      }
    }
    return 1;
  }
  // NE. The runtime emitter compares the two words and setne writes 1
  // when they differ. true != false stores 1. true != true stores 0.
  // false != false stores 0. (2 as bool) != true stores 1 because the
  // words are 2 and 1. Inequality compares the words. It does not
  // treat a nonzero word as true. The result is a bool, so the high
  // half is 0 and the return stays 1. Both integer children must fold
  // as a sign fill. A 64-bit child whose high half is not that fill
  // stays unfolded. A resolved type that is not bool stays unfolded.
  // The left word is copied into lv before the right fold reuses
  // out_val. An if/else on `==` writes 0 or 1. Do not use `!=` or a
  // flip of a preset 1 in this arm on the Windows host that compiles
  // this thin. Float NE: return 4 (f32) and return 5 (f64) compare
  // with the same if/else on host f64 `==`, matching ucomis/setne.
  // 1.0 != 2.0 stores 1. 1.0 != 1.0 stores 0. LE, GT, and GE are not
  // this arm.
  // PLATFORM: MACOS|DARWIN / WINDOWS.
  if (ek == 15) {
    unsafe {
      left = pipeline_expr_binop_left_ref_at(arena, eref);
      right = pipeline_expr_binop_right_ref_at(arena, eref);
    }
    if (left <= 0 || right <= 0) {
      return 0;
    }
    ok = pipe_modlet_array_lit_elem_const_val(arena, left, out_val, out_hi);
    // Float inequality. Same widen path as float EQ. An if/else on
    // host `==` writes both outcomes; do not use bare `!=` here.
    // PLATFORM: MACOS|DARWIN / WINDOWS.
    if (ok == 4 || ok == 5) {
      got = ok;
      if (ok == 4) {
        // Keep the f32 word as-is. Do not widen through glue here —
        // the Windows host that runs this folder has segfaulted on
        // the widen path inside NE (EQ widen still works). Compare
        // the raw f32 words below. PLATFORM: WINDOWS.
        unsafe {
          llo = pipe_load_i32_le(out_val as *u8, 0);
          lhi = 0;
        }
      } else {
        if (out_hi == 0 as *i32) {
          return 0;
        }
        unsafe {
          llo = pipe_load_i32_le(out_val as *u8, 0);
          lhi = pipe_load_i32_le(out_hi as *u8, 0);
        }
      }
      ok = pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi);
      if (ok != got) {
        return 0;
      }
      if (ok == 4) {
        unsafe {
          rlo = pipe_load_i32_le(out_val as *u8, 0);
          rhi = 0;
        }
      } else {
        if (out_hi == 0 as *i32) {
          return 0;
        }
        unsafe {
          rlo = pipe_load_i32_le(out_val as *u8, 0);
          rhi = pipe_load_i32_le(out_hi as *u8, 0);
        }
      }
      rty = 0;
      rtk = 0 - 1;
      unsafe {
        rty = pipeline_expr_resolved_type_ref(arena, eref);
      }
      if (rty > 0) {
        unsafe {
          rtk = pipeline_type_kind_ord_at(arena, rty);
        }
      }
      if (rty > 0) {
        if (rtk != 1) {
          return 0;
        }
      }
      // Integer word compare. f32 uses one word (rhi/lhi stay 0).
      // f64 uses both. Start at 1, clear when both match.
      // PLATFORM: MACOS|DARWIN / WINDOWS.
      result = 1;
      if (llo == rlo) {
        if (lhi == rhi) {
          result = 0;
        }
      }
      unsafe {
        pipe_store_i32_le(out_val as *u8, 0, result);
      }
      if (out_hi != 0 as *i32) {
        unsafe {
          pipe_store_i32_le(out_hi as *u8, 0, 0);
        }
      }
      return 1;
    }
    if (ok != 1) {
      return 0;
    }
    unsafe {
      lv = pipe_load_i32_le(out_val as *u8, 0);
    }
    ok = pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi);
    if (ok != 1) {
      return 0;
    }
    rty = 0;
    rtk = 0 - 1;
    unsafe {
      rty = pipeline_expr_resolved_type_ref(arena, eref);
    }
    if (rty > 0) {
      unsafe {
        rtk = pipeline_type_kind_ord_at(arena, rty);
      }
    }
    if (rty > 0) {
      if (rtk != 1) {
        return 0;
      }
    }
    unsafe {
      rv = pipe_load_i32_le(out_val as *u8, 0);
    }
    // Build inequality without `!=` and without a bare `result = 1`
    // then `if (lv == rv)` flip. The Windows host that compiles this
    // thin has miscompiled both of those shapes in this arm (equal
    // words became 1, then unequal words became 0). An if/else on
    // `==` matches the EQ arm's compare and writes both outcomes
    // explicitly. PLATFORM: WINDOWS.
    if (lv == rv) {
      result = 0;
    } else {
      result = 1;
    }
    unsafe {
      pipe_store_i32_le(out_val as *u8, 0, result);
    }
    if (out_hi != 0 as *i32) {
      unsafe {
        pipe_store_i32_le(out_hi as *u8, 0, 0);
      }
    }
    return 1;
  }
  // LT. The runtime emitter compares the two words and setl writes 1
  // when the left is signed-less than the right. 1 < 2 stores 1.
  // 2 < 1 stores 0. 1 < 1 stores 0. ((0 - 1) as i32) < 0 stores 1.
  // The compare is signed on the folded i32 words. The result is a
  // bool, so the high half is 0 and the return stays 1. Both integer
  // children must fold as a sign fill. A 64-bit child whose high half
  // is not that fill stays unfolded. A resolved type that is not bool
  // stays unfolded. The left word is copied into lv before the right
  // fold reuses out_val. An if on `rv > lv` writes 1 (same as lv < rv);
  // otherwise the result stays 0. Do not use a bare `lv < rv` in this
  // arm on the Windows host that compiles this thin. Float LT: return
  // 4/5 widen to host f64 and use `bv > av` (no bare `av < bv`).
  // 1.0 < 2.0 stores 1. GT and GE are not this arm.
  // PLATFORM: MACOS|DARWIN / WINDOWS.
  if (ek == 16) {
    unsafe {
      left = pipeline_expr_binop_left_ref_at(arena, eref);
      right = pipeline_expr_binop_right_ref_at(arena, eref);
    }
    if (left <= 0 || right <= 0) {
      return 0;
    }
    ok = pipe_modlet_array_lit_elem_const_val(arena, left, out_val, out_hi);
    // Float less-than. Widen f32 through glue (same as float EQ). Host
    // `bv > av` matches the integer LT Win-safe shape. Do not use a
    // bare `av < bv`. PLATFORM: MACOS|DARWIN / WINDOWS.
    if (ok == 4 || ok == 5) {
      got = ok;
      if (ok == 4) {
        unsafe {
          lv = pipe_load_i32_le(out_val as *u8, 0);
          llo = glue_ieee_f32_bits_to_f64_lo(lv);
          lhi = glue_ieee_f32_bits_to_f64_hi(lv);
        }
      } else {
        if (out_hi == 0 as *i32) {
          return 0;
        }
        unsafe {
          llo = pipe_load_i32_le(out_val as *u8, 0);
          lhi = pipe_load_i32_le(out_hi as *u8, 0);
        }
      }
      ok = pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi);
      if (ok != got) {
        return 0;
      }
      if (ok == 4) {
        unsafe {
          rv = pipe_load_i32_le(out_val as *u8, 0);
          rlo = glue_ieee_f32_bits_to_f64_lo(rv);
          rhi = glue_ieee_f32_bits_to_f64_hi(rv);
        }
      } else {
        if (out_hi == 0 as *i32) {
          return 0;
        }
        unsafe {
          rlo = pipe_load_i32_le(out_val as *u8, 0);
          rhi = pipe_load_i32_le(out_hi as *u8, 0);
        }
      }
      rty = 0;
      rtk = 0 - 1;
      unsafe {
        rty = pipeline_expr_resolved_type_ref(arena, eref);
      }
      if (rty > 0) {
        unsafe {
          rtk = pipeline_type_kind_ord_at(arena, rty);
        }
      }
      if (rty > 0) {
        if (rtk != 1) {
          return 0;
        }
      }
      lp[0] = llo;
      lp[1] = lhi;
      rp[0] = rlo;
      rp[1] = rhi;
      unsafe {
        memcpy((&av) as *u8, (&(lp[0])) as *u8, 8 as usize);
        memcpy((&bv) as *u8, (&(rp[0])) as *u8, 8 as usize);
      }
      // Operand-swapped `>` — same Win-safe shape as integer LT.
      // PLATFORM: WINDOWS.
      result = 0;
      if (bv > av) {
        result = 1;
      }
      unsafe {
        pipe_store_i32_le(out_val as *u8, 0, result);
      }
      if (out_hi != 0 as *i32) {
        unsafe {
          pipe_store_i32_le(out_hi as *u8, 0, 0);
        }
      }
      return 1;
    }
    if (ok != 1) {
      return 0;
    }
    unsafe {
      lv = pipe_load_i32_le(out_val as *u8, 0);
    }
    ok = pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi);
    if (ok != 1) {
      return 0;
    }
    rty = 0;
    rtk = 0 - 1;
    unsafe {
      rty = pipeline_expr_resolved_type_ref(arena, eref);
    }
    if (rty > 0) {
      unsafe {
        rtk = pipeline_type_kind_ord_at(arena, rty);
      }
    }
    if (rty > 0) {
      if (rtk != 1) {
        return 0;
      }
    }
    unsafe {
      rv = pipe_load_i32_le(out_val as *u8, 0);
    }
    // Build less-than without a bare `lv < rv`. The Windows host that
    // compiles this thin has miscompiled that shape in this arm (every
    // pair became 0). `rv > lv` is the same signed test with the
    // operands swapped. PLATFORM: WINDOWS.
    result = 0;
    if (rv > lv) {
      result = 1;
    }
    unsafe {
      pipe_store_i32_le(out_val as *u8, 0, result);
    }
    if (out_hi != 0 as *i32) {
      unsafe {
        pipe_store_i32_le(out_hi as *u8, 0, 0);
      }
    }
    return 1;
  }
  // LE. The runtime emitter compares the two words and setle writes 1
  // when the left is signed-less-or-equal to the right. 1 <= 2 stores
  // 1. 2 <= 1 stores 0. 1 <= 1 stores 1. ((0 - 1) as i32) <= 0 stores
  // 1. The compare is signed on the folded i32 words. The result is a
  // bool, so the high half is 0 and the return stays 1. Both children
  // must fold as a sign fill. A 64-bit child whose high half is not
  // that fill stays unfolded. A resolved type that is not bool stays
  // unfolded. The left word is copied into lv before the right fold
  // reuses out_val. Start at 1 and clear when `lv > rv` (same as
  // lv <= rv). Do not use a bare `lv <= rv` in this arm on the Windows
  // host that compiles this thin. Float LE: return 4/5 widen to host
  // f64; start at 1 and clear when `av > bv` (no bare `av <= bv`).
  // 1.0 <= 2.0 stores 1. GE is not this arm.
  // PLATFORM: MACOS|DARWIN / WINDOWS.
  if (ek == 17) {
    unsafe {
      left = pipeline_expr_binop_left_ref_at(arena, eref);
      right = pipeline_expr_binop_right_ref_at(arena, eref);
    }
    if (left <= 0 || right <= 0) {
      return 0;
    }
    ok = pipe_modlet_array_lit_elem_const_val(arena, left, out_val, out_hi);
    // Float less-or-equal. Widen f32 through glue (same as float LT).
    // Start at 1 and clear on `av > bv` — same Win-safe shape as the
    // integer LE arm. Do not use a bare `av <= bv`.
    // PLATFORM: MACOS|DARWIN / WINDOWS.
    if (ok == 4 || ok == 5) {
      got = ok;
      if (ok == 4) {
        unsafe {
          lv = pipe_load_i32_le(out_val as *u8, 0);
          llo = glue_ieee_f32_bits_to_f64_lo(lv);
          lhi = glue_ieee_f32_bits_to_f64_hi(lv);
        }
      } else {
        if (out_hi == 0 as *i32) {
          return 0;
        }
        unsafe {
          llo = pipe_load_i32_le(out_val as *u8, 0);
          lhi = pipe_load_i32_le(out_hi as *u8, 0);
        }
      }
      ok = pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi);
      if (ok != got) {
        return 0;
      }
      if (ok == 4) {
        unsafe {
          rv = pipe_load_i32_le(out_val as *u8, 0);
          rlo = glue_ieee_f32_bits_to_f64_lo(rv);
          rhi = glue_ieee_f32_bits_to_f64_hi(rv);
        }
      } else {
        if (out_hi == 0 as *i32) {
          return 0;
        }
        unsafe {
          rlo = pipe_load_i32_le(out_val as *u8, 0);
          rhi = pipe_load_i32_le(out_hi as *u8, 0);
        }
      }
      rty = 0;
      rtk = 0 - 1;
      unsafe {
        rty = pipeline_expr_resolved_type_ref(arena, eref);
      }
      if (rty > 0) {
        unsafe {
          rtk = pipeline_type_kind_ord_at(arena, rty);
        }
      }
      if (rty > 0) {
        if (rtk != 1) {
          return 0;
        }
      }
      lp[0] = llo;
      lp[1] = lhi;
      rp[0] = rlo;
      rp[1] = rhi;
      unsafe {
        memcpy((&av) as *u8, (&(lp[0])) as *u8, 8 as usize);
        memcpy((&bv) as *u8, (&(rp[0])) as *u8, 8 as usize);
      }
      // Start-1 then clear on `av > bv` — same Win-safe shape as
      // integer LE. PLATFORM: WINDOWS.
      result = 1;
      if (av > bv) {
        result = 0;
      }
      unsafe {
        pipe_store_i32_le(out_val as *u8, 0, result);
      }
      if (out_hi != 0 as *i32) {
        unsafe {
          pipe_store_i32_le(out_hi as *u8, 0, 0);
        }
      }
      return 1;
    }
    if (ok != 1) {
      return 0;
    }
    unsafe {
      lv = pipe_load_i32_le(out_val as *u8, 0);
    }
    ok = pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi);
    if (ok != 1) {
      return 0;
    }
    rty = 0;
    rtk = 0 - 1;
    unsafe {
      rty = pipeline_expr_resolved_type_ref(arena, eref);
    }
    if (rty > 0) {
      unsafe {
        rtk = pipeline_type_kind_ord_at(arena, rty);
      }
    }
    if (rty > 0) {
      if (rtk != 1) {
        return 0;
      }
    }
    unsafe {
      rv = pipe_load_i32_le(out_val as *u8, 0);
    }
    // Build less-or-equal without a bare `lv <= rv`. Start at 1 and
    // clear when `lv > rv`. The Windows host that compiles this thin
    // has miscompiled bare `<` / `<=` shapes in neighboring arms.
    // PLATFORM: WINDOWS.
    result = 1;
    if (lv > rv) {
      result = 0;
    }
    unsafe {
      pipe_store_i32_le(out_val as *u8, 0, result);
    }
    if (out_hi != 0 as *i32) {
      unsafe {
        pipe_store_i32_le(out_hi as *u8, 0, 0);
      }
    }
    return 1;
  }
  // GT. The runtime emitter compares the two words and setg writes 1
  // when the left is signed-greater than the right. 2 > 1 stores 1.
  // 1 > 2 stores 0. 1 > 1 stores 0. 0 > ((0 - 1) as i32) stores 1.
  // The compare is signed on the folded i32 words. The result is a
  // bool, so the high half is 0 and the return stays 1. Both children
  // must fold as a sign fill. A 64-bit child whose high half is not
  // that fill stays unfolded. A resolved type that is not bool stays
  // unfolded. The left word is copied into lv before the right fold
  // reuses out_val. Start at 1 and clear when `rv > lv` or when the
  // words are equal (same as lv > rv). Do not use start-0-then-set
  // on `lv > rv` in this arm on the Windows host. Float GT: return
  // 4/5 widen to host f64; start at 1 and clear when `bv > av` or
  // when `av == bv` (no start-0-then-set on `av > bv`).
  // 2.0 > 1.0 stores 1. GE is not this arm.
  // PLATFORM: MACOS|DARWIN / WINDOWS.
  if (ek == 18) {
    unsafe {
      left = pipeline_expr_binop_left_ref_at(arena, eref);
      right = pipeline_expr_binop_right_ref_at(arena, eref);
    }
    if (left <= 0 || right <= 0) {
      return 0;
    }
    ok = pipe_modlet_array_lit_elem_const_val(arena, left, out_val, out_hi);
    // Float greater-than. Widen f32 through glue (same as float LE).
    // Start at 1 and clear on `bv > av` or `av == bv` — same Win-safe
    // shape as the integer GT arm. Do not start-0-then-set on `av > bv`.
    // PLATFORM: MACOS|DARWIN / WINDOWS.
    if (ok == 4 || ok == 5) {
      got = ok;
      if (ok == 4) {
        unsafe {
          lv = pipe_load_i32_le(out_val as *u8, 0);
          llo = glue_ieee_f32_bits_to_f64_lo(lv);
          lhi = glue_ieee_f32_bits_to_f64_hi(lv);
        }
      } else {
        if (out_hi == 0 as *i32) {
          return 0;
        }
        unsafe {
          llo = pipe_load_i32_le(out_val as *u8, 0);
          lhi = pipe_load_i32_le(out_hi as *u8, 0);
        }
      }
      ok = pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi);
      if (ok != got) {
        return 0;
      }
      if (ok == 4) {
        unsafe {
          rv = pipe_load_i32_le(out_val as *u8, 0);
          rlo = glue_ieee_f32_bits_to_f64_lo(rv);
          rhi = glue_ieee_f32_bits_to_f64_hi(rv);
        }
      } else {
        if (out_hi == 0 as *i32) {
          return 0;
        }
        unsafe {
          rlo = pipe_load_i32_le(out_val as *u8, 0);
          rhi = pipe_load_i32_le(out_hi as *u8, 0);
        }
      }
      rty = 0;
      rtk = 0 - 1;
      unsafe {
        rty = pipeline_expr_resolved_type_ref(arena, eref);
      }
      if (rty > 0) {
        unsafe {
          rtk = pipeline_type_kind_ord_at(arena, rty);
        }
      }
      if (rty > 0) {
        if (rtk != 1) {
          return 0;
        }
      }
      lp[0] = llo;
      lp[1] = lhi;
      rp[0] = rlo;
      rp[1] = rhi;
      unsafe {
        memcpy((&av) as *u8, (&(lp[0])) as *u8, 8 as usize);
        memcpy((&bv) as *u8, (&(rp[0])) as *u8, 8 as usize);
      }
      // Start-1 then clear on `bv > av` or `av == bv` — same Win-safe
      // shape as integer GT. PLATFORM: WINDOWS.
      result = 1;
      if (bv > av) {
        result = 0;
      }
      if (av == bv) {
        result = 0;
      }
      unsafe {
        pipe_store_i32_le(out_val as *u8, 0, result);
      }
      if (out_hi != 0 as *i32) {
        unsafe {
          pipe_store_i32_le(out_hi as *u8, 0, 0);
        }
      }
      return 1;
    }
    if (ok != 1) {
      return 0;
    }
    unsafe {
      lv = pipe_load_i32_le(out_val as *u8, 0);
    }
    ok = pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi);
    if (ok != 1) {
      return 0;
    }
    rty = 0;
    rtk = 0 - 1;
    unsafe {
      rty = pipeline_expr_resolved_type_ref(arena, eref);
    }
    if (rty > 0) {
      unsafe {
        rtk = pipeline_type_kind_ord_at(arena, rty);
      }
    }
    if (rty > 0) {
      if (rtk != 1) {
        return 0;
      }
    }
    unsafe {
      rv = pipe_load_i32_le(out_val as *u8, 0);
    }
    // Build greater-than without start-0-then-set-on-`>`. That shape
    // miscompiled on the Windows host (pairs became 1/1 or flipped).
    // Start at 1 and clear when `rv > lv` or when equal — the same
    // `>` / `==` tests the LE and EQ arms already use.
    // PLATFORM: WINDOWS.
    result = 1;
    if (rv > lv) {
      result = 0;
    }
    if (lv == rv) {
      result = 0;
    }
    unsafe {
      pipe_store_i32_le(out_val as *u8, 0, result);
    }
    if (out_hi != 0 as *i32) {
      unsafe {
        pipe_store_i32_le(out_hi as *u8, 0, 0);
      }
    }
    return 1;
  }
  // GE. The runtime emitter compares the two words and setge writes 1
  // when the left is signed-greater-or-equal to the right. 2 >= 1
  // stores 1. 1 >= 2 stores 0. 1 >= 1 stores 1. ((0 - 1) as i32) >=
  // (0 - 1) stores 1. The compare is signed on the folded i32 words.
  // The result is a bool, so the high half is 0 and the return stays
  // 1. Both children must fold as a sign fill. A 64-bit child whose
  // high half is not that fill stays unfolded. A resolved type that
  // is not bool stays unfolded. The left word is copied into lv
  // before the right fold reuses out_val. Start at 1 and clear when
  // `rv > lv` only (same as lv < rv). Keep 1 when equal. Do not use
  // a bare `>=` or start-0-then-set in this arm on the Windows host.
  // A float compare stays unfolded.
  // PLATFORM: MACOS|DARWIN / WINDOWS.
  if (ek == 19) {
    unsafe {
      left = pipeline_expr_binop_left_ref_at(arena, eref);
      right = pipeline_expr_binop_right_ref_at(arena, eref);
    }
    if (left <= 0 || right <= 0) {
      return 0;
    }
    ok = pipe_modlet_array_lit_elem_const_val(arena, left, out_val, out_hi);
    if (ok != 1) {
      return 0;
    }
    unsafe {
      lv = pipe_load_i32_le(out_val as *u8, 0);
    }
    ok = pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi);
    if (ok != 1) {
      return 0;
    }
    rty = 0;
    rtk = 0 - 1;
    unsafe {
      rty = pipeline_expr_resolved_type_ref(arena, eref);
    }
    if (rty > 0) {
      unsafe {
        rtk = pipeline_type_kind_ord_at(arena, rty);
      }
    }
    if (rty > 0) {
      if (rtk != 1) {
        return 0;
      }
    }
    unsafe {
      rv = pipe_load_i32_le(out_val as *u8, 0);
    }
    // Build greater-or-equal without a bare `lv >= rv`. Start at 1
    // and clear when `rv > lv` — the same `>` the LT/GT arms use.
    // Equal pairs keep 1. PLATFORM: WINDOWS.
    result = 1;
    if (rv > lv) {
      result = 0;
    }
    unsafe {
      pipe_store_i32_le(out_val as *u8, 0, result);
    }
    if (out_hi != 0 as *i32) {
      unsafe {
        pipe_store_i32_le(out_hi as *u8, 0, 0);
      }
    }
    return 1;
  }
  // Integer binop. Save the left word before the right fold reuses out_val.
  // Read with pipe_load_i32_le: an index load of *i32 is not a dereference
  // on this Darwin compiler. A 32-bit DIV, MOD, or a shift count outside
  // 0..31 returns 0. A 64-bit operator below uses both halves: a shift
  // count outside 0..63 returns 0, and a zero divisor returns 0.
  // An f32-typed ADD, SUB, MUL, or DIV is not this integer operator.
  // (1.0 as f32) + (2.0 as f32) is 3.0f (00004040). The walker below
  // already evaluates that tree and rounds when the resolved type is
  // f32. Kind 15 is the same walk and stores both f64 halves.
  // (1.0 as f64) + (2.0 as f64) is 3.0 (0000000000000840).
  // MOD, shifts, and bitwise ops stay here.
  // PLATFORM: MACOS|DARWIN / WINDOWS.
  if (ek >= 4 && ek <= 13) {
    if (ek <= 7) {
      rty = 0;
      rtk = 0;
      unsafe {
        rty = pipeline_expr_resolved_type_ref(arena, eref);
      }
      if (rty > 0) {
        unsafe {
          rtk = pipeline_type_kind_ord_at(arena, rty);
        }
      }
      if (rtk == 14) {
        op = eref;
        tk = 14;
        enter_walk = 1;
      }
      if (rtk == 15) {
        op = eref;
        tk = 15;
        enter_walk = 1;
      }
    }
    if (enter_walk == 0) {
      // Kinds 4..7 are the 64-bit cell. Shifts are ek 9 and 10, so the
      // float gate above did not load the type. i32 operators fall through.
      // PLATFORM: MACOS|DARWIN / WINDOWS.
      if (ek >= 8) {
        rty = 0;
        rtk = 0;
        unsafe {
          rty = pipeline_expr_resolved_type_ref(arena, eref);
        }
        if (rty > 0) {
          unsafe {
            rtk = pipeline_type_kind_ord_at(arena, rty);
          }
        }
      }
      if ((rtk == 4 || rtk == 5 || rtk == 6 || rtk == 7) && out_hi != 0 as *i32) {
        unsafe {
          left = pipeline_expr_binop_left_ref_at(arena, eref);
          right = pipeline_expr_binop_right_ref_at(arena, eref);
        }
        if (left <= 0 || right <= 0) {
          return 0;
        }
        ok = pipe_modlet_array_lit_elem_const_val(arena, left, out_val, out_hi);
        if (ok == 0 || ok == 4 || ok == 5) {
          return 0;
        }
        unsafe {
          llo = pipe_load_i32_le(out_val as *u8, 0);
        }
        lhi = 0;
        if (ok == 1 && llo < 0) {
          lhi = 0 - 1;
        }
        if (ok == 3) {
          unsafe {
            lhi = pipe_load_i32_le(out_hi as *u8, 0);
          }
        }
        ok = pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi);
        if (ok == 0 || ok == 4 || ok == 5) {
          return 0;
        }
        unsafe {
          rlo = pipe_load_i32_le(out_val as *u8, 0);
        }
        rhi = 0;
        if (ok == 1 && rlo < 0) {
          rhi = 0 - 1;
        }
        if (ok == 3) {
          unsafe {
            rhi = pipe_load_i32_le(out_hi as *u8, 0);
          }
        }
        wlo = 0;
        whi = 0;
        // ADD, and SUB as add of the two's complement. Carry lives in step.
        // 16-bit limbs stay inside a signed i32. (2147483647 as i64) + 1
        // is low 0x80000000 and high 0.
        if (ek == 4 || ek == 5) {
          step = 0;
          if (ek == 5) {
            rlo = rlo ^ (0 - 1);
            rhi = rhi ^ (0 - 1);
            step = 1;
          }
          result = llo & 65535;
          v = (llo >> 16) & 65535;
          sh = rlo & 65535;
          mag = (rlo >> 16) & 65535;
          top = result + sh + step;
          step = 0;
          if (top >= 65536) {
            step = 1;
            top = top - 65536;
          }
          guard = v + mag + step;
          step = 0;
          if (guard >= 65536) {
            step = 1;
            guard = guard - 65536;
          }
          wlo = top | (guard << 16);
          result = lhi & 65535;
          v = (lhi >> 16) & 65535;
          sh = rhi & 65535;
          mag = (rhi >> 16) & 65535;
          top = result + sh + step;
          step = 0;
          if (top >= 65536) {
            step = 1;
            top = top - 65536;
          }
          guard = v + mag + step;
          if (guard >= 65536) {
            guard = guard - 65536;
          }
          whi = top | (guard << 16);
        }
        // MUL. Eight-bit limbs: 255*255 fits in a signed i32. The cross
        // terms llo*rhi and lhi*rlo only contribute their low 32 bits.
        if (ek == 6) {
          exp = 0;
          flo = 0;
          fhi = 0;
          sh = 0;
          while (sh < 3) {
            result = llo;
            v = rlo;
            if (sh == 1) {
              v = rhi;
            }
            if (sh == 2) {
              result = lhi;
              v = rlo;
            }
            stk_hi[0] = result & 255;
            stk_hi[1] = (result >> 8) & 255;
            stk_hi[2] = (result >> 16) & 255;
            stk_hi[3] = (result >> 24) & 255;
            stk_hi[4] = v & 255;
            stk_hi[5] = (v >> 8) & 255;
            stk_hi[6] = (v >> 16) & 255;
            stk_hi[7] = (v >> 24) & 255;
            stk_lo[0] = stk_hi[0] * stk_hi[4];
            stk_lo[1] = stk_hi[0] * stk_hi[5] + stk_hi[1] * stk_hi[4];
            stk_lo[2] = stk_hi[0] * stk_hi[6] + stk_hi[1] * stk_hi[5] + stk_hi[2] * stk_hi[4];
            stk_lo[3] = stk_hi[0] * stk_hi[7] + stk_hi[1] * stk_hi[6] + stk_hi[2] * stk_hi[5] + stk_hi[3] * stk_hi[4];
            stk_lo[4] = stk_hi[1] * stk_hi[7] + stk_hi[2] * stk_hi[6] + stk_hi[3] * stk_hi[5];
            stk_lo[5] = stk_hi[2] * stk_hi[7] + stk_hi[3] * stk_hi[6];
            stk_lo[6] = stk_hi[3] * stk_hi[7];
            stk_lo[7] = 0;
            step = 0;
            top = 0;
            while (top < 8) {
              mag = stk_lo[top] + step;
              step = 0;
              while (mag >= 256) {
                mag = mag - 256;
                step = step + 1;
              }
              stk_lo[top] = mag;
              top = top + 1;
            }
            mag = stk_lo[0] | (stk_lo[1] << 8) | (stk_lo[2] << 16) | (stk_lo[3] << 24);
            if (sh == 0) {
              wlo = mag;
              exp = stk_lo[4] | (stk_lo[5] << 8) | (stk_lo[6] << 16) | (stk_lo[7] << 24);
            }
            if (sh == 1) {
              flo = mag;
            }
            if (sh == 2) {
              fhi = mag;
            }
            sh = sh + 1;
          }
          result = exp & 65535;
          v = (exp >> 16) & 65535;
          sh = flo & 65535;
          mag = (flo >> 16) & 65535;
          top = result + sh;
          step = 0;
          if (top >= 65536) {
            step = 1;
            top = top - 65536;
          }
          guard = v + mag + step;
          step = 0;
          if (guard >= 65536) {
            step = 1;
            guard = guard - 65536;
          }
          result = top | (guard << 16);
          v = (result >> 16) & 65535;
          top = (result & 65535) + (fhi & 65535) + step;
          step = 0;
          if (top >= 65536) {
            step = 1;
            top = top - 65536;
          }
          guard = v + ((fhi >> 16) & 65535) + step;
          if (guard >= 65536) {
            guard = guard - 65536;
          }
          whi = top | (guard << 16);
        }
        if (ek == 11) {
          wlo = llo & rlo;
          whi = lhi & rhi;
        }
        if (ek == 12) {
          wlo = llo | rlo;
          whi = lhi | rhi;
        }
        if (ek == 13) {
          wlo = llo ^ rlo;
          whi = lhi ^ rhi;
        }
        // SHL is logical. SHR is arithmetic for i64 and isize, logical
        // for u64 and usize. A count outside 0..63 is not a constant.
        if (ek == 9 || ek == 10) {
          if (rhi != 0 || rlo < 0 || rlo >= 64) {
            return 0;
          }
          if (rlo == 0) {
            wlo = llo;
            whi = lhi;
          }
          if (rlo >= 32) {
            sh = rlo - 32;
            wlo = 0;
            whi = 0;
            if (ek == 9) {
              if (sh == 0) {
                whi = llo;
              }
              if (sh > 0) {
                whi = llo << sh;
              }
            }
            if (ek == 10) {
              if (sh == 0) {
                wlo = lhi;
              }
              if (sh > 0 && sh < 31) {
                if (rtk == 5 || rtk == 7) {
                  wlo = lhi >> sh;
                }
                if (rtk == 4 || rtk == 6) {
                  if (lhi >= 0) {
                    wlo = lhi >> sh;
                  }
                  if (lhi < 0) {
                    top = 32 - sh;
                    guard = 2147483647;
                    if (top < 31) {
                      guard = (1 << top) - 1;
                    }
                    wlo = (lhi >> sh) & guard;
                  }
                }
              }
              if (sh == 31) {
                wlo = 0;
                if (lhi < 0) {
                  wlo = 1;
                  if (rtk == 5 || rtk == 7) {
                    wlo = 0 - 1;
                  }
                }
              }
              if (rtk == 5 || rtk == 7) {
                if (lhi < 0) {
                  whi = 0 - 1;
                }
              }
            }
          }
          if (rlo > 0 && rlo < 32) {
            sh = rlo;
            if (ek == 9) {
              wlo = llo << sh;
              mag = 0;
              top = 32 - sh;
              if (llo >= 0) {
                mag = llo >> top;
              }
              if (llo < 0) {
                guard = 2147483647;
                if (sh < 31) {
                  guard = (1 << sh) - 1;
                }
                mag = (llo >> top) & guard;
              }
              whi = (lhi << sh) | mag;
            }
            if (ek == 10) {
              mag = 0;
              if (llo >= 0) {
                mag = llo >> sh;
              }
              if (llo < 0) {
                top = 32 - sh;
                guard = 2147483647;
                if (top < 31) {
                  guard = (1 << top) - 1;
                }
                mag = (llo >> sh) & guard;
              }
              wlo = mag | (lhi << (32 - sh));
              if (rtk == 5 || rtk == 7) {
                whi = lhi >> sh;
              }
              if (rtk == 4 || rtk == 6) {
                if (lhi >= 0) {
                  whi = lhi >> sh;
                }
                if (lhi < 0) {
                  top = 32 - sh;
                  guard = 2147483647;
                  if (top < 31) {
                    guard = (1 << top) - 1;
                  }
                  whi = (lhi >> sh) & guard;
                }
              }
            }
          }
        }
        // DIV and MOD. Toward zero. Remainder sign follows the dividend.
        // Unsigned kinds 4 and 6 do not look at the sign bit. Zero and
        // signed INT_MIN / -1 stay unfolded. PLATFORM: MACOS|DARWIN / WINDOWS.
        if (ek == 7 || ek == 8) {
          if (rlo == 0 && rhi == 0) {
            return 0;
          }
          if ((rtk == 5 || rtk == 7) && llo == 0 && lhi == (0 - 2147483647 - 1) && rlo == (0 - 1) && rhi == (0 - 1)) {
            return 0;
          }
          lp[0] = llo;
          lp[1] = lhi;
          rp[0] = rlo;
          rp[1] = rhi;
          exp = 0;
          src = 0;
          if (rtk == 5 || rtk == 7) {
            if (lp[1] < 0) {
              src = 1;
              exp = 1;
              flo = lp[0] ^ (0 - 1);
              fhi = lp[1] ^ (0 - 1);
              step = 1;
              sh = 0;
              while (sh < 2) {
                result = flo;
                if (sh == 1) {
                  result = fhi;
                }
                mag = result & 65535;
                top = (result >> 16) & 65535;
                mag = mag + step;
                step = 0;
                if (mag >= 65536) {
                  step = 1;
                  mag = mag - 65536;
                }
                top = top + step;
                step = 0;
                if (top >= 65536) {
                  step = 1;
                  top = top - 65536;
                }
                result = mag | (top << 16);
                if (sh == 0) {
                  flo = result;
                }
                if (sh == 1) {
                  fhi = result;
                }
                sh = sh + 1;
              }
              lp[0] = flo;
              lp[1] = fhi;
            }
            if (rp[1] < 0) {
              guard = exp;
              exp = 0;
              if (guard == 0) {
                exp = 1;
              }
              flo = rp[0] ^ (0 - 1);
              fhi = rp[1] ^ (0 - 1);
              step = 1;
              sh = 0;
              while (sh < 2) {
                result = flo;
                if (sh == 1) {
                  result = fhi;
                }
                mag = result & 65535;
                top = (result >> 16) & 65535;
                mag = mag + step;
                step = 0;
                if (mag >= 65536) {
                  step = 1;
                  mag = mag - 65536;
                }
                top = top + step;
                step = 0;
                if (top >= 65536) {
                  step = 1;
                  top = top - 65536;
                }
                result = mag | (top << 16);
                if (sh == 0) {
                  flo = result;
                }
                if (sh == 1) {
                  fhi = result;
                }
                sh = sh + 1;
              }
              rp[0] = flo;
              rp[1] = fhi;
            }
          }
          flo = 0;
          fhi = 0;
          wlo = 0;
          whi = 0;
          k = 63;
          while (k >= 0) {
            bit = 0;
            if (k >= 32) {
              bit = (lp[1] >> (k - 32)) & 1;
            }
            if (k < 32) {
              bit = (lp[0] >> k) & 1;
            }
            step = 0;
            if (flo < 0) {
              step = 1;
            }
            flo = (flo << 1) | bit;
            fhi = (fhi << 1) | step;
            guard = 0;
            if (fhi >= 0 && rp[1] >= 0) {
              if (fhi > rp[1]) {
                guard = 1;
              }
              if (fhi == rp[1]) {
                if (flo >= 0 && rp[0] >= 0 && flo >= rp[0]) {
                  guard = 1;
                }
                if (flo < 0 && rp[0] < 0 && flo >= rp[0]) {
                  guard = 1;
                }
                if (flo < 0 && rp[0] >= 0) {
                  guard = 1;
                }
              }
            }
            if (fhi < 0 && rp[1] >= 0) {
              guard = 1;
            }
            if (fhi < 0 && rp[1] < 0) {
              if (fhi > rp[1]) {
                guard = 1;
              }
              if (fhi == rp[1]) {
                if (flo >= 0 && rp[0] >= 0 && flo >= rp[0]) {
                  guard = 1;
                }
                if (flo < 0 && rp[0] < 0 && flo >= rp[0]) {
                  guard = 1;
                }
                if (flo < 0 && rp[0] >= 0) {
                  guard = 1;
                }
              }
            }
            if (guard == 1) {
              result = rp[0] ^ (0 - 1);
              v = rp[1] ^ (0 - 1);
              step = 1;
              mag = (flo & 65535) + (result & 65535) + step;
              step = 0;
              if (mag >= 65536) {
                step = 1;
                mag = mag - 65536;
              }
              top = ((flo >> 16) & 65535) + ((result >> 16) & 65535) + step;
              step = 0;
              if (top >= 65536) {
                step = 1;
                top = top - 65536;
              }
              flo = mag | (top << 16);
              mag = (fhi & 65535) + (v & 65535) + step;
              step = 0;
              if (mag >= 65536) {
                step = 1;
                mag = mag - 65536;
              }
              top = ((fhi >> 16) & 65535) + ((v >> 16) & 65535) + step;
              if (top >= 65536) {
                top = top - 65536;
              }
              fhi = mag | (top << 16);
              if (k >= 32) {
                sh = k - 32;
                if (sh == 31) {
                  whi = whi | (0 - 2147483647 - 1);
                }
                if (sh < 31) {
                  whi = whi | (1 << sh);
                }
              }
              if (k < 32) {
                if (k == 31) {
                  wlo = wlo | (0 - 2147483647 - 1);
                }
                if (k < 31) {
                  wlo = wlo | (1 << k);
                }
              }
            }
            k = k - 1;
          }
          if (ek == 8) {
            wlo = flo;
            whi = fhi;
            exp = src;
          }
          if (exp == 1) {
            flo = wlo ^ (0 - 1);
            fhi = whi ^ (0 - 1);
            step = 1;
            sh = 0;
            while (sh < 2) {
              result = flo;
              if (sh == 1) {
                result = fhi;
              }
              mag = result & 65535;
              top = (result >> 16) & 65535;
              mag = mag + step;
              step = 0;
              if (mag >= 65536) {
                step = 1;
                mag = mag - 65536;
              }
              top = top + step;
              step = 0;
              if (top >= 65536) {
                step = 1;
                top = top - 65536;
              }
              result = mag | (top << 16);
              if (sh == 0) {
                flo = result;
              }
              if (sh == 1) {
                fhi = result;
              }
              sh = sh + 1;
            }
            wlo = flo;
            whi = fhi;
          }
        }
        unsafe {
          pipe_store_i32_le(out_val as *u8, 0, wlo);
          pipe_store_i32_le(out_hi as *u8, 0, whi);
        }
        return 3;
      }
    unsafe {
      left = pipeline_expr_binop_left_ref_at(arena, eref);
      right = pipeline_expr_binop_right_ref_at(arena, eref);
    }
    if (left <= 0 || right <= 0) {
      return 0;
    }
    // Return 3 carries a high half this 32-bit operator does not accept.
    // Return 4 is f32 bits. Return 5 is f64 bits. Adding those bits
    // is not a float add.
    ok = pipe_modlet_array_lit_elem_const_val(arena, left, out_val, out_hi);
    if (ok == 0 || ok == 3 || ok == 4 || ok == 5) {
      return 0;
    }
    unsafe {
      lv = pipe_load_i32_le(out_val as *u8, 0);
    }
    ok = pipe_modlet_array_lit_elem_const_val(arena, right, out_val, out_hi);
    if (ok == 0 || ok == 3 || ok == 4 || ok == 5) {
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
    // 14 is f32: the word below is the IEEE pattern, not a trunc.
    // 15 is f64: both halves below are the IEEE pattern, not a trunc.
    if (tk != 0 && tk != 1 && tk != 2 && tk != 3 && tk != 4 && tk != 5 && tk != 6 && tk != 7 && tk != 14 && tk != 15) {
      return 0;
    }
    // A child return of 2 is a zero high half. A narrower cast of that
    // word is an i32, so the baker must sign-fill it. A 64-bit cast
    // keeps the zero high half.
    ok = pipe_modlet_array_lit_elem_const_val(arena, op, out_val, out_hi);
    // TYPE_F64. Return 1 is a signed i32; glue_i64_to_f64_bits is the
    // host cast. Return 5 is already both f64 halves. Return 4 is an
    // f32 word widened by the existing glue helpers. Return 2 and
    // return 3 must not be read as a signed i32. Return 0 is a float
    // tree, stored after the walker. 1 as f64 is 000000000000f03f.
    // (1.0 as f32) as f64 is the same eight bytes.
    // PLATFORM: MACOS|DARWIN / WINDOWS.
    if (tk == 15) {
      if (out_hi == 0 as *i32) {
        return 0;
      }
      if (ok == 1) {
        unsafe {
          v = pipe_load_i32_le(out_val as *u8, 0);
          glue_i64_to_f64_bits(v as i64, &(lp[0]), &(lp[1]));
          pipe_store_i32_le(out_val as *u8, 0, lp[0]);
          pipe_store_i32_le(out_hi as *u8, 0, lp[1]);
        }
        return 5;
      }
      if (ok == 5) {
        return 5;
      }
      if (ok == 4) {
        unsafe {
          v = pipe_load_i32_le(out_val as *u8, 0);
          flo = glue_ieee_f32_bits_to_f64_lo(v);
          fhi = glue_ieee_f32_bits_to_f64_hi(v);
          pipe_store_i32_le(out_val as *u8, 0, flo);
          pipe_store_i32_le(out_hi as *u8, 0, fhi);
        }
        return 5;
      }
      if (ok != 0) {
        return 0;
      }
    }
    // TYPE_F32. Return 1 is a signed i32; glue_i32_to_f32_bits is the
    // host cast. Return 4 is already the f32 word (nested as f32).
    // Return 5 is an f64 value; pack it with the existing helper.
    // Return 2 and return 3 must not be read as a signed i32.
    // Return 0 is a float tree, packed after the walker.
    // (1 as i32) as f32 stores 0x3f800000 and returns 4.
    if (tk == 14) {
      if (ok == 1) {
        unsafe {
          v = pipe_load_i32_le(out_val as *u8, 0);
          result = glue_i32_to_f32_bits(v);
          pipe_store_i32_le(out_val as *u8, 0, result);
        }
        return 4;
      }
      if (ok == 4) {
        return 4;
      }
      if (ok == 5) {
        if (out_hi == 0 as *i32) {
          return 0;
        }
        unsafe {
          flo = pipe_load_i32_le(out_val as *u8, 0);
          fhi = pipe_load_i32_le(out_hi as *u8, 0);
          result = glue_ieee_f64_bits_to_f32_bits(flo, fhi);
          pipe_store_i32_le(out_val as *u8, 0, result);
        }
        return 4;
      }
      if (ok != 0) {
        return 0;
      }
    }
    if (ok == 1) {
      return 1;
    }
    if (ok == 2) {
      if (tk == 4 || tk == 5 || tk == 6 || tk == 7) {
        return 2;
      }
      return 1;
    }
    // The child already wrote both halves. A 32-bit target cannot keep
    // a high word, so that cast stays unfolded.
    if (ok == 3) {
      if (tk == 4 || tk == 5 || tk == 6 || tk == 7) {
        return 3;
      }
      return 0;
    }
    // Not an integer. The walker below evaluates the float tree.
    // op is already the cast operand. tk is the cast target.
    enter_walk = 1;
  }
  // Walker shared by an AS whose child did not fold as an integer and
  // by an f32-typed or f64-typed ADD, SUB, MUL, or DIV. op is the walk
  // root. tk 14 packs one f32 word and returns 4. tk 15 stores both
  // f64 halves and returns 5. Any other accepted tk truncates to an
  // integer. The four host f64 operators stay separate ifs. There is
  // no second float folder.
  // PLATFORM: MACOS|DARWIN / WINDOWS.
  if (enter_walk == 1) {
    // Frames: 0 enter, 1 the unary child, the cast operand, or the
    // binop left child is on the stack, 2 value is ready, 3 binop
    // left bits sit in this frame and the right child is on the stack.
    // For a cast, stk_aux holds 14 (f32) or 15 (f64). For a binop it
    // holds the right child ref. Eight frames cover the probe trees.
    // A deeper tree, a float MOD, or a non-float node returns 0.
    // Host f64 is the operator. An f32 node then calls the existing
    // glue_ieee helpers.
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
                if (sek == 54) {
                  // AS to f32 or f64 inside the float tree. Other targets
                  // are not part of this walk. stk_aux keeps 14 or 15.
                  unsafe {
                    child = pipeline_expr_as_operand_ref_at(arena, sref);
                    left = pipeline_expr_as_target_type_ref_at(arena, sref);
                  }
                  rtk = 0;
                  if (left > 0) {
                    unsafe {
                      rtk = pipeline_type_kind_ord_at(arena, left);
                    }
                  }
                  if (child <= 0 || (rtk != 14 && rtk != 15)) {
                    sp = 0;
                  } else {
                    stk_aux[si] = rtk;
                    unsafe {
                      sek = pipeline_expr_kind_ord_at(arena, child);
                    }
                    // A nested cast stays here only when its target is
                    // also f32 or f64. An integer child is one signed
                    // i32. Return 2 is a zero high half, and
                    // glue_i32_to_f32_bits would read that word as a
                    // negative i32, so it stays unfolded.
                    rty = 0;
                    if (sek == 54) {
                      unsafe {
                        rty = pipeline_expr_as_target_type_ref_at(arena, child);
                      }
                      if (rty > 0) {
                        unsafe {
                          rty = pipeline_type_kind_ord_at(arena, rty);
                        }
                      }
                    }
                    if (sek == 1 || sek == 22 || sek == 4 || sek == 5 || sek == 6 || sek == 7 || rty == 14 || rty == 15) {
                      if (sp >= 8) {
                        sp = 0;
                      } else {
                        stk_step[si] = 1;
                        stk_ref[sp] = child;
                        stk_step[sp] = 0;
                        sp = sp + 1;
                      }
                    } else {
                      oparts[0] = 0;
                      ok = pipe_modlet_array_lit_elem_const_val(arena, child, &(oparts[0]), &(oparts[1]));
                      if (ok != 1) {
                        sp = 0;
                      } else {
                        lv = oparts[0];
                        if (rtk == 14) {
                          unsafe {
                            result = glue_i32_to_f32_bits(lv);
                            stk_lo[si] = glue_ieee_f32_bits_to_f64_lo(result);
                            stk_hi[si] = glue_ieee_f32_bits_to_f64_hi(result);
                          }
                        } else {
                          unsafe {
                            glue_i64_to_f64_bits(lv as i64, &(lp[0]), &(lp[1]));
                          }
                          stk_lo[si] = lp[0];
                          stk_hi[si] = lp[1];
                        }
                        stk_step[si] = 2;
                      }
                    }
                  }
                } else {
                  sp = 0;
                }
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
              // Cast completion is its own if. The f64 operators stay
              // out of this compare's else, so the divisor reload is
              // not dropped.
              v = 0;
              if (pstep == 1 && sek == 54) {
                stk_lo[pi] = stk_lo[si];
                stk_hi[pi] = stk_hi[si];
                if (stk_aux[pi] == 14) {
                  unsafe {
                    result = glue_ieee_f64_bits_to_f32_bits(stk_lo[pi], stk_hi[pi]);
                    stk_lo[pi] = glue_ieee_f32_bits_to_f64_lo(result);
                    stk_hi[pi] = glue_ieee_f32_bits_to_f64_hi(result);
                  }
                }
                stk_step[pi] = 2;
                sp = si;
                v = 1;
              }
              if (v == 0 && pstep == 1 && sek == 22) {
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
                    // TYPE_F32 binop: the host operator ran in f64.
                    // Round back to f32 and widen so the trunc matches
                    // an f32 operation. 16777216.0 + 1.0 is 16777217.0
                    // in f64 and 16777216.0 in f32. An unset or f64
                    // type stays f64, so 16777217.0 as i32 is unchanged.
                    rty = 0;
                    unsafe {
                      rty = pipeline_expr_resolved_type_ref(arena, stk_ref[pi]);
                    }
                    if (rty > 0) {
                      unsafe {
                        rtk = pipeline_type_kind_ord_at(arena, rty);
                      }
                      if (rtk == 14) {
                        unsafe {
                          result = glue_ieee_f64_bits_to_f32_bits(stk_lo[pi], stk_hi[pi]);
                          stk_lo[pi] = glue_ieee_f32_bits_to_f64_lo(result);
                          stk_hi[pi] = glue_ieee_f32_bits_to_f64_hi(result);
                        }
                      }
                    }
                    stk_step[pi] = 2;
                    sp = si;
                  } else {
                    // v == 1 means the cast arm already finished this
                    // frame. Zeroing sp here would throw that value away.
                    if (v == 0) {
                      sp = 0;
                    }
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
    // Outer target is f64. The walker left both IEEE halves in flo/fhi.
    // Store them and return 5. Do not truncate and do not pack to f32.
    // 1.0 / 0.0 as an f64 element is +inf (000000000000f07f). The same
    // div as an i32 still hits the exponent check below and returns 0.
    // A null out_hi cannot carry the high half.
    // PLATFORM: MACOS|DARWIN / WINDOWS.
    if (tk == 15) {
      if (out_hi == 0 as *i32) {
        return 0;
      }
      unsafe {
        pipe_store_i32_le(out_val as *u8, 0, flo);
        pipe_store_i32_le(out_hi as *u8, 0, fhi);
      }
      return 5;
    }
    // Outer target is f32. The walker left f64 bits in flo/fhi.
    // Pack them with the existing helper. Do not truncate: 1.0f is
    // 0x3f800000, and 16777217.0 as f32 rounds to 16777216
    // (0000804b). Return 4. An integer parent of this cast still
    // walks the tree, so (1 as f32) as i32 stays 1.
    if (tk == 14) {
      unsafe {
        result = glue_ieee_f64_bits_to_f32_bits(flo, fhi);
        pipe_store_i32_le(out_val as *u8, 0, result);
      }
      return 4;
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
    // |x| >= 2^32. The low word goes to out_val and the high word to
    // out_hi. Return 3 tells the baker to store that high word.
    // Sign-fill and a zero high half are both the wrong pattern:
    // 4294967296.0 is low 0 and high 1.
    // Integer bit k is significand bit (k + 52 - e). Significand bit 52
    // is the implicit 1, bits 32..51 are the low 20 bits of fhi, and
    // bits 0..31 are flo. A logical bit of a negative word is an
    // arithmetic shift masked with 1. Bit 31 and bit 63 are ORed in as
    // INT_MIN so a left shift never has to set the sign bit itself.
    if (e > 31) {
      if (out_hi == 0 as *i32) {
        return 0;
      }
      if (tk != 4 && tk != 5 && tk != 6 && tk != 7) {
        return 0;
      }
      // |x| >= 2^64 does not fit in any 64-bit cell.
      if (e >= 64) {
        return 0;
      }
      // Binade [2^63, 2^64). Exact ±2^63 both store low 0 and high
      // 0x80000000: the same bits as 9223372036854775808.0 as i64 /
      // as u64. Positive exact falls through the bit loop with no
      // negate; negative exact negates 2^63 and lands on the same
      // pattern. A non-exact value in this binade stays unfolded.
      // PLATFORM: MACOS|DARWIN / WINDOWS.
      if (e == 63) {
        if ((fhi & 1048575) != 0 || flo != 0) {
          return 0;
        }
      }
      wlo = 0;
      whi = 0;
      k = 0;
      while (k < 64) {
        src = k + 52 - e;
        bit = 0;
        if (src == 52) {
          bit = 1;
        }
        if (src >= 0 && src <= 31) {
          bit = (flo >> src) & 1;
        }
        if (src >= 32 && src <= 51) {
          bit = (fhi >> (src - 32)) & 1;
        }
        if (bit != 0) {
          if (k < 31) {
            wlo = wlo | (1 << k);
          }
          if (k == 31) {
            wlo = wlo | (0 - 2147483647 - 1);
          }
          if (k > 31 && k < 63) {
            whi = whi | (1 << (k - 32));
          }
          if (k == 63) {
            whi = whi | (0 - 2147483647 - 1);
          }
        }
        k = k + 1;
      }
      // Two's complement of the magnitude. Carry into the high word
      // only when the low word is 0.
      if (fhi < 0) {
        if (wlo == 0) {
          whi = (whi ^ (0 - 1)) + 1;
        }
        if (wlo != 0) {
          wlo = 0 - wlo;
          whi = whi ^ (0 - 1);
        }
      }
      unsafe {
        pipe_store_i32_le(out_val as *u8, 0, wlo);
        pipe_store_i32_le(out_hi as *u8, 0, whi);
      }
      return 3;
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
    // half is 0. i64/u64/isize/usize return 2 (zero high half).
    // i32 and u32 return 1 with the same low word: 2147483648.0 as i32
    // and as u32 both store 0x80000000, matching
    // (2147483648.0 as i64) as i32. Bool and u8 stay unfolded.
    // Each shift stays inside a positive i32. Bit 31 is ORed in last.
    // PLATFORM: MACOS|DARWIN / WINDOWS.
    if (e == 31) {
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
      if (tk == 4 || tk == 5 || tk == 6 || tk == 7) {
        return 2;
      }
      if (tk == 0 || tk == 3) {
        return 1;
      }
      return 0;
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
