// knife256/10.2 product body of typeck_coerce_init_float_lit_to_decl.
// Cap tip cannot re-emit typeck.x (the mega -c is a hollow check_expr).
// The linked mega object still contains the old one-peel text. Link
// weakens that symbol so this strong definition is the one the thirteen
// BRANCH26 sites call. Do not copy a second body back into typeck.x.
// PLATFORM: SHARED — the stamp rule is the same on macOS, Ubuntu, and
// Windows. Weakening the stale Mach-O symbol is the Darwin link step.

export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_set_resolved_type_ref(arena: *u8, expr_ref: i32, ty: i32): void;

/**
 * Stamp a float literal, or a chain of unary minuses of one, with the
 * f32 or f64 declaration type.
 * One minus used to be peeled and the literal under a second minus stayed
 * the default f64. Emit then built an f64 immediate and stored the low 32
 * bits into an f32 slot, so -(-1.0) became 0.0.
 * @param arena *u8 — AST arena; null returns 0
 * @param init_ref i32 — initializer or operand expr
 * @param decl_ty_ref i32 — destination f32 or f64 type ref
 * @param decl_kind i32 — TypeKind ordinal; only 14 (f32) and 15 (f64) stamp
 * @param init_kind i32 — ExprKind of init_ref; 1 is a bare float, 22 is unary minus
 * @return i32 — 1 when the literal and each minus are stamped, else 0
 * The walk follows kind 22 only, at most 32 steps, and stamps only when
 * the innermost expr is a float literal (kind 1). Kind 23 and kind 24
 * do not enter. A longer chain returns 0 and leaves the default f64.
 * Two loops, not a recursive helper: the frame must stay inside the
 * cap-tip stack budget. Each bound is its own compare. A chained &&
 * clobbers a register in the bootstrap image.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function typeck_coerce_init_float_lit_to_decl(arena: *u8, init_ref: i32, decl_ty_ref: i32,
decl_kind: i32, init_kind: i32): i32 {
  // PLATFORM: SHARED — one stamp for let, assign, return, and call args.
  unsafe {
    let ord_expr_float: i32 = 1;
    let ord_neg: i32 = 22;
    let ord_f32: i32 = 14;
    let ord_f64: i32 = 15;
    let cur: i32 = 0;
    let cur_k: i32 = 0;
    let deep: i32 = 0;
    let op: i32 = 0;
    let walk: i32 = 0;
    let n: i32 = 0;
    if (arena == 0 as *u8) {
      return 0;
    }
    if (decl_kind != ord_f32 && decl_kind != ord_f64) {
      return 0;
    }
    if (init_kind == ord_expr_float) {
      pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
      return 1;
    }
    // Kind 22 only. A bitwise not or logical not is not a sign chain.
    if (init_kind != ord_neg) {
      return 0;
    }
    cur = init_ref;
    cur_k = ord_neg;
    deep = 0;
    while (cur_k == ord_neg) {
      if (deep < 32) {
        op = pipeline_expr_unary_operand_ref_at(arena, cur);
        if (op <= 0) {
          cur_k = 0;
        } else {
          cur = op;
          deep = deep + 1;
          cur_k = pipeline_expr_kind_ord_at(arena, cur);
        }
      } else {
        cur_k = 0;
      }
    }
    if (cur_k != ord_expr_float) {
      return 0;
    }
    if (deep <= 0) {
      return 0;
    }
    // Innermost literal, then each minus outside it. Emit reads the
    // operand type, so an unstamped inner minus still negates as f64.
    pipeline_expr_set_resolved_type_ref(arena, cur, decl_ty_ref);
    walk = init_ref;
    n = 0;
    while (n < deep) {
      pipeline_expr_set_resolved_type_ref(arena, walk, decl_ty_ref);
      op = pipeline_expr_unary_operand_ref_at(arena, walk);
      if (op <= 0) {
        n = deep;
      } else {
        walk = op;
        n = n + 1;
      }
    }
    return 1;
  }
}
