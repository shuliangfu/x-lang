// knife256/10.2 Cap tip linked body of typeck_check_expr_assign.
// Source authority is the i32 TYPE_VECTOR splat pre-stamp in typeck.x.
// Cap tip -c of that mega emits a hollow mov w0,#0; ret, so this thin
// is what the link runs. Plain ASSIGN (kind 28) of an INT_LIT, of
// unary minus / bitwise not of an INT_LIT, or of one, two, three, or
// five more unaries of that unary, onto a TYPE_VECTOR of i32 stamps the RHS
// with the LHS type, then calls the demoted body. A constant non-negative
// INDEX of that vector is stamped the same way. A dynamic index is not:
// its store is still one word. The walk accepts
// kind 22 and kind 23 through 32 steps. Probes covered one through
// eight minuses and the seven-deep mixed chain. A 33rd step calls
// the demoted body with no stamp. A TYPE_VECTOR of f32 also
// stamps a bare FLOAT_LIT, one unary minus of a FLOAT_LIT, one more
// unary minus of that, one unary beyond that, and one unary beyond
// that, when the LHS is a VAR or a FIELD. Two minuses cancel. Three
// minuses apply the sign once. Four minuses cancel again. Five
// minuses apply the sign once more. Six minuses cancel again. Seven
// minuses apply the sign once more. Eight minuses cancel again.
// Nine minuses apply the sign once more. Ten minuses cancel again.
// Eleven minuses apply the sign once more. Twelve minuses cancel
// again. Thirteen minuses apply the sign once more. Fourteen
// minuses cancel again. Fifteen minuses apply the sign once
// more. The float-lit
// checker keeps an already-resolved type. A chain of at most 32 unary minuses of a FLOAT_LIT is stamped.
// One more unary and a bitwise not call the demoted body with no stamp.
// Every other assign calls the demoted body with no stamp.
// A plain ASSIGN of an ARRAY_LIT onto an array or slice of an i32
// TYPE_VECTOR stamps each integer element with that vector type
// before the demoted body. The demoted walker only stamps integer 0
// onto kind 13, so `a = [3, -3]` stayed i32. check_expr keeps an
// already-resolved INT_LIT and an already-stamped i32-vector unary.
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
export extern "C" function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_int_val_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_is_null_keyword_c(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_arena_num_types(arena: *u8): i32;
export extern "C" function pipeline_expr_set_resolved_type_ref(arena: *u8, expr_ref: i32, ty: i32): void;
export extern "C" function typeck_stamp_arr_i32_vec_elems(
  arena: *u8, init_ref: i32, decl_ty_ref: i32): i32;

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
 * operand, for one more unary of that lit, and for one, two, three, or four
 * unaries beyond that. A bare INT_LIT
 * is stamped when the LHS is a VAR, a FIELD, or a constant
 * non-negative INDEX. A dynamic or negative index stays unstamped.
 * The field assign emitter fills every lane of an INT_LIT wider than
 * 16 bytes, and kind 22 or 23 calls the same let-init, so
 * `h.v = ~(-3)` on Vec8i is the same splat as `v = ~(-3)`.
 * The index emitter fills that same RHS when the index is a
 * non-negative INT_LIT and the element is wider than 16 bytes.
 * Keyword null stays unstamped. Unary minus / bitwise not of an
 * INT_LIT, and a kind 22 / kind 23 chain around it, is stamped for a
 * VAR, a FIELD, or that constant INDEX. Probes covered one through
 * eight minuses and the seven-deep mixed assign. A 33rd step, a binop, LOGNOT, compound
 * assign, and deref are not stamped. A TYPE_VECTOR of f32 stamps a bare FLOAT_LIT, one
 * unary minus of a FLOAT_LIT, one more unary minus of that, one unary
 * beyond that, one unary beyond that, and one unary beyond that, for
 * a VAR or a FIELD. Two minuses cancel. Three minuses apply the sign
 * once. Four minuses cancel again. Five minuses apply the sign once
 * more. Six minuses cancel again. Seven minuses apply the sign once
 * more. Eight minuses cancel again. Nine minuses apply the sign once
 * more. Ten minuses cancel again. Eleven minuses apply the sign once
 * more. Twelve minuses cancel again. Thirteen minuses apply the sign
 * once more. Fourteen minuses cancel again. Fifteen minuses apply
 * the sign once more. The float-lit checker keeps an
 * already-resolved type, so the
 * bare stamp survives. The unary checker keeps the one-deep, two-deep,
 * three-deep, four-deep, five-deep, six-deep, seven-deep, eight-deep,
 * nine-deep, ten-deep, eleven-deep, twelve-deep, thirteen-deep,
 * fourteen-deep, and fifteen-deep
 * stamps. At most 32 unary minuses of that float are stamped. One more
 * unary and a bitwise not of that float are not stamped.
 * An ARRAY_LIT assigned to an array or slice whose element is a
 * TYPE_VECTOR of i32 stamps each integer element through
 * typeck_stamp_arr_i32_vec_elems, then still calls demoted. A VAR
 * element, a binop, a nested ARRAY_LIT, kind 24, and kind 8 stay
 * unstamped. The demoted walker then checks equality.
 * A failed LHS check does not call
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
    let ord_index: i32 = 47;
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
    let quad_ref: i32 = 0;
    let quad_k: i32 = 0;
    let pent_ref: i32 = 0;
    let pent_k: i32 = 0;
    let hex_ref: i32 = 0;
    let hex_k: i32 = 0;
    let u_go: i32 = 0;
    let u_deep: i32 = 0;
    let u_stop: i32 = 0;
    let lhs_ok: i32 = 0;
    let splat_ok: i32 = 0;
    let idx_ref: i32 = 0;
    let idx_k: i32 = 0;
    let idx_lit: i32 = 0;
    let idx_val: i32 = 0;
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
     * unstamped. A non-null INT_LIT is stamped for a VAR, a FIELD, or
     * a constant non-negative INDEX. Unary minus / bitwise not of one
     * is stamped for those same left sides. The walk stops at 32.
     * Probes covered through eight minuses. A 33rd step stays
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
                  /*
                   * INDEX is stamped only when its index expr is a
                   * non-negative INT_LIT. That is the arm the Darwin
                   * filler splats. A VAR index stays on the demoted
                   * mismatch instead of a one-word store.
                   * PLATFORM: SHARED — the type rule, not the store.
                   */
                  idx_lit = 0;
                  if (lhs_kind == ord_index) {
                    idx_ref = pipeline_expr_index_index_ref(arena, left_ref);
                    if (idx_ref > 0) {
                      idx_k = pipeline_expr_kind_ord_at(arena, idx_ref);
                      if (idx_k == ord_lit) {
                        if (pipeline_expr_is_null_keyword_c(arena, idx_ref) == 0) {
                          idx_val = pipeline_expr_int_val_at(arena, idx_ref);
                          if (idx_val >= 0) {
                            idx_lit = 1;
                          }
                        }
                      }
                    }
                  }
                  if (rhs_kind == ord_lit) {
                    if (pipeline_expr_is_null_keyword_c(arena, right_ref) == 0) {
                      if (lhs_kind == ord_var) {
                        splat_ok = 1;
                      }
                      if (lhs_kind == ord_field) {
                        splat_ok = 1;
                      }
                      if (idx_lit == 1) {
                        splat_ok = 1;
                      }
                    }
                  }
                  /*
                   * Walk kind 22 and kind 23 together, at most 32 steps.
                   * The innermost expr must be a non-null INT_LIT, and
                   * the left side must be a VAR, a FIELD, or a constant
                   * non-negative INDEX. Kind 24 does
                   * not enter. A longer chain stays unstamped. Probes covered
                   * through eight minuses. Depth 32 was not run. One loop,
                   * not a seventh local. PLATFORM: SHARED.
                   */
                  if (rhs_kind == ord_neg) {
                    u_go = 1;
                  }
                  if (rhs_kind == ord_bitnot) {
                    u_go = 1;
                  }
                  if (lhs_kind == ord_var) {
                    lhs_ok = 1;
                  }
                  if (lhs_kind == ord_field) {
                    lhs_ok = 1;
                  }
                  if (idx_lit == 1) {
                    lhs_ok = 1;
                  }
                  if (u_go != 0) {
                    if (lhs_ok != 0) {
                      op_ref = right_ref;
                      op_k = rhs_kind;
                      u_deep = 0;
                      u_stop = 0;
                      while (u_stop == 0) {
                        if (u_deep < 32) {
                          if (op_k == ord_neg) {
                            inner_ref = pipeline_expr_unary_operand_ref_at(arena, op_ref);
                            if (inner_ref <= 0) {
                              op_k = -1;
                              u_stop = 1;
                            } else {
                              op_ref = inner_ref;
                              u_deep = u_deep + 1;
                              op_k = pipeline_expr_kind_ord_at(arena, op_ref);
                            }
                          } else {
                            if (op_k == ord_bitnot) {
                              inner_ref = pipeline_expr_unary_operand_ref_at(arena, op_ref);
                              if (inner_ref <= 0) {
                                op_k = -1;
                                u_stop = 1;
                              } else {
                                op_ref = inner_ref;
                                u_deep = u_deep + 1;
                                op_k = pipeline_expr_kind_ord_at(arena, op_ref);
                              }
                            } else {
                              u_stop = 1;
                            }
                          }
                        } else {
                          // Kind 0 is INT_LIT. A 33rd step must stay unstamped.
                          op_k = -1;
                          u_stop = 1;
                        }
                      }
                      if (op_k == ord_lit) {
                        if (u_deep > 0) {
                          if (pipeline_expr_is_null_keyword_c(arena, op_ref) == 0) {
                            splat_ok = 1;
                          }
                        }
                      }
                    }
                  }
                }
              }
              /*
               * TYPE_VECTOR of f32 (Vec4f). A bare FLOAT_LIT, one unary
               * minus of a FLOAT_LIT, one more unary minus of that, one
               * unary beyond that, one unary beyond that, and one
               * unary beyond that, on a VAR or a FIELD, is the splat
               * the let-init already fills. Two minuses cancel. Three
               * minuses apply the sign once. Four minuses cancel
               * again. Five minuses apply the sign once more. Six
               * minuses cancel again. Seven minuses apply the sign
               * once more. Eight minuses cancel again. Nine minuses
               * apply the sign once more. Ten minuses cancel again.
               * Eleven minuses apply the sign once more.
               * Twelve minuses cancel again.
               * Thirteen minuses apply the sign once more.
               * Fourteen minuses cancel again.
               * Fifteen minuses apply the sign once more.
               * Kind 22 and kind 1 are
               * separate compares. The float-lit checker keeps an
               * already-resolved type, so the kind-1 stamp survives.
               * The unary checker keeps the one-deep, two-deep,
               * three-deep, four-deep, five-deep, six-deep,
               * seven-deep, eight-deep, nine-deep, ten-deep, eleven-deep,
               * twelve-deep, thirteen-deep, fourteen-deep, and fifteen-deep stamps. At most 32 unary minuses are stamped. One more
               * unary stays kind 22.
               * Bitwise not stays off.
               * An i32 element does not enter.
               * PLATFORM: SHARED.
               */
              if (elem_k == 14) {
                let fop: i32 = 0;
                let fop_k: i32 = 0;
                let f_in: i32 = 0;
                let f_in_k: i32 = 0;
                let f_deep: i32 = 0;
                let f_deep_k: i32 = 0;
                let f_quad: i32 = 0;
                let f_quad_k: i32 = 0;
                let f_pent: i32 = 0;
                let f_pent_k: i32 = 0;
                let f_hex: i32 = 0;
                let f_hex_k: i32 = 0;
                let f_sept: i32 = 0;
                let f_sept_k: i32 = 0;
                let f_oct: i32 = 0;
                let f_oct_k: i32 = 0;
                let f_nona: i32 = 0;
                let f_nona_k: i32 = 0;
                let f_deca: i32 = 0;
                let f_deca_k: i32 = 0;
                let f_undeca: i32 = 0;
                let f_undeca_k: i32 = 0;
                let f_duodeca: i32 = 0;
                let f_duodeca_k: i32 = 0;
                let f_tredeca: i32 = 0;
                let f_tredeca_k: i32 = 0;
                let f_quattuordeca: i32 = 0;
                let f_quattuordeca_k: i32 = 0;
                let f_quindecim: i32 = 0;
                let f_quindecim_k: i32 = 0;
                if (right_ref > 0) {
                  lhs_kind = pipeline_expr_kind_ord_at(arena, left_ref);
                  rhs_kind = pipeline_expr_kind_ord_at(arena, right_ref);
                  /*
                   * Walk EXPR_NEG (kind 22) until the operand is not another
                   * minus. The innermost must be a FLOAT_LIT (kind 1).
                   * An odd count applies the sign once in the emitter. An
                   * even count cancels. Stop at 32 steps so a corrupt kind-22
                   * cycle cannot hang the compile. One more minus stays
                   * declined. Kind 23 and kind 24 do not enter. This is a
                   * loop, not a recursive call: the frame is already near the
                   * cap-tip stack budget. The bound is its own compare. A
                   * chained && clobbers a register in the bootstrap image.
                   * PLATFORM: SHARED.
                   */
                  if (rhs_kind == ord_neg) {
                    f_in = right_ref;
                    f_deep = 0;
                    f_in_k = 22;
                    while (f_in_k == 22) {
                      if (f_deep < 32) {
                        f_quad = 0;
                        f_quad = pipeline_expr_unary_operand_ref_at(arena, f_in);
                        if (f_quad <= 0) {
                          f_in_k = 0;
                        } else {
                          f_in = f_quad;
                          f_deep = f_deep + 1;
                          f_in_k = pipeline_expr_kind_ord_at(arena, f_in);
                        }
                      } else {
                        f_in_k = 0;
                      }
                    }
                    if (f_in_k == 1) {
                      if (f_deep > 0) {
                        if (lhs_kind == ord_var) {
                          splat_ok = 1;
                        }
                        if (lhs_kind == ord_field) {
                          splat_ok = 1;
                        }
                      }
                    }
                  }

                  if (rhs_kind == 1) {
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
    if (splat_ok == 1) {
      pipeline_expr_set_resolved_type_ref(arena, right_ref, lt);
    }
    /*
     * Whole-array ASSIGN. The demoted walker stamps kind 13 only for
     * integer 0, so `a = [3, -3]` stayed i32. Stamp integer elements
     * first. check_expr keeps a resolved INT_LIT and a stamped i32
     * vector unary. Nested array literals stay on the walker.
     * PLATFORM: SHARED.
     */
    typeck_stamp_arr_i32_vec_elems(arena, right_ref, lt);
    return typeck_check_expr_assign__demoted(
      module, arena, expr_ref, return_type_ref, ctx);
  }
}
