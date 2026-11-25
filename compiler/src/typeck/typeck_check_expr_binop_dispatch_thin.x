// 10.37: tip-peel parent binop dispatcher so cmp call binds to overlay T
// (redefine-sym on cap_repr_weak retargets in-object bl to seed_dead).
// PLATFORM: SHARED · Cap tip / tip cold.

export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function typeck_check_expr_binop_cmp(
  module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern "C" function typeck_check_expr_binop_arith(
  module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;

#[no_mangle]
export function typeck_check_expr_binop(
  module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  unsafe {
    let ord_eq: i32 = 14;
    let ord_ne: i32 = 15;
    let ord_lt: i32 = 16;
    let ord_le: i32 = 17;
    let ord_gt: i32 = 18;
    let ord_ge: i32 = 19;
    let ord_logand: i32 = 20;
    let ord_logor: i32 = 21;
    let expr_kind: i32 = 0;
    expr_kind = pipeline_expr_kind_ord_at(arena, expr_ref);
    if (expr_kind == ord_eq || expr_kind == ord_ne || expr_kind == ord_lt || expr_kind == ord_le
    || expr_kind == ord_gt || expr_kind == ord_ge || expr_kind == ord_logand
    || expr_kind == ord_logor) {
      return typeck_check_expr_binop_cmp(module, arena, expr_ref, return_type_ref, ctx);
    }
    return typeck_check_expr_binop_arith(module, arena, expr_ref, return_type_ref, ctx);
  }
}
