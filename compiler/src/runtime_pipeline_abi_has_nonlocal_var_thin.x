// Live body of glue_expr_tree_has_nonlocal_var_c.
// The copy in runtime_pipeline_abi.x is an extern. pabi_weak still has
// the old strong definition. This object is linked first, so this body
// wins. The old walk stopped at a binop, a unary, an AS, a field, an
// array literal, or a struct literal. An if, a ternary, or a block was
// invisible, so `let n = if (g == 1) { 4 } else { 9 }` stayed in pass 0
// and read g before a prior store. This is the one walk. A transparent
// block is peeled by the existing helper. A block that still has lets,
// an expr statement, or one unsafe region is walked here with the
// existing block getters. A call is not this function. Do not add a
// second walker.
// PLATFORM: SHARED.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_asm_local_var_stack_off_scoped(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_right_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_as_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, i: i32): i32;
export extern function pipeline_expr_struct_lit_num_fields(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_init_ref(arena: *u8, expr_ref: i32, i: i32): i32;
export extern function pipeline_expr_if_cond_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_if_then_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_if_else_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_expr_block_transparent_value_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_block_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function ast_ast_block_num_lets(arena: *u8, block_ref: i32): i32;
export extern function ast_pipeline_block_let_init_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_ast_block_final_expr_ref(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_expr_stmts(arena: *u8, block_ref: i32): i32;
export extern function ast_pipeline_block_expr_stmt_ref(arena: *u8, block_ref: i32, ei: i32): i32;
export extern function ast_ast_block_num_stmt_order(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_stmt_order_kind(arena: *u8, block_ref: i32, si: i32): i32;
export extern function ast_ast_block_stmt_order_idx(arena: *u8, block_ref: i32, si: i32): i32;
export extern function pipeline_block_region_body_ref(arena: *u8, block_ref: i32, ri: i32): i32;

/**
 * True when the expr tree reads a VAR that is not a block local.
 * @param arena *u8 - AST arena; null returns 0
 * @param ctx *u8 - AsmFuncCtx; null returns 0
 * @param expr_ref i32 - expr pool ref; not positive returns 0
 * @return i32 - 1 when a module global or extern VAR is read; 0 otherwise
 * Pass 0 must not hoist that let ahead of an earlier store. A local
 * and a parameter have a frame slot, so they return 0. An if (kind 25)
 * and a ternary (kind 27) walk the condition and both arms before the
 * AS getter. A block (kind 26) asks the existing transparent peel, then
 * walks let inits, the final expr, and expr statements. One unsafe
 * region (stmt kind 6) is the inner block from the existing region
 * getter. Nested nodes are this same function. A call is claimed by
 * glue_expr_tree_has_call_index_c and is not a hit here.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function glue_expr_tree_has_nonlocal_var_c(arena: *u8, ctx: *u8, expr_ref: i32): i32 {
  let ko: i32 = 0;
  let i: i32 = 0;
  let n: i32 = 0;
  let left_ref: i32 = 0;
  let right_ref: i32 = 0;
  let op_ref: i32 = 0;
  let peeled: i32 = 0;
  let br: i32 = 0;
  let nso: i32 = 0;
  let sk: i32 = 0;
  let idx: i32 = 0;
  let inner: i32 = 0;
  let step: i32 = 0;
  let arm: i32 = 0;
  let off: i32 = 0;
  if (arena == (0 as *u8)) {
    return 0;
  }
  if (ctx == (0 as *u8)) {
    return 0;
  }
  if (expr_ref <= 0) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  // EXPR_VAR = 3. A missing frame slot is a module global or an extern.
  if (ko == 3) {
    unsafe {
      off = glue_asm_local_var_stack_off_scoped(arena, ctx, expr_ref);
    }
    if (off < 0) {
      return 1;
    }
    return 0;
  }
  // Kinds 4..21, including a lane compare. Both sides can read a global.
  if (ko >= 4) {
    if (ko <= 21) {
      unsafe {
        left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
        right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
      }
      if (glue_expr_tree_has_nonlocal_var_c(arena, ctx, left_ref) != 0) {
        return 1;
      }
      return glue_expr_tree_has_nonlocal_var_c(arena, ctx, right_ref);
    }
  }
  // Unary, bitwise not, logical not, or a return operand.
  step = 0;
  if (ko == 22) {
    step = 1;
  }
  if (ko == 23) {
    step = 1;
  }
  if (ko == 24) {
    step = 1;
  }
  if (ko == 41) {
    step = 1;
  }
  if (step != 0) {
    unsafe {
      op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    }
    return glue_expr_tree_has_nonlocal_var_c(arena, ctx, op_ref);
  }
  // IF = 25 and TERNARY = 27 share the if child slots. Checked before
  // the AS getter. A missing arm is not positive and the recursive
  // call returns 0. Nested ifs stay this walk. PLATFORM: SHARED.
  arm = 0;
  if (ko == 25) {
    arm = 1;
  }
  if (ko == 27) {
    arm = 1;
  }
  if (arm != 0) {
    unsafe {
      left_ref = pipeline_expr_if_cond_ref_at(arena, expr_ref);
      right_ref = pipeline_expr_if_then_ref_at(arena, expr_ref);
      op_ref = pipeline_expr_if_else_ref_at(arena, expr_ref);
    }
    if (glue_expr_tree_has_nonlocal_var_c(arena, ctx, left_ref) != 0) {
      return 1;
    }
    if (glue_expr_tree_has_nonlocal_var_c(arena, ctx, right_ref) != 0) {
      return 1;
    }
    return glue_expr_tree_has_nonlocal_var_c(arena, ctx, op_ref);
  }
  // BLOCK = 26. The peel sees a transparent block and unsafe { g }.
  // It returns 0 when the block still has lets. One region unwrap uses
  // the existing getter. The same ref is not walked again.
  // PLATFORM: SHARED.
  if (ko == 26) {
    unsafe {
      peeled = glue_expr_block_transparent_value_ref_at(arena, expr_ref);
    }
    if (peeled > 0) {
      if (peeled != expr_ref) {
        if (glue_expr_tree_has_nonlocal_var_c(arena, ctx, peeled) != 0) {
          return 1;
        }
      }
    }
    unsafe {
      br = pipeline_expr_block_ref_at(arena, expr_ref);
    }
    if (br <= 0) {
      return 0;
    }
    unsafe {
      nso = ast_ast_block_num_stmt_order(arena, br);
    }
    if (nso == 1) {
      unsafe {
        sk = ast_ast_block_stmt_order_kind(arena, br, 0);
        idx = ast_ast_block_stmt_order_idx(arena, br, 0);
      }
      if (sk == 6) {
        if (idx >= 0) {
          unsafe {
            inner = pipeline_block_region_body_ref(arena, br, idx);
          }
          if (inner > 0) {
            br = inner;
          }
        }
      }
    }
    unsafe {
      n = ast_ast_block_num_lets(arena, br);
    }
    i = 0;
    while (i < n) {
      unsafe {
        left_ref = ast_pipeline_block_let_init_ref(arena, br, i);
      }
      if (left_ref > 0) {
        if (left_ref != expr_ref) {
          if (glue_expr_tree_has_nonlocal_var_c(arena, ctx, left_ref) != 0) {
            return 1;
          }
        }
      }
      i = i + 1;
    }
    unsafe {
      left_ref = ast_ast_block_final_expr_ref(arena, br);
    }
    if (left_ref > 0) {
      if (left_ref != expr_ref) {
        if (glue_expr_tree_has_nonlocal_var_c(arena, ctx, left_ref) != 0) {
          return 1;
        }
      }
    }
    unsafe {
      n = ast_ast_block_num_expr_stmts(arena, br);
    }
    i = 0;
    while (i < n) {
      unsafe {
        left_ref = ast_pipeline_block_expr_stmt_ref(arena, br, i);
      }
      if (left_ref > 0) {
        if (left_ref != expr_ref) {
          if (glue_expr_tree_has_nonlocal_var_c(arena, ctx, left_ref) != 0) {
            return 1;
          }
        }
      }
      i = i + 1;
    }
    return 0;
  }
  // EXPR_AS. A positive operand is the child. Kind 54 may still
  // report that operand through this getter.
  unsafe {
    op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
  }
  if (op_ref > 0) {
    return glue_expr_tree_has_nonlocal_var_c(arena, ctx, op_ref);
  }
  if (ko == 44) {
    unsafe {
      left_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
    }
    return glue_expr_tree_has_nonlocal_var_c(arena, ctx, left_ref);
  }
  if (ko == 46) {
    unsafe {
      n = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
    }
    i = 0;
    while (i < n) {
      unsafe {
        left_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, i);
      }
      if (glue_expr_tree_has_nonlocal_var_c(arena, ctx, left_ref) != 0) {
        return 1;
      }
      i = i + 1;
    }
    return 0;
  }
  if (ko == 45) {
    unsafe {
      n = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
    }
    i = 0;
    while (i < n) {
      unsafe {
        left_ref = pipeline_expr_struct_lit_init_ref(arena, expr_ref, i);
      }
      if (glue_expr_tree_has_nonlocal_var_c(arena, ctx, left_ref) != 0) {
        return 1;
      }
      i = i + 1;
    }
    return 0;
  }
  return 0;
}
