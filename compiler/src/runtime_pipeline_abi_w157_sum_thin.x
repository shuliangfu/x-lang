// Thin pure: wave157 frame-size spill summation cluster.
// G.7: bodies MUST match mega runtime_pipeline_abi.x wave157 leave.
// ensure injects via inject_thin_leaf (PREFER_ASM).
// Unblocked: COMMON + reloc_r_type accessors (PAGE21/PAGEOFF12; ld -r OK).
// wave406: HARD BAN tip reinject both ends — standalone -c PREFER green
//   but Darwin product inject ARM64_RELOC_BRANCH26 (same class as w404).
// PLATFORM: SHARED freestanding frame-size · LINUX gold · MACOS.

export extern function ast_ast_block_final_expr_ref(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_for_cond_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_ast_block_for_init_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_ast_block_for_step_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_ast_block_num_consts(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_expr_stmts(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_for_loops(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_if_stmts(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_lets(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_loops(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_regions(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_stmt_order(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_stmt_order_idx(arena: *u8, block_ref: i32, si: i32): i32;
export extern function ast_ast_block_stmt_order_kind(arena: *u8, block_ref: i32, si: i32): i32;
export extern function ast_ast_block_while_cond_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_pipeline_block_const_init_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_pipeline_block_expr_stmt_ref(arena: *u8, block_ref: i32, ei: i32): i32;
export extern function ast_pipeline_block_if_cond_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_pipeline_block_if_else_body_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_pipeline_block_if_then_body_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_pipeline_block_let_init_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function glue_index_elem_byte_sz_from_type_ref_c(arena: *u8, tr: i32): i32;
export extern function pipeline_block_for_body_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function pipeline_block_labeled_is_goto(arena: *u8, block_ref: i32, li: i32): i32;
export extern function pipeline_block_labeled_return_expr_ref(arena: *u8, block_ref: i32, li: i32): i32;
export extern function pipeline_block_let_init_ref(arena: *u8, block_ref: i32, let_idx: i32): i32;
export extern function pipeline_block_let_type_ref(arena: *u8, block_ref: i32, let_idx: i32): i32;
export extern function pipeline_block_num_labeled_stmts(arena: *u8, block_ref: i32): i32;
export extern function pipeline_block_region_body_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function pipeline_block_while_body_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, i: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_as_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_right_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_block_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_call_arg_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_call_num_args_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_if_cond_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_if_else_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_if_then_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_method_call_arg_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_method_call_base_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_method_call_num_args_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_init_ref(arena: *u8, expr_ref: i32, i: i32): i32;
export extern function pipeline_expr_struct_lit_num_fields(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;

// wave157 pure-owned leave: frame-size spill byte summation cluster
// (was Cap residual EOF of pipeline_asm_emit_spill.c).
// Public faces:
//   · glue_asm_sum_block_call_spill_bytes
//   · glue_sum_block_slice_reent_dc_bytes_c
// Private walk helper: w157_sum_expr_call_spill_bytes (BSS total/visits).
// Cap residual remaining in spill: binop VAR slot cache BSS, 7.3 live_fwd /
// Chaitin / break-continue, index-scratch methods.
// Cold twins under seed #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
// PLATFORM: SHARED freestanding frame-size estimation · dual-end L2.
// ============================================================================

// METHOD_CALL accessors: declared once at file top (export extern "C").
// Do not redeclare here — dual export extern is scored as same-param overload
// and pure-asm emits _u8_ptr_i32_reti32 U (G.7; Stage12 s4 HW hybrid).
// PLATFORM: SHARED.

// Soft leave-off BSS: recursive expr walk totals + iterative block stack.
// Last-wins reentrancy (matches historical Cap residual statics).
let g_w157_spill_total: i32 = 0;
let g_w157_spill_visits: i32 = 0;
let g_w157_walk_stack: i32[8192] = [];

/**
 * Recursive sum of permanent call-arg spill bytes under one expression.
 * CALL(48)/METHOD_CALL(49): each reg-class arg (and method receiver) reserves
 * 8B without reclaim (w1041; was 32/16); nested calls counted in subtrees. Walks binop/ASSIGN
 * (*ASSIGN 28..38 via binop left/right)/unary/AS/INDEX/FIELD/ARRAY_LIT/
 * STRUCT_LIT/EXPR_IF children. ASSIGN must be walked: body expr stmts are
 * often `x = call(...)`; omitting them under-sizes pure-asm frames.
 * Soft leave-off: mutates g_w157_spill_total / g_w157_spill_visits.
 * @param arena *u8 - ASTArena*
 * @param expr_ref i32 - expression pool ref; <=0 no-op
 * wave157 pure helper. PLATFORM: SHARED.
 */
function w157_sum_expr_call_spill_bytes(arena: *u8, expr_ref: i32): void {
  let ko: i32 = 0;
  let i: i32 = 0;
  let n: i32 = 0;
  let arg_ref: i32 = 0;
  let op: i32 = 0;
  let as_op: i32 = 0;
  if (arena == 0 as *u8 || expr_ref <= 0) {
    return;
  }
  if (g_w157_spill_visits >= 65536) {
    return;
  }
  g_w157_spill_visits = g_w157_spill_visits + 1;
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  // EXPR_CALL = 48
  if (ko == 48) {
    let need: i32 = 0;
    let ako: i32 = 0;
    unsafe {
      n = pipeline_expr_call_num_args_at(arena, expr_ref);
    }
    if (n < 0) {
      n = 0;
    }
    if (n > 64) {
      n = 64;
    }
    i = 0;
    while (i < n) {
      unsafe {
        arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, i);
      }
      w157_sum_expr_call_spill_bytes(arena, arg_ref);
      // w1042: EXPR_VAR reuses stack home — no fresh spill slot.
      unsafe {
        ako = pipeline_expr_kind_ord_at(arena, arg_ref);
      }
      if (arg_ref > 0 && ako != 3) {
        need = need + 1;
      }
      i = i + 1;
    }
    if (need > 0 || n == 0) {
      need = need + 1;
    }
    g_w157_spill_total = g_w157_spill_total + need * 8;
    return;
  }
  // EXPR_METHOD_CALL = 49
  if (ko == 49) {
    let need_m: i32 = 0;
    let ako_m: i32 = 0;
    unsafe {
      arg_ref = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
    }
    w157_sum_expr_call_spill_bytes(arena, arg_ref);
    unsafe {
      ako_m = pipeline_expr_kind_ord_at(arena, arg_ref);
    }
    if (arg_ref > 0 && ako_m != 3) {
      need_m = need_m + 1;
    }
    unsafe {
      n = pipeline_expr_method_call_num_args_at(arena, expr_ref);
    }
    if (n < 0) {
      n = 0;
    }
    if (n > 64) {
      n = 64;
    }
    i = 0;
    while (i < n) {
      unsafe {
        arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, i);
      }
      w157_sum_expr_call_spill_bytes(arena, arg_ref);
      unsafe {
        ako_m = pipeline_expr_kind_ord_at(arena, arg_ref);
      }
      if (arg_ref > 0 && ako_m != 3) {
        need_m = need_m + 1;
      }
      i = i + 1;
    }
    if (need_m > 0) {
      need_m = need_m + 1;
    }
    g_w157_spill_total = g_w157_spill_total + need_m * 8;
    return;
  }
  // P12g root fix (2026-09-15): EXPR_IF(25)/EXPR_BLOCK(26) share kind
  // ordinals with the binop set — an else-if chain parses into a nested
  // EXPR_IF chain whose arms are EXPR_BLOCK-wrapped blocks (parser
  // if_stmt_parts_to_if_expr). Routing them through the binop branch loses
  // the else arm, so every chain beyond the first arm vanished from the
  // call-spill estimate (big-function frames under-reserved; spill peaks
  // crossed the frame top into the caller). Try the if/block accessors
  // first; fall through to binop when they read empty (shared ordinals
  // stay honored). PLATFORM: SHARED — twin in seeds .c.
  if (ko == 25) {
    unsafe {
      arg_ref = pipeline_expr_if_cond_ref_at(arena, expr_ref);
    }
    if (arg_ref > 0) {
      w157_sum_expr_call_spill_bytes(arena, arg_ref);
      unsafe {
        op = pipeline_expr_if_then_ref_at(arena, expr_ref);
      }
      w157_sum_expr_call_spill_bytes(arena, op);
      unsafe {
        op = pipeline_expr_if_else_ref_at(arena, expr_ref);
      }
      w157_sum_expr_call_spill_bytes(arena, op);
      return;
    }
  }
  if (ko == 26) {
    unsafe {
      op = pipeline_expr_block_ref_at(arena, expr_ref);
    }
    if (op > 0) {
      w157_walk_block_rec_x(arena, op, 40);
      return;
    }
  }
  // binops (4..21, 25, 26) + ASSIGN / *ASSIGN (28..38).
  // ASSIGN reuses binop left/right (ast.h AST_EXPR_ASSIGN). Without this walk,
  // pure-asm frame sizing under-counts sequential `x = f(g())` expr stmts:
  // next_offset still advances on emit, but compute_frame_size only reserved the
  // min 512B scratch → spill homes past the frame clobber caller's saved LR
  // (mac hybrid ONLY=rt_run_compiler_parsed SEGV pc=0x4 when argc=4 smashed LR).
  // PLATFORM: SHARED freestanding frame-size estimation · dual-end L2.
  if ((ko >= 4 && ko <= 21) || ko == 25 || ko == 26 || (ko >= 28 && ko <= 38)) {
    unsafe {
      arg_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
      op = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    }
    w157_sum_expr_call_spill_bytes(arena, arg_ref);
    w157_sum_expr_call_spill_bytes(arena, op);
    return;
  }
  // unary / LOGNOT / RETURN-style operand (22..24, 41) + ADDR_OF (51).
  // ADDR_OF of INDEX (`&buf[0]` as a CALL arg) must be walked so nested
  // calls inside the operand count; emit also parks INDEX temps on
  // next_offset which the CALL n*32 term does not cover alone.
  if (ko == 22 || ko == 23 || ko == 24 || ko == 41 || ko == 51) {
    unsafe {
      op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    }
    w157_sum_expr_call_spill_bytes(arena, op);
    return;
  }
  // EXPR_AS = 54 or as_operand present
  unsafe {
    as_op = pipeline_expr_as_operand_ref_at(arena, expr_ref);
  }
  if (ko == 54 || as_op > 0) {
    op = as_op;
    if (op <= 0) {
      unsafe {
        op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
      }
    }
    w157_sum_expr_call_spill_bytes(arena, op);
    return;
  }
  // INDEX = 47
  if (ko == 47) {
    unsafe {
      arg_ref = pipeline_expr_index_base_ref(arena, expr_ref);
      op = pipeline_expr_index_index_ref(arena, expr_ref);
    }
    w157_sum_expr_call_spill_bytes(arena, arg_ref);
    w157_sum_expr_call_spill_bytes(arena, op);
    return;
  }
  // FIELD_ACCESS = 44
  if (ko == 44) {
    unsafe {
      op = pipeline_expr_field_access_base_ref(arena, expr_ref);
    }
    w157_sum_expr_call_spill_bytes(arena, op);
    return;
  }
  // ARRAY_LIT = 46; max elems 1024
  if (ko == 46) {
    unsafe {
      n = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
    }
    if (n > 1024) {
      n = 1024;
    }
    i = 0;
    while (i < n) {
      unsafe {
        arg_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, i);
      }
      w157_sum_expr_call_spill_bytes(arena, arg_ref);
      i = i + 1;
    }
    return;
  }
  // STRUCT_LIT = 45
  if (ko == 45) {
    unsafe {
      n = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
    }
    if (n > 64) {
      n = 64;
    }
    i = 0;
    while (i < n) {
      unsafe {
        arg_ref = pipeline_expr_struct_lit_init_ref(arena, expr_ref, i);
      }
      w157_sum_expr_call_spill_bytes(arena, arg_ref);
      i = i + 1;
    }
    return;
  }
  // EXPR_IF / ternary (cond present)
  unsafe {
    arg_ref = pipeline_expr_if_cond_ref_at(arena, expr_ref);
  }
  if (arg_ref > 0) {
    w157_sum_expr_call_spill_bytes(arena, arg_ref);
    unsafe {
      op = pipeline_expr_if_then_ref_at(arena, expr_ref);
    }
    w157_sum_expr_call_spill_bytes(arena, op);
    unsafe {
      op = pipeline_expr_if_else_ref_at(arena, expr_ref);
    }
    w157_sum_expr_call_spill_bytes(arena, op);
  }
}

/**
 * Pre-sum frame bytes for TYPE_SLICE let reent deep-copy buffers.
 * Each `let s: T[] = call()` / METHOD reserves max_n*esz payload (max_n=1024,
 * esz from elem type) plus +32B bulk-copy spill pair when esz>8. Walks if /
 * while / for / region nested bodies only (lets only; call-arg stays separate).
 * @param arena *u8 - ASTArena*
 * @param block_ref i32 - function body block
 * @return i32 - total payload bytes (>=0)
 * wave157 pure-owned. PLATFORM: SHARED freestanding frame layout.
 */
#[no_mangle]
export function glue_sum_block_slice_reent_dc_bytes_c(arena: *u8, block_ref: i32): i32 {
  let total: i32 = 0;
  let sp: i32 = 0;
  let seen: i32 = 0;
  let cur: i32 = 0;
  let i: i32 = 0;
  let n: i32 = 0;
  let ch: i32 = 0;
  let tref: i32 = 0;
  let init_ref: i32 = 0;
  let ik: i32 = 0;
  let esz: i32 = 4;
  let elem_tr: i32 = 0;
  let nbytes: i32 = 0;
  let max_n: i32 = 1024;
  let max_payload: i32 = 0;
  if (arena == 0 as *u8 || block_ref <= 0) {
    return 0;
  }
  g_w157_walk_stack[0] = block_ref;
  sp = 1;
  while (sp > 0 && seen < 65536) {
    seen = seen + 1;
    sp = sp - 1;
    cur = g_w157_walk_stack[sp];
    if (cur <= 0) {
      continue;
    }
    unsafe {
      n = ast_ast_block_num_lets(arena, cur);
    }
    i = 0;
    while (i < n) {
      unsafe {
        tref = pipeline_block_let_type_ref(arena, cur, i);
        init_ref = pipeline_block_let_init_ref(arena, cur, i);
      }
      if (tref > 0 && init_ref > 0) {
        unsafe {
          ik = pipeline_type_kind_ord_at(arena, tref);
        }
        // TYPE_SLICE = 11
        if (ik == 11) {
          unsafe {
            ik = pipeline_expr_kind_ord_at(arena, init_ref);
          }
          // EXPR_CALL=48 METHOD_CALL=49
          if (ik == 48 || ik == 49) {
            esz = 4;
            unsafe {
              elem_tr = pipeline_type_elem_ref_at(arena, tref);
            }
            if (elem_tr > 0) {
              unsafe {
                esz = glue_index_elem_byte_sz_from_type_ref_c(arena, elem_tr);
              }
            }
            if (esz <= 0) {
              esz = 4;
            }
            // wave632: keep esz>8; weird mid widths → 4
            if (esz != 1 && esz != 2 && esz != 4 && esz != 8 && esz <= 8) {
              esz = 4;
            }
            if (esz > 8) {
              max_payload = 1024 * 64;
            } else {
              max_payload = 8192;
            }
            max_n = 1024;
            if (esz > 0 && max_n > max_payload / esz) {
              max_n = max_payload / esz;
            }
            if (max_n <= 0) {
              max_n = 1;
            }
            nbytes = max_n * esz;
            if (nbytes > 0 && nbytes <= max_payload) {
              total = total + nbytes;
              if (esz > 8) {
                total = total + 32;
              }
            }
          }
        }
      }
      i = i + 1;
    }
    unsafe {
      n = ast_ast_block_num_if_stmts(arena, cur);
    }
    i = 0;
    while (i < n) {
      unsafe {
        ch = ast_pipeline_block_if_then_body_ref(arena, cur, i);
      }
      if (ch > 0 && sp < 8192) {
        g_w157_walk_stack[sp] = ch;
        sp = sp + 1;
      }
      unsafe {
        ch = ast_pipeline_block_if_else_body_ref(arena, cur, i);
      }
      if (ch > 0 && sp < 8192) {
        g_w157_walk_stack[sp] = ch;
        sp = sp + 1;
      }
      i = i + 1;
    }
    unsafe {
      n = ast_ast_block_num_loops(arena, cur);
    }
    i = 0;
    while (i < n) {
      unsafe {
        ch = pipeline_block_while_body_ref(arena, cur, i);
      }
      if (ch > 0 && sp < 8192) {
        g_w157_walk_stack[sp] = ch;
        sp = sp + 1;
      }
      i = i + 1;
    }
    unsafe {
      n = ast_ast_block_num_for_loops(arena, cur);
    }
    i = 0;
    while (i < n) {
      unsafe {
        ch = pipeline_block_for_body_ref(arena, cur, i);
      }
      if (ch > 0 && sp < 8192) {
        g_w157_walk_stack[sp] = ch;
        sp = sp + 1;
      }
      i = i + 1;
    }
    unsafe {
      n = ast_ast_block_num_regions(arena, cur);
    }
    i = 0;
    while (i < n) {
      unsafe {
        ch = pipeline_block_region_body_ref(arena, cur, i);
      }
      if (ch > 0 && sp < 8192) {
        g_w157_walk_stack[sp] = ch;
        sp = sp + 1;
      }
      i = i + 1;
    }
  }
  return total;
}

/**
 * Block-tree sum of permanent call-arg spill temp for compute_frame_size.
 * Walks const/let inits, expr stmts, final_expr, if/while/for conds + nested
 * bodies; uses w157_sum_expr_call_spill_bytes for each expr root.
 * @param arena *u8 - ASTArena*
 * @param block_ref i32 - function body (or nested) block
 * @return i32 - estimated spill bytes (>=0)
 * wave157 pure-owned. PLATFORM: SHARED freestanding frame layout.
 */
#[no_mangle]
function w157_walk_block_rec_x(arena: *u8, cur: i32, depth: i32): void {
  let i: i32 = 0;
  let n: i32 = 0;
  let ch: i32 = 0;
  let er: i32 = 0;
  let fin: i32 = 0;
  let nso: i32 = 0;
  let sok: i32 = 0;
  let soi: i32 = 0;
  if (arena == (0 as *u8) || cur <= 0 || depth <= 0) {
    return;
  }
  if (g_w157_spill_visits > 65536) {
    return;
  }
  unsafe {
    nso = ast_ast_block_num_stmt_order(arena, cur);
  }
  if (nso > 0) {
    i = 0;
    while (i < nso) {
      unsafe {
        sok = ast_ast_block_stmt_order_kind(arena, cur, i);
        soi = ast_ast_block_stmt_order_idx(arena, cur, i);
      }
      if (soi >= 0) {
        if (sok == 2) {
          unsafe { er = ast_pipeline_block_expr_stmt_ref(arena, cur, soi); }
          w157_sum_expr_call_spill_bytes(arena, er);
        } else if (sok == 1) {
          unsafe { er = ast_pipeline_block_let_init_ref(arena, cur, soi); }
          w157_sum_expr_call_spill_bytes(arena, er);
        } else if (sok == 0) {
          unsafe { er = ast_pipeline_block_const_init_ref(arena, cur, soi); }
          w157_sum_expr_call_spill_bytes(arena, er);
        } else if (sok == 5) {
          unsafe { er = ast_pipeline_block_if_cond_ref(arena, cur, soi); }
          w157_sum_expr_call_spill_bytes(arena, er);
          unsafe { ch = ast_pipeline_block_if_then_body_ref(arena, cur, soi); }
          if (ch > 0) { w157_walk_block_rec_x(arena, ch, depth - 1); }
          unsafe { ch = ast_pipeline_block_if_else_body_ref(arena, cur, soi); }
          if (ch > 0) { w157_walk_block_rec_x(arena, ch, depth - 1); }
        } else if (sok == 3) {
          unsafe { er = ast_ast_block_while_cond_ref(arena, cur, soi); }
          w157_sum_expr_call_spill_bytes(arena, er);
          unsafe { ch = pipeline_block_while_body_ref(arena, cur, soi); }
          if (ch > 0) { w157_walk_block_rec_x(arena, ch, depth - 1); }
        } else if (sok == 4) {
          unsafe { er = ast_ast_block_for_init_ref(arena, cur, soi); }
          w157_sum_expr_call_spill_bytes(arena, er);
          unsafe { er = ast_ast_block_for_cond_ref(arena, cur, soi); }
          w157_sum_expr_call_spill_bytes(arena, er);
          unsafe { er = ast_ast_block_for_step_ref(arena, cur, soi); }
          w157_sum_expr_call_spill_bytes(arena, er);
          unsafe { ch = pipeline_block_for_body_ref(arena, cur, soi); }
          if (ch > 0) { w157_walk_block_rec_x(arena, ch, depth - 1); }
        } else if (sok == 6) {
          unsafe { ch = pipeline_block_region_body_ref(arena, cur, soi); }
          if (ch > 0) { w157_walk_block_rec_x(arena, ch, depth - 1); }
        } else if (sok == 7) {
          unsafe {
            if (pipeline_block_labeled_is_goto(arena, cur, soi) == 0) {
              er = pipeline_block_labeled_return_expr_ref(arena, cur, soi);
              if (er > 0) { w157_sum_expr_call_spill_bytes(arena, er); }
            }
          }
        }
      }
      i = i + 1;
    }
    unsafe { fin = ast_ast_block_final_expr_ref(arena, cur); }
    if (fin > 0) { w157_sum_expr_call_spill_bytes(arena, fin); }
    return;
  }
  unsafe {
    n = ast_ast_block_num_consts(arena, cur);
    i = 0;
    while (i < n) {
      er = ast_pipeline_block_const_init_ref(arena, cur, i);
      w157_sum_expr_call_spill_bytes(arena, er);
      i = i + 1;
    }
    n = ast_ast_block_num_lets(arena, cur);
    i = 0;
    while (i < n) {
      er = ast_pipeline_block_let_init_ref(arena, cur, i);
      w157_sum_expr_call_spill_bytes(arena, er);
      i = i + 1;
    }
    n = ast_ast_block_num_expr_stmts(arena, cur);
    i = 0;
    while (i < n) {
      er = ast_pipeline_block_expr_stmt_ref(arena, cur, i);
      w157_sum_expr_call_spill_bytes(arena, er);
      i = i + 1;
    }
    fin = ast_ast_block_final_expr_ref(arena, cur);
    if (fin > 0) { w157_sum_expr_call_spill_bytes(arena, fin); }
    n = ast_ast_block_num_if_stmts(arena, cur);
    i = 0;
    while (i < n) {
      er = ast_pipeline_block_if_cond_ref(arena, cur, i);
      w157_sum_expr_call_spill_bytes(arena, er);
      ch = ast_pipeline_block_if_then_body_ref(arena, cur, i);
      if (ch > 0) { w157_walk_block_rec_x(arena, ch, depth - 1); }
      ch = ast_pipeline_block_if_else_body_ref(arena, cur, i);
      if (ch > 0) { w157_walk_block_rec_x(arena, ch, depth - 1); }
      i = i + 1;
    }
    n = ast_ast_block_num_loops(arena, cur);
    i = 0;
    while (i < n) {
      er = ast_ast_block_while_cond_ref(arena, cur, i);
      w157_sum_expr_call_spill_bytes(arena, er);
      ch = pipeline_block_while_body_ref(arena, cur, i);
      if (ch > 0) { w157_walk_block_rec_x(arena, ch, depth - 1); }
      i = i + 1;
    }
    n = ast_ast_block_num_for_loops(arena, cur);
    i = 0;
    while (i < n) {
      er = ast_ast_block_for_init_ref(arena, cur, i);
      w157_sum_expr_call_spill_bytes(arena, er);
      er = ast_ast_block_for_cond_ref(arena, cur, i);
      w157_sum_expr_call_spill_bytes(arena, er);
      er = ast_ast_block_for_step_ref(arena, cur, i);
      w157_sum_expr_call_spill_bytes(arena, er);
      ch = pipeline_block_for_body_ref(arena, cur, i);
      if (ch > 0) { w157_walk_block_rec_x(arena, ch, depth - 1); }
      i = i + 1;
    }
    n = ast_ast_block_num_regions(arena, cur);
    i = 0;
    while (i < n) {
      ch = pipeline_block_region_body_ref(arena, cur, i);
      if (ch > 0) { w157_walk_block_rec_x(arena, ch, depth - 1); }
      i = i + 1;
    }
    n = pipeline_block_num_labeled_stmts(arena, cur);
    i = 0;
    while (i < n) {
      if (pipeline_block_labeled_is_goto(arena, cur, i) == 0) {
        er = pipeline_block_labeled_return_expr_ref(arena, cur, i);
        if (er > 0) { w157_sum_expr_call_spill_bytes(arena, er); }
      }
      i = i + 1;
    }
  }
}

export function glue_asm_sum_block_call_spill_bytes(arena: *u8, block_ref: i32): i32 {
  let sp: i32 = 0;
  let seen: i32 = 0;
  let cur: i32 = 0;
  let i: i32 = 0;
  let n: i32 = 0;
  let ch: i32 = 0;
  let fin: i32 = 0;
  let er: i32 = 0;
  let nso: i32 = 0;
  let sok: i32 = 0;
  let soi: i32 = 0;
  if (arena == 0 as *u8 || block_ref <= 0) {
    return 0;
  }
  g_w157_spill_total = 0;
  g_w157_spill_visits = 0;
  g_w157_walk_stack[0] = block_ref;
  sp = 1;
  while (sp > 0 && seen < 65536) {
    seen = seen + 1;
    sp = sp - 1;
    cur = g_w157_walk_stack[sp];
    if (cur <= 0) {
      continue;
    }
    // P12g root fix (2026-09-15): when a block carries a stmt_order it is the
    // emitter's sequencing authority — deep else-chains are only fully visible
    // there (the per-kind array view truncates with nesting depth, under-
    // reserving call-spill scratch so big functions' spill peaks cross the
    // frame top into the caller's frame). Dispatch kinds against the SAME
    // pools the emitter reads (idx = pool index); the raw-array walk below
    // stays for nso==0 blocks only, so nothing is double counted. Over-
    // reserving is safe; under-reserving is the bug class.
    // PLATFORM: SHARED — twin in seeds/runtime_pipeline_abi.from_x.c.
    unsafe {
      nso = ast_ast_block_num_stmt_order(arena, cur);
    }
    if (nso > 0) {
      i = 0;
      while (i < nso) {
        unsafe {
          sok = ast_ast_block_stmt_order_kind(arena, cur, i);
          soi = ast_ast_block_stmt_order_idx(arena, cur, i);
        }
        if (soi >= 0) {
          if (sok == 2) {
            unsafe {
              er = ast_pipeline_block_expr_stmt_ref(arena, cur, soi);
            }
            w157_sum_expr_call_spill_bytes(arena, er);
          } else if (sok == 1) {
            unsafe {
              er = ast_pipeline_block_let_init_ref(arena, cur, soi);
            }
            w157_sum_expr_call_spill_bytes(arena, er);
          } else if (sok == 0) {
            unsafe {
              er = ast_pipeline_block_const_init_ref(arena, cur, soi);
            }
            w157_sum_expr_call_spill_bytes(arena, er);
          } else if (sok == 5) {
            unsafe {
              er = ast_pipeline_block_if_cond_ref(arena, cur, soi);
            }
            w157_sum_expr_call_spill_bytes(arena, er);
            unsafe {
              ch = ast_pipeline_block_if_then_body_ref(arena, cur, soi);
            }
            if (ch > 0 && sp < 8192) {
              g_w157_walk_stack[sp] = ch;
              sp = sp + 1;
            }
            unsafe {
              ch = ast_pipeline_block_if_else_body_ref(arena, cur, soi);
            }
            if (ch > 0 && sp < 8192) {
              g_w157_walk_stack[sp] = ch;
              sp = sp + 1;
            }
          } else if (sok == 3) {
            unsafe {
              er = ast_ast_block_while_cond_ref(arena, cur, soi);
            }
            w157_sum_expr_call_spill_bytes(arena, er);
            unsafe {
              ch = pipeline_block_while_body_ref(arena, cur, soi);
            }
            if (ch > 0 && sp < 8192) {
              g_w157_walk_stack[sp] = ch;
              sp = sp + 1;
            }
          } else if (sok == 4) {
            unsafe {
              er = ast_ast_block_for_init_ref(arena, cur, soi);
            }
            w157_sum_expr_call_spill_bytes(arena, er);
            unsafe {
              er = ast_ast_block_for_cond_ref(arena, cur, soi);
            }
            w157_sum_expr_call_spill_bytes(arena, er);
            unsafe {
              er = ast_ast_block_for_step_ref(arena, cur, soi);
            }
            w157_sum_expr_call_spill_bytes(arena, er);
            unsafe {
              ch = pipeline_block_for_body_ref(arena, cur, soi);
            }
            if (ch > 0 && sp < 8192) {
              g_w157_walk_stack[sp] = ch;
              sp = sp + 1;
            }
          } else if (sok == 6) {
            unsafe {
              ch = pipeline_block_region_body_ref(arena, cur, soi);
            }
            if (ch > 0 && sp < 8192) {
              g_w157_walk_stack[sp] = ch;
              sp = sp + 1;
            }
          } else if (sok == 7) {
            unsafe {
              if (pipeline_block_labeled_is_goto(arena, cur, soi) == 0) {
                er = pipeline_block_labeled_return_expr_ref(arena, cur, soi);
                if (er > 0) {
                  w157_sum_expr_call_spill_bytes(arena, er);
                }
              }
            }
          }
        }
        i = i + 1;
      }
      // final expr may not be a stmt_order item on every parse path; walking
      // it unconditionally can only over-reserve (safe direction).
      unsafe {
        fin = ast_ast_block_final_expr_ref(arena, cur);
      }
      if (fin > 0) {
        w157_sum_expr_call_spill_bytes(arena, fin);
      }
      continue;
    }
    unsafe {
      n = ast_ast_block_num_consts(arena, cur);
    }
    i = 0;
    while (i < n) {
      unsafe {
        er = ast_pipeline_block_const_init_ref(arena, cur, i);
      }
      w157_sum_expr_call_spill_bytes(arena, er);
      i = i + 1;
    }
    unsafe {
      n = ast_ast_block_num_lets(arena, cur);
    }
    i = 0;
    while (i < n) {
      unsafe {
        er = ast_pipeline_block_let_init_ref(arena, cur, i);
      }
      w157_sum_expr_call_spill_bytes(arena, er);
      i = i + 1;
    }
    unsafe {
      n = ast_ast_block_num_expr_stmts(arena, cur);
    }
    i = 0;
    while (i < n) {
      unsafe {
        er = ast_pipeline_block_expr_stmt_ref(arena, cur, i);
      }
      w157_sum_expr_call_spill_bytes(arena, er);
      i = i + 1;
    }
    unsafe {
      fin = ast_ast_block_final_expr_ref(arena, cur);
    }
    if (fin > 0) {
      w157_sum_expr_call_spill_bytes(arena, fin);
    }
    unsafe {
      n = ast_ast_block_num_if_stmts(arena, cur);
    }
    i = 0;
    while (i < n) {
      unsafe {
        er = ast_pipeline_block_if_cond_ref(arena, cur, i);
      }
      w157_sum_expr_call_spill_bytes(arena, er);
      unsafe {
        ch = ast_pipeline_block_if_then_body_ref(arena, cur, i);
      }
      if (ch > 0 && sp < 8192) {
        g_w157_walk_stack[sp] = ch;
        sp = sp + 1;
      }
      unsafe {
        ch = ast_pipeline_block_if_else_body_ref(arena, cur, i);
      }
      if (ch > 0 && sp < 8192) {
        g_w157_walk_stack[sp] = ch;
        sp = sp + 1;
      }
      i = i + 1;
    }
    unsafe {
      n = ast_ast_block_num_loops(arena, cur);
    }
    i = 0;
    while (i < n) {
      unsafe {
        er = ast_ast_block_while_cond_ref(arena, cur, i);
      }
      w157_sum_expr_call_spill_bytes(arena, er);
      unsafe {
        ch = pipeline_block_while_body_ref(arena, cur, i);
      }
      if (ch > 0 && sp < 8192) {
        g_w157_walk_stack[sp] = ch;
        sp = sp + 1;
      }
      i = i + 1;
    }
    unsafe {
      n = ast_ast_block_num_for_loops(arena, cur);
    }
    i = 0;
    while (i < n) {
      unsafe {
        er = ast_ast_block_for_init_ref(arena, cur, i);
      }
      w157_sum_expr_call_spill_bytes(arena, er);
      unsafe {
        er = ast_ast_block_for_cond_ref(arena, cur, i);
      }
      w157_sum_expr_call_spill_bytes(arena, er);
      unsafe {
        er = ast_ast_block_for_step_ref(arena, cur, i);
      }
      w157_sum_expr_call_spill_bytes(arena, er);
      unsafe {
        ch = pipeline_block_for_body_ref(arena, cur, i);
      }
      if (ch > 0 && sp < 8192) {
        g_w157_walk_stack[sp] = ch;
        sp = sp + 1;
      }
      i = i + 1;
    }
    unsafe {
      n = ast_ast_block_num_regions(arena, cur);
    }
    i = 0;
    while (i < n) {
      unsafe {
        ch = pipeline_block_region_body_ref(arena, cur, i);
      }
      if (ch > 0 && sp < 8192) {
        g_w157_walk_stack[sp] = ch;
        sp = sp + 1;
      }
      i = i + 1;
    }
    // Labeled return expressions (C / .x parser).
    // Without this walk, calls in return expressions (e.g. return f(a, b, c, d, e))
    // are not counted in call_spill, leading to stack under-allocation in pure-asm frames.
    unsafe {
      n = pipeline_block_num_labeled_stmts(arena, cur);
    }
    i = 0;
    while (i < n) {
      unsafe {
        if (pipeline_block_labeled_is_goto(arena, cur, i) == 0) {
          er = pipeline_block_labeled_return_expr_ref(arena, cur, i);
        } else {
          er = 0;
        }
      }
      if (er > 0) {
        w157_sum_expr_call_spill_bytes(arena, er);
      }
      i = i + 1;
    }
  }
  return g_w157_spill_total;
}

// end wave157 pure-owned leave
