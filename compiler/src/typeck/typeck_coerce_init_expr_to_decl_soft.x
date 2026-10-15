// knife256/10.2 Cap tip linked body of typeck_coerce_init_expr_to_decl.
// Source authority is the i32 TYPE_VECTOR splat in typeck.x. Cap tip -c
// of that mega emits a hollow mov w0,#0; ret, so this thin is what the
// link runs. An INT_LIT, unary minus / bitwise not of an INT_LIT, or
// one, two, three, four, or five more unaries of that unary, into a TYPE_VECTOR
// of i32 is stamped with the declared type. The walk lives in
// typeck_stamp_i32_vector_int_splat, which the return coerce thin
// calls too. It accepts kind 22 and kind 23 through 32 steps. Probes
// covered one through eight minuses and the seven-deep mixed chain.
// A 33rd step calls the demoted body. A TYPE_VECTOR of f32 also
// stamps a FLOAT_LIT and one
// a chain of at most 32 unary minuses of that literal. An odd count
// applies the sign once. An even count cancels. One more unary
// and a bitwise not call the demoted body.
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
 * Stamp a bare INT_LIT, or a kind-22 / kind-23 chain of one, as a
 * TYPE_VECTOR of i32. Let coerce, the return coerce thin, the
 * call-arg checker, the struct-lit field coerce, the block checker
 * (on the block's value tail), and the ternary checker (on each arm)
 * all call this.
 * It does not call the demoted body.
 * @param arena *u8 — AST arena; null returns 0
 * @param init_ref i32 — initializer or return operand; <= 0 returns 0
 * @param decl_ty_ref i32 — declared or expected type; <= 0 returns 0
 * @return i32 — 1 when the expr's resolved type was set to decl_ty_ref, else 0
 * Kind 24, a FLOAT_LIT, a VAR, a binop, keyword null, and a 33rd unary
 * stay 0. Kind 0 is INT_LIT, so a failed step sets the cursor kind to
 * -1. Depth 32 was not probed. Two compares, not a chained &&.
 * PLATFORM: SHARED — same type rule on every host.
 */
#[no_mangle]
export function typeck_stamp_i32_vector_int_splat(
  arena: *u8, init_ref: i32, decl_ty_ref: i32): i32 {
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
    let u_go: i32 = 0;
    let u_deep: i32 = 0;
    let u_stop: i32 = 0;
    let ntypes: i32 = 0;
    if (arena == 0 as *u8 || init_ref <= 0 || decl_ty_ref <= 0) {
      return 0;
    }
    ntypes = pipeline_arena_num_types(arena);
    if (decl_ty_ref > ntypes) {
      return 0;
    }
    decl_kind = pipeline_type_kind_ord_at(arena, decl_ty_ref);
    if (decl_kind != ord_vector) {
      return 0;
    }
    elem_ref = pipeline_type_elem_ref_at(arena, decl_ty_ref);
    if (elem_ref <= 0) {
      return 0;
    }
    if (elem_ref > ntypes) {
      return 0;
    }
    elem_k = pipeline_type_kind_ord_at(arena, elem_ref);
    if (elem_k != ord_i32) {
      return 0;
    }
    init_kind = pipeline_expr_kind_ord_at(arena, init_ref);
    if (init_kind == ord_lit) {
      if (pipeline_expr_is_null_keyword_c(arena, init_ref) == 0) {
        splat_ok = 1;
      }
    }
    /*
     * Walk kind 22 and kind 23 together, at most 32 steps.
     * The innermost expr must be a non-null INT_LIT. Kind 24
     * does not enter. A longer chain stays unstamped.
     * Probes covered through eight minuses. Depth 32 was not run.
     * Each bound is its own compare. PLATFORM: SHARED.
     */
    if (init_kind == ord_neg) {
      u_go = 1;
    }
    if (init_kind == ord_bitnot) {
      u_go = 1;
    }
    if (u_go != 0) {
      op_ref = init_ref;
      op_k = init_kind;
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
    if (splat_ok == 1) {
      pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
      return 1;
    }
    return 0;
  }
}

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
 * already splats INT_LIT and a kind 22 / kind 23 chain around it.
 * Probes covered one through eight minuses and the seven-deep mixed
 * chain. A 33rd step, a variable, a binop,
 * and keyword null stay on the demoted body. A TYPE_VECTOR of f32
 * stamps a FLOAT_LIT and a chain of at most 32 unary minuses of that
 * literal. An odd count applies the sign once. An even count cancels.
 * One more unary of that float stays on the demoted body.
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
    let u_go: i32 = 0;
    let u_deep: i32 = 0;
    let u_stop: i32 = 0;
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
    /*
     * One i32 walk, shared with the return coerce thin. A hit already
     * wrote the resolved type. A miss continues into the f32 walk.
     * PLATFORM: SHARED.
     */
    if (typeck_stamp_i32_vector_int_splat(arena, init_ref, decl_ty_ref) == 1) {
      return 1;
    }
    decl_kind = pipeline_type_kind_ord_at(arena, decl_ty_ref);
    init_kind = pipeline_expr_kind_ord_at(arena, init_ref);
    /*
     * i32 TYPE_VECTOR already returned via the shared stamp. This
     * block is the f32 walk only. Out-of-range element refs stay on
     * the demoted body. PLATFORM: SHARED.
     */
    if (decl_kind == ord_vector) {
      elem_ref = pipeline_type_elem_ref_at(arena, decl_ty_ref);
      if (elem_ref > 0) {
        if (elem_ref <= ntypes) {
          elem_k = pipeline_type_kind_ord_at(arena, elem_ref);
          /*
           * TYPE_VECTOR of f32 (Vec4f). A FLOAT_LIT, one unary minus of
           * a FLOAT_LIT, one more unary minus of that, one unary
           * beyond that, one unary beyond that, one unary beyond
           * that, one unary beyond that, or one unary beyond that,
           * or one unary beyond that, is the same splat the emitter
           * fills. Two, four, six, eight, ten, and twelve minuses
           * cancel. Three, five, seven, nine, eleven, and thirteen
           * apply the sign once. Kind 1 and kind 22 are separate
           * compares. Ten minuses cancel again. Eleven minuses apply
           * the sign once more. Twelve minuses cancel again. Thirteen
           * minuses apply the sign once more. Fourteen minuses cancel
           * again. Fifteen minuses apply the sign once more.
           * One more than 32 unary minuses stays kind 22 at the inner
           * operand, so it is not stamped.
           * Bitwise not stays off. An i32 element does not enter.
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
            if (init_kind == 1) {
              splat_ok = 1;
            }
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
            if (init_kind == 22) {
              f_in = init_ref;
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
                  splat_ok = 1;
                }
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
