// knife256/10.2 Cap tip linked body of typeck_check_expr_return.
// Source authority for the element stamp is typeck_stamp_arr_i32_vec_elems.
// Cap tip -c of mega typeck.x emits a hollow mov w0,#0; ret, so this
// thin is what the link runs. The live caller is
// pipeline_typeck_check_expr_return_c in another object. It branches
// to this symbol. The mega body only stamps integer 0 onto a kind-13
// element, so `return [3, -3]` of [2]Vec8i stayed i32
// ("expected ?, found i32"). The ? printer is the kind-13 name and is
// not changed here. This thin stamps each integer element of an array
// or slice of an i32 TYPE_VECTOR, then calls the demoted body.
// check_expr keeps an already-resolved INT_LIT and an already-stamped
// i32-vector unary, so the stamp survives the check inside demoted.
// A VAR element, a binop, a nested ARRAY_LIT, kind 24, and kind 8 stay
// unstamped. Call-argument checking is a different function.
// PLATFORM: SHARED — the type rule is the same on macOS, Ubuntu, and Windows.
// The demote step that makes this symbol win is Mach-O only.

export extern "C" function typeck_check_expr_return__demoted(
  module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern "C" function pipeline_expr_unary_operand_ref_at(
  arena: *u8, expr_ref: i32): i32;
export extern "C" function typeck_stamp_arr_i32_vec_elems(
  arena: *u8, init_ref: i32, decl_ty_ref: i32): i32;

/**
 * Stamp integer elements of a returned array literal, then run demoted.
 * @param module *u8 — caller module; passed through, may be null
 * @param arena *u8 — AST arena; null skips the stamp and still calls demoted
 * @param expr_ref i32 — RETURN expr (kind 41); the value is its unary operand
 * @param return_type_ref i32 — function return type; <= 0 skips the stamp
 * @param ctx *u8 — dep context, passed through; may be null
 * @return i32 — the demoted checker result
 * The operand is read with pipeline_expr_unary_operand_ref_at, the same
 * accessor the demoted body uses. The helper returns 0 for a non-literal,
 * for a count outside 1..1024, and for any element type other than a
 * TYPE_VECTOR of i32. Named i32x8 is kind 8 and is not stamped.
 * A scalar Vec8i return is not an ARRAY_LIT, so the existing integral
 * coerce inside the demoted body still stamps it. A failed return still
 * returns the demoted code. Two compares, not a chained &&.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function typeck_check_expr_return(
  module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  unsafe {
    let op_ref: i32 = 0;
    if (arena != 0 as *u8) {
      if (expr_ref > 0) {
        if (return_type_ref > 0) {
          op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
          if (op_ref > 0) {
            /*
             * Whole-array return. Stamp integer elements before demoted
             * check_expr. The walker only accepts integer 0 on kind 13.
             * Nested array literals stay on that walker.
             * PLATFORM: SHARED.
             */
            typeck_stamp_arr_i32_vec_elems(arena, op_ref, return_type_ref);
          }
        }
      }
    }
    return typeck_check_expr_return__demoted(
      module, arena, expr_ref, return_type_ref, ctx);
  }
}
