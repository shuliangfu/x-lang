// Live body of glue_expr_tree_has_call_index_c.
// The copy in runtime_pipeline_abi.x is an extern. pabi_weak still has
// the old strong definition. This object is linked first, so this body
// wins. The old walk stopped at a binop, a unary, an AS, an index, a
// field, an array literal, or a struct literal. An if, a ternary, or a
// block was invisible, so `let n = if { pick() }` stayed in pass 0 and
// ran before a prior store. This is the one walk. A transparent block
// is peeled by the existing helper. A block that still has lets, an
// expr statement, or an unsafe region is walked here with the existing
// block getters. Every unsafe region in that block is the same block
// walk, including when a let shares the block. A match walks its
// scrutinee, each arm result, and each arm guard through this same
// function. Patterns are not expressions. A dereference walks its
// operand through this same function. Kind 51 stays out. Do not add
// a second walker.
// PLATFORM: SHARED.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_right_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_as_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
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
export extern function pipeline_expr_match_matched_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_match_num_arms_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_match_arm_result_ref(arena: *u8, expr_ref: i32, i: i32): i32;
export extern function pipeline_expr_match_arm_guard_ref(arena: *u8, expr_ref: i32, i: i32): i32;

/**
 * True when a block contains an index, a call, or a method call.
 * @param arena *u8 - AST arena; null returns 0
 * @param br i32 - block pool ref; not positive returns 0
 * @param expr_ref i32 - expr that owns this walk; a child equal to it is skipped
 * @return i32 - 1 when a call, an index, or a method is present; 0 otherwise
 * Every unsafe region (stmt kind 6) uses the existing region getter.
 * A region body is this same function. A let init, the final expr, and
 * an expr statement are glue_expr_tree_has_call_index_c. The same
 * block ref is not entered again. PLATFORM: SHARED.
 */
