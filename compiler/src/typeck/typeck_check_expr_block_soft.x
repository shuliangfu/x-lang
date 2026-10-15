// knife256/10.2 Cap tip linked body of typeck_check_expr_block.
// A block arm of `let v: Vec8i = if (c) { 3 } else { -3 }` is checked
// with the Vec8i decl as the expected type. The value tail stays i32,
// so the block and the if stay i32 and the let reports expected ?,
// found i32. After the demoted check, the same
// typeck_stamp_i32_vector_int_splat used by let, return, call, and
// struct fields runs on that tail. A hit sets this block expr's
// resolved type to the expected vector. The existing if join then
// sees Vec8i on both arms. A VAR tail is not a literal chain, so a
// block whose value is already Vec8i keeps the type the demoted body
// copied. Kind 24 and a float literal are not stamped. Stamping
// inside int_lit would mark every literal. This function does not.
// PLATFORM: SHARED — the type rule is the same on macOS, Ubuntu, and
// Windows. The demote step that makes this symbol win is Mach-O only.

export extern "C" function typeck_check_expr_block__demoted(
  module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern "C" function typeck_stamp_i32_vector_int_splat(
  arena: *u8, init_ref: i32, decl_ty_ref: i32): i32;
export extern "C" function typeck_block_expr_value_ref(arena: *u8, block_ref: i32): i32;
export extern "C" function pipeline_expr_block_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_set_resolved_type_ref(
  arena: *u8, expr_ref: i32, ty: i32): void;

/**
 * Stamp a Vec8i literal chain that is the value of a block expr.
 * @param module *u8 — caller module; passed through to the demoted body
 * @param arena *u8 — AST arena; null defers to the demoted body
 * @param expr_ref i32 — EXPR_BLOCK; <= 0 defers
 * @param return_type_ref i32 — expected type of this block. The stamp
 *   runs only when that type is a TYPE_VECTOR of i32. Other expected
 *   types leave the demoted block type in place.
 * @param ctx *u8 — dep context; passed through
 * @return i32 — the demoted check result. 0 is success. -1 is failure.
 * The stamp writes the tail and, on a hit, this block expr. It does
 * not walk kind 24, a float, or a 33rd unary. A statement if body is
 * a block ref passed to check_block, not this expr. PLATFORM: SHARED.
 */
#[no_mangle]
export function typeck_check_expr_block(
  module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  unsafe {
    let rc: i32 = 0;
    let block_ref: i32 = 0;
    let tail: i32 = 0;
    let stamped: i32 = 0;
    rc = typeck_check_expr_block__demoted(
      module, arena, expr_ref, return_type_ref, ctx);
    if (rc != 0) {
      return rc;
    }
    if (arena == 0 as *u8) {
      return 0;
    }
    if (expr_ref <= 0) {
      return 0;
    }
    if (return_type_ref <= 0) {
      return 0;
    }
    block_ref = pipeline_expr_block_ref_at(arena, expr_ref);
    if (block_ref <= 0) {
      return 0;
    }
    tail = typeck_block_expr_value_ref(arena, block_ref);
    if (tail <= 0) {
      return 0;
    }
    /*
     * The demoted body already copied the tail's i32 type onto this
     * block. The stamp returns 1 only for a non-null INT_LIT or a
     * kind-22 / kind-23 chain of one, and it rewrites that tail.
     * Overwrite the block only on that hit so a VAR tail stays the
     * vector type check_block already stored. PLATFORM: SHARED.
     */
    stamped = typeck_stamp_i32_vector_int_splat(arena, tail, return_type_ref);
    if (stamped == 1) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, return_type_ref);
    }
    return 0;
  }
}
