// Thin pure: mixed-width integer ADD and SUB, and f32-expression promote
// (w1591 add / f32, w1594 sub).
// glue_binop_operand_is_64bit_elf_c keeps the first typed operand. An i32
// on the left hides an i64 on the right. The add was then 32-bit and cltq
// dropped the high half. The rbx-minus-rax sub is already subq on x86, and
// the same missed width still runs cltq and keeps only the low 32 bits.
// An f32 binop assigned to f64 has no type ref, so the promote helper
// no-ops and the f32 bits are stored as an f64.
// Integer times f64 already goes through the binop_wide mixed leaf.
// Integer times a wide integer is not this object.
// w1597: u32 minus u32, and u8 minus u8, kept a 64-bit result. On x86 the
// rbx-minus-rax encoder is subq, so 0 - 1 stays -1. A literal on the right
// uses subl, which wraps at 32 bits, and then cltq sign-extends that wrap.
// Zero-extend the low 32 bits for u32, or the low 8 bits for u8, and skip
// cltq. A wide integer on either side stays a full 64-bit subtract. i32
// still sign-extends. The rax-minus-rbx direction is in this object too,
// so a literal on the right takes the same zero-extend.
// w1598: an add of two i32-stamped literals, or of a u32 and a literal, stored
// into a u32 still used that 32-bit add and then cltq. The 32-bit add already
// zero-extends. cltq makes a sum at or above 2^31 negative before the 8-byte
// store. When this add is a u32 let's initializer, or the right-hand side of
// an assign to a u32 variable, zero-extend and skip cltq. A literal has no
// block ref, so the current function body is scanned, including nested while,
// for, and if bodies. An i32 destination still sign-extends. An add that is
// not stored in a u32 still sign-extends. A wide integer stays on the 64-bit
// add.
// w1599: that store scan takes the binop kind. Add still passes 4. The
// binop-wide overlay calls the same scan with 6, for a 32-bit product that
// is stored in a u32. The add tail in this file is otherwise unchanged.
// LINUX links this object ahead of the egg. Do not rebuild the pabi egg.
// Darwin and Windows keep the previous body until they relink.
// PLATFORM: SHARED — x86_64 and arm64 encoders; LINUX installs the object.

