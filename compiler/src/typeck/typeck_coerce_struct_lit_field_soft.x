// knife256/10.2 Cap tip linked body of
// typeck_coerce_struct_lit_field_inits_to_layout.
// The mega stamps a zero INT_LIT onto a TYPE_VECTOR field and then
// requires the init type to equal the field type. A non-zero INT_LIT
// stays i32, so `H { v: 3 }` is an assignment mismatch. The same
// typeck_stamp_i32_vector_int_splat that let, return, and call
// arguments use runs here, after the field type is known, then the
// demoted body sees equal types. Stamping inside the overload score
// would make pick(3) prefer Vec8i. This function does not.
// PLATFORM: SHARED — the type rule is the same on macOS, Ubuntu, and
// Windows. The demote step that makes this symbol win is Mach-O only.

export extern "C" function typeck_coerce_struct_lit_field_inits_to_layout__demoted(
  module: *u8, arena: *u8, expr_ref: i32, base_ty: i32): i32;
export extern "C" function typeck_stamp_i32_vector_int_splat(
  arena: *u8, init_ref: i32, decl_ty_ref: i32): i32;
export extern "C" function pipeline_expr_struct_lit_num_fields(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_struct_lit_init_ref(arena: *u8, expr_ref: i32, fi: i32): i32;
export extern "C" function pipeline_expr_struct_lit_type_name_len(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_struct_lit_type_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern "C" function pipeline_expr_struct_lit_field_name_len(arena: *u8, expr_ref: i32, fi: i32): i32;
export extern "C" function pipeline_expr_struct_lit_field_name_into(
  arena: *u8, expr_ref: i32, fi: i32, out: *u8): void;
export extern "C" function typeck_get_field_type_ref_from_layout(
  module: *u8, type_name: *u8, type_name_len: i32, field_name: *u8, field_name_len: i32): i32;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_if_then_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_if_else_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_block_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function typeck_block_expr_value_ref(arena: *u8, block_ref: i32): i32;
export extern "C" function pipeline_expr_set_resolved_type_ref(
  arena: *u8, expr_ref: i32, ty: i32): void;

/**
 * Stamp a Vec8i field init that is an i32 literal chain, then run the
 * old field coerce.
 * @param module *u8 — layout module; null defers to the demoted body
 * @param arena *u8 — AST arena; null defers
 * @param expr_ref i32 — EXPR_STRUCT_LIT; <= 0 defers
 * @param base_ty i32 — expected struct type; the demoted body still
 *   applies generic substitution. This stamp uses the layout field
 *   type. A kind-13 field is not a type parameter, so that substitution
 *   returns 0 and the layout type is the one the equality check uses.
 * @return i32 — the demoted coerce result
 * A name longer than 63 bytes is left to the demoted body. Kind 24,
 * a float literal, and a non-vector field are not stamped. An if or
 * a ternary is stamped only when both arms are a non-null INT_LIT or
 * a kind-22 / kind-23 chain. The field inits were checked with
 * expected 0, so the block and ternary checkers did not see this
 * field type. One arm that is not a literal chain leaves the demoted
 * type. PLATFORM: SHARED.
 */
/**
 * Stamp one if or ternary arm when the field type is a Vec8i.
 * @param arena *u8 — AST arena; null is not passed
 * @param arm_ref i32 — then or else arm; <= 0 returns 0
 * @param field_ty i32 — layout field type
 * @return i32 — 1 when that arm is a literal chain and was stamped
 * A block arm stamps its value tail and sets the block expr type.
 * A bare arm is the ternary literal itself. A VAR, a binop, kind 24,
 * and a float return 0 without a write. PLATFORM: SHARED.
 */
function typeck_struct_field_stamp_arm(
  arena: *u8, arm_ref: i32, field_ty: i32): i32 {
  unsafe {
    let ord_block: i32 = 26;
    let ko: i32 = 0;
    let block_ref: i32 = 0;
    let tail: i32 = 0;
    let stamped: i32 = 0;
    if (arm_ref <= 0) {
      return 0;
    }
    ko = pipeline_expr_kind_ord_at(arena, arm_ref);
    if (ko == ord_block) {
      block_ref = pipeline_expr_block_ref_at(arena, arm_ref);
      if (block_ref <= 0) {
        return 0;
      }
      tail = typeck_block_expr_value_ref(arena, block_ref);
      if (tail <= 0) {
        return 0;
      }
      /*
       * The block was checked with expected 0, so its tail is still
       * i32. The stamp rewrites that tail only for a literal chain.
       * PLATFORM: SHARED.
       */
      stamped = typeck_stamp_i32_vector_int_splat(arena, tail, field_ty);
      if (stamped == 1) {
        pipeline_expr_set_resolved_type_ref(arena, arm_ref, field_ty);
      }
      return stamped;
    }
    return typeck_stamp_i32_vector_int_splat(arena, arm_ref, field_ty);
  }
}

#[no_mangle]
export function typeck_coerce_struct_lit_field_inits_to_layout(
  module: *u8, arena: *u8, expr_ref: i32, base_ty: i32): i32 {
  unsafe {
    let nf: i32 = 0;
    let nlen: i32 = 0;
    let flen: i32 = 0;
    let fi: i32 = 0;
    let init_r: i32 = 0;
    let ftr: i32 = 0;
    let stamped: i32 = 0;
    let ko_arm: i32 = 0;
    let then_ref: i32 = 0;
    let else_ref: i32 = 0;
    let stamped_then: i32 = 0;
    let stamped_else: i32 = 0;
    let name_buf: u8[64];
    let field_buf: u8[64];
    if (module == 0 as *u8) {
      return typeck_coerce_struct_lit_field_inits_to_layout__demoted(
        module, arena, expr_ref, base_ty);
    }
    if (arena == 0 as *u8) {
      return typeck_coerce_struct_lit_field_inits_to_layout__demoted(
        module, arena, expr_ref, base_ty);
    }
    if (expr_ref <= 0) {
      return typeck_coerce_struct_lit_field_inits_to_layout__demoted(
        module, arena, expr_ref, base_ty);
    }
    nf = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
    nlen = pipeline_expr_struct_lit_type_name_len(arena, expr_ref);
    /*
     * The demoted body returns success without looking at fields when
     * the lit has no type name yet. Do not invent a name here.
     * PLATFORM: SHARED.
     */
    if (nf > 0) {
      if (nlen > 0) {
        if (nlen <= 63) {
          pipeline_expr_struct_lit_type_name_into(arena, expr_ref, &name_buf[0]);
          fi = 0;
          while (fi < nf) {
            flen = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, fi);
            if (flen > 0) {
              if (flen <= 63) {
                pipeline_expr_struct_lit_field_name_into(arena, expr_ref, fi, &field_buf[0]);
                ftr = typeck_get_field_type_ref_from_layout(module, &name_buf[0], nlen, &field_buf[0], flen);
                init_r = pipeline_expr_struct_lit_init_ref(arena, expr_ref, fi);
                if (init_r > 0) {
                  if (ftr > 0) {
                    stamped = typeck_stamp_i32_vector_int_splat(arena, init_r, ftr);
                    /*
                     * A literal init is already stamped above. An if
                     * (kind 25) or a ternary (kind 27) was checked
                     * with expected 0, so both arms are still i32.
                     * Stamp each arm with this field type. Both hits
                     * set the if or ternary itself, and the demoted
                     * equality then sees the vector. One miss leaves
                     * the i32. PLATFORM: SHARED.
                     */
                    if (stamped == 0) {
                      ko_arm = pipeline_expr_kind_ord_at(arena, init_r);
                      if (ko_arm == 25) {
                        stamped_then = 0;
                        stamped_else = 0;
                        then_ref = pipeline_expr_if_then_ref_at(arena, init_r);
                        else_ref = pipeline_expr_if_else_ref_at(arena, init_r);
                        stamped_then = typeck_struct_field_stamp_arm(arena, then_ref, ftr);
                        stamped_else = typeck_struct_field_stamp_arm(arena, else_ref, ftr);
                        if (stamped_then == 1) {
                          if (stamped_else == 1) {
                            pipeline_expr_set_resolved_type_ref(arena, init_r, ftr);
                            stamped = 1;
                          }
                        }
                      }
                      if (ko_arm == 27) {
                        stamped_then = 0;
                        stamped_else = 0;
                        then_ref = pipeline_expr_if_then_ref_at(arena, init_r);
                        else_ref = pipeline_expr_if_else_ref_at(arena, init_r);
                        stamped_then = typeck_struct_field_stamp_arm(arena, then_ref, ftr);
                        stamped_else = typeck_struct_field_stamp_arm(arena, else_ref, ftr);
                        if (stamped_then == 1) {
                          if (stamped_else == 1) {
                            pipeline_expr_set_resolved_type_ref(arena, init_r, ftr);
                            stamped = 1;
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
            fi = fi + 1;
          }
        }
      }
    }
    /*
     * stamped is read so the write stays live. The demoted body does
     * not clear a kind-13 resolved type before the equality check.
     * Both arms call it. PLATFORM: SHARED.
     */
    if (stamped == 1) {
      return typeck_coerce_struct_lit_field_inits_to_layout__demoted(
        module, arena, expr_ref, base_ty);
    }
    return typeck_coerce_struct_lit_field_inits_to_layout__demoted(
      module, arena, expr_ref, base_ty);
  }
}
