// Live body of glue_live_fwd_collect_expr_uses_for_defer.
// The copy in runtime_pipeline_abi.x is an extern. pabi_weak still has
// the old strong definition. This object is linked first, so this body
// wins. The old walk stopped at a binop, a unary, an AS, an index, a
// field, an array literal, or a struct literal. An if, a ternary, or
// a match was invisible, so `let n = match c { 1 => 4; _ => 9; }`
// stayed in pass 0 and read c before `c = 1`. This is the one walk.
// A transparent block is peeled by the existing helper. A block that
// still has lets is then walked with the existing block getters.
// Every unsafe region in that block is the same block walk, including
// when a let shares the block. A dereference uses the same unary
// operand getter. Do not add a second walker.
// PLATFORM: SHARED.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, expr_ref: i32): i32;
export extern function glue_live_fwd_add_u8(gen: *u8, off: i32): void;
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
export extern function pipeline_expr_match_matched_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_match_num_arms_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_match_arm_result_ref(arena: *u8, expr_ref: i32, i: i32): i32;
export extern function pipeline_expr_match_arm_guard_ref(arena: *u8, expr_ref: i32, i: i32): i32;
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
 * Record stack slots read inside one block, for the pass-1 defer mask.
 * @param arena *u8 - AST arena; null returns without writing
 * @param ctx *u8 - AsmFuncCtx; null returns without writing
 * @param br i32 - block pool ref; not positive returns
 * @param expr_ref i32 - expr that owns this walk; a child equal to it is skipped
 * @param gen *u8 - GlueBlockLiveFwd overlay (u8[136]); null returns
 * @param peeled i32 - value already recorded by the transparent peel; skipped
 * Every unsafe region (stmt kind 6) uses the existing region getter.
 * A region body is this same function, with no peel to skip. A let
 * init, the final expr, and an expr statement are
 * glue_live_fwd_collect_expr_uses_for_defer. The same block ref is
 * not entered again. A repeated slot is one entry.
 * PLATFORM: SHARED.
 */
function glue_live_fwd_collect_block_for_defer(
  arena: *u8, ctx: *u8, br: i32, expr_ref: i32, gen: *u8, peeled: i32
): void {
  let i: i32 = 0;
  let n: i32 = 0;
  let nso: i32 = 0;
  let sk: i32 = 0;
  let idx: i32 = 0;
  let inner: i32 = 0;
  let child: i32 = 0;
  if (arena == (0 as *u8)) {
    return;
  }
  if (ctx == (0 as *u8)) {
    return;
  }
  if (gen == (0 as *u8)) {
    return;
  }
  if (br <= 0) {
    return;
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
            glue_live_fwd_collect_block_for_defer(arena, ctx, inner, expr_ref, gen, 0);
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
        glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, child, gen);
      }
    }
    i = i + 1;
  }
  unsafe {
    child = ast_ast_block_final_expr_ref(arena, br);
  }
  if (child > 0) {
    if (child != expr_ref) {
      if (child != peeled) {
        glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, child, gen);
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
        glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, child, gen);
      }
    }
    i = i + 1;
  }
}