export extern function glue_binop_operand_is_scalar_f64_elf_c(arena: *u8, ctx: *u8, expr_ref: i32): i32;
export extern function glue_binop_operand_is_scalar_f32_elf_c(arena: *u8, ctx: *u8, expr_ref: i32): i32;
export extern function glue_binop_operand_is_64bit_elf_c(arena: *u8, ctx: *u8, left_ref: i32, right_ref: i32): i32;
export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_ptr_arith_scale_rbx_offset_if_left_ptr_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ta: i32): i32;
export extern function glue_binop_maybe_sxt_i32_result_elf_c(arena: *u8, ctx: *u8, left_ref: i32, right_ref: i32, elf_ctx: *u8, ta: i32): i32;
export extern function glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function glue_enc_zxt_u32_result_to_rax_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function glue_enc_zxt_u8_result_to_rax_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_sub_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_subsd_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_subss_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_addsd_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_addss_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_rax_plus_rbx_scale1_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_add_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_sub_rbx_rax_then_mov_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_subsd_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_subss_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_append_u8_c(elf_ctx: *u8, byte: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rbx_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_asm_emit_func_index_c(): i32;
export extern function pipeline_module_func_param_type_ref_for_name(mod: *u8, func_index: i32, name: *u8, name_len: i32): i32;
export extern function pipeline_asm_emit_ctx_scope_block_get(): i32;
export extern function pipeline_block_resolve_var_type_ref(arena: *u8, block_ref: i32, name: *u8, name_len: i32): i32;
export extern function pipeline_module_func_body_ref_at(mod: *u8, func_index: i32): i32;
export extern function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_right_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_block_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function ast_ast_block_num_lets(arena: *u8, block_ref: i32): i32;
export extern function pipeline_block_let_init_ref(arena: *u8, block_ref: i32, index: i32): i32;
export extern function pipeline_block_let_type_ref(arena: *u8, block_ref: i32, index: i32): i32;
export extern function ast_ast_block_num_expr_stmts(arena: *u8, block_ref: i32): i32;
export extern function pipeline_block_expr_stmt_ref(arena: *u8, block_ref: i32, index: i32): i32;
export extern function ast_ast_block_num_loops(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_for_loops(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_if_stmts(arena: *u8, block_ref: i32): i32;
export extern function pipeline_block_while_body_ref(arena: *u8, block_ref: i32, index: i32): i32;
export extern function pipeline_block_for_body_ref(arena: *u8, block_ref: i32, index: i32): i32;
export extern function pipeline_block_if_then_body_ref(arena: *u8, block_ref: i32, index: i32): i32;
export extern function pipeline_block_if_else_body_ref(arena: *u8, block_ref: i32, index: i32): i32;

/**
 * Type kind of one operand, or -1 when it has no type ref.
 * Resolved type wins. A VAR with an empty stamp uses its declaration.
 * @param arena *u8 — AST arena; null returns -1
 * @param ctx *u8 — emit context for the VAR declaration; null skips that fallback
 * @param expr_ref i32 — operand expression; <=0 returns -1
 * @return i32 — type kind, or -1
 * PLATFORM: SHARED freestanding emit.
 */
function w1591_operand_kind(arena: *u8, ctx: *u8, expr_ref: i32): i32 {
  let tr: i32 = 0;
  let kind: i32 = 0;
  if (arena == (0 as *u8) || expr_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
    if (tr <= 0 && ctx != (0 as *u8)) {
      tr = glue_var_decl_type_ref_elf_c(arena, ctx, expr_ref);
    }
    if (tr <= 0) {
      return 0 - 1;
    }
    kind = pipeline_type_kind_ord_at(arena, tr);
  }
  return kind;
}

/**
 * True when the operand is a 64-bit integer, not a pointer.
 * A pointer (kind 9) stays on the existing scale path. A wide INT_LIT
 * and a nested 64-bit binop count, because the pair helper never sees
 * them once the other side already has a narrower type.
 * @param arena *u8 — AST arena
 * @param ctx *u8 — emit context
 * @param expr_ref i32 — one operand
 * @return i32 — 1 when the operand is a wide integer, else 0
 * PLATFORM: SHARED freestanding emit.
 */
function w1591_is_wide_int(arena: *u8, ctx: *u8, expr_ref: i32): i32 {
  let kind: i32 = 0;
  let wide: i32 = 0;
  kind = w1591_operand_kind(arena, ctx, expr_ref);
  if (kind == 9) {
    return 0;
  }
  if (kind == 4 || kind == 5 || kind == 6 || kind == 7) {
    return 1;
  }
  unsafe {
    wide = glue_binop_operand_is_64bit_elf_c(arena, ctx, expr_ref, 0);
  }
  if (wide != 0 && kind != 9) {
    return 1;
  }
  return 0;
}

/**
 * True when the operand is an i32, u8, or u32.
 * @param arena *u8 — AST arena
 * @param ctx *u8 — emit context
 * @param expr_ref i32 — one operand
 * @return i32 — 1 when the operand is a narrow integer, else 0
 * PLATFORM: SHARED freestanding emit.
 */
function w1591_is_narrow_int(arena: *u8, ctx: *u8, expr_ref: i32): i32 {
  let kind: i32 = 0;
  kind = w1591_operand_kind(arena, ctx, expr_ref);
  if (kind == 0 || kind == 2 || kind == 3) {
    return 1;
  }
  return 0;
}

/**
 * True when expr is an INT_LIT that fits in i32.
 * The lit shortcut parks that immediate in rbx with a zero-extending mov.
 * A wide literal is not this case.
 * @param arena *u8 — AST arena
 * @param expr_ref i32 — expression ref
 * @return i32 — 1 when it is an i32-fit literal, else 0
 * PLATFORM: SHARED freestanding emit.
 */
function w1591_is_narrow_lit(arena: *u8, expr_ref: i32): i32 {
  let ko: i32 = 0;
  let wide: i32 = 0;
  if (arena == (0 as *u8) || expr_ref <= 0) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  if (ko != 0) {
    return 0;
  }
  unsafe {
    wide = glue_binop_operand_is_64bit_elf_c(arena, 0 as *u8, expr_ref, 0);
  }
  if (wide != 0) {
    return 0;
  }
  return 1;
}

/**
 * Sign-extend the i32 in rbx to 64 bits and restore rax.
 * The lit encoder writes mov imm32 to ebx, which zero-extends.
 * cdqe runs on rax, so rbx moves through rax around the saved left value.
 * @param elf_ctx *u8 — encoder context
 * @param ta i32 — 0 is x86_64, 1 is arm64
 * @return i32 — 0 ok, -1 encode failure
 * PLATFORM: SHARED — x86_64 cdqe and arm64 sxtw.
 */
function w1591_sxt_rbx(elf_ctx: *u8, ta: i32): i32 {
  unsafe {
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/**
 * True when this block stores the binop of left_ref and right_ref into a u32.
 * A let whose initializer is that binop, or an assign whose right-hand side
 * is that binop and whose left-hand side is a u32 variable, counts. Other
 * destinations stay on the signed tail. Nested while, for, and if bodies
 * are scanned after this block. The walk is capped so a corrupt count
 * cannot run away.
 * @param arena *u8 — AST arena; null returns 0
 * @param ctx *u8 — emit context; null skips the assign walk
 * @param block_ref i32 — block that may own the let or the assign; <=0 returns 0
 * @param left_ref i32 — binop's left expression
 * @param right_ref i32 — binop's right expression
 * @param depth i32 — 0 at the function body; each nested body adds one; above 16 returns 0
 * @param op_kind i32 — expression kind of the binop; 4 is add, 6 is mul
 * @return i32 — 1 when the stored result is u32, else 0
 * PLATFORM: SHARED freestanding emit.
 */
function w1598_block_has_u32_add(arena: *u8, ctx: *u8, block_ref: i32, left_ref: i32, right_ref: i32, depth: i32, op_kind: i32): i32 {
  let n: i32 = 0;
  let i: i32 = 0;
  let init: i32 = 0;
  let init_kind: i32 = 0;
  let tr: i32 = 0;
  let tk: i32 = 0;
  let er: i32 = 0;
  let rhs: i32 = 0;
  let rhs_kind: i32 = 0;
  let lhs: i32 = 0;
  let lhs_kind: i32 = 0;
  let child_l: i32 = 0;
  let child_r: i32 = 0;
  if (arena == (0 as *u8) || block_ref <= 0 || left_ref <= 0 || right_ref <= 0 || depth > 16) {
    return 0;
  }
  unsafe {
    n = ast_ast_block_num_lets(arena, block_ref);
  }
  if (n < 0) {
    n = 0;
  }
  if (n > 4096) {
    n = 4096;
  }
  i = 0;
  while (i < n) {
    init = 0;
    unsafe {
      init = pipeline_block_let_init_ref(arena, block_ref, i);
    }
    if (init > 0) {
      init_kind = 0;
      unsafe {
        init_kind = pipeline_expr_kind_ord_at(arena, init);
      }
      // op_kind selects the binop (4 add, 6 mul). A wider expression
      // around it is not this operation.
      if (init_kind == op_kind) {
        child_l = 0;
        child_r = 0;
        unsafe {
          child_l = pipeline_expr_binop_left_ref_at(arena, init);
          child_r = pipeline_expr_binop_right_ref_at(arena, init);
        }
        if (child_l == left_ref && child_r == right_ref) {
          tr = 0;
          unsafe {
            tr = pipeline_block_let_type_ref(arena, block_ref, i);
          }
          if (tr > 0) {
            tk = 0;
            unsafe {
              tk = pipeline_type_kind_ord_at(arena, tr);
            }
            // TYPE_U32 = 3. The slot must keep the low 32 bits.
            if (tk == 3) {
              return 1;
            }
          }
        }
      }
    }
    i = i + 1;
  }
  if (ctx == (0 as *u8)) {
    return w1598_nested_has_u32_add(arena, ctx, block_ref, left_ref, right_ref, depth, op_kind);
  }
  n = 0;
  unsafe {
    n = ast_ast_block_num_expr_stmts(arena, block_ref);
  }
  if (n < 0) {
    n = 0;
  }
  if (n > 4096) {
    n = 4096;
  }
  i = 0;
  while (i < n) {
    er = 0;
    unsafe {
      er = pipeline_block_expr_stmt_ref(arena, block_ref, i);
    }
    if (er > 0) {
      init_kind = 0;
      unsafe {
        init_kind = pipeline_expr_kind_ord_at(arena, er);
      }
      // EXPR_ASSIGN = 28. Left is the variable, right is the value.
      if (init_kind == 28) {
        rhs = 0;
        unsafe {
          rhs = pipeline_expr_binop_right_ref_at(arena, er);
        }
        if (rhs > 0) {
          rhs_kind = 0;
          unsafe {
            rhs_kind = pipeline_expr_kind_ord_at(arena, rhs);
          }
          if (rhs_kind == op_kind) {
            child_l = 0;
            child_r = 0;
            unsafe {
              child_l = pipeline_expr_binop_left_ref_at(arena, rhs);
              child_r = pipeline_expr_binop_right_ref_at(arena, rhs);
            }
            if (child_l == left_ref && child_r == right_ref) {
              lhs = 0;
              unsafe {
                lhs = pipeline_expr_binop_left_ref_at(arena, er);
              }
              if (lhs > 0) {
                lhs_kind = 0;
                unsafe {
                  lhs_kind = pipeline_expr_kind_ord_at(arena, lhs);
                }
                // EXPR_VAR = 3. Field assigns stay on the signed tail.
                if (lhs_kind == 3) {
                  tr = 0;
                  unsafe {
                    tr = glue_var_decl_type_ref_elf_c(arena, ctx, lhs);
                  }
                  if (tr > 0) {
                    tk = 0;
                    unsafe {
                      tk = pipeline_type_kind_ord_at(arena, tr);
                    }
                    if (tk == 3) {
                      return 1;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    i = i + 1;
  }
  return w1598_nested_has_u32_add(arena, ctx, block_ref, left_ref, right_ref, depth, op_kind);
}

/**
 * True when a nested while, for, or if body stores this binop into a u32.
 * The parent block's lets and assigns are already scanned. Each nested
 * body adds one to depth. At 16 the walk stops, so a body that points at
 * its parent cannot run away.
 * @param arena *u8 — AST arena; null returns 0
 * @param ctx *u8 — emit context; forwarded into each nested body
 * @param block_ref i32 — parent block; <=0 returns 0
 * @param left_ref i32 — binop's left expression
 * @param right_ref i32 — binop's right expression
 * @param depth i32 — depth of the parent; >=16 returns 0
 * @param op_kind i32 — expression kind of the binop; 4 is add, 6 is mul
 * @return i32 — 1 when a nested body stores the binop into a u32, else 0
 * PLATFORM: SHARED freestanding emit.
 */
function w1598_nested_has_u32_add(arena: *u8, ctx: *u8, block_ref: i32, left_ref: i32, right_ref: i32, depth: i32, op_kind: i32): i32 {
  let n: i32 = 0;
  let i: i32 = 0;
  let child: i32 = 0;
  if (arena == (0 as *u8) || block_ref <= 0 || left_ref <= 0 || right_ref <= 0 || depth >= 16) {
    return 0;
  }
  unsafe {
    n = ast_ast_block_num_loops(arena, block_ref);
  }
  if (n < 0) {
    n = 0;
  }
  if (n > 4096) {
    n = 4096;
  }
  i = 0;
  while (i < n) {
    child = 0;
    unsafe {
      child = pipeline_block_while_body_ref(arena, block_ref, i);
    }
    // A body that is this block would cycle. Skip it.
    if (child > 0 && child != block_ref) {
      if (w1598_block_has_u32_add(arena, ctx, child, left_ref, right_ref, depth + 1, op_kind) != 0) {
        return 1;
      }
    }
    i = i + 1;
  }
  n = 0;
  unsafe {
    n = ast_ast_block_num_for_loops(arena, block_ref);
  }
  if (n < 0) {
    n = 0;
  }
  if (n > 4096) {
    n = 4096;
  }
  i = 0;
  while (i < n) {
    child = 0;
    unsafe {
      child = pipeline_block_for_body_ref(arena, block_ref, i);
    }
    if (child > 0 && child != block_ref) {
      if (w1598_block_has_u32_add(arena, ctx, child, left_ref, right_ref, depth + 1, op_kind) != 0) {
        return 1;
      }
    }
    i = i + 1;
  }
  n = 0;
  unsafe {
    n = ast_ast_block_num_if_stmts(arena, block_ref);
  }
  if (n < 0) {
    n = 0;
  }
  if (n > 4096) {
    n = 4096;
  }
  i = 0;
  while (i < n) {
    child = 0;
    unsafe {
      child = pipeline_block_if_then_body_ref(arena, block_ref, i);
    }
    if (child > 0 && child != block_ref) {
      if (w1598_block_has_u32_add(arena, ctx, child, left_ref, right_ref, depth + 1, op_kind) != 0) {
        return 1;
      }
    }
    child = 0;
    unsafe {
      child = pipeline_block_if_else_body_ref(arena, block_ref, i);
    }
    if (child > 0 && child != block_ref) {
      if (w1598_block_has_u32_add(arena, ctx, child, left_ref, right_ref, depth + 1, op_kind) != 0) {
        return 1;
      }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * True when the binop of these two operands is stored into a u32.
 * An operand block is tried first. A literal has no block ref, so the
 * current function body is scanned after that, including nested while,
 * for, and if bodies. The mul overlay calls this by the bare name.
 * @param arena *u8 — AST arena; null returns 0
 * @param ctx *u8 — emit context; null still checks lets
 * @param left_ref i32 — binop's left expression
 * @param right_ref i32 — binop's right expression
 * @param op_kind i32 — expression kind of the binop; 4 is add, 6 is mul
 * @return i32 — 1 when the stored result is u32, else 0
 * PLATFORM: SHARED freestanding emit. LINUX — both overlays link this name.
 */
#[no_mangle]
export function w1598_add_stored_in_u32(arena: *u8, ctx: *u8, left_ref: i32, right_ref: i32, op_kind: i32): i32 {
  let block_l: i32 = 0;
  let block_r: i32 = 0;
  let block_f: i32 = 0;
  let fi: i32 = 0;
  let mod: *u8 = 0 as *u8;
  if (arena == (0 as *u8) || left_ref <= 0 || right_ref <= 0) {
    return 0;
  }
  unsafe {
    block_l = pipeline_expr_block_ref_at(arena, left_ref);
    block_r = pipeline_expr_block_ref_at(arena, right_ref);
    mod = pipeline_asm_emit_module_ref_c();
    fi = pipeline_asm_emit_func_index_c();
    // Index 0 is the first function. A negative index means emit has not
    // entered a function, so there is no body to scan.
    if (mod != (0 as *u8) && fi >= 0) {
      block_f = pipeline_module_func_body_ref_at(mod, fi);
    }
  }
  if (block_l > 0) {
    if (w1598_block_has_u32_add(arena, ctx, block_l, left_ref, right_ref, 0, op_kind) != 0) {
      return 1;
    }
  }
  if (block_r > 0 && block_r != block_l) {
    if (w1598_block_has_u32_add(arena, ctx, block_r, left_ref, right_ref, 0, op_kind) != 0) {
      return 1;
    }
  }
  if (block_f > 0 && block_f != block_l && block_f != block_r) {
    if (w1598_block_has_u32_add(arena, ctx, block_f, left_ref, right_ref, 0, op_kind) != 0) {
      return 1;
    }
  }
  return 0;
}

/**
 * Emit integer or float ADD of the values already in rax and rbx.
 * Same float, pointer-scale, and 32-bit arms as the egg. A narrow
 * integer next to a wide integer uses the 64-bit add and does not cltq.
 * A narrow literal is sign-extended in rbx first. An i32 variable is
 * sign-extended in rax; that cdqe is a no-op when the slot load already
 * sign-extended. A 32-bit add stored into a u32 is zero-extended instead,
 * so a sum at or above 2^31 does not become a negative i64 in that slot.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — encoder context
 * @param ctx *u8 — emit context
 * @param left_ref i32 — left expression; rax for a variable, rbx for an i32 literal
 * @param right_ref i32 — right expression; rbx for a variable
 * @param ta i32 — 0 is x86_64, 1 is arm64
 * @return i32 — 0 ok, nonzero encode failure
 * PLATFORM: SHARED — x86_64 REX.W add and arm64 ADD X.
 */
#[no_mangle]
export function glue_emit_binop_add_rax_rbx_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, left_ref: i32, right_ref: i32, ta: i32): i32 {
  let rc: i32 = 0;
  let is_64bit: i32 = 0;
  let left_kind: i32 = 0;
  let lit_mixed: i32 = 0;
  unsafe {
    if ((ta == 0 || ta == 1) && (glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) != 0) && (glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref) != 0)) {
      return backend_enc_addsd_rax_rbx_arch(elf_ctx, ta);
    }
    if ((ta == 0 || ta == 1) && (glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) != 0) && (glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref) != 0)) {
      return backend_enc_addss_rax_rbx_arch(elf_ctx, ta);
    }
    if (glue_ptr_arith_scale_rbx_offset_if_left_ptr_c(arena, elf_ctx, left_ref, right_ref, ta) != 0) {
      return 0 - 1;
    }
    is_64bit = glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, right_ref);
  }
  if (is_64bit != 0) {
    // The i32 literal shortcut zero-extends into rbx. Sign-extend it
    // before a 64-bit add so a negative literal keeps its sign.
    lit_mixed = 0;
    if (w1591_is_narrow_lit(arena, left_ref) != 0 && w1591_is_wide_int(arena, ctx, right_ref) != 0) {
      lit_mixed = 1;
    }
    if (w1591_is_narrow_lit(arena, right_ref) != 0 && w1591_is_wide_int(arena, ctx, left_ref) != 0) {
      lit_mixed = 1;
    }
    if (lit_mixed != 0) {
      if (w1591_sxt_rbx(elf_ctx, ta) != 0) {
        return 0 - 1;
      }
    }
    unsafe {
      return backend_enc_rax_plus_rbx_scale1_arch(elf_ctx, ta);
    }
  }
  // i32 on the left hides the i64 from the pair helper. The variable
  // path leaves the i32 in rax and the i64 in rbx. Skip the later cltq.
  if (w1591_is_narrow_lit(arena, left_ref) == 0 && w1591_is_wide_int(arena, ctx, right_ref) != 0 && w1591_is_narrow_int(arena, ctx, left_ref) != 0) {
    left_kind = w1591_operand_kind(arena, ctx, left_ref);
    if (left_kind == 0) {
      unsafe {
        if (glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx, ta) != 0) {
          return 0 - 1;
        }
      }
    }
    unsafe {
      return backend_enc_rax_plus_rbx_scale1_arch(elf_ctx, ta);
    }
  }
  unsafe {
    rc = backend_enc_add_rax_rbx_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return rc;
  }
  // Stored into a u32: keep the zero-extended low 32 bits. cltq would make
  // a sum at or above 2^31 negative in the 8-byte slot. i32 still cltqs.
  // EXPR_ADD is kind 4. Mul passes 6 from the other overlay.
  if (w1598_add_stored_in_u32(arena, ctx, left_ref, right_ref, 4) != 0) {
    unsafe {
      return glue_enc_zxt_u32_result_to_rax_elf_c(elf_ctx, ta);
    }
  }
  unsafe {
    return glue_binop_maybe_sxt_i32_result_elf_c(arena, ctx, left_ref, right_ref, elf_ctx, ta);
  }
}

/**
 * Emit rbx - rax as a 64-bit subtract and leave the result in rax.
 * x86 uses the existing subq-then-mov encoder. arm64 uses SUB X0, X1, X0
 * because the shared then-mov face is still a 32-bit W subtract.
 * @param elf_ctx *u8 — encoder context; null is rejected by append
 * @param ta i32 — 0 is x86_64, 1 is arm64
 * @return i32 — 0 ok, -1 encode failure
 * PLATFORM: SHARED — x86_64 REX.W sub and arm64 SUB X.
 */
function w1594_emit_wide_sub_rbx_minus_rax(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    // 0xCB000020 — SUB X0, X1, X0. Little-endian bytes 20 00 00 CB.
    unsafe {
      if (backend_enc_append_u8_c(elf_ctx, 32) != 0) {
        return 0 - 1;
      }
      if (backend_enc_append_u8_c(elf_ctx, 0) != 0) {
        return 0 - 1;
      }
      if (backend_enc_append_u8_c(elf_ctx, 0) != 0) {
        return 0 - 1;
      }
      if (backend_enc_append_u8_c(elf_ctx, 203) != 0) {
        return 0 - 1;
      }
    }
    return 0;
  }
  unsafe {
    return backend_enc_sub_rbx_rax_then_mov_arch(elf_ctx, ta);
  }
}

/**
 * Unsigned width of a narrow subtraction, or 0 when the signed path stays.
 * Both sides u32, or one u32 and a narrow literal, return 3. Both sides u8,
 * or one u8 and a narrow literal, return 2. A wide integer on either side
 * returns 0 so the full 64-bit difference is kept. An i32 still returns 0
 * and the caller sign-extends.
 * @param arena *u8 — AST arena
 * @param ctx *u8 — emit context; null skips the declaration fallback
 * @param left_ref i32 — left operand
 * @param right_ref i32 — right operand
 * @return i32 — 3 for u32, 2 for u8, 0 otherwise
 * PLATFORM: SHARED — type kinds only; the extend is emitted by the caller.
 */
function w1597_unsigned_kind(arena: *u8, ctx: *u8, left_ref: i32, right_ref: i32): i32 {
  let lk: i32 = 0;
  let rk: i32 = 0;
  if (w1591_is_wide_int(arena, ctx, left_ref) != 0) {
    return 0;
  }
  if (w1591_is_wide_int(arena, ctx, right_ref) != 0) {
    return 0;
  }
  lk = w1591_operand_kind(arena, ctx, left_ref);
  rk = w1591_operand_kind(arena, ctx, right_ref);
  if (lk == 3 && rk == 3) {
    return 3;
  }
  if (lk == 2 && rk == 2) {
    return 2;
  }
  // A bare literal has no unsigned type of its own. Next to a u32 or u8
  // it takes that width. Next to an i32 the caller still sign-extends.
  if (lk == 3 && w1591_is_narrow_lit(arena, right_ref) != 0) {
    return 3;
  }
  if (rk == 3 && w1591_is_narrow_lit(arena, left_ref) != 0) {
    return 3;
  }
  if (lk == 2 && w1591_is_narrow_lit(arena, right_ref) != 0) {
    return 2;
  }
  if (rk == 2 && w1591_is_narrow_lit(arena, left_ref) != 0) {
    return 2;
  }
  return 0;
}

/**
 * Zero-extend rax to a u32 or a u8.
 * u32 uses mov %eax,%eax. u8 uses and $0xff,%eax. A u8 must not use the
 * u32 form: a 32-bit subtract of 0 - 1 leaves 0xffffffff, and only the
 * byte mask wraps that to 255.
 * @param elf_ctx *u8 — encoder context
 * @param ta i32 — 0 is x86_64, 1 is arm64
 * @param kind i32 — 3 for u32, 2 for u8
 * @return i32 — 0 ok, -1 when kind is neither or the encoder fails
 * PLATFORM: SHARED — existing zxt encoders; x86_64 and arm64.
 */
function w1597_zxt_rax(elf_ctx: *u8, ta: i32, kind: i32): i32 {
  unsafe {
    if (kind == 3) {
      return glue_enc_zxt_u32_result_to_rax_elf_c(elf_ctx, ta);
    }
    if (kind == 2) {
      return glue_enc_zxt_u8_result_to_rax_elf_c(elf_ctx, ta);
    }
  }
  return 0 - 1;
}

/**
 * After a narrow subtract, zero-extend an unsigned result or sign-extend i32.
 * Unsigned returns before cltq. subq of two u32 values leaves the high half
 * set on wrap; the zero-extend keeps only the low 32 bits. subl of a u8
 * wraps at 32 bits, so the u8 form must mask to 8 bits.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — encoder context
 * @param ctx *u8 — emit context
 * @param left_ref i32 — left operand
 * @param right_ref i32 — right operand
 * @param ta i32 — 0 is x86_64, 1 is arm64
 * @return i32 — 0 ok, nonzero encode failure
 * PLATFORM: SHARED — x86_64 mov/and and arm64 uxtw/uxtb.
 */
function w1597_finish_narrow(arena: *u8, elf_ctx: *u8, ctx: *u8, left_ref: i32, right_ref: i32, ta: i32): i32 {
  let uk: i32 = 0;
  uk = w1597_unsigned_kind(arena, ctx, left_ref, right_ref);
  if (uk != 0) {
    return w1597_zxt_rax(elf_ctx, ta, uk);
  }
  unsafe {
    return glue_binop_maybe_sxt_i32_result_elf_c(arena, ctx, left_ref, right_ref, elf_ctx, ta);
  }
}

/**
 * Emit rbx minus rax for integer or float SUB.
 * Same float arms as the egg. A narrow integer on the left next to a wide
 * integer is sign-extended and subtracted at 64 bits, with no following
 * cltq. i32 minus i32 still uses that cltq. A u32 or u8 minus the same
 * width, or minus a narrow literal, is zero-extended and does not cltq.
 * A wide left already takes the 64-bit arm; a narrow literal in rbx is
 * sign-extended first so -1 stays negative.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — encoder context
 * @param ctx *u8 — emit context
 * @param left_ref i32 — left expression, already in rbx
 * @param right_ref i32 — right expression, already in rax
 * @param ta i32 — 0 is x86_64, 1 is arm64
 * @return i32 — 0 ok, nonzero encode failure
 * PLATFORM: SHARED — x86_64 subq and arm64 SUB X. LINUX links this body.
 */
#[no_mangle]
export function glue_emit_binop_sub_rbx_minus_rax_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, left_ref: i32, right_ref: i32, ta: i32): i32 {
  let rc: i32 = 0;
  let is_64bit: i32 = 0;
  let left_kind: i32 = 0;
  let mixed: i32 = 0;
  unsafe {
    if ((ta == 0 || ta == 1) && (glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) != 0) && (glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref) != 0)) {
      return backend_enc_subsd_rbx_rax_arch(elf_ctx, ta);
    }
    if ((ta == 0 || ta == 1) && (glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) != 0) && (glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref) != 0)) {
      return backend_enc_subss_rbx_rax_arch(elf_ctx, ta);
    }
    is_64bit = glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, right_ref);
  }
  // mov imm32 into rbx zero-extends. A negative i32 literal next to a
  // wide right must be sign-extended before the 64-bit subtract.
  if (is_64bit != 0 && w1591_is_narrow_lit(arena, left_ref) != 0 && w1591_is_wide_int(arena, ctx, right_ref) != 0) {
    if (w1591_sxt_rbx(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
  }
  // i32 on the left hides the i64, so is_64bit stays 0. x86 then-mov is
  // already subq; cltq below would discard the high half.
  mixed = 0;
  if (is_64bit == 0 && w1591_is_wide_int(arena, ctx, right_ref) != 0) {
    left_kind = w1591_operand_kind(arena, ctx, left_ref);
    if (w1591_is_narrow_lit(arena, left_ref) != 0 || left_kind == 0) {
      mixed = 1;
    }
  }
  if (mixed != 0) {
    if (w1591_sxt_rbx(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    return w1594_emit_wide_sub_rbx_minus_rax(elf_ctx, ta);
  }
  unsafe {
    if (is_64bit != 0 && ta == 1) {
      rc = w1594_emit_wide_sub_rbx_minus_rax(elf_ctx, ta);
    } else {
      rc = backend_enc_sub_rbx_rax_then_mov_arch(elf_ctx, ta);
    }
  }
  if (rc != 0) {
    return rc;
  }
  if (is_64bit != 0) {
    return 0;
  }
  // u32 and u8 wrap here. i32 still sign-extends inside the finish helper.
  return w1597_finish_narrow(arena, elf_ctx, ctx, left_ref, right_ref, ta);
}

/**
 * Emit rax minus rbx for integer or float SUB.
 * Same float, pointer-scale, and 64-bit arms as the egg. The right-hand
 * literal path lands here: subl already wraps at 32 bits, and the egg then
 * sign-extended because the literal is an unstamped i32. A u32 or u8 result
 * is zero-extended instead. i32 still sign-extends. A wide operand returns
 * before that extend.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — encoder context
 * @param ctx *u8 — emit context
 * @param left_ref i32 — left expression, already in rax
 * @param right_ref i32 — right expression, already in rbx
 * @param ta i32 — 0 is x86_64, 1 is arm64
 * @return i32 — 0 ok, nonzero encode failure
 * PLATFORM: SHARED — x86_64 subq %rbx,%rax and arm64 SUB X0,X0,X1. LINUX links this body.
 */
#[no_mangle]
export function glue_emit_binop_sub_rax_minus_rbx_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, left_ref: i32, right_ref: i32, ta: i32): i32 {
  let rc: i32 = 0;
  let is_64bit: i32 = 0;
  unsafe {
    if ((ta == 0 || ta == 1) && (glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) != 0) && (glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref) != 0)) {
      return backend_enc_subsd_rax_rbx_arch(elf_ctx, ta);
    }
    if ((ta == 0 || ta == 1) && (glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) != 0) && (glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref) != 0)) {
      return backend_enc_subss_rax_rbx_arch(elf_ctx, ta);
    }
    if (glue_ptr_arith_scale_rbx_offset_if_left_ptr_c(arena, elf_ctx, left_ref, right_ref, ta) != 0) {
      return 0 - 1;
    }
    is_64bit = glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, right_ref);
    if (is_64bit != 0) {
      // Same bytes as the egg. x86: subq %rbx,%rax (48 29 d8).
      // arm64: SUB X0, X0, X1 (00 00 01 CB).
      if (ta == 0) {
        if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
          return 0 - 1;
        }
        if (backend_enc_append_u8_c(elf_ctx, 41) != 0) {
          return 0 - 1;
        }
        if (backend_enc_append_u8_c(elf_ctx, 216) != 0) {
          return 0 - 1;
        }
      } else if (ta == 1) {
        if (backend_enc_append_u8_c(elf_ctx, 0) != 0) {
          return 0 - 1;
        }
        if (backend_enc_append_u8_c(elf_ctx, 0) != 0) {
          return 0 - 1;
        }
        if (backend_enc_append_u8_c(elf_ctx, 1) != 0) {
          return 0 - 1;
        }
        if (backend_enc_append_u8_c(elf_ctx, 203) != 0) {
          return 0 - 1;
        }
      } else {
        rc = backend_enc_sub_rax_rbx_arch(elf_ctx, ta);
      }
    } else {
      rc = backend_enc_sub_rax_rbx_arch(elf_ctx, ta);
    }
  }
  if (rc != 0) {
    return rc;
  }
  if (is_64bit != 0) {
    return 0;
  }
  return w1597_finish_narrow(arena, elf_ctx, ctx, left_ref, right_ref, ta);
}

