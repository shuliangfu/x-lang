// knife256/10.2 Cap tip linked body of typeck_check_expr_if_ternary.
// `let v: Vec8i = c != 0 ? 3 : -3` checks both arms with the Vec8i
// decl. Each arm stays i32, the ternary stays i32, and the let
// reports expected ?, found i32. The same miss is a return mismatch
// and a call-argument mismatch. An if expr is kind 25: its arms are
// blocks, and the block checker already stamps those tails. This
// thin does not stamp kind 25. After the demoted ternary check
// accepts two i32 arms, the same typeck_stamp_i32_vector_int_splat
// used by let, return, call, struct fields, and blocks runs on each
// arm. Both hits set this ternary's resolved type to the expected
// vector. One miss leaves the demoted i32 type. Kind 24 and a float
// literal are not stamped. Stamping inside int_lit would mark every
// literal. This function does not.
// PLATFORM: SHARED — the type rule is the same on macOS, Ubuntu, and
// Windows. The demote step that makes this symbol win is Mach-O only.

export extern "C" function typeck_check_expr_if_ternary__demoted(
  module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern "C" function typeck_stamp_i32_vector_int_splat(
  arena: *u8, init_ref: i32, decl_ty_ref: i32): i32;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_if_then_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_if_else_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_set_resolved_type_ref(
  arena: *u8, expr_ref: i32, ty: i32): void;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_expr_array_lit_num_elems_at(
  arena: *u8, expr_ref: i32): i32;
export extern "C" function typeck_vector_lanes_of_type(arena: *u8, ty_ref: i32): i32;
export extern "C" function pipeline_expr_block_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function typeck_block_expr_value_ref(arena: *u8, block_ref: i32): i32;

/**
 * Stamp both arms of a Vec8i integer-literal ternary.
 * @param module *u8 — caller module; passed through to the demoted body
 * @param arena *u8 — AST arena; null defers to the demoted body
 * @param expr_ref i32 — EXPR_IF or EXPR_TERNARY; <= 0 defers
 * @param return_type_ref i32 — expected type. The stamp runs only when
 *   that type is a TYPE_VECTOR of i32 and this expr is kind 27.
 * @param ctx *u8 — dep context; passed through
 * @return i32 — the demoted check result. 0 is success. -1 is failure.
 * A kind-25 if returns the demoted result with no extra write. A
 * ternary whose arms are not both a non-null INT_LIT or a kind-22 /
 * kind-23 chain keeps the demoted type. The stamp does not walk kind
 * 24, a float, or a 33rd unary. An address whose expected type is a
 * pointer to named Vec8i checks this ternary with that pointer.
 * An array-literal arm is then an i32 array, so the demoted pair
 * check fails. Stamp that arm with the Vec8i pointee first.
 * Named i32x8 is the same kind 8, five bytes, i 3 2 x 8. The
 * address check leaves the then arm as an i32 array. The demoted
 * ternary keeps that then type, so codegen sees an array. Stamp
 * an 8-elem array arm with that i32x8 pointee too. The value form
 * already stores it. Named f32x8 is kind 8, five bytes, f 3 2 x 8.
 * The same address check leaves that then arm as a float array.
 * Stamp an 8-elem array arm with that f32x8 pointee too. The
 * value form already stores those lanes. Named u32x8 is kind 8,
 * five bytes, u 3 2 x 8. The same address check leaves that then
 * arm as an i32 array. Stamp an 8-elem array arm with that u32x8
 * pointee too. The value form already stores those lanes.
 * Named i32x4 is kind 8, five bytes, i 3 2 x 4. The same address
 * check leaves that then arm as an i32 array. Stamp a 4-elem
 * array arm with that i32x4 pointee. The value form already
 * stores those lanes. Named u32x4 is kind 8, five bytes,
 * u 3 2 x 4. The same address check leaves that then arm as
 * an i32 array. Stamp a 4-elem array arm with that u32x4
 * pointee. The value form already stores those lanes. Named
 * f32x4 is kind 8, five bytes, f 3 2 x 4. The same address
 * check leaves that then arm as a float array. A named arm
 * and that array are not the same type, so the demoted pair
 * check fails. Stamp a 4-elem array arm with that f32x4
 * pointee. The value form already stores those lanes.
 * Named Vec4f is kind 8, five bytes, V e c 4 f. The same
 * address check leaves that then arm as a float array. A
 * named arm and that array are not the same type, so the
 * demoted pair check fails. Stamp a 4-elem array arm with
 * that Vec4f pointee. The value form already stores those
 * lanes. Named i32x16 is kind 8, six bytes, i 3 2 x 1 6.
 * The same address check leaves that then arm as an i32
 * array. Stamp a 16-elem array arm with that i32x16
 * pointee. The value form already stores those lanes.
 * Named u32x16 is kind 8, six bytes, u 3 2 x 1 6.
 * The same address check leaves that then arm as an i32
 * array. Stamp a 16-elem array arm with that u32x16
 * pointee. The value form already stores those lanes.
 * Lane count is typeck_vector_lanes_of_type, not a name
 * list. Named f32x16 is f 3 2 x 1 6 and is 16 lanes, so
 * a 16-elem array arm is stamped with that pointee too.
 * A kind-25 if arm is a block. When the expected type is
 * a pointer, the kind-46 tail of that block is stamped
 * the same way. The value form is not a pointer.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function typeck_check_expr_if_ternary(
  module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  unsafe {
    let ord_ternary: i32 = 27;
    let rc: i32 = 0;
    let kind: i32 = 0;
    let then_ref: i32 = 0;
    let else_ref: i32 = 0;
    let stamped_then: i32 = 0;
    let stamped_else: i32 = 0;
    let pk: i32 = 0;
    let pt: i32 = 0;
    let step: i32 = 0;
    let arm_ref: i32 = 0;
    let arm_k: i32 = 0;
    let arm_n: i32 = 0;
    let want_n: i32 = 0;
    let kind_ok: i32 = 0;
    let lanes_ok: i32 = 0;
    let block_ref: i32 = 0;
    let tail: i32 = 0;
    let tail_k: i32 = 0;
    /*
     * Expected type of an address is a pointer (kind 9). The pointee
     * lane count is 0, so a kind-46 arm stays a plain array. The pair
     * check accepts an integer array against a named SIMD, the ternary
     * keeps that array, and address codegen fails. Lane count comes
     * from typeck_vector_lanes_of_type: an 'x' plus 4, 8, or 16, and
     * the Vec4f / Vec8i aliases. Stamp a kind-46 arm whose element
     * count equals that count with the pointee, before the demoted
     * pair check. A kind-25 if arm is a block (kind 26). Peel it and
     * stamp the same kind-46 tail. The value form is not a pointer,
     * so it does not enter. The integer splat below is unchanged.
     * PLATFORM: SHARED.
     */
    if (arena != 0 as *u8) {
      if (expr_ref > 0) {
        if (return_type_ref > 0) {
          kind = pipeline_expr_kind_ord_at(arena, expr_ref);
          kind_ok = 0;
          if (kind == ord_ternary) {
            kind_ok = 1;
          }
          if (kind == 25) {
            kind_ok = 1;
          }
          if (kind_ok == 1) {
            pk = pipeline_type_kind_ord_at(arena, return_type_ref);
            if (pk == 9) {
              pt = pipeline_type_elem_ref_at(arena, return_type_ref);
              if (pt > 0) {
                pk = pipeline_type_kind_ord_at(arena, pt);
                if (pk == 8) {
                  want_n = typeck_vector_lanes_of_type(arena, pt);
                  lanes_ok = 0;
                  if (want_n == 4) {
                    lanes_ok = 1;
                  }
                  if (want_n == 8) {
                    lanes_ok = 1;
                  }
                  if (want_n == 16) {
                    lanes_ok = 1;
                  }
                  if (lanes_ok == 1) {
                    then_ref = pipeline_expr_if_then_ref_at(arena, expr_ref);
                    else_ref = pipeline_expr_if_else_ref_at(arena, expr_ref);
                    step = 0;
                    while (step < 2) {
                      arm_ref = 0;
                      if (step == 0) {
                        arm_ref = then_ref;
                      }
                      if (step == 1) {
                        arm_ref = else_ref;
                      }
                      if (arm_ref > 0) {
                        arm_k = pipeline_expr_kind_ord_at(arena, arm_ref);
                        if (arm_k == 46) {
                          arm_n = pipeline_expr_array_lit_num_elems_at(
                            arena, arm_ref);
                          if (arm_n == want_n) {
                            pipeline_expr_set_resolved_type_ref(
                              arena, arm_ref, pt);
                          }
                        }
                        if (arm_k == 26) {
                          block_ref = pipeline_expr_block_ref_at(arena, arm_ref);
                          if (block_ref > 0) {
                            tail = typeck_block_expr_value_ref(arena, block_ref);
                            if (tail > 0) {
                              tail_k = pipeline_expr_kind_ord_at(arena, tail);
                              if (tail_k == 46) {
                                arm_n = pipeline_expr_array_lit_num_elems_at(
                                  arena, tail);
                                if (arm_n == want_n) {
                                  pipeline_expr_set_resolved_type_ref(
                                    arena, tail, pt);
                                }
                              }
                            }
                          }
                        }
                      }
                      step = step + 1;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    rc = typeck_check_expr_if_ternary__demoted(
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
    kind = pipeline_expr_kind_ord_at(arena, expr_ref);
    if (kind != ord_ternary) {
      return 0;
    }
    then_ref = pipeline_expr_if_then_ref_at(arena, expr_ref);
    else_ref = pipeline_expr_if_else_ref_at(arena, expr_ref);
    /*
     * The demoted body already required the two arm types to match
     * and stored that i32 on this ternary. The stamp returns 1 only
     * for a non-null INT_LIT or a kind-22 / kind-23 chain, and it
     * rewrites that arm. Overwrite the ternary only when both arms
     * hit, so a binop arm stays the demoted i32. PLATFORM: SHARED.
     */
    if (then_ref > 0) {
      stamped_then = typeck_stamp_i32_vector_int_splat(
        arena, then_ref, return_type_ref);
    }
    if (else_ref > 0) {
      stamped_else = typeck_stamp_i32_vector_int_splat(
        arena, else_ref, return_type_ref);
    }
    if (stamped_then == 1) {
      if (stamped_else == 1) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, return_type_ref);
      }
    }
    return 0;
  }
}
