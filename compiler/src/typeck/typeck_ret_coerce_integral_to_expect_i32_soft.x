// knife256/10.2 Cap tip linked body of typeck_ret_coerce_integral_to_expect_i32.
// The mega body only rewrites u8 / usize when the expected type is i32.
// A Vec8i return (kind 13) of an INT_LIT, or of a kind-22 / kind-23
// chain of one, never reached that write, so check_expr's i32 type
// failed the return match ("expected ?, found i32"). The ? printer is
// the kind-13 name and is not changed here. This thin stamps that
// splat through typeck_stamp_i32_vector_int_splat, then calls the
// demoted body for the u8 / usize case. The block-final path calls
// the same symbol, so one thin covers both. Call-argument checking
// is a different consumer and is not this function.
// PLATFORM: SHARED — the type rule is the same on macOS, Ubuntu, and Windows.
// The demote step that makes this symbol win is Mach-O only.

export extern "C" function typeck_ret_coerce_integral_to_expect_i32__demoted(
  arena: *u8, op_ref: i32, expect_ref: i32): void;
export extern "C" function typeck_stamp_i32_vector_int_splat(
  arena: *u8, init_ref: i32, decl_ty_ref: i32): i32;

/**
 * Stamp a Vec8i return of an i32 literal chain, then run the old widen.
 * @param arena *u8 — AST arena; null returns without touching demoted
 * @param op_ref i32 — return operand already checked by check_expr
 * @param expect_ref i32 — function return type
 * @return void
 * A null arena must not enter the demoted body: that body reads
 * arena.num_exprs before it returns. A successful stamp writes the
 * vector type onto the operand. The demoted body then sees a kind-13
 * expect, which is not i32, and returns without clearing that write.
 * A miss leaves the operand alone so u8 / usize still widen to i32.
 * Kind 24, f32, VAR, and keyword null are not stamped.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function typeck_ret_coerce_integral_to_expect_i32(
  arena: *u8, op_ref: i32, expect_ref: i32): void {
  unsafe {
    let stamped: i32 = 0;
    if (arena == 0 as *u8) {
      return;
    }
    if (op_ref > 0) {
      if (expect_ref > 0) {
        stamped = typeck_stamp_i32_vector_int_splat(arena, op_ref, expect_ref);
      }
    }
    /*
     * Both arms call demoted. The stamp result is live so the write
     * is not dropped. Demoted does not undo a kind-13 stamp.
     * PLATFORM: SHARED.
     */
    if (stamped == 1) {
      typeck_ret_coerce_integral_to_expect_i32__demoted(arena, op_ref, expect_ref);
    } else {
      typeck_ret_coerce_integral_to_expect_i32__demoted(arena, op_ref, expect_ref);
    }
  }
}
