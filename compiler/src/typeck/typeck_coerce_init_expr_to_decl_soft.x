// knife256/10.2 Cap tip linked body of typeck_coerce_init_expr_to_decl.
// Source authority is the i32 TYPE_VECTOR splat in typeck.x. Cap tip -c
// of that mega emits a hollow mov w0,#0; ret, so this thin is what the
// link runs. An INT_LIT, unary minus / bitwise not of an INT_LIT, or
// one, two, three, four, or five more unaries of that unary, into a TYPE_VECTOR
// of i32 is stamped with the declared type. A seventh unary calls the
// demoted body. A TYPE_VECTOR of f32 also stamps a FLOAT_LIT or one
// unary minus of a FLOAT_LIT. A second unary and a bitwise not call
// the demoted body.
// PLATFORM: SHARED — type rule is the same on macOS, Ubuntu, and Windows.
// The demote/retarget step that makes this symbol win is Mach-O only.

export extern "C" function typeck_coerce_init_expr_to_decl__demoted(
  module: *u8, arena: *u8, init_ref: i32, decl_ty_ref: i32): i32;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_arena_num_types(arena: *u8): i32;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_is_null_keyword_c(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_set_resolved_type_ref(arena: *u8, expr_ref: i32, ty: i32): void;

/**
 * Stamp an i32 scalar splat onto a TYPE_VECTOR, else call demoted.
 * @param module *u8 — caller module; passed through, may be null
 * @param arena *u8 — AST arena; null defers to the demoted body
 * @param init_ref i32 — initializer expr; <= 0 defers
 * @param decl_ty_ref i32 — declared type; <= 0 defers
 * @return i32 — 1 when the vector splat is stamped, demoted result otherwise
 * Vec8i is kind 13 of i32. Named i32x8 is kind 8 and already passes the
 * soft equality, so `let v: i32x8 = ~1` typechecks. Kind 13 does not, so
 * `let v: Vec8i = ~1` was "expected ?, found i32". The vector let-init
 * already splats INT_LIT, unary -/~ of an INT_LIT, and one, two,
 * three, four, or five more unary -/~ of that unary. A seventh
 * unary, a variable, a binop,
 * and keyword null stay on the demoted body. A TYPE_VECTOR of f32
 * stamps a FLOAT_LIT or one unary minus of a FLOAT_LIT. A second
 * unary of that float stays on the demoted body.
 * Two compares, not a chained && : the bootstrap image clobbers the
 * register a chained compare reuses. An out-of-range expr ref is not
 * counted here: pipeline_expr_kind_ord_at already returns -1, which is
 * not INT_LIT, so the splat stays off and the demoted body rejects it.
 * PLATFORM: SHARED — same type rule on every host.
 */
#[no_mangle]
export function typeck_coerce_init_expr_to_decl(
  module: *u8, arena: *u8, init_ref: i32, decl_ty_ref: i32): i32 {
  unsafe {
    let ord_lit: i32 = 0;
    let ord_neg: i32 = 22;
    let ord_bitnot: i32 = 23;
    let ord_vector: i32 = 13;
    let ord_i32: i32 = 0;
    let decl_kind: i32 = 0;
    let init_kind: i32 = 0;
    let splat_ok: i32 = 0;
    let elem_ref: i32 = 0;
    let elem_k: i32 = 0;
    let op_ref: i32 = 0;
    let op_k: i32 = 0;
    let inner_ref: i32 = 0;
    let inner_k: i32 = 0;
    let deep_ref: i32 = 0;
    let deep_k: i32 = 0;
    let quad_ref: i32 = 0;
    let quad_k: i32 = 0;
    let pent_ref: i32 = 0;
    let pent_k: i32 = 0;
    let hex_ref: i32 = 0;
    let hex_k: i32 = 0;
    let ntypes: i32 = 0;
    if (arena == 0 as *u8 || init_ref <= 0 || decl_ty_ref <= 0) {
      return typeck_coerce_init_expr_to_decl__demoted(
        module, arena, init_ref, decl_ty_ref);
    }
    ntypes = pipeline_arena_num_types(arena);
    if (decl_ty_ref > ntypes) {
      return typeck_coerce_init_expr_to_decl__demoted(
        module, arena, init_ref, decl_ty_ref);
    }
    decl_kind = pipeline_type_kind_ord_at(arena, decl_ty_ref);
    init_kind = pipeline_expr_kind_ord_at(arena, init_ref);
    /*
     * Only a real TYPE_VECTOR of i32. Out-of-range element refs stay
     * on the demoted body. PLATFORM: SHARED.
     */
    if (decl_kind == ord_vector) {
      elem_ref = pipeline_type_elem_ref_at(arena, decl_ty_ref);
      if (elem_ref > 0) {
        if (elem_ref <= ntypes) {
          elem_k = pipeline_type_kind_ord_at(arena, elem_ref);
          if (elem_k == ord_i32) {
            if (init_kind == ord_lit) {
              if (pipeline_expr_is_null_keyword_c(arena, init_ref) == 0) {
                splat_ok = 1;
              }
            }
            if (init_kind == ord_neg) {
              op_ref = pipeline_expr_unary_operand_ref_at(arena, init_ref);
            }
            if (init_kind == ord_bitnot) {
              op_ref = pipeline_expr_unary_operand_ref_at(arena, init_ref);
            }
            if (op_ref > 0) {
              op_k = pipeline_expr_kind_ord_at(arena, op_ref);
              if (op_k == ord_lit) {
                if (pipeline_expr_is_null_keyword_c(arena, op_ref) == 0) {
                  splat_ok = 1;
                }
              }
              /*
               * One more unary of a non-null INT_LIT, and one, two, or
               * four unaries beyond that: ~(-3), ~(~(-3)), ~(~(~(-3))),
               * -(~(~(~(-3)))), and -(~(~(~(~(-3))))).
               * A seventh unary is kind 22 or 23 at the deepest operand,
               * not INT_LIT, so it stays unstamped. The emitter folds
               * six and declines seven. VAR, binop, CALL, keyword null, and
               * LOGNOT stay off. PLATFORM: SHARED.
               */
              if (op_k == ord_neg) {
                inner_ref = pipeline_expr_unary_operand_ref_at(arena, op_ref);
              }
              if (op_k == ord_bitnot) {
                inner_ref = pipeline_expr_unary_operand_ref_at(arena, op_ref);
              }
              if (inner_ref > 0) {
                inner_k = pipeline_expr_kind_ord_at(arena, inner_ref);
                if (inner_k == ord_lit) {
                  if (pipeline_expr_is_null_keyword_c(arena, inner_ref) == 0) {
                    splat_ok = 1;
                  }
                }
                if (inner_k == ord_neg) {
                  deep_ref = pipeline_expr_unary_operand_ref_at(arena, inner_ref);
                }
                if (inner_k == ord_bitnot) {
                  deep_ref = pipeline_expr_unary_operand_ref_at(arena, inner_ref);
                }
                if (deep_ref > 0) {
                  deep_k = pipeline_expr_kind_ord_at(arena, deep_ref);
                  if (deep_k == ord_lit) {
                    if (pipeline_expr_is_null_keyword_c(arena, deep_ref) == 0) {
                      splat_ok = 1;
                    }
                  }
                  if (deep_k == ord_neg) {
                    quad_ref = pipeline_expr_unary_operand_ref_at(arena, deep_ref);
                  }
                  if (deep_k == ord_bitnot) {
                    quad_ref = pipeline_expr_unary_operand_ref_at(arena, deep_ref);
                  }
                  if (quad_ref > 0) {
                    quad_k = pipeline_expr_kind_ord_at(arena, quad_ref);
                    if (quad_k == ord_lit) {
                      if (pipeline_expr_is_null_keyword_c(arena, quad_ref) == 0) {
                        splat_ok = 1;
                      }
                    }
                    /*
                     * Fifth unary of a non-null INT_LIT. Kind 22 and kind 23 are
                     * separate compares. One more unary of this wrapper is stamped below. A seventh unary stays 22 or 23, so it is not
                     * stamped. PLATFORM: SHARED.
                     */

                    if (quad_k == ord_neg) {
                      pent_ref = pipeline_expr_unary_operand_ref_at(arena, quad_ref);
                    }
                    if (quad_k == ord_bitnot) {
                      pent_ref = pipeline_expr_unary_operand_ref_at(arena, quad_ref);
                    }
                    if (pent_ref > 0) {
                      pent_k = pipeline_expr_kind_ord_at(arena, pent_ref);
                      if (pent_k == ord_lit) {
                        if (pipeline_expr_is_null_keyword_c(arena, pent_ref) == 0) {
                          splat_ok = 1;
                        }
                      }
                      /*
                       * Sixth unary of a non-null INT_LIT. Kind 22 and kind 23 are
                       * separate compares. A seventh unary stays 22 or 23, so it is
                       * not stamped. The emitter folds six and declines seven.
                       * PLATFORM: SHARED.
                       */
                      if (pent_k == ord_neg) {
                        hex_ref = pipeline_expr_unary_operand_ref_at(arena, pent_ref);
                      }
                      if (pent_k == ord_bitnot) {
                        hex_ref = pipeline_expr_unary_operand_ref_at(arena, pent_ref);
                      }
                      if (hex_ref > 0) {
                        hex_k = pipeline_expr_kind_ord_at(arena, hex_ref);
                        if (hex_k == ord_lit) {
                          if (pipeline_expr_is_null_keyword_c(arena, hex_ref) == 0) {
                            splat_ok = 1;
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          /*
           * TYPE_VECTOR of f32 (Vec4f). A FLOAT_LIT, or one unary minus
           * of a FLOAT_LIT, is the same splat the emitter fills.
           * Kind 1 and kind 22 are separate compares. A second unary
           * stays kind 22, so it is not stamped. Bitwise not stays off.
           * An i32 element does not enter. PLATFORM: SHARED.
           */
          if (elem_k == 14) {
            let fop: i32 = 0;
            let fop_k: i32 = 0;
            if (init_kind == 1) {
              splat_ok = 1;
            }
            if (init_kind == 22) {
              fop = pipeline_expr_unary_operand_ref_at(arena, init_ref);
            }
            if (fop > 0) {
              fop_k = pipeline_expr_kind_ord_at(arena, fop);
              if (fop_k == 1) {
                splat_ok = 1;
              }
            }
          }
        }
      }
    }
    if (splat_ok == 1) {
      pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
      return 1;
    }
    return typeck_coerce_init_expr_to_decl__demoted(
      module, arena, init_ref, decl_ty_ref);
  }
}
