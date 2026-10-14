// knife256/10.2 Cap tip linked body of typeck_check_expr_assign.
// Source authority is the i32 TYPE_VECTOR splat pre-stamp in typeck.x.
// Cap tip -c of that mega emits a hollow mov w0,#0; ret, so this thin
// is what the link runs. Plain ASSIGN (kind 28) of an INT_LIT, of
// unary minus / bitwise not of an INT_LIT, or of one or two more
// unaries of that unary, onto a TYPE_VECTOR of i32 stamps the RHS
// with the LHS type, then calls the demoted body. A fourth unary
// calls the demoted body with no stamp.
// Every other assign calls the demoted body with no stamp.
// PLATFORM: SHARED — type rule is the same on macOS, Ubuntu, and Windows.
// The demote/retarget step that makes this symbol win is Mach-O only.

export extern "C" function typeck_check_expr_assign__demoted(
  module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern "C" function typeck_check_expr(
  module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_binop_right_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_is_null_keyword_c(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_arena_num_types(arena: *u8): i32;
export extern "C" function pipeline_expr_set_resolved_type_ref(arena: *u8, expr_ref: i32, ty: i32): void;

/**
 * Pre-stamp an i32 scalar splat on plain ASSIGN, then call demoted.
 * @param module *u8 — caller module; null defers to the demoted body
 * @param arena *u8 — AST arena; null defers to the demoted body
 * @param expr_ref i32 — assign expr; <= 0 defers to the demoted body
 * @param return_type_ref i32 — enclosing return type, passed through
 * @param ctx *u8 — dep context, passed through; may be null
 * @return i32 — demoted result, or -1 when the LHS check fails
 * Vec8i is kind 13 of i32. Named i32x4 / i32x8 are kind 8 and already
 * accept `v = 1` and `v = ~1` through soft equality. Kind 13 does not,
 * so `v = 1` / `h.v = ~1` was "expected ?, found i32". The lit checker
 * no-ops when the RHS is already resolved, so this stamp survives
 * demoted assign. The unary checker keeps the stamp for an INT_LIT
 * operand, for one more unary of that lit, and for one unary beyond
 * that. A bare INT_LIT
 * is stamped when the LHS is a VAR or a FIELD.
 * The field assign emitter fills every lane of an INT_LIT wider than
 * 16 bytes, and kind 22 or 23 calls the same let-init, so
 * `h.v = ~(-3)` on Vec8i is the same splat as `v = ~(-3)`.
 * Keyword null stays unstamped. Unary minus / bitwise not of an
 * INT_LIT, and one more unary of that, is stamped for a VAR or a
 * FIELD. A fourth unary, a binop, LOGNOT, compound assign, deref, and
 * a float vector are not stamped. A failed LHS check does not call
 * demoted, so the diagnostic is not emitted twice.
 * Two compares, not a chained && : the bootstrap image clobbers the
 * register a chained compare reuses.
 * PLATFORM: SHARED — same type rule on every host.
 */
#[no_mangle]
export function typeck_check_expr_assign(
  module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  unsafe {
    let ord_assign: i32 = 28;
    let ord_lit: i32 = 0;
    let ord_var: i32 = 3;
    let ord_neg: i32 = 22;
    let ord_bitnot: i32 = 23;
    let ord_field: i32 = 44;
    let ord_vector: i32 = 13;
    let ord_i32: i32 = 0;
    let expr_kind: i32 = 0;
    let left_ref: i32 = 0;
    let right_ref: i32 = 0;
    let lt: i32 = 0;
    let ntypes: i32 = 0;
    let rc: i32 = 0;
    let elem_ref: i32 = 0;
    let elem_k: i32 = 0;
    let rhs_kind: i32 = 0;
    let lhs_kind: i32 = 0;
    let op_ref: i32 = 0;
    let op_k: i32 = 0;
    let inner_ref: i32 = 0;
    let inner_k: i32 = 0;
    let deep_ref: i32 = 0;
    let deep_k: i32 = 0;
    let splat_ok: i32 = 0;
    if (module == 0 as *u8 || arena == 0 as *u8 || expr_ref <= 0) {
      return typeck_check_expr_assign__demoted(
        module, arena, expr_ref, return_type_ref, ctx);
    }
    expr_kind = pipeline_expr_kind_ord_at(arena, expr_ref);
    if (expr_kind != ord_assign) {
      return typeck_check_expr_assign__demoted(
        module, arena, expr_ref, return_type_ref, ctx);
    }
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    /*
     * A missing LHS is the demoted body's job (it may accept an empty
     * assign). Do not typecheck a null ref here.
     * PLATFORM: SHARED.
     */
    if (left_ref <= 0) {
      return typeck_check_expr_assign__demoted(
        module, arena, expr_ref, return_type_ref, ctx);
    }
    rc = typeck_check_expr(module, arena, left_ref, 0, ctx);
    if (rc != 0) {
      return 0 - 1;
    }
    /*
     * Only a real TYPE_VECTOR of i32. Out-of-range element refs stay
     * unstamped. A non-null INT_LIT is stamped for a VAR or a FIELD.
     * Unary minus / bitwise not of one, and exactly one more unary of
     * that lit, or one unary beyond that, is stamped for a VAR or a
     * FIELD. A fourth unary stays
     * unstamped.
     * PLATFORM: SHARED — element kind is the type rule, not a host ABI.
     */
    lt = pipeline_expr_resolved_type_ref(arena, left_ref);
    ntypes = pipeline_arena_num_types(arena);
    if (lt > 0) {
      if (lt <= ntypes) {
        if (pipeline_type_kind_ord_at(arena, lt) == ord_vector) {
          elem_ref = pipeline_type_elem_ref_at(arena, lt);
          if (elem_ref > 0) {
            if (elem_ref <= ntypes) {
              elem_k = pipeline_type_kind_ord_at(arena, elem_ref);
              if (elem_k == ord_i32) {
                if (right_ref > 0) {
                  lhs_kind = pipeline_expr_kind_ord_at(arena, left_ref);
                  rhs_kind = pipeline_expr_kind_ord_at(arena, right_ref);
                  if (rhs_kind == ord_lit) {
                    if (pipeline_expr_is_null_keyword_c(arena, right_ref) == 0) {
                      if (lhs_kind == ord_var) {
                        splat_ok = 1;
                      }
                      if (lhs_kind == ord_field) {
                        splat_ok = 1;
                      }
                    }
                  }
                  if (rhs_kind == ord_neg) {
                    op_ref = pipeline_expr_unary_operand_ref_at(arena, right_ref);
                  }
                  if (rhs_kind == ord_bitnot) {
                    op_ref = pipeline_expr_unary_operand_ref_at(arena, right_ref);
                  }
                  if (op_ref > 0) {
                    op_k = pipeline_expr_kind_ord_at(arena, op_ref);
                    if (op_k == ord_lit) {
                      if (pipeline_expr_is_null_keyword_c(arena, op_ref) == 0) {
                        if (lhs_kind == ord_var) {
                          splat_ok = 1;
                        }
                        if (lhs_kind == ord_field) {
                          splat_ok = 1;
                        }
                      }
                    }
                    /*
                     * One more unary of a non-null INT_LIT, and exactly
                     * one unary beyond that, still only a VAR or a
                     * FIELD. A fourth unary, an i32 variable, a binop,
                     * keyword null, and LOGNOT stay unstamped. The
                     * emitter folds four and declines five.
                     * PLATFORM: SHARED.
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
                          if (lhs_kind == ord_var) {
                            splat_ok = 1;
                          }
                          if (lhs_kind == ord_field) {
                            splat_ok = 1;
                          }
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
                            if (lhs_kind == ord_var) {
                              splat_ok = 1;
                            }
                            if (lhs_kind == ord_field) {
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
          }
        }
      }
    }
    if (splat_ok == 1) {
      pipeline_expr_set_resolved_type_ref(arena, right_ref, lt);
    }
    return typeck_check_expr_assign__demoted(
      module, arena, expr_ref, return_type_ref, ctx);
  }
}
