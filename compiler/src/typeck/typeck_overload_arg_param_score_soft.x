// knife256/10.2 product entry of typeck_overload_arg_param_score.
// Cap tip cannot re-emit typeck.x. The linked mega still holds the old
// score text, which peels one unary minus. Darwin ld aliases that text to
// typeck_overload_arg_param_score_mega and weakens the old name, so this
// strong definition is the one the BRANCH26 sites call.
// Two or more minuses of a float literal made the one-peel see another
// minus. The score returned -1, and the call checker emitted T001 before
// the later float-lit stamp. This entry keeps every other score. Only
// that -1, on a minus chain of one float literal, becomes the same weak
// 100 a single minus already receives for an f32 or f64 formal.
// PLATFORM: SHARED — the score rule is the same on macOS, Ubuntu, and
// Windows. The alias is the Darwin link step.

export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_call_arg_ref(arena: *u8, call_ref: i32, arg_i: i32): i32;
export extern "C" function pipeline_expr_method_call_arg_ref(arena: *u8, call_ref: i32, arg_i: i32): i32;
export extern "C" function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, ty_ref: i32): i32;
export extern "C" function typeck_get_dep_return_type_in_caller_arena(from_dep_index: i32,
dep_return_type_ref: i32, caller_arena: *u8, ctx: *u8): i32;
export extern "C" function typeck_overload_arg_param_score_mega(caller_arena: *u8, call_expr_ref: i32,
arg_i: i32, param_ty_raw: i32, from_dep_index: i32, ctx: *u8): i32;

/**
 * Score one argument, then accept a longer unary-minus chain of a float.
 * @param caller_arena *u8 — caller expression pool; null returns the mega score
 * @param call_expr_ref i32 — EXPR_CALL (48) or EXPR_METHOD_CALL (49)
 * @param arg_i i32 — argument index; negative returns the mega score
 * @param param_ty_raw i32 — formal type ref before dep mapping
 * @param from_dep_index i32 — dep slot, or negative for the caller module
 * @param ctx *u8 — dep context; used only when from_dep_index is non-negative
 * @return i32 — mega score when that score is non-negative; 100 when the
 *   mega rejected a chain of at least two unary minuses of a float literal
 *   and the formal is f32 or f64; otherwise the mega's negative score
 * The walk follows kind 22 only, at most 32 steps. Kind 23 and kind 24
 * do not enter. One minus stays on the mega path. The frame is one
 * function: no recursive helper, no chained &&.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function typeck_overload_arg_param_score(caller_arena: *u8, call_expr_ref: i32, arg_i: i32,
param_ty_raw: i32, from_dep_index: i32, ctx: *u8): i32 {
  // PLATFORM: SHARED — one score entry for overload pick and the call checker.
  unsafe {
    let ord_method: i32 = 49;
    let ord_neg: i32 = 22;
    let ord_float: i32 = 1;
    let ord_f32: i32 = 14;
    let ord_f64: i32 = 15;
    let sc: i32 = 0;
    let call_kind: i32 = 0;
    let arg_ref: i32 = 0;
    let cur: i32 = 0;
    let cur_k: i32 = 0;
    let deep: i32 = 0;
    let op: i32 = 0;
    let param_ty: i32 = 0;
    let pk: i32 = 0;
    sc = typeck_overload_arg_param_score_mega(caller_arena, call_expr_ref, arg_i, param_ty_raw,
    from_dep_index, ctx);
    if (sc < 0) {
      if (caller_arena != 0 as *u8) {
        if (call_expr_ref > 0) {
          if (arg_i >= 0) {
            call_kind = pipeline_expr_kind_ord_at(caller_arena, call_expr_ref);
            arg_ref = 0;
            if (call_kind == ord_method) {
              arg_ref = pipeline_expr_method_call_arg_ref(caller_arena, call_expr_ref, arg_i);
            } else {
              arg_ref = pipeline_expr_call_arg_ref(caller_arena, call_expr_ref, arg_i);
            }
            if (arg_ref > 0) {
              cur = arg_ref;
              cur_k = pipeline_expr_kind_ord_at(caller_arena, cur);
              deep = 0;
              while (cur_k == ord_neg) {
                if (deep < 32) {
                  op = pipeline_expr_unary_operand_ref_at(caller_arena, cur);
                  if (op <= 0) {
                    cur_k = 0;
                  } else {
                    cur = op;
                    deep = deep + 1;
                    cur_k = pipeline_expr_kind_ord_at(caller_arena, cur);
                  }
                } else {
                  cur_k = 0;
                }
              }
              // Depth 1 is the mega's own peel. Only a longer chain
              // reached this -1 with a float literal at the bottom.
              if (cur_k == ord_float) {
                if (deep > 1) {
                  param_ty = param_ty_raw;
                  if (from_dep_index < 0) {
                    param_ty = param_ty_raw;
                  } else {
                    param_ty = typeck_get_dep_return_type_in_caller_arena(from_dep_index, param_ty_raw,
                    caller_arena, ctx);
                    if (param_ty == 0) {
                      return 0 - 1;
                    }
                  }
                  if (param_ty > 0) {
                    pk = pipeline_type_kind_ord_at(caller_arena, param_ty);
                    if (pk == ord_f32) {
                      return 100;
                    }
                    if (pk == ord_f64) {
                      return 100;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    return sc;
  }
}
