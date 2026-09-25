// 3-argument folder used by Darwin and Windows module-array bakers.
// Ubuntu's runtime_pipeline_abi_modlet_thin.x keeps the 4-argument
// folder (it also returns the high half). Do not link this object on
// Linux: the symbol name matches, the ABI does not.
// PLATFORM: MACOS|DARWIN / WINDOWS. Do not PREFER this into
// runtime_pipeline_abi.o. Do not modify that object in place.

export extern "C" function pipeline_expr_as_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_as_target_type_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_int_val_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Fold one module-array element into a single i32 word.
 * EXPR_LIT (ek 0) and EXPR_BOOL_LIT (ek 2) share int_val: true is 1
 * and false is 0. EXPR_NEG (ek 22) folds only when its operand is a
 * LIT. EXPR_AS (ek 54) accepts TYPE_I32 (0), TYPE_BOOL (1), TYPE_U8 (2),
 * and TYPE_U32 (3). The baker peels esz bytes of this word, so a u8
 * cell keeps the low byte and 2 as bool stays 2. A float operand, an
 * integer binop, and a 64-bit target return 0: this ABI has no high
 * half and no second folder.
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
  // NEG of a LIT only. (0 - 1) is SUB, not this arm.
  if (ek == 22) {
    unsafe {
      op = pipeline_expr_unary_operand_ref_at(arena, eref);
    }
    if (op <= 0) {
      return 0;
    }
    unsafe {
      ek = pipeline_expr_kind_ord_at(arena, op);
    }
    if (ek != 0) {
      return 0;
    }
    unsafe {
      v = pipeline_expr_int_val_at(arena, op);
    }
    unsafe {
      pipe_store_i32_le(out_val as *u8, 0, 0 - v);
    }
    return 1;
  }
  // AS. 32-bit targets only. The operand must fold with this function.
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