function glue_has_call_block_c(arena: *u8, br: i32, expr_ref: i32): i32 {
  let i: i32 = 0;
  let n: i32 = 0;
  let nso: i32 = 0;
  let sk: i32 = 0;
  let idx: i32 = 0;
  let inner: i32 = 0;
  let child: i32 = 0;
  if (arena == (0 as *u8)) {
    return 0;
  }
  if (br <= 0) {
    return 0;
  }
  unsafe {
    nso = ast_ast_block_num_stmt_order(arena, br);
  }
  i = 0;
  while (i < nso) {
    unsafe {
      sk = ast_ast_block_stmt_order_kind(arena, br, i);
      idx = ast_ast_block_stmt_order_idx(arena, br, i);
    }
    if (sk == 6) {
      if (idx >= 0) {
        unsafe {
          inner = pipeline_block_region_body_ref(arena, br, idx);
        }
        if (inner > 0) {
          if (inner != br) {
            if (glue_has_call_block_c(arena, inner, expr_ref) != 0) {
              return 1;
            }
          }
        }
      }
    }
    i = i + 1;
  }
  unsafe {
    n = ast_ast_block_num_lets(arena, br);
  }
  i = 0;
  while (i < n) {
    unsafe {
      child = ast_pipeline_block_let_init_ref(arena, br, i);
    }
    if (child > 0) {
      if (child != expr_ref) {
        if (glue_expr_tree_has_call_index_c(arena, child) != 0) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  unsafe {
    child = ast_ast_block_final_expr_ref(arena, br);
  }
  if (child > 0) {
    if (child != expr_ref) {
      if (glue_expr_tree_has_call_index_c(arena, child) != 0) {
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
      child = ast_pipeline_block_expr_stmt_ref(arena, br, i);
    }
    if (child > 0) {
      if (child != expr_ref) {
        if (glue_expr_tree_has_call_index_c(arena, child) != 0) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * True when the expr tree contains an index, a call, or a method call.
 * @param arena *u8 - AST arena; null returns 0
 * @param expr_ref i32 - expr pool ref; not positive returns 0
 * @return i32 - 1 when a call, an index, or a method is present; 0 otherwise
 * Pass 0 must not hoist that let ahead of an earlier store. An if (kind
 * 25) and a ternary (kind 27) walk the condition and both arms before
 * the AS getter, so a stale AS slot cannot hide the call. A block (kind
 * 26) asks the existing transparent peel, then walks let inits, the
 * final expr, and expr statements. Every unsafe region (stmt kind 6)
 * is that same block walk, including when a let shares the block.
 * A match walks its scrutinee, each arm result, and each arm guard
 * through this same function. Patterns are not expressions.
 * A dereference (kind 52) shares the unary operand slot and walks
 * that operand through this same function. Kind 51 is not a call.
 * Nested nodes are this same function. A global
 * read with no call is not this function.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function glue_expr_tree_has_call_index_c(arena: *u8, expr_ref: i32): i32 {
  let ko: i32 = 0;
  let i: i32 = 0;
  let n: i32 = 0;
  let left_ref: i32 = 0;
  let right_ref: i32 = 0;
  let op_ref: i32 = 0;
  let peeled: i32 = 0;
  let br: i32 = 0;
  let step: i32 = 0;
  let arm: i32 = 0;
  if (arena == (0 as *u8)) {
    return 0;
  }
  if (expr_ref <= 0) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  // INDEX = 47, CALL = 48, METHOD = 49. The node itself is enough.
  if (ko == 47) {
    return 1;
  }
  if (ko == 48) {
    return 1;
  }
  if (ko == 49) {
    return 1;
  }
  // Kinds 4..21, including a lane compare. Both sides can hold a call.
  if (ko >= 4) {
    if (ko <= 21) {
      unsafe {
        left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
        right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
      }
      if (glue_expr_tree_has_call_index_c(arena, left_ref) != 0) {
        return 1;
      }
      return glue_expr_tree_has_call_index_c(arena, right_ref);
    }
  }
  // Unary, bitwise not, logical not, a return operand, or a
  // dereference. Kind 52 shares the unary operand slot. Kind 51
  // stays out: an address is not a call. PLATFORM: SHARED.
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
  if (ko == 52) {
    step = 1;
  }
  if (step != 0) {
    unsafe {
      op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    }
    return glue_expr_tree_has_call_index_c(arena, op_ref);
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
    if (glue_expr_tree_has_call_index_c(arena, left_ref) != 0) {
      return 1;
    }
    if (glue_expr_tree_has_call_index_c(arena, right_ref) != 0) {
      return 1;
    }
    return glue_expr_tree_has_call_index_c(arena, op_ref);
  }
  // BLOCK = 26. The peel sees `{ pick() }` and `unsafe { pick() }`.
  // It returns 0 when the block still has lets, and it returns only
  // the final expr of `{ pick(); 4 }`, so the expr statement is walked
  // below. Every unsafe region is that same block walk, including when
  // a let shares the block. PLATFORM: SHARED.
  if (ko == 26) {
    unsafe {
      peeled = glue_expr_block_transparent_value_ref_at(arena, expr_ref);
    }
    if (peeled > 0) {
      if (peeled != expr_ref) {
        if (glue_expr_tree_has_call_index_c(arena, peeled) != 0) {
          return 1;
        }
      }
    }
    unsafe {
      br = pipeline_expr_block_ref_at(arena, expr_ref);
    }
    return glue_has_call_block_c(arena, br, expr_ref);
  }
  // MATCH = 43. Checked before the AS getter so a stale AS slot
  // cannot hide the scrutinee or the arms. The scrutinee, each arm
  // result, and each arm guard are this same walk. A missing guard
  // is not positive and the recursive call returns 0. Patterns are
  // a literal or a variant index, not an expr. PLATFORM: SHARED.
  if (ko == 43) {
    unsafe {
      left_ref = pipeline_expr_match_matched_ref_at(arena, expr_ref);
    }
    if (left_ref > 0) {
      if (left_ref != expr_ref) {
        if (glue_expr_tree_has_call_index_c(arena, left_ref) != 0) {
          return 1;
        }
      }
    }
    unsafe {
      n = pipeline_expr_match_num_arms_at(arena, expr_ref);
    }
    i = 0;
    while (i < n) {
      unsafe {
        left_ref = pipeline_expr_match_arm_result_ref(arena, expr_ref, i);
        right_ref = pipeline_expr_match_arm_guard_ref(arena, expr_ref, i);
      }
      if (left_ref > 0) {
        if (left_ref != expr_ref) {
          if (glue_expr_tree_has_call_index_c(arena, left_ref) != 0) {
            return 1;
          }
        }
      }
      if (right_ref > 0) {
        if (right_ref != expr_ref) {
          if (glue_expr_tree_has_call_index_c(arena, right_ref) != 0) {
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
    return glue_expr_tree_has_call_index_c(arena, op_ref);
  }
  if (ko == 44) {
    unsafe {
      left_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
    }
    return glue_expr_tree_has_call_index_c(arena, left_ref);
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
      if (glue_expr_tree_has_call_index_c(arena, left_ref) != 0) {
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
      if (glue_expr_tree_has_call_index_c(arena, left_ref) != 0) {
        return 1;
      }
      i = i + 1;
    }
    return 0;
  }
  return 0;
}
