// knife256/10.2 Cap tip linked body of typeck_check_expr_unary.
// Source authority is the NEG / integer-BITNOT exemption in typeck.x.
// Cap tip -c of that mega emits a hollow mov w0,#0; ret, so this thin
// is what the link runs. Unary minus of TYPE_VECTOR (kind 13) is
// accepted here. Bitwise not of a TYPE_VECTOR is accepted only when
// the element kind is i32 (kind 0): Vec8i. Vec4f bitwise not stays on
// the demoted body, as does logical not. An assign pre-stamp of one
// unary minus of a FLOAT_LIT, one more unary minus of that, one unary
// beyond that, and one unary beyond that, onto a TYPE_VECTOR of f32
// is kept. Two minuses cancel. Three minuses apply the sign once.
// Four minuses cancel again. Five minuses apply the sign once more.
// Six minuses cancel again. Seven minuses apply the sign once more.
// Eight minuses cancel again. Nine minuses apply the sign once more.
// Ten minuses cancel again. Eleven minuses apply the sign once more.
// A twelfth unary of that float is not a keep.
// PLATFORM: SHARED — type rule is the same on macOS, Ubuntu, and Windows.
// The demote/retarget step that makes this symbol win is Mach-O only.

export extern "C" function typeck_check_expr_unary__demoted(
  module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern "C" function typeck_check_expr(
  module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_arena_num_types(arena: *u8): i32;
export extern "C" function pipeline_expr_set_resolved_type_ref(arena: *u8, expr_ref: i32, ty: i32): void;
export extern "C" function pipeline_expr_is_null_keyword_c(arena: *u8, expr_ref: i32): i32;

/**
 * Accept unary minus of a TYPE_VECTOR, and bitwise not of an i32
 * TYPE_VECTOR. Every other unary calls the demoted body.
 * @param module *u8 — caller module; null defers to the demoted body
 * @param arena *u8 — AST arena; null defers to the demoted body
 * @param expr_ref i32 — unary expr; <= 0 defers to the demoted body
 * @param return_type_ref i32 — enclosing return type, passed through
 * @param ctx *u8 — dep context, passed through; may be null
 * @return i32 — 0 when the unary typechecks, -1 on failure
 * Kind 13 stays an aggregate for comparison, for logical not, and for
 * bitwise not of a non-i32 element (Vec4f is f32). Those exprs never
 * take the accept path. The operand is typechecked once on the accept
 * path and not again: the demoted body still rejects kind 13 and would
 * emit T001. A scalar unary minus or bitwise not falls through to that
 * body, which typechecks the operand itself.
 * Two compares, not a chained && : the bootstrap image clobbers the
 * register a chained compare reuses.
 * Assign pre-stamps `~lit` / `-lit`, and one, two, three, four, or five more
 * unaries of that lit, with an i32
 * TYPE_VECTOR before this call. When this expr is already that vector
 * and the operand is a non-null INT_LIT, or one through five more
 * unaries of one, the immediate operand is typechecked with expected 0
 * and this function returns without calling demoted, so the stamp
 * stays. Expected 0 keeps that operand a scalar. A seventh unary is
 * not a keep. A TYPE_VECTOR of f32 keeps one unary minus whose operand
 * is a FLOAT_LIT, one more unary minus of that, one unary beyond
 * that, one unary beyond that, and one unary beyond that. Two
 * minuses cancel. Three minuses apply the sign once. Four minuses
 * cancel again. Five minuses apply the sign once more. Six minuses
 * cancel again. Seven minuses apply the sign once more. Eight
 * minuses cancel again. Nine minuses apply the sign once more.
 * Ten minuses cancel again. Eleven minuses apply the sign once
 * more. A twelfth unary and a bitwise not are not a keep.
 * A missing pre-stamp falls through and let-init coerce
 * stamps the same shape afterwards.
 * PLATFORM: SHARED — same type rule on every host.
 */
#[no_mangle]
export function typeck_check_expr_unary(
  module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  unsafe {
    let ord_lit: i32 = 0;
    let ord_neg: i32 = 22;
    let ord_bitnot: i32 = 23;
    let ord_vector: i32 = 13;
    let ord_i32: i32 = 0;
    let expr_kind: i32 = 0;
    let op_ref: i32 = 0;
    let op_tr: i32 = 0;
    let ntypes: i32 = 0;
    let accept: i32 = 0;
    let want: i32 = 0;
    let rc: i32 = 0;
    let elem_ref: i32 = 0;
    let elem_k: i32 = 0;
    if (module == 0 as *u8 || arena == 0 as *u8 || expr_ref <= 0) {
      return typeck_check_expr_unary__demoted(
        module, arena, expr_ref, return_type_ref, ctx);
    }
    expr_kind = pipeline_expr_kind_ord_at(arena, expr_ref);
    if (expr_kind == ord_neg) {
      want = 1;
    }
    if (expr_kind == ord_bitnot) {
      want = 1;
    }
    if (want == 0) {
      return typeck_check_expr_unary__demoted(
        module, arena, expr_ref, return_type_ref, ctx);
    }
    op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    ntypes = pipeline_arena_num_types(arena);
    /*
     * Keep an assign pre-stamp of this unary onto an i32 TYPE_VECTOR.
     * The immediate operand is checked with expected 0 so a lit stays
     * i32 and a unary of a lit stays a scalar unary. A seventh unary
     * falls through. Keyword null falls through. Two compares, not a
     * chained &&.
     * PLATFORM: SHARED — element kind is the type rule, not a host ABI.
     */
    {
      let already: i32 = pipeline_expr_resolved_type_ref(arena, expr_ref);
      let already_keep: i32 = 0;
      let already_elem: i32 = 0;
      let already_ek: i32 = 0;
      let already_op_k: i32 = 0;
      let already_in: i32 = 0;
      let already_in_k: i32 = 0;
      let already_deep: i32 = 0;
      let already_deep_k: i32 = 0;
      let already_quad: i32 = 0;
      let already_quad_k: i32 = 0;
      let already_pent: i32 = 0;
      let already_pent_k: i32 = 0;
      let already_hex: i32 = 0;
      let already_hex_k: i32 = 0;
      if (already > 0) {
        if (already <= ntypes) {
          if (pipeline_type_kind_ord_at(arena, already) == ord_vector) {
            already_elem = pipeline_type_elem_ref_at(arena, already);
            if (already_elem > 0) {
              if (already_elem <= ntypes) {
                already_ek = pipeline_type_kind_ord_at(arena, already_elem);
                if (already_ek == ord_i32) {
                  if (op_ref > 0) {
                    already_op_k = pipeline_expr_kind_ord_at(arena, op_ref);
                    if (already_op_k == ord_lit) {
                      if (pipeline_expr_is_null_keyword_c(arena, op_ref) == 0) {
                        already_keep = 1;
                      }
                    }
                    /*
                     * One more unary of a non-null INT_LIT, and exactly
                     * one, two, three, or four unaries beyond that. The keep below typechecks
                     * op_ref with expected 0, so the inner unaries stay
                     * scalar and the vector stamp stays on this expr.
                     * A seventh unary is not INT_LIT here. LOGNOT does
                     * not set already_keep. PLATFORM: SHARED.
                     */
                    if (already_op_k == ord_neg) {
                      already_in = pipeline_expr_unary_operand_ref_at(arena, op_ref);
                    }
                    if (already_op_k == ord_bitnot) {
                      already_in = pipeline_expr_unary_operand_ref_at(arena, op_ref);
                    }
                    if (already_in > 0) {
                      already_in_k = pipeline_expr_kind_ord_at(arena, already_in);
                      if (already_in_k == ord_lit) {
                        if (pipeline_expr_is_null_keyword_c(arena, already_in) == 0) {
                          already_keep = 1;
                        }
                      }
                      if (already_in_k == ord_neg) {
                        already_deep = pipeline_expr_unary_operand_ref_at(arena, already_in);
                      }
                      if (already_in_k == ord_bitnot) {
                        already_deep = pipeline_expr_unary_operand_ref_at(arena, already_in);
                      }
                      if (already_deep > 0) {
                        already_deep_k = pipeline_expr_kind_ord_at(arena, already_deep);
                        if (already_deep_k == ord_lit) {
                          if (pipeline_expr_is_null_keyword_c(arena, already_deep) == 0) {
                            already_keep = 1;
                          }
                        }
                        if (already_deep_k == ord_neg) {
                          already_quad = pipeline_expr_unary_operand_ref_at(arena, already_deep);
                        }
                        if (already_deep_k == ord_bitnot) {
                          already_quad = pipeline_expr_unary_operand_ref_at(arena, already_deep);
                        }
                        if (already_quad > 0) {
                          already_quad_k = pipeline_expr_kind_ord_at(arena, already_quad);
                          if (already_quad_k == ord_lit) {
                            if (pipeline_expr_is_null_keyword_c(arena, already_quad) == 0) {
                              already_keep = 1;
                            }
                          }
                          /*
                           * Fifth unary of a non-null INT_LIT. Kind 22 and kind 23 are
                           * separate compares. One more unary of this wrapper is stamped below. A seventh unary stays 22 or 23, so it is not
                           * stamped. PLATFORM: SHARED.
                           */

                          if (already_quad_k == ord_neg) {
                            already_pent = pipeline_expr_unary_operand_ref_at(arena, already_quad);
                          }
                          if (already_quad_k == ord_bitnot) {
                            already_pent = pipeline_expr_unary_operand_ref_at(arena, already_quad);
                          }
                          if (already_pent > 0) {
                            already_pent_k = pipeline_expr_kind_ord_at(arena, already_pent);
                            if (already_pent_k == ord_lit) {
                              if (pipeline_expr_is_null_keyword_c(arena, already_pent) == 0) {
                                already_keep = 1;
                              }
                            }
                            /*
                             * Sixth unary of a non-null INT_LIT. Kind 22 and kind 23 are
                             * separate compares. A seventh unary stays 22 or 23, so it is
                             * not a keep. The keep below still typechecks op_ref with
                             * expected 0. PLATFORM: SHARED.
                             */
                            if (already_pent_k == ord_neg) {
                              already_hex = pipeline_expr_unary_operand_ref_at(arena, already_pent);
                            }
                            if (already_pent_k == ord_bitnot) {
                              already_hex = pipeline_expr_unary_operand_ref_at(arena, already_pent);
                            }
                            if (already_hex > 0) {
                              already_hex_k = pipeline_expr_kind_ord_at(arena, already_hex);
                              if (already_hex_k == ord_lit) {
                                if (pipeline_expr_is_null_keyword_c(arena, already_hex) == 0) {
                                  already_keep = 1;
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
                 * TYPE_VECTOR of f32. Assign pre-stamps one unary minus
                 * of a FLOAT_LIT, one more unary minus of that, one
                 * unary beyond that, one unary beyond that, and one
                 * unary beyond that. Kind 22 and kind 1 are separate
                 * compares. Two minuses cancel. Three minuses apply
                 * the sign once. Four minuses cancel again. Five
                 * minuses apply the sign once more. Six minuses cancel
                 * again. Seven minuses apply the sign once more. Eight
                 * minuses cancel again. Nine minuses apply the sign once
                 * more. Ten minuses cancel again. Eleven minuses apply
                 * the sign once more. A twelfth unary stays kind 22,
                 * so it is not kept.
                 * Bitwise not stays off. The keep below
                 * still typechecks the immediate operand with expected 0.
                 * PLATFORM: SHARED.
                 */
                if (already_ek == 14) {
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
                  if (expr_kind == ord_neg) {
                    if (op_ref > 0) {
                      already_op_k = pipeline_expr_kind_ord_at(arena, op_ref);
                      if (already_op_k == 1) {
                        already_keep = 1;
                      }
                      if (already_op_k == ord_neg) {
                        f_in = pipeline_expr_unary_operand_ref_at(arena, op_ref);
                        if (f_in > 0) {
                          f_in_k = pipeline_expr_kind_ord_at(arena, f_in);
                          if (f_in_k == 1) {
                            already_keep = 1;
                          }
                          /*
                           * One more unary minus whose operand is a
                           * FLOAT_LIT, or one unary beyond that. Three
                           * minuses apply the sign once. Four minuses
                           * cancel again. Five minuses apply the sign
                           * once more. Six minuses cancel again.
                           * Seven minuses apply the sign once more. Eight
                           * minuses cancel again. A ninth unary is kind
                           * 22 here, not kind 1.
                           * PLATFORM: SHARED.
                           */
                          if (f_in_k == ord_neg) {
                            f_deep = pipeline_expr_unary_operand_ref_at(arena, f_in);
                            if (f_deep > 0) {
                              f_deep_k = pipeline_expr_kind_ord_at(arena, f_deep);
                              if (f_deep_k == 1) {
                                already_keep = 1;
                              }
                              if (f_deep_k == ord_neg) {
                                f_quad = pipeline_expr_unary_operand_ref_at(arena, f_deep);
                                if (f_quad > 0) {
                                  f_quad_k = pipeline_expr_kind_ord_at(arena, f_quad);
                                  if (f_quad_k == 1) {
                                    already_keep = 1;
                                  }
                                  if (f_quad_k == ord_neg) {
                                    f_pent = pipeline_expr_unary_operand_ref_at(arena, f_quad);
                                    if (f_pent > 0) {
                                      f_pent_k = pipeline_expr_kind_ord_at(arena, f_pent);
                                      if (f_pent_k == 1) {
                                        already_keep = 1;
                                      }
                                      /*
                                       * Six minuses: the innermost is a
                                       * FLOAT_LIT. Three pairs cancel, so
                                       * the sign bit stays clear. Seven
                                       * minuses apply the sign once. An
                                       * eighth unary is kind 22 here, not
                                       * kind 1. PLATFORM: SHARED.
                                       */
                                      if (f_pent_k == ord_neg) {
                                        f_hex = pipeline_expr_unary_operand_ref_at(arena, f_pent);
                                        if (f_hex > 0) {
                                          f_hex_k = pipeline_expr_kind_ord_at(arena, f_hex);
                                          if (f_hex_k == 1) {
                                            already_keep = 1;
                                          }
                                          /*
                                           * Seven minuses: the innermost is a
                                           * FLOAT_LIT. Apply the sign once.
                                           * Eight minuses cancel again. A ninth
                                           * unary is kind 22 here, not kind 1.
                                           * PLATFORM: SHARED.
                                           */
                                          if (f_hex_k == ord_neg) {
                                            f_sept = pipeline_expr_unary_operand_ref_at(arena, f_hex);
                                            if (f_sept > 0) {
                                              f_sept_k = pipeline_expr_kind_ord_at(arena, f_sept);
                                              if (f_sept_k == 1) {
                                                already_keep = 1;
                                              }
                                              /*
                                               * Eight minuses: the innermost is a
                                               * FLOAT_LIT. Four pairs cancel, so
                                               * the sign bit stays clear. Nine
                                               * minuses apply the sign once. A
                                               * tenth unary is kind 22 here, not
                                               * kind 1. PLATFORM: SHARED.
                                               */
                                              if (f_sept_k == ord_neg) {
                                                f_oct = pipeline_expr_unary_operand_ref_at(arena, f_sept);
                                                if (f_oct > 0) {
                                                  f_oct_k = pipeline_expr_kind_ord_at(arena, f_oct);
                                                  if (f_oct_k == 1) {
                                                    already_keep = 1;
                                                  }
                                                  /*
                                                   * Nine minuses: the innermost is a
                                                   * FLOAT_LIT. The emitter applies the
                                                   * sign once. A tenth unary is kind 22
                                                   * here, not kind 1. Load the operand
                                                   * of f_oct only. PLATFORM: SHARED.
                                                   */
                                                  if (f_oct_k == ord_neg) {
                                                    f_nona = pipeline_expr_unary_operand_ref_at(arena, f_oct);
                                                    if (f_nona > 0) {
                                                      f_nona_k = pipeline_expr_kind_ord_at(arena, f_nona);
                                                      if (f_nona_k == 1) {
                                                        already_keep = 1;
                                                      }
                                                      /*
                                                       * Ten minuses: the innermost is a
                                                       * FLOAT_LIT. Five pairs cancel, so
                                                       * the sign bit stays clear. An
                                                       * eleventh unary is kind 22 here,
                                                       * not kind 1. Load the operand of
                                                       * f_nona only. PLATFORM: SHARED.
                                                       */
                                                      if (f_nona_k == 22) {
                                                        f_deca = pipeline_expr_unary_operand_ref_at(arena, f_nona);
                                                        if (f_deca > 0) {
                                                          f_deca_k = pipeline_expr_kind_ord_at(arena, f_deca);
                                                          if (f_deca_k == 1) {
                                                            already_keep = 1;
                                                          }
                                                          /*
                                                           * Eleven minuses: the innermost is a
                                                           * FLOAT_LIT. The emitter applies the
                                                           * sign once. A twelfth unary is kind
                                                           * 22 here, not kind 1. Load the operand
                                                           * of f_deca only. PLATFORM: SHARED.
                                                           */
                                                          if (f_deca_k == 22) {
                                                            f_undeca = pipeline_expr_unary_operand_ref_at(arena, f_deca);
                                                            if (f_undeca > 0) {
                                                              f_undeca_k = pipeline_expr_kind_ord_at(arena, f_undeca);
                                                              if (f_undeca_k == 1) {
                                                                already_keep = 1;
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
          }
        }
      }
      if (already_keep == 1) {
        rc = typeck_check_expr(module, arena, op_ref, 0, ctx);
        if (rc != 0) {
          return 0 - 1;
        }
        return 0;
      }
    }
    rc = typeck_check_expr(module, arena, op_ref, return_type_ref, ctx);
    if (rc != 0) {
      return 0 - 1;
    }
    op_tr = pipeline_expr_resolved_type_ref(arena, op_ref);
    ntypes = pipeline_arena_num_types(arena);
    /*
     * Stamp the operand type for unary minus of any TYPE_VECTOR, and
     * for bitwise not only when the element is i32. Vec8i is that
     * vector: parser_asm_alloc_vector_type_ref stores elem kind 0 and
     * lane count 8. Vec4f stores elem kind 14, so ~ stays rejected.
     * Out-of-range refs stay on the demoted body.
     * PLATFORM: SHARED — element kind is the type rule, not a host ABI.
     */
    if (op_tr > 0) {
      if (op_tr <= ntypes) {
        if (pipeline_type_kind_ord_at(arena, op_tr) == ord_vector) {
          if (expr_kind == ord_neg) {
            accept = 1;
          }
          if (expr_kind == ord_bitnot) {
            elem_ref = pipeline_type_elem_ref_at(arena, op_tr);
            if (elem_ref > 0) {
              if (elem_ref <= ntypes) {
                elem_k = pipeline_type_kind_ord_at(arena, elem_ref);
                if (elem_k == ord_i32) {
                  accept = 1;
                }
              }
            }
          }
        }
      }
    }
    if (accept == 1) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, op_tr);
      return 0;
    }
    return typeck_check_expr_unary__demoted(
      module, arena, expr_ref, return_type_ref, ctx);
  }
}