/**
 * Record stack slots read by one expr, for the pass-1 defer mask.
 * @param arena *u8 - AST arena; null returns without writing
 * @param ctx *u8 - AsmFuncCtx; null returns without writing
 * @param expr_ref i32 - expr pool ref; not positive returns
 * @param gen *u8 - GlueBlockLiveFwd overlay (u8[136]); null returns
 * A VAR records its frame slot. A binop, including a lane compare
 * (kinds 14..19), walks both sides. A unary, an AS, an index, a
 * field, an array literal, and a struct literal walk their children.
 * An if (kind 25) and a ternary (kind 27) walk the condition, the
 * then arm, and the else arm. A transparent block (kind 26) walks
 * the value the existing peel returns. A block that still has lets
 * is not peeled; this walk then records let inits, the final expr,
 * and expr statements with the existing block getters. Every unsafe
 * region (stmt kind 6) is that same block walk, including when a let
 * shares the block. A match (kind 43) walks
 * the scrutinee, each arm result, and each arm guard before the AS
 * getter. A dereference (kind 52) walks its operand through the same
 * unary getter. Nested nodes are this same function. Kind 51 is not
 * a VAR.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function glue_live_fwd_collect_expr_uses_for_defer(
  arena: *u8, ctx: *u8, expr_ref: i32, gen: *u8
): void {
  let ko: i32 = 0;
  let i: i32 = 0;
  let n: i32 = 0;
  let left_ref: i32 = 0;
  let right_ref: i32 = 0;
  let op_ref: i32 = 0;
  let off: i32 = 0;
  let step: i32 = 0;
  let arm: i32 = 0;
  let peeled: i32 = 0;
  let br: i32 = 0;
  if (arena == (0 as *u8)) {
    return;
  }
  if (ctx == (0 as *u8)) {
    return;
  }
  if (gen == (0 as *u8)) {
    return;
  }
  if (expr_ref <= 0) {
    return;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  // EXPR_VAR = 3. The slot is already assigned when the defer mask
  // is built. A missing home is not a local use.
  if (ko == 3) {
    unsafe {
      off = glue_var_expr_stack_off_elf_c(arena, ctx, expr_ref);
    }
    if (off >= 0) {
      unsafe {
        glue_live_fwd_add_u8(gen, off);
      }
    }
    return;
  }
  // Kinds 4..21, including EQ..GE. Both sides are uses.
  if (ko >= 4) {
    if (ko <= 21) {
      unsafe {
        left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
        right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
      }
      glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, left_ref, gen);
      glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, right_ref, gen);
      return;
    }
  }
  // Unary, bitwise not, logical not, a return operand, or a
  // dereference. Kind 52 stores its operand in the same unary slot
  // the existing getter reads. The walk records that operand. This
  // is not the assign-deref store, and the kind-52 emit stub stays.
  // PLATFORM: SHARED.
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
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, op_ref, gen);
    return;
  }
  // IF = 25 and TERNARY = 27 share the if child slots. Checked before
  // the AS getter: that getter reads a different slot, and a stale
  // value there must not hide the arms. The condition and both arms
  // are uses. A missing arm is not positive and the recursive call
  // returns. Nested ifs stay this walk. PLATFORM: SHARED.
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
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, left_ref, gen);
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, right_ref, gen);
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, op_ref, gen);
    return;
  }
  // BLOCK = 26. The existing peel sees a transparent block and
  // returns 0 when the block still has lets or loops. This walk does
  // not replace that peel. Every unsafe region is the same block walk,
  // including when a let shares the block. A repeated slot is one
  // entry: glue_live_fwd_add_u8 dedups. PLATFORM: SHARED.
  if (ko == 26) {
    unsafe {
      peeled = glue_expr_block_transparent_value_ref_at(arena, expr_ref);
    }
    if (peeled > 0) {
      if (peeled != expr_ref) {
        glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, peeled, gen);
      }
    }
    unsafe {
      br = pipeline_expr_block_ref_at(arena, expr_ref);
    }
    glue_live_fwd_collect_block_for_defer(arena, ctx, br, expr_ref, gen, peeled);
    return;
  }
  // MATCH = 43. Checked before the AS getter so a stale AS slot
  // cannot hide the scrutinee or the arms. The scrutinee, each arm
  // result, and each arm guard are uses. A missing guard is not
  // positive and the recursive call returns. Patterns are a literal
  // or a variant index, not an expr. PLATFORM: SHARED.
  if (ko == 43) {
    unsafe {
      left_ref = pipeline_expr_match_matched_ref_at(arena, expr_ref);
    }
    if (left_ref > 0) {
      if (left_ref != expr_ref) {
        glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, left_ref, gen);
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
          glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, left_ref, gen);
        }
      }
      if (right_ref > 0) {
        if (right_ref != expr_ref) {
          glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, right_ref, gen);
        }
      }
      i = i + 1;
    }
    return;
  }
  // EXPR_AS. A positive operand ref is the use. Kind 54 may still
  // report that operand through this getter.
  unsafe {
    op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
  }
  if (op_ref > 0) {
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, op_ref, gen);
    return;
  }
  // EXPR_INDEX = 47. Base and index are both uses.
  if (ko == 47) {
    unsafe {
      left_ref = pipeline_expr_index_base_ref(arena, expr_ref);
      right_ref = pipeline_expr_index_index_ref(arena, expr_ref);
    }
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, left_ref, gen);
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, right_ref, gen);
    return;
  }
  // FIELD = 44. The base is the use.
  if (ko == 44) {
    unsafe {
      left_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
    }
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, left_ref, gen);
    return;
  }
  // ARRAY_LIT = 46.
  if (ko == 46) {
    unsafe {
      n = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
    }
    i = 0;
    while (i < n) {
      unsafe {
        left_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, i);
      }
      glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, left_ref, gen);
      i = i + 1;
    }
    return;
  }
  // STRUCT_LIT = 45.
  if (ko == 45) {
    unsafe {
      n = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
    }
    i = 0;
    while (i < n) {
      unsafe {
        left_ref = pipeline_expr_struct_lit_init_ref(arena, expr_ref, i);
      }
      glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, left_ref, gen);
      i = i + 1;
    }
    return;
  }
}
