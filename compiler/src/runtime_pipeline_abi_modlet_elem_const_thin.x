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
export extern function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

/**
 * Fold one module-array element into a single i32 word.
 * EXPR_LIT (ek 0) and EXPR_BOOL_LIT (ek 2) share int_val: true is 1
 * and false is 0. EXPR_NEG (ek 22) folds its operand with this function,
 * then negates that 32-bit word. EXPR_ADD through EXPR_BITXOR (ek 4..13)
 * fold both children the same way. DIV (7) and MOD (8) return 0 when the
 * divisor is 0 or the pair is INT_MIN and -1, so the baker loud-fails
 * instead of trapping. A shift count outside 0..31 returns 0.
 * EXPR_AS (ek 54) accepts TYPE_I32 (0), TYPE_BOOL (1), TYPE_U8 (2),
 * and TYPE_U32 (3). The baker peels esz bytes of this word, so a u8
 * cell keeps the low byte: (0 - 1) as u8 stores 255, 256 as u8 stores 0,
 * and 2 as bool stays 2. A float operand and a 64-bit target return 0:
 * this ABI has no high half and no float folder.
 * @param arena *u8 — AST arena; null returns 0
 * @param eref i32 — expression ref; <= 0 returns 0
 * @param out_val *i32 — one i32 slot; null returns 0; written only on success
 * @return i32 — 1 when out_val holds the folded word, 0 when the expr is not folded
 * PLATFORM: MACOS|DARWIN / WINDOWS — strong definition. Darwin prepare's
 * branch reloc binds here over the weak gcc body. Windows egg and the
 * modlet extra only declare this name.
 * Compile this file with XLANG_PREFER_ASM_O=1. DIV and MOD must not
 * emit a call to xlang_panic_.
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
  // on this Darwin compiler. Undefined DIV, MOD, and shifts return 0
  // without storing, so the baker loud-fails.
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
    // EXPR_DIV=7 and EXPR_MOD=8. Zero and INT_MIN with -1 are not constants.
    // lv + 2147483647 == -1 only for the most-negative i32.
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
  // AS. 32-bit targets only. The operand must fold with this function.
  // The low word is already in out_val. The baker peels the bytes.
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
    if (pipe_modlet_array_lit_elem_const_val(arena, op, out_val) == 0) {
      return 0;
    }
    return 1;
  }
  return 0;
}