/**
 * Type ref of a float source, including an f32 add, sub, mul, or div.
 * A variable still resolves through its parameter or local declaration.
 * An f32 binop wins over a non-f32 stamp: the arithmetic bits are f32,
 * so a later promote emits cvtss2sd before an f64 store.
 * @param arena *u8 — AST arena; null returns 0
 * @param expr_ref i32 — source expression; <=0 returns 0
 * @return i32 — type ref, or 0 when none applies
 * PLATFORM: SHARED — type ref only; the convert stays in the promote helper.
 */
#[no_mangle]
export function glue_float_promote_src_ty_ref_c(arena: *u8, expr_ref: i32): i32 {
  let tr: i32 = 0;
  // name_into zeros 256 bytes. A shorter stack slot is overwritten upward
  // through the saved return address (the f32-var compile fault).
  let vname: u8[256] = [];
  let vlen: i32 = 0;
  let ko: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let fi: i32 = 0;
  let scope_br: i32 = 0;
  let body_ref: i32 = 0;
  let left_ref: i32 = 0;
  let right_ref: i32 = 0;
  let left_ty: i32 = 0;
  let right_ty: i32 = 0;
  let left_kind: i32 = 0;
  let right_kind: i32 = 0;
  if (arena == (0 as *u8) || expr_ref <= 0) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  if (ko == 3) {
    unsafe {
      vlen = pipeline_expr_var_name_len(arena, expr_ref);
    }
    if (vlen > 0 && vlen <= 63) {
      unsafe {
        pipeline_expr_var_name_into(arena, expr_ref, &vname[0]);
        mod = pipeline_asm_emit_module_ref_c();
        fi = pipeline_asm_emit_func_index_c();
      }
      if (fi >= 0 && mod != (0 as *u8)) {
        unsafe {
          tr = pipeline_module_func_param_type_ref_for_name(mod, fi, &vname[0], vlen);
        }
        if (tr > 0) {
          return tr;
        }
      }
      unsafe {
        scope_br = pipeline_asm_emit_ctx_scope_block_get();
      }
      if (scope_br > 0) {
        unsafe {
          tr = pipeline_block_resolve_var_type_ref(arena, scope_br, &vname[0], vlen);
        }
        if (tr > 0) {
          return tr;
        }
      }
      if (fi >= 0 && mod != (0 as *u8)) {
        unsafe {
          body_ref = pipeline_module_func_body_ref_at(mod, fi);
        }
        if (body_ref > 0) {
          unsafe {
            tr = pipeline_block_resolve_var_type_ref(arena, body_ref, &vname[0], vlen);
          }
          if (tr > 0) {
            return tr;
          }
        }
      }
    }
  }
  // ADD=4 SUB=5 MUL=6 DIV=7. Both f32 children: the result bits are f32
  // even when this expr already carries a non-f32 stamp.
  if (ko == 4 || ko == 5 || ko == 6 || ko == 7) {
    unsafe {
      left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
      right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    }
    if (left_ref > 0 && right_ref > 0) {
      left_ty = glue_float_promote_src_ty_ref_c(arena, left_ref);
      right_ty = glue_float_promote_src_ty_ref_c(arena, right_ref);
      if (left_ty > 0 && right_ty > 0) {
        unsafe {
          left_kind = pipeline_type_kind_ord_at(arena, left_ty);
          right_kind = pipeline_type_kind_ord_at(arena, right_ty);
        }
        if (left_kind == 14 && right_kind == 14) {
          return left_ty;
        }
      }
    }
  }
  unsafe {
    tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
  }
  if (tr > 0) {
    return tr;
  }
  return 0;
}
