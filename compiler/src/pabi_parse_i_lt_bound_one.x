// Recompile of glue_parse_i_lt_bound_c so Win64 7th incoming
// arg is loaded from 0x40(%rbp) (n_var_ref), not the rcx shadow
// home 0x10(%rbp) (arena). Official body wrote n_var_ref[0]=0
// into arena.num_types and dropped array-local frame reservation
// to 8 bytes. No typool layout change. PLATFORM: SHARED.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_right_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_int_val_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_block_let_init_lit_c(arena: *u8, block_ref: i32, var_ref: i32, out_lit: *i32): i32;

#[no_mangle]
export function glue_parse_i_lt_bound_c(arena: *u8, block_ref: i32, cond_ref: i32, i_var_ref: *i32, n_lit: *i32, n_is_const: *i32, n_var_ref: *i32): i32 {
  if (i_var_ref == 0) { return 0; }
  if (n_lit == 0) { return 0; }
  if (n_is_const == 0) { return 0; }
  if (n_var_ref == 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, cond_ref) != 16) { return 0; }
    let left_ref: i32 = pipeline_expr_binop_left_ref_at(arena, cond_ref);
    let right_ref: i32 = pipeline_expr_binop_right_ref_at(arena, cond_ref);
    if (pipeline_expr_kind_ord_at(arena, left_ref) != 3) { return 0; }
    i_var_ref[0] = left_ref;
    let rko: i32 = pipeline_expr_kind_ord_at(arena, right_ref);
    if (rko == 0) {
      n_lit[0] = pipeline_expr_int_val_at(arena, right_ref);
      if (n_lit[0] <= 0) { return 0; }
      n_is_const[0] = 1;
      n_var_ref[0] = 0;
      return 1;
    }
    if (rko != 3) { return 0; }
    n_var_ref[0] = right_ref;
    let prop: i32 = glue_block_let_init_lit_c(arena, block_ref, right_ref, n_lit);
    if (prop != 0) {
      if (n_lit[0] <= 0) { return 0; }
      n_is_const[0] = 1;
      return 1;
    }
    n_is_const[0] = 0;
  }
  return 1;
}
