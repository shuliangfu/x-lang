// 10.37 Cap residual: usual-arith when one cmp peer is 64-bit int.
// Thin overlay — Cap tip / tip-cold (typeck.x full rebuild blocked on unsafe).
// PLATFORM: SHARED · Cap tip / tip cold.

export extern "C" function typeck_ensure_bool_type_ref(arena: *u8): i32;
export extern "C" function pipeline_expr_set_resolved_type_ref(arena: *u8, expr_ref: i32, ty: i32): void;
export extern "C" function typeck_check_expr(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern "C" function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_binop_right_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_expr_line_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_col_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function typeck_type_refs_equal(arena: *u8, a: i32, b: i32): i32;
export extern "C" function typeck_type_ref_is_bool(arena: *u8, ty: i32): i32;
export extern "C" function typeck_expr_is_null_keyword(arena: *u8, expr_ref: i32): i32;
export extern "C" function typeck_type_is_aggregate_cmp_operand(module: *u8, arena: *u8, ty: i32): i32;
export extern "C" function typeck_coerce_init_lit_to_decl(arena: *u8, init_ref: i32, decl_ty: i32, decl_kind: i32, init_kind: i32): i32;
export extern "C" function typeck_coerce_init_float_lit_to_decl(arena: *u8, init_ref: i32, decl_ty: i32, decl_kind: i32, init_kind: i32): i32;
export extern "C" function typeck_cmp_promote_subint_to_i32(arena: *u8, expr_ref: i32, ty: i32): i32;
export extern "C" function typeck_integer_widen_ok_refs(arena: *u8, dest_ty: i32, src_ty: i32): i32;
export extern "C" function driver_diagnostic_typeck_comparison_type_mismatch(line: i32, col: i32): void;
export extern "C" function driver_diagnostic_typeck_logical_operand_not_bool(line: i32, col: i32): void;
export extern "C" function driver_diagnostic_typeck_invalid_aggregate_cmp(line: i32, col: i32): void;

#[no_mangle]
export function typeck_check_expr_binop_cmp(
  module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  unsafe {
    let bop_l: i32 = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    let bop_r: i32 = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    let bt: i32 = 0;
    let lt_cmp: i32 = 0;
    let rt_cmp: i32 = 0;
    let lko_cmp: i32 = 0;
    let rko_cmp: i32 = 0;
    let lk_cmp: i32 = 0;
    let rk_cmp: i32 = 0;
    let ord_lit: i32 = 0;
    let ord_f32: i32 = 14;
    let ord_logand: i32 = 20;
    let ord_logor: i32 = 21;
    let expr_kind_cmp: i32 = 0;
    let line_ac: i32 = 0;
    let col_ac: i32 = 0;
    let is_logical: i32 = 0;
    if (typeck_check_expr(module, arena, bop_l, return_type_ref, ctx) != 0) {
      return 0 - 1;
    }
    if (typeck_check_expr(module, arena, bop_r, return_type_ref, ctx) != 0) {
      return 0 - 1;
    }
    if (typeck_expr_is_null_keyword(arena, bop_l) != 0
    && typeck_expr_is_null_keyword(arena, bop_r) == 0) {
      rt_cmp = pipeline_expr_resolved_type_ref(arena, bop_r);
      rko_cmp = 0;
      if (rt_cmp > 0) {
        rko_cmp = pipeline_type_kind_ord_at(arena, rt_cmp);
      }
      if (rt_cmp > 0 && rko_cmp != 9) {
        line_ac = pipeline_expr_line_at(arena, expr_ref);
        col_ac = pipeline_expr_col_at(arena, expr_ref);
        driver_diagnostic_typeck_comparison_type_mismatch(line_ac, col_ac);
        return 0 - 1;
      }
    } else if (typeck_expr_is_null_keyword(arena, bop_r) != 0
    && typeck_expr_is_null_keyword(arena, bop_l) == 0) {
      lt_cmp = pipeline_expr_resolved_type_ref(arena, bop_l);
      lko_cmp = 0;
      if (lt_cmp > 0) {
        lko_cmp = pipeline_type_kind_ord_at(arena, lt_cmp);
      }
      if (lt_cmp > 0 && lko_cmp != 9) {
        line_ac = pipeline_expr_line_at(arena, expr_ref);
        col_ac = pipeline_expr_col_at(arena, expr_ref);
        driver_diagnostic_typeck_comparison_type_mismatch(line_ac, col_ac);
        return 0 - 1;
      }
    }
    expr_kind_cmp = pipeline_expr_kind_ord_at(arena, expr_ref);
    if (expr_kind_cmp == ord_logand || expr_kind_cmp == ord_logor) {
      is_logical = 1;
    }
    lt_cmp = pipeline_expr_resolved_type_ref(arena, bop_l);
    rt_cmp = pipeline_expr_resolved_type_ref(arena, bop_r);
    if (is_logical != 0) {
      if (lt_cmp > 0 && typeck_type_ref_is_bool(arena, lt_cmp) == 0) {
        line_ac = pipeline_expr_line_at(arena, expr_ref);
        col_ac = pipeline_expr_col_at(arena, expr_ref);
        driver_diagnostic_typeck_logical_operand_not_bool(line_ac, col_ac);
        return 0 - 1;
      }
      if (rt_cmp > 0 && typeck_type_ref_is_bool(arena, rt_cmp) == 0) {
        line_ac = pipeline_expr_line_at(arena, expr_ref);
        col_ac = pipeline_expr_col_at(arena, expr_ref);
        driver_diagnostic_typeck_logical_operand_not_bool(line_ac, col_ac);
        return 0 - 1;
      }
      bt = typeck_ensure_bool_type_ref(arena);
      if (bt != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, bt);
      }
      return 0;
    }
    if (lt_cmp > 0 && rt_cmp > 0) {
      lko_cmp = pipeline_type_kind_ord_at(arena, lt_cmp);
      rko_cmp = pipeline_type_kind_ord_at(arena, rt_cmp);
      lk_cmp = pipeline_expr_kind_ord_at(arena, bop_l);
      rk_cmp = pipeline_expr_kind_ord_at(arena, bop_r);
      if (lko_cmp == ord_f32) {
        typeck_coerce_init_float_lit_to_decl(arena, bop_r, lt_cmp, ord_f32, rk_cmp);
      } else if (rko_cmp == ord_f32) {
        typeck_coerce_init_float_lit_to_decl(arena, bop_l, rt_cmp, ord_f32, lk_cmp);
      }
      if (typeck_type_is_aggregate_cmp_operand(module, arena, lt_cmp) != 0
      || typeck_type_is_aggregate_cmp_operand(module, arena, rt_cmp) != 0) {
        line_ac = pipeline_expr_line_at(arena, expr_ref);
        col_ac = pipeline_expr_col_at(arena, expr_ref);
        driver_diagnostic_typeck_invalid_aggregate_cmp(line_ac, col_ac);
        return 0 - 1;
      }
      lt_cmp = pipeline_expr_resolved_type_ref(arena, bop_l);
      rt_cmp = pipeline_expr_resolved_type_ref(arena, bop_r);
      if (lt_cmp > 0 && rt_cmp > 0) {
        lko_cmp = pipeline_type_kind_ord_at(arena, lt_cmp);
        rko_cmp = pipeline_type_kind_ord_at(arena, rt_cmp);
        lk_cmp = pipeline_expr_kind_ord_at(arena, bop_l);
        rk_cmp = pipeline_expr_kind_ord_at(arena, bop_r);
        if (rk_cmp == ord_lit && typeck_coerce_init_lit_to_decl(arena, bop_r, lt_cmp, lko_cmp, rk_cmp) != 0) {
          rt_cmp = pipeline_expr_resolved_type_ref(arena, bop_r);
        } else if (lk_cmp == ord_lit
        && typeck_coerce_init_lit_to_decl(arena, bop_l, rt_cmp, rko_cmp, lk_cmp) != 0) {
          lt_cmp = pipeline_expr_resolved_type_ref(arena, bop_l);
        }
        if (lt_cmp > 0 && rt_cmp > 0) {
          if (typeck_type_refs_equal(arena, lt_cmp, rt_cmp) == 0) {
            if (typeck_cmp_promote_subint_to_i32(arena, bop_l, lt_cmp) != 0) {
              lt_cmp = pipeline_expr_resolved_type_ref(arena, bop_l);
            }
            if (typeck_cmp_promote_subint_to_i32(arena, bop_r, rt_cmp) != 0) {
              rt_cmp = pipeline_expr_resolved_type_ref(arena, bop_r);
            }
          }
          if (typeck_type_refs_equal(arena, lt_cmp, rt_cmp) == 0) {
            lko_cmp = pipeline_type_kind_ord_at(arena, lt_cmp);
            rko_cmp = pipeline_type_kind_ord_at(arena, rt_cmp);
            if ((lko_cmp == 4 || lko_cmp == 5 || lko_cmp == 6 || lko_cmp == 7)
            && typeck_integer_widen_ok_refs(arena, lt_cmp, rt_cmp) != 0) {
              pipeline_expr_set_resolved_type_ref(arena, bop_r, lt_cmp);
              rt_cmp = lt_cmp;
            } else if ((rko_cmp == 4 || rko_cmp == 5 || rko_cmp == 6 || rko_cmp == 7)
            && typeck_integer_widen_ok_refs(arena, rt_cmp, lt_cmp) != 0) {
              pipeline_expr_set_resolved_type_ref(arena, bop_l, rt_cmp);
              lt_cmp = rt_cmp;
            }
          }
          if (typeck_type_refs_equal(arena, lt_cmp, rt_cmp) == 0) {
            line_ac = pipeline_expr_line_at(arena, expr_ref);
            col_ac = pipeline_expr_col_at(arena, expr_ref);
            driver_diagnostic_typeck_comparison_type_mismatch(line_ac, col_ac);
            return 0 - 1;
          }
        }
      }
    }
    bt = typeck_ensure_bool_type_ref(arena);
    if (bt != 0) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, bt);
    }
    return 0;
  }
}
