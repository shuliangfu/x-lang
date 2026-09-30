// Thin pure override: per-block call-arg spill budget for frame sizing.
// w1500 (终局待办 10.23): pure .x replacement for the former host-cc sidecar
// seeds/runtime_pipeline_abi_call_spill_overlay.c (w157 walk + w1497 exact
// per-arg GP units). Same exported symbols, same numbers:
//   glue_asm_sum_block_call_spill_bytes(arena, block_ref)
//     CALL(48): (args that are not EXPR_VAR + 1) * 8; on x86_64 each arg
//     counts its real GP units from glue_sysv_x86_call_arg_slot_c (1 or 2).
//     METHOD_CALL(49): (base + args + 1) * 8, doubled on x86_64.
//   glue_asm_last_call_max_gp_units_c() — widest outgoing GP unit count seen
//     by the last walk (-1 when the body has no call); compute_frame_size
//     reserves the Windows shadow + stack-arg area from it.
// Arguments are walked before the per-call units are counted; the sum is the
// same as the C order because every contribution is an addition.
// src/runtime_pipeline_abi.x and src/runtime_pipeline_abi_w157_sum_thin.x are
// not edited (pabi is not rebuilt; w157_sum_thin stays under the reinject ban).
// g05_relink_env.sh compiles this with the current product (pure asm, no host
// cc) and links it ahead of pabi (Linux first-wins over spill.o / pabi,
// Darwin pabi copies are weak, Windows weakens pabi_weak).
// PLATFORM: SHARED freestanding frame-size · MACOS|ARM64 · LINUX x86_64 · WINDOWS x86_64.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_call_num_args_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_call_arg_ref(arena: *u8, expr_ref: i32, i: i32): i32;
export extern function pipeline_expr_method_call_base_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_method_call_num_args_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_method_call_arg_ref(arena: *u8, expr_ref: i32, i: i32): i32;
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
export extern function pipeline_expr_block_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function ast_ast_block_num_consts(arena: *u8, block_ref: i32): i32;
export extern function ast_pipeline_block_const_init_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_ast_block_num_lets(arena: *u8, block_ref: i32): i32;
export extern function ast_pipeline_block_let_init_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_ast_block_num_expr_stmts(arena: *u8, block_ref: i32): i32;
export extern function ast_pipeline_block_expr_stmt_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_ast_block_final_expr_ref(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_if_stmts(arena: *u8, block_ref: i32): i32;
export extern function ast_pipeline_block_if_cond_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_pipeline_block_if_then_body_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_pipeline_block_if_else_body_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_ast_block_num_loops(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_while_cond_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function pipeline_block_while_body_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_ast_block_num_for_loops(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_for_init_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_ast_block_for_cond_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_ast_block_for_step_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function pipeline_block_for_body_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_ast_block_num_regions(arena: *u8, block_ref: i32): i32;
export extern function pipeline_block_region_body_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function pipeline_block_num_labeled_stmts(arena: *u8, block_ref: i32): i32;
export extern function pipeline_block_labeled_is_goto(arena: *u8, block_ref: i32, li: i32): i32;
export extern function pipeline_block_labeled_return_expr_ref(arena: *u8, block_ref: i32, li: i32): i32;
export extern function ast_ast_block_num_stmt_order(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_stmt_order_kind(arena: *u8, block_ref: i32, si: i32): i32;
export extern function ast_ast_block_stmt_order_idx(arena: *u8, block_ref: i32, si: i32): i32;
export extern function glue_sysv_x86_call_arg_slot_c(arena: *u8, call_expr_ref: i32, nargs: i32, arg_index: i32, out_kind: *i32, out_reg_k: *i32, out_stack_k: *i32): void;
export extern function pipeline_asm_host_is_arm64_c(): i32;
export extern function pipeline_expr_match_num_arms_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_match_matched_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_match_arm_result_ref(arena: *u8, expr_ref: i32, i: i32): i32;
export extern function pipeline_expr_match_arm_guard_ref(arena: *u8, expr_ref: i32, i: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_expr_struct_lit_value_bytes(a: *u8, m: *u8, expr_ref: i32): i32;
export extern function glue_call_return_byte_size_c(arena: *u8, call_expr_ref: i32): i32;
/** w1521: Win64 by-ref >16B call-arg temp bytes (bcd). PLATFORM: WINDOWS x86_64. */
export extern function w1521_win_call_mem_temp_bytes_c(arena: *u8, call: i32, nargs: i32, is_method: i32): i32;
export extern function glue_call_param_type_ref_at(arena: *u8, call_expr_ref: i32, param_index: i32): i32;
export extern function glue_sysv_arg_byte_size_c(arena: *u8, ctx: *u8, pty: i32, arg_ref: i32): i32;
export extern function glue_sysv_arg_gp_units_from_size_c(sz: i32): i32;

// Walk state: [0] total bytes, [1] visits, [2] x86 flag, [3] widest GP units,
// [4] arm64 binop left-preserve frame homes (w1503),
// [5] STRUCT_LIT value temp bytes (w1509),
// [6] arm64 sret CALL result temps + x8 save slot; Win64 by-ref arg copies (w1521).
let w1500_cs_st: i32[7] = [];

/** Record the widest outgoing GP unit count. PLATFORM: SHARED. */
function w1500_cs_note_gp(gp: i32): void {
  if (gp > w1500_cs_st[3]) {
    w1500_cs_st[3] = gp;
  }
}

/**
 * x86_64 CALL budget: per-arg GP units from the call packer (gp: distance to
 * the next gp arg, 1..2, last gp 2; xmm/stack 1). Adds (need+1)*8 to the
 * total and notes total_gp+1 (sret). Not recursive: the caller walked the
 * args already. PLATFORM: LINUX+WINDOWS x86_64.
 */
function w1500_cs_call_x86(arena: *u8, call: i32, n: i32): void {
  let kind: i32[64] = [];
  let reg: i32[64] = [];
  let i: i32 = 0;
  let j: i32 = 0;
  let u: i32 = 0;
  let k0: i32 = 0;
  let r0: i32 = 0;
  let s0: i32 = 0;
  let total_gp: i32 = 0;
  let need: i32 = 0;
  let arg_ref: i32 = 0;
  let found: i32 = 0;
  i = 0;
  while (i < n) {
    k0 = 2;
    r0 = 0;
    s0 = 0;
    unsafe {
      glue_sysv_x86_call_arg_slot_c(arena, call, n, i, &k0, &r0, &s0);
    }
    kind[i] = k0;
    reg[i] = r0;
    i = i + 1;
  }
  i = 0;
  while (i < n) {
    u = 1;
    if (kind[i] == 0) {
      u = 2;
      found = 0;
      j = i + 1;
      while (j < n && found == 0) {
        if (kind[j] == 0) {
          u = reg[j] - reg[i];
          found = 1;
        }
        j = j + 1;
      }
      if (u < 1) {
        u = 1;
      }
      if (u > 2) {
        u = 2;
      }
      if (reg[i] + u > total_gp) {
        total_gp = reg[i] + u;
      }
    }
    unsafe {
      arg_ref = pipeline_expr_call_arg_ref(arena, call, i);
    }
    if (arg_ref > 0) {
      let ak: i32 = 0;
      unsafe {
        ak = pipeline_expr_kind_ord_at(arena, arg_ref);
      }
      if (ak != 3) {
        need = need + u;
      } else if (u >= 2) {
        need = need + u;
      }
    }
    i = i + 1;
  }
  if (need > 0 || n == 0) {
    need = need + 1;
  }
  w1500_cs_st[0] = w1500_cs_st[0] + need * 8;
  w1500_cs_note_gp(total_gp + 1);
}

/**
 * w1544: arm64 call-arg spill units for one argument (every argument).
 * The AAPCS64 packer (backend_call_dispatch.x, glue_sysv_spill_rax_rdx_to_frame_c)
 * spills each register-class argument to a fresh frame slot from next_offset
 * (16B per single-GP arg, 32B per dual-GP arg; the frame doubles these units).
 * Only a single-GP EXPR_VAR with a local stack home reuses that home, so a
 * 16-byte struct VAR, a slice/array VAR (LEA) or a VAR without a local home
 * still takes a slot. The old walk counted VAR args as zero: a pure-asm
 * lexer_next_into (lex: Lexer, data: u8[]) wrote its temps past the frame
 * into the caller's fp/lr. Counting every argument over-reserves at most one
 * 16B slot per scalar VAR arg. pty 0 = method call (no formal lookup).
 * @return i32 - GP units 1..2
 * PLATFORM: MACOS|ARM64.
 */
function w1544_cs_arm_units(arena: *u8, call: i32, i: i32, arg_ref: i32, is_method: i32): i32 {
  let pty: i32 = 0;
  let sz: i32 = 0;
  let u: i32 = 1;
  if (arg_ref <= 0) {
    return 0;
  }
  if (is_method == 0) {
    unsafe {
      pty = glue_call_param_type_ref_at(arena, call, i);
    }
  }
  unsafe {
    sz = glue_sysv_arg_byte_size_c(arena, 0 as *u8, pty, arg_ref);
    u = glue_sysv_arg_gp_units_from_size_c(sz);
  }
  if (u < 1) {
    u = 1;
  }
  if (u > 2) {
    u = 2;
  }
  return u;
}

/** Count args that are not EXPR_VAR(3). PLATFORM: SHARED. */
function w1500_cs_non_var(arena: *u8, e: i32): i32 {
  let k: i32 = 0;
  if (e <= 0) {
    return 0;
  }
  unsafe {
    k = pipeline_expr_kind_ord_at(arena, e);
  }
  if (k != 3) {
    return 1;
  }
  return 0;
}

/** Recursive call-arg spill sum under one expression. PLATFORM: SHARED. */
function w1500_cs_expr(arena: *u8, expr_ref: i32): void {
  let ko: i32 = 0;
  let n: i32 = 0;
  let i: i32 = 0;
  let arg_ref: i32 = 0;
  let op: i32 = 0;
  let as_op: i32 = 0;
  let need: i32 = 0;
  let mod_p: *u8 = 0 as *u8;
  if (arena == (0 as *u8) || expr_ref <= 0) {
    return;
  }
  w1500_cs_st[1] = w1500_cs_st[1] + 1;
  if (w1500_cs_st[1] > 32768) {
    return;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  if (ko == 48) {
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
      w1500_cs_expr(arena, arg_ref);
      if (w1500_cs_st[2] == 0) {
        // w1544: arm64 spills VAR args too (see w1544_cs_arm_units). MACOS|ARM64.
        need = need + w1544_cs_arm_units(arena, expr_ref, i, arg_ref, 0);
      } else {
        need = need + w1500_cs_non_var(arena, arg_ref);
      }
      i = i + 1;
    }
    if (w1500_cs_st[2] != 0) {
      // w1521 (10.57): Win64 by-reference >16B arg copies (0 off Windows).
      unsafe {
        // Call first into a local: Win x86 emit pushes the left operand then calls
        // without shadow space; the gcc-built callee homes rcx over that push.
        op = w1521_win_call_mem_temp_bytes_c(arena, expr_ref, n, 0);
        w1500_cs_st[6] = w1500_cs_st[6] + op;
        op = 0;
      }
      w1500_cs_call_x86(arena, expr_ref, n);
      return;
    }
    // w1521 (终局待办 10.57): pipeline_asm_emit_call_elf_c takes a result
    // temp (align8(ret) bytes) plus an 8-byte x8 save slot from next_offset
    // for every CALL returning > 16 bytes. PLATFORM: MACOS|ARM64.
    unsafe {
      op = glue_call_return_byte_size_c(arena, expr_ref);
    }
    if (op > 16) {
      w1500_cs_st[6] = w1500_cs_st[6] + ((op + 7) & (0 - 8)) + 16;
    }
    op = 0;
    if (need > 0 || n == 0) {
      need = need + 1;
    }
    w1500_cs_st[0] = w1500_cs_st[0] + need * 8;
    return;
  }
  if (ko == 49) {
    unsafe {
      arg_ref = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
    }
    w1500_cs_expr(arena, arg_ref);
    need = w1500_cs_non_var(arena, arg_ref);
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
      w1500_cs_expr(arena, arg_ref);
      if (w1500_cs_st[2] == 0) {
        // w1544: arm64 method args spill like CALL args. MACOS|ARM64.
        need = need + w1544_cs_arm_units(arena, expr_ref, i, arg_ref, 1);
      } else {
        need = need + w1500_cs_non_var(arena, arg_ref);
      }
      i = i + 1;
    }
    if (need > 0) {
      need = need + 1;
    }
    if (w1500_cs_st[2] != 0) {
      // w1521 (10.57): Win64 by-reference >16B arg copies (0 off Windows).
      unsafe {
        // Call first into a local: Win x86 emit pushes the left operand then calls
        // without shadow space; the gcc-built callee homes rcx over that push.
        op = w1521_win_call_mem_temp_bytes_c(arena, expr_ref, n, 1);
        w1500_cs_st[6] = w1500_cs_st[6] + op;
        op = 0;
      }
      need = need * 2;
      w1500_cs_note_gp(2 * (n + 1) + 1);
    }
    w1500_cs_st[0] = w1500_cs_st[0] + need * 8;
    return;
  }
  if (ko == 25) {
    unsafe {
      arg_ref = pipeline_expr_if_cond_ref_at(arena, expr_ref);
    }
    if (arg_ref > 0) {
      w1500_cs_expr(arena, arg_ref);
      unsafe {
        op = pipeline_expr_if_then_ref_at(arena, expr_ref);
      }
      w1500_cs_expr(arena, op);
      unsafe {
        op = pipeline_expr_if_else_ref_at(arena, expr_ref);
      }
      w1500_cs_expr(arena, op);
      return;
    }
  }
  if (ko == 26) {
    unsafe {
      op = pipeline_expr_block_ref_at(arena, expr_ref);
    }
    if (op > 0) {
      w1500_cs_block(arena, op, 40);
      return;
    }
  }
  if (ko == 43) {
    // w1503: MATCH scrutinee, guards and arm results (binops/calls inside
    // arms were not counted, so their frame homes were missing).
    unsafe {
      op = pipeline_expr_match_matched_ref_at(arena, expr_ref);
      n = pipeline_expr_match_num_arms_at(arena, expr_ref);
    }
    w1500_cs_expr(arena, op);
    if (n > 1024) {
      n = 1024;
    }
    i = 0;
    while (i < n) {
      unsafe {
        op = pipeline_expr_match_arm_guard_ref(arena, expr_ref, i);
        arg_ref = pipeline_expr_match_arm_result_ref(arena, expr_ref, i);
      }
      w1500_cs_expr(arena, op);
      w1500_cs_expr(arena, arg_ref);
      i = i + 1;
    }
    return;
  }
  if ((ko >= 4 && ko <= 21) || ko == 25 || ko == 26 || (ko >= 28 && ko <= 38)) {
    unsafe {
      arg_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
      op = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    }
    // w1503 (终局待办 10.31/10.27): on arm64 glue_binop_preserve_rax_for_rbx_load
    // parks the left value in a fresh frame home (next_offset += 8, never
    // released). Count one home per binop whose right side is not an int or
    // bool literal so compute_frame_size reserves them. MACOS|ARM64.
    if (w1500_cs_st[2] == 0 && ko >= 4 && ko <= 21 && op > 0) {
      unsafe {
        need = pipeline_expr_kind_ord_at(arena, op);
      }
      if (need != 0 && need != 2) {
        w1500_cs_st[4] = w1500_cs_st[4] + 1;
      }
      need = 0;
    }
    w1500_cs_expr(arena, arg_ref);
    w1500_cs_expr(arena, op);
    return;
  }
  if (ko == 22 || ko == 23 || ko == 24 || ko == 41 || ko == 51) {
    unsafe {
      op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    }
    w1500_cs_expr(arena, op);
    return;
  }
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
    w1500_cs_expr(arena, op);
    return;
  }
  if (ko == 47) {
    unsafe {
      arg_ref = pipeline_expr_index_base_ref(arena, expr_ref);
      op = pipeline_expr_index_index_ref(arena, expr_ref);
    }
    w1500_cs_expr(arena, arg_ref);
    w1500_cs_expr(arena, op);
    return;
  }
  if (ko == 44) {
    unsafe {
      op = pipeline_expr_field_access_base_ref(arena, expr_ref);
    }
    w1500_cs_expr(arena, op);
    return;
  }
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
      w1500_cs_expr(arena, arg_ref);
      i = i + 1;
    }
    return;
  }
  if (ko == 45) {
    unsafe {
      n = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
    }
    if (n > 64) {
      n = 64;
    }
    // w1509 (终局待办 10.32): a STRUCT_LIT rvalue takes an 8-aligned temp
    // home from next_offset while the body is emitted (Windows leftover
    // pipeline_asm_emit_struct_lit_fields_elf_c, stack_slot_off -1). Count
    // max(value bytes, 8 per field) + 8 alignment so the frame covers it.
    need = 0;
    unsafe {
      mod_p = pipeline_asm_emit_module_ref_c();
      if (mod_p != (0 as *u8)) {
        need = pipeline_expr_struct_lit_value_bytes(arena, mod_p, expr_ref);
      }
    }
    if (need < n * 8) {
      need = n * 8;
    }
    if (need < 8) {
      need = 8;
    }
    if (need <= 4096) {
      need = ((need + 7) / 8) * 8 + 8;
      w1500_cs_st[5] = w1500_cs_st[5] + need;
    }
    i = 0;
    while (i < n) {
      unsafe {
        arg_ref = pipeline_expr_struct_lit_init_ref(arena, expr_ref, i);
      }
      w1500_cs_expr(arena, arg_ref);
      i = i + 1;
    }
    return;
  }
  unsafe {
    arg_ref = pipeline_expr_if_cond_ref_at(arena, expr_ref);
  }
  if (arg_ref > 0) {
    w1500_cs_expr(arena, arg_ref);
    unsafe {
      op = pipeline_expr_if_then_ref_at(arena, expr_ref);
    }
    w1500_cs_expr(arena, op);
    unsafe {
      op = pipeline_expr_if_else_ref_at(arena, expr_ref);
    }
    w1500_cs_expr(arena, op);
  }
}

/** One stmt_order entry. PLATFORM: SHARED. */
function w1500_cs_stmt(arena: *u8, cur: i32, sok: i32, soi: i32, depth: i32): void {
  let er: i32 = 0;
  let ch: i32 = 0;
  if (sok == 2) {
    unsafe {
      er = ast_pipeline_block_expr_stmt_ref(arena, cur, soi);
    }
    w1500_cs_expr(arena, er);
  } else if (sok == 1) {
    unsafe {
      er = ast_pipeline_block_let_init_ref(arena, cur, soi);
    }
    w1500_cs_expr(arena, er);
  } else if (sok == 0) {
    unsafe {
      er = ast_pipeline_block_const_init_ref(arena, cur, soi);
    }
    w1500_cs_expr(arena, er);
  } else if (sok == 5) {
    unsafe {
      er = ast_pipeline_block_if_cond_ref(arena, cur, soi);
    }
    w1500_cs_expr(arena, er);
    unsafe {
      ch = ast_pipeline_block_if_then_body_ref(arena, cur, soi);
    }
    if (ch > 0) {
      w1500_cs_block(arena, ch, depth - 1);
    }
    unsafe {
      ch = ast_pipeline_block_if_else_body_ref(arena, cur, soi);
    }
    if (ch > 0) {
      w1500_cs_block(arena, ch, depth - 1);
    }
  } else if (sok == 3) {
    unsafe {
      er = ast_ast_block_while_cond_ref(arena, cur, soi);
    }
    w1500_cs_expr(arena, er);
    unsafe {
      ch = pipeline_block_while_body_ref(arena, cur, soi);
    }
    if (ch > 0) {
      w1500_cs_block(arena, ch, depth - 1);
    }
  } else if (sok == 4) {
    unsafe {
      er = ast_ast_block_for_init_ref(arena, cur, soi);
    }
    w1500_cs_expr(arena, er);
    unsafe {
      er = ast_ast_block_for_cond_ref(arena, cur, soi);
    }
    w1500_cs_expr(arena, er);
    unsafe {
      er = ast_ast_block_for_step_ref(arena, cur, soi);
    }
    w1500_cs_expr(arena, er);
    unsafe {
      ch = pipeline_block_for_body_ref(arena, cur, soi);
    }
    if (ch > 0) {
      w1500_cs_block(arena, ch, depth - 1);
    }
  } else if (sok == 6) {
    unsafe {
      ch = pipeline_block_region_body_ref(arena, cur, soi);
    }
    if (ch > 0) {
      w1500_cs_block(arena, ch, depth - 1);
    }
  } else if (sok == 7) {
    let gt: i32 = 0;
    unsafe {
      gt = pipeline_block_labeled_is_goto(arena, cur, soi);
    }
    if (gt == 0) {
      unsafe {
        er = pipeline_block_labeled_return_expr_ref(arena, cur, soi);
      }
      if (er > 0) {
        w1500_cs_expr(arena, er);
      }
    }
  }
}

/** Legacy (no stmt_order) block walk. PLATFORM: SHARED. */
function w1500_cs_block_legacy(arena: *u8, cur: i32, depth: i32): void {
  let i: i32 = 0;
  let n: i32 = 0;
  let er: i32 = 0;
  let ch: i32 = 0;
  let gt: i32 = 0;
  unsafe {
    n = ast_ast_block_num_consts(arena, cur);
  }
  i = 0;
  while (i < n) {
    unsafe {
      er = ast_pipeline_block_const_init_ref(arena, cur, i);
    }
    w1500_cs_expr(arena, er);
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
    w1500_cs_expr(arena, er);
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
    w1500_cs_expr(arena, er);
    i = i + 1;
  }
  unsafe {
    er = ast_ast_block_final_expr_ref(arena, cur);
  }
  if (er > 0) {
    w1500_cs_expr(arena, er);
  }
  unsafe {
    n = ast_ast_block_num_if_stmts(arena, cur);
  }
  i = 0;
  while (i < n) {
    w1500_cs_stmt(arena, cur, 5, i, depth);
    i = i + 1;
  }
  unsafe {
    n = ast_ast_block_num_loops(arena, cur);
  }
  i = 0;
  while (i < n) {
    w1500_cs_stmt(arena, cur, 3, i, depth);
    i = i + 1;
  }
  unsafe {
    n = ast_ast_block_num_for_loops(arena, cur);
  }
  i = 0;
  while (i < n) {
    w1500_cs_stmt(arena, cur, 4, i, depth);
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
    if (ch > 0) {
      w1500_cs_block(arena, ch, depth - 1);
    }
    i = i + 1;
  }
  unsafe {
    n = pipeline_block_num_labeled_stmts(arena, cur);
  }
  i = 0;
  while (i < n) {
    unsafe {
      gt = pipeline_block_labeled_is_goto(arena, cur, i);
    }
    if (gt == 0) {
      unsafe {
        er = pipeline_block_labeled_return_expr_ref(arena, cur, i);
      }
      if (er > 0) {
        w1500_cs_expr(arena, er);
      }
    }
    i = i + 1;
  }
}

/** Block walk: stmt_order path when present, else legacy. PLATFORM: SHARED. */
function w1500_cs_block(arena: *u8, cur: i32, depth: i32): void {
  let i: i32 = 0;
  let nso: i32 = 0;
  let sok: i32 = 0;
  let soi: i32 = 0;
  let fin: i32 = 0;
  if (arena == (0 as *u8) || cur <= 0 || depth <= 0) {
    return;
  }
  if (w1500_cs_st[1] > 32768) {
    return;
  }
  unsafe {
    nso = ast_ast_block_num_stmt_order(arena, cur);
  }
  if (nso <= 0) {
    w1500_cs_block_legacy(arena, cur, depth);
    return;
  }
  i = 0;
  while (i < nso) {
    unsafe {
      sok = ast_ast_block_stmt_order_kind(arena, cur, i);
      soi = ast_ast_block_stmt_order_idx(arena, cur, i);
    }
    if (soi >= 0) {
      w1500_cs_stmt(arena, cur, sok, soi, depth);
    }
    i = i + 1;
  }
  unsafe {
    fin = ast_ast_block_final_expr_ref(arena, cur);
  }
  if (fin > 0) {
    w1500_cs_expr(arena, fin);
  }
}

/**
 * Sum permanent call-arg spill bytes for one function body.
 * @return bytes (0 for a leaf). PLATFORM: SHARED.
 */
#[no_mangle]
export function glue_asm_sum_block_call_spill_bytes(arena: *u8, block_ref: i32): i32 {
  let arm: i32 = 0;
  if (arena == (0 as *u8) || block_ref <= 0) {
    return 0;
  }
  w1500_cs_st[0] = 0;
  w1500_cs_st[1] = 0;
  w1500_cs_st[3] = 0 - 1;
  w1500_cs_st[4] = 0;
  w1500_cs_st[5] = 0;
  w1500_cs_st[6] = 0;
  unsafe {
    arm = pipeline_asm_host_is_arm64_c();
  }
  if (arm == 0) {
    w1500_cs_st[2] = 1;
  } else {
    w1500_cs_st[2] = 0;
  }
  w1500_cs_block(arena, block_ref, 256);
  return w1500_cs_st[0];
}

/** Widest outgoing GP units from the last walk (-1 = no call). PLATFORM: SHARED. */
#[no_mangle]
export function glue_asm_last_call_max_gp_units_c(): i32 {
  return w1500_cs_st[3];
}

/** arm64 binop left-preserve frame homes from the last walk (w1503). PLATFORM: MACOS|ARM64. */
#[no_mangle]
export function glue_asm_last_binop_preserve_homes_c(): i32 {
  return w1500_cs_st[4];
}

/** STRUCT_LIT value temp bytes from the last walk (w1509). PLATFORM: WINDOWS x86_64. */
#[no_mangle]
export function glue_asm_last_struct_lit_temp_bytes_c(): i32 {
  return w1500_cs_st[5];
}

/** arm64 sret CALL temp bytes from the last walk (w1521). PLATFORM: MACOS|ARM64. */
#[no_mangle]
export function glue_asm_last_sret_call_temp_bytes_c(): i32 {
  return w1500_cs_st[6];
}
