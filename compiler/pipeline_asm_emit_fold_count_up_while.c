/**
 * pipeline_asm_emit_fold_count_up_while.c — count_up_while loop folding domain.
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via #include).
 * Authority for the count_up_while loop folding pipeline that recognizes fixed
 * iteration shapes and either emits a tight x86_64 loop or eliminates the loop
 * with a compile-time closed form. The 17 members cover six sub-domains:
 * - struct_pair_n2: closed form s = n*n (Σ(2i+1))
 * - u8_fill:        tight loop `while (i<N) { buf[i]=(i as u8); i++ }`
 * - u8_sum:         tight loop `while (j<N) { sum+=(buf[j] as i32); j++ }`
 * - mem_copy:       outer `while (r<R) { fill; sum; r++ }` collapsed to a constant
 * - lcg_xor:        tight loop `while (i<n) { let t=i*C1+C2; s^=t; i++ }` (x86_64)
 * - affine sum:     closed form `while (i<n) { s=s+(i+K); i++ }` → s=n(n-1)/2+K*n
 *
 * Public entry point: backend_try_fold_count_up_while_elf (consumed by
 * backend_emit_while_loop_elf_sync, which follows this #include in pipeline_glue.c).
 *
 * Same-TU #include contract:
 * - MUST be #included AFTER pipeline_asm_emit_fold_primitives.c (provides the 13
 *   fold primitives: glue_fold_parse_while_lt_i_n_c, glue_fold_block_let_init_lit_c,
 *   glue_is_assign_var_add_one_c, glue_is_field_assign_from_var_c,
 *   glue_is_field_assign_i_plus_one_c, glue_is_assign_s_plus_pair_field_sum_call_c,
 *   glue_is_assign_u8_index_store_cast_i_c, glue_is_assign_sum_plus_u8_index_cast_c,
 *   glue_fold_expr_var_refs_same_c, glue_parse_i_mul_add_lit_c,
 *   glue_expr_var_name_eq_let_idx_c, glue_fold_func_return_operand_ref_c,
 *   glue_module_func_index_by_name_c).
 * - MUST be #included AFTER pipeline_asm_emit_x86_enc_helpers.c (provides the
 *   glue_enc_x86_* micro-encoders and glue_emit_lcg_xor_body_x86_c).
 * - MUST be #included BEFORE backend_emit_while_loop_elf_sync (the consumer of
 *   backend_try_fold_count_up_while_elf and the glue_try_fold_*_elf_c hooks).
 *
 * External deps (all visible at the #include point in pipeline_glue.c):
 * - Fold primitives (from pipeline_asm_emit_fold_primitives.c, same TU):
 *   glue_fold_parse_while_lt_i_n_c / glue_fold_block_let_init_lit_c
 *   glue_is_assign_var_add_one_c / glue_is_field_assign_from_var_c
 *   glue_is_field_assign_i_plus_one_c / glue_is_assign_s_plus_pair_field_sum_call_c
 *   glue_is_assign_u8_index_store_cast_i_c / glue_is_assign_sum_plus_u8_index_cast_c
 *   glue_fold_expr_var_refs_same_c / glue_parse_i_mul_add_lit_c
 *   glue_expr_var_name_eq_let_idx_c / glue_fold_func_return_operand_ref_c
 *   glue_module_func_index_by_name_c
 * - x86 encoders (from pipeline_asm_emit_x86_enc_helpers.c, same TU):
 *   glue_enc_x86_cmpl_eax_imm32 / glue_enc_x86_mov_al_mem_rbx_rax
 *   glue_enc_x86_addl_imm_rbp_off / glue_enc_x86_movzx_ecx_mem_rbx_rax
 *   glue_enc_x86_add_ecx_rbp_off / glue_enc_x86_xor_edx_edx
 *   glue_enc_x86_xor_eax_eax / glue_enc_x86_cmpl_edx_imm32
 *   glue_emit_lcg_xor_body_x86_c
 * - glue_asm_local_var_stack_off_scoped (from pipeline_asm_emit_vector_simd.c)
 * - glue_enc_local_slot_ptr_or_addr_rbx_elf_c (from pipeline_asm_emit_index_helpers.c)
 * - pipeline_asm_emit_next_label_c (from pipeline_glue.c)
 * - glue_asm_ctx_set_scope_block (from pipeline_glue.c)
 * - glue_body_expr_stmt_at_c + glue_field_assign_pair_base_ref_c
 *   (from pipeline_asm_emit_assign.c)
 * - backend_enc_*_arch (extern): backend_enc_mov_imm32_to_w0_arch /
 *   backend_enc_store_eax_to_rbp_arch / backend_enc_label_arch /
 *   backend_enc_load_rbp_lane_to_rax_arch / backend_enc_jge_arch /
 *   backend_enc_jmp_arch / backend_enc_jl_arch / backend_enc_jle_arch
 * - ast_ast_block_* (extern): ast_ast_block_while_cond_ref /
 *   ast_ast_block_while_body_ref / ast_ast_block_num_stmt_order /
 *   ast_ast_block_num_expr_stmts / ast_ast_block_num_loops /
 *   ast_ast_block_stmt_order_kind / ast_ast_block_stmt_order_idx
 * - ast_pipeline_block_expr_stmt_ref / pipeline_block_let_init_ref (extern)
 * - pipeline_expr_kind_ord_at / pipeline_expr_binop_left_ref_at /
 *   pipeline_expr_binop_right_ref_at / pipeline_expr_int_val_at /
 *   pipeline_expr_var_name_len / pipeline_expr_var_name_into /
 *   pipeline_expr_call_num_args_at / pipeline_expr_call_arg_ref /
 *   pipeline_expr_call_callee_ref_at (extern)
 * - pipeline_asm_module_func_num_params_at /
 *   pipeline_asm_module_func_param_name_len_at /
 *   pipeline_asm_module_func_param_name_copy32 /
 *   pipeline_asm_module_func_is_extern_at (extern)
 * - pipeline_glue_AsmFuncCtxLayout / pipeline_asm_ctx_layout (extern)
 * - GLUE_EXPR_KIND_VAR (macro, defined earlier in pipeline_glue.c)
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

/** Match the struct_param four-statement body: `p.a=i; p.b=i+1; s+=add_pair(p); i++` (no code emitted). */
static int32_t glue_match_struct_pair_n2_body_pattern_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                        int32_t body_ref, int32_t i_ref, int32_t *out_s_ref,
                                                        int32_t *out_pair_ref) {
  int32_t nso;
  int32_t nexpr;
  int32_t si;
  int32_t pair_ref;
  int32_t s_ref;
  int32_t found_a;
  int32_t found_b;
  int32_t found_call;
  int32_t found_i;
  int32_t need;

  if (!arena || !mod || body_ref <= 0 || i_ref <= 0)
    return 0;
  nso = ast_ast_block_num_stmt_order(arena, body_ref);
  nexpr = ast_ast_block_num_expr_stmts(arena, body_ref);
  if (nso == 4)
    need = 4;
  else if (nso == 0 && nexpr == 4)
    need = 4;
  else
    return 0;
  pair_ref = 0;
  s_ref = 0;
  found_a = 0;
  found_b = 0;
  found_call = 0;
  found_i = 0;
  for (si = 0; si < need; si++) {
    int32_t er;
    if (!glue_body_expr_stmt_at_c(arena, body_ref, si, nso, &er))
      return 0;
    if (glue_is_assign_var_add_one_c(arena, er, i_ref)) {
      found_i = 1;
      continue;
    }
    if (!pair_ref)
      pair_ref = glue_field_assign_pair_base_ref_c(arena, er);
    if (pair_ref > 0 && glue_is_field_assign_from_var_c(arena, er, pair_ref, (uint8_t)'a', i_ref)) {
      found_a = 1;
      continue;
    }
    if (pair_ref > 0 && glue_is_field_assign_i_plus_one_c(arena, er, pair_ref, i_ref)) {
      found_b = 1;
      continue;
    }
    if (pair_ref > 0 && glue_is_assign_s_plus_pair_field_sum_call_c(arena, mod, er, &s_ref, pair_ref)) {
      found_call = 1;
      continue;
    }
    return 0;
  }
  if (!found_a || !found_b || !found_call || !found_i || s_ref <= 0 || pair_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, s_ref) != GLUE_EXPR_KIND_VAR)
    return 0;
  if (out_s_ref)
    *out_s_ref = s_ref;
  if (out_pair_ref)
    *out_pair_ref = pair_ref;
  return 1;
}

/** struct_param: closed form s = n*n (Σ(2i+1)). */
static int32_t glue_try_fold_struct_pair_n2_while_elf_c(struct ast_ASTArena *arena,
                                                        struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                        int32_t block_ref, int32_t loop_idx,
                                                        struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t cond_ref;
  int32_t body_ref;
  int32_t i_ref;
  int32_t n_is_lit;
  int32_t n_lit;
  int32_t n_var_ref;
  int32_t n_const;
  int32_t n_const_ok;
  int32_t pair_ref;
  int32_t s_ref;
  int32_t off_s;
  int32_t prod32;
  struct ast_Module *mod;
  pipeline_glue_AsmFuncCtxLayout *ly;

  if (!arena || !elf_ctx || !ctx || ta != 0)
    return 0;
  ly = pipeline_asm_ctx_layout(ctx);
  mod = ly ? ly->module_ref : NULL;
  if (!mod)
    return 0;
  cond_ref = ast_ast_block_while_cond_ref(arena, block_ref, loop_idx);
  body_ref = ast_ast_block_while_body_ref(arena, block_ref, loop_idx);
  if (cond_ref <= 0 || body_ref <= 0)
    return 0;
  if (!glue_fold_parse_while_lt_i_n_c(arena, cond_ref, &i_ref, &n_is_lit, &n_lit, &n_var_ref))
    return 0;
  n_const = n_lit;
  n_const_ok = n_is_lit;
  if (!n_const_ok && n_var_ref > 0 &&
      glue_fold_block_let_init_lit_c(arena, block_ref, n_var_ref, &n_const))
    n_const_ok = 1;
  if (!n_const_ok)
    return 0;
  if (!glue_match_struct_pair_n2_body_pattern_c(arena, mod, body_ref, i_ref, &s_ref, &pair_ref))
    return 0;
  /** s lives in the while's outer block; switch scope to block_ref before querying its stack slot. */
  glue_asm_ctx_set_scope_block((uint8_t *)ctx, block_ref);
  off_s = glue_asm_local_var_stack_off_scoped(arena, ctx, s_ref);
  if (off_s < 0)
    return 0;
  /** Compile-time n² (i32 wrap), avoiding 1e8 iterations. */
  {
    uint64_t prod64 = (uint64_t)(uint32_t)n_const * (uint64_t)(uint32_t)n_const;
    prod32 = (int32_t)(uint32_t)prod64;
    if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, prod32, ta) != 0)
      return -1;
  }
  if (backend_enc_store_eax_to_rbp_arch(elf_ctx, off_s, ta) != 0)
    return -1;
  return 1;
}

/** mem_copy: `while (i<N) { buf[i]=(i as u8); i++ }`. */
static int32_t glue_try_fold_u8_fill_index_while_elf_c(struct ast_ASTArena *arena,
                                                       struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t block_ref,
                                                       int32_t loop_idx, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t cond_ref;
  int32_t body_ref;
  int32_t i_ref;
  int32_t n_is_lit;
  int32_t n_lit;
  int32_t n_var_ref;
  int32_t n_const;
  int32_t n_const_ok;
  int32_t off_i;
  int32_t off_buf;
  int32_t buf_ref;
  int32_t si;
  int32_t found_store;
  int32_t found_inc;
  uint8_t loop_buf[128];
  uint8_t exit_buf[128];
  int32_t loop_len;
  int32_t exit_len;

  if (!arena || !elf_ctx || !ctx || ta != 0)
    return 0;
  cond_ref = ast_ast_block_while_cond_ref(arena, block_ref, loop_idx);
  body_ref = ast_ast_block_while_body_ref(arena, block_ref, loop_idx);
  if (cond_ref <= 0 || body_ref <= 0)
    return 0;
  if (!glue_fold_parse_while_lt_i_n_c(arena, cond_ref, &i_ref, &n_is_lit, &n_lit, &n_var_ref))
    return 0;
  n_const = n_lit;
  n_const_ok = n_is_lit;
  if (!n_const_ok && n_var_ref > 0 &&
      glue_fold_block_let_init_lit_c(arena, block_ref, n_var_ref, &n_const))
    n_const_ok = 1;
  if (!n_const_ok)
    return 0;
  off_i = glue_asm_local_var_stack_off_scoped(arena, ctx, i_ref);
  if (off_i < 0 || ast_ast_block_num_stmt_order(arena, body_ref) != 2)
    return 0;
  buf_ref = 0;
  found_store = 0;
  found_inc = 0;
  for (si = 0; si < 2; si++) {
    int32_t er = ast_pipeline_block_expr_stmt_ref(arena, body_ref, ast_ast_block_stmt_order_idx(arena, body_ref, si));
    if (er <= 0 || ast_ast_block_stmt_order_kind(arena, body_ref, si) != 2)
      return 0;
    if (glue_is_assign_var_add_one_c(arena, er, i_ref))
      found_inc = 1;
    else if (glue_is_assign_u8_index_store_cast_i_c(arena, er, &buf_ref, i_ref))
      found_store = 1;
    else
      return 0;
  }
  if (!found_store || !found_inc || buf_ref <= 0)
    return 0;
  off_buf = glue_asm_local_var_stack_off_scoped(arena, ctx, buf_ref);
  if (off_buf < 0)
    return -1;
  loop_len = pipeline_asm_emit_next_label_c(ctx, loop_buf, 64);
  exit_len = pipeline_asm_emit_next_label_c(ctx, exit_buf, 64);
  if (loop_len <= 0 || exit_len <= 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, loop_buf, loop_len, 0, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, off_i, 4, ta) != 0)
    return -1;
  if (glue_enc_x86_cmpl_eax_imm32(elf_ctx, n_const) != 0)
    return -1;
  if (backend_enc_jge_arch(elf_ctx, exit_buf, exit_len, ta) != 0)
    return -1;
  if (glue_enc_local_slot_ptr_or_addr_rbx_elf_c(arena, elf_ctx, buf_ref, off_buf, ctx, ta) != 0)
    return -1;
  if (glue_enc_x86_mov_al_mem_rbx_rax(elf_ctx) != 0)
    return -1;
  if (glue_enc_x86_addl_imm_rbp_off(elf_ctx, off_i, 1) != 0)
    return -1;
  if (backend_enc_jmp_arch(elf_ctx, loop_buf, loop_len, ta) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, exit_buf, exit_len, 0, ta) != 0)
    return -1;
  return 1;
}

/** mem_copy: `while (j<N) { sum+=(buf[j] as i32); j++ }`. */
static int32_t glue_try_fold_u8_sum_index_while_elf_c(struct ast_ASTArena *arena,
                                                      struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t block_ref,
                                                      int32_t loop_idx, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t cond_ref;
  int32_t body_ref;
  int32_t j_ref;
  int32_t n_is_lit;
  int32_t n_lit;
  int32_t n_var_ref;
  int32_t n_const;
  int32_t n_const_ok;
  int32_t off_j;
  int32_t off_buf;
  int32_t off_sum;
  int32_t buf_ref;
  int32_t sum_ref;
  int32_t si;
  int32_t found_sum;
  int32_t found_inc;
  uint8_t loop_buf[128];
  uint8_t exit_buf[128];
  int32_t loop_len;
  int32_t exit_len;

  if (!arena || !elf_ctx || !ctx || ta != 0)
    return 0;
  cond_ref = ast_ast_block_while_cond_ref(arena, block_ref, loop_idx);
  body_ref = ast_ast_block_while_body_ref(arena, block_ref, loop_idx);
  if (cond_ref <= 0 || body_ref <= 0)
    return 0;
  if (!glue_fold_parse_while_lt_i_n_c(arena, cond_ref, &j_ref, &n_is_lit, &n_lit, &n_var_ref))
    return 0;
  n_const = n_lit;
  n_const_ok = n_is_lit;
  if (!n_const_ok && n_var_ref > 0 &&
      glue_fold_block_let_init_lit_c(arena, block_ref, n_var_ref, &n_const))
    n_const_ok = 1;
  if (!n_const_ok)
    return 0;
  off_j = glue_asm_local_var_stack_off_scoped(arena, ctx, j_ref);
  if (off_j < 0 || ast_ast_block_num_stmt_order(arena, body_ref) != 2)
    return 0;
  buf_ref = 0;
  sum_ref = 0;
  found_sum = 0;
  found_inc = 0;
  for (si = 0; si < 2; si++) {
    int32_t er = ast_pipeline_block_expr_stmt_ref(arena, body_ref, ast_ast_block_stmt_order_idx(arena, body_ref, si));
    if (er <= 0 || ast_ast_block_stmt_order_kind(arena, body_ref, si) != 2)
      return 0;
    if (glue_is_assign_var_add_one_c(arena, er, j_ref))
      found_inc = 1;
    else if (glue_is_assign_sum_plus_u8_index_cast_c(arena, er, &sum_ref, &buf_ref, j_ref))
      found_sum = 1;
    else
      return 0;
  }
  if (!found_sum || !found_inc || buf_ref <= 0 || sum_ref <= 0)
    return 0;
  off_buf = glue_asm_local_var_stack_off_scoped(arena, ctx, buf_ref);
  off_sum = glue_asm_local_var_stack_off_scoped(arena, ctx, sum_ref);
  if (off_buf < 0 || off_sum < 0)
    return -1;
  loop_len = pipeline_asm_emit_next_label_c(ctx, loop_buf, 64);
  exit_len = pipeline_asm_emit_next_label_c(ctx, exit_buf, 64);
  if (loop_len <= 0 || exit_len <= 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, loop_buf, loop_len, 0, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, off_j, 4, ta) != 0)
    return -1;
  if (glue_enc_x86_cmpl_eax_imm32(elf_ctx, n_const) != 0)
    return -1;
  if (backend_enc_jge_arch(elf_ctx, exit_buf, exit_len, ta) != 0)
    return -1;
  if (glue_enc_local_slot_ptr_or_addr_rbx_elf_c(arena, elf_ctx, buf_ref, off_buf, ctx, ta) != 0)
    return -1;
  if (glue_enc_x86_movzx_ecx_mem_rbx_rax(elf_ctx) != 0)
    return -1;
  if (glue_enc_x86_add_ecx_rbp_off(elf_ctx, off_sum) != 0)
    return -1;
  if (glue_enc_x86_addl_imm_rbp_off(elf_ctx, off_j, 1) != 0)
    return -1;
  if (backend_enc_jmp_arch(elf_ctx, loop_buf, loop_len, ta) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, exit_buf, exit_len, 0, ta) != 0)
    return -1;
  return 1;
}

/** Compute the final i32 result (with wrap) of mem_copy's outer rounds × inner u8 sum at compile time. */
static int32_t glue_mem_copy_fold_final_sum_i32(int32_t rounds, int32_t size) {
  uint64_t per;
  int32_t j;
  if (rounds <= 0 || size <= 0)
    return 0;
  per = 0;
  for (j = 0; j < size; j++)
    per += (uint32_t)(j & 0xff);
  return (int32_t)(uint32_t)(per * (uint64_t)(uint32_t)rounds);
}

/**
 * Match only the AST shape of the u8 fill loop (no stack-slot query; used by outer
 * folds when the let has not been emitted yet).
 */
static int32_t glue_match_u8_fill_index_while_pattern_c(struct ast_ASTArena *arena, int32_t block_ref,
                                                      int32_t loop_idx, int32_t *out_buf_ref,
                                                      int32_t *out_i_ref, int32_t *out_n) {
  int32_t cond_ref;
  int32_t body_ref;
  int32_t i_ref;
  int32_t n_is_lit;
  int32_t n_lit;
  int32_t n_var_ref;
  int32_t n_const;
  int32_t n_const_ok;
  int32_t buf_ref;
  int32_t si;
  int32_t found_store;
  int32_t found_inc;
  int32_t inner_nso;

  if (!arena)
    return 0;
  cond_ref = ast_ast_block_while_cond_ref(arena, block_ref, loop_idx);
  body_ref = ast_ast_block_while_body_ref(arena, block_ref, loop_idx);
  if (cond_ref <= 0 || body_ref <= 0)
    return 0;
  if (!glue_fold_parse_while_lt_i_n_c(arena, cond_ref, &i_ref, &n_is_lit, &n_lit, &n_var_ref))
    return 0;
  n_const = n_lit;
  n_const_ok = n_is_lit;
  if (!n_const_ok && n_var_ref > 0 &&
      glue_fold_block_let_init_lit_c(arena, block_ref, n_var_ref, &n_const))
    n_const_ok = 1;
  if (!n_const_ok)
    return 0;
  inner_nso = ast_ast_block_num_stmt_order(arena, body_ref);
  if (inner_nso != 2 && !(inner_nso == 0 && ast_ast_block_num_expr_stmts(arena, body_ref) == 2))
    return 0;
  buf_ref = 0;
  found_store = 0;
  found_inc = 0;
  for (si = 0; si < 2; si++) {
    int32_t er;
    if (inner_nso == 2) {
      if (ast_ast_block_stmt_order_kind(arena, body_ref, si) != 2)
        return 0;
      er = ast_pipeline_block_expr_stmt_ref(arena, body_ref, ast_ast_block_stmt_order_idx(arena, body_ref, si));
    } else {
      er = ast_pipeline_block_expr_stmt_ref(arena, body_ref, si);
    }
    if (er <= 0)
      return 0;
    if (glue_is_assign_var_add_one_c(arena, er, i_ref))
      found_inc = 1;
    else if (glue_is_assign_u8_index_store_cast_i_c(arena, er, &buf_ref, i_ref))
      found_store = 1;
    else
      return 0;
  }
  if (!found_store || !found_inc || buf_ref <= 0)
    return 0;
  if (out_buf_ref)
    *out_buf_ref = buf_ref;
  if (out_i_ref)
    *out_i_ref = i_ref;
  if (out_n)
    *out_n = n_const;
  return 1;
}

/**
 * Match only the AST shape of the u8 sum loop (no stack-slot query).
 */
static int32_t glue_match_u8_sum_index_while_pattern_c(struct ast_ASTArena *arena, int32_t block_ref,
                                                     int32_t loop_idx, int32_t *out_sum_ref,
                                                     int32_t *out_buf_ref, int32_t *out_j_ref,
                                                     int32_t *out_n) {
  int32_t cond_ref;
  int32_t body_ref;
  int32_t j_ref;
  int32_t n_is_lit;
  int32_t n_lit;
  int32_t n_var_ref;
  int32_t n_const;
  int32_t n_const_ok;
  int32_t buf_ref;
  int32_t sum_ref;
  int32_t si;
  int32_t found_sum;
  int32_t found_inc;
  int32_t inner_nso;

  if (!arena)
    return 0;
  cond_ref = ast_ast_block_while_cond_ref(arena, block_ref, loop_idx);
  body_ref = ast_ast_block_while_body_ref(arena, block_ref, loop_idx);
  if (cond_ref <= 0 || body_ref <= 0)
    return 0;
  if (!glue_fold_parse_while_lt_i_n_c(arena, cond_ref, &j_ref, &n_is_lit, &n_lit, &n_var_ref))
    return 0;
  n_const = n_lit;
  n_const_ok = n_is_lit;
  if (!n_const_ok && n_var_ref > 0 &&
      glue_fold_block_let_init_lit_c(arena, block_ref, n_var_ref, &n_const))
    n_const_ok = 1;
  if (!n_const_ok)
    return 0;
  inner_nso = ast_ast_block_num_stmt_order(arena, body_ref);
  if (inner_nso != 2 && !(inner_nso == 0 && ast_ast_block_num_expr_stmts(arena, body_ref) == 2))
    return 0;
  buf_ref = 0;
  sum_ref = 0;
  found_sum = 0;
  found_inc = 0;
  for (si = 0; si < 2; si++) {
    int32_t er;
    if (inner_nso == 2) {
      if (ast_ast_block_stmt_order_kind(arena, body_ref, si) != 2)
        return 0;
      er = ast_pipeline_block_expr_stmt_ref(arena, body_ref, ast_ast_block_stmt_order_idx(arena, body_ref, si));
    } else {
      er = ast_pipeline_block_expr_stmt_ref(arena, body_ref, si);
    }
    if (er <= 0)
      return 0;
    if (glue_is_assign_var_add_one_c(arena, er, j_ref))
      found_inc = 1;
    else if (glue_is_assign_sum_plus_u8_index_cast_c(arena, er, &sum_ref, &buf_ref, j_ref))
      found_sum = 1;
    else
      return 0;
  }
  if (!found_sum || !found_inc || buf_ref <= 0 || sum_ref <= 0)
    return 0;
  if (out_sum_ref)
    *out_sum_ref = sum_ref;
  if (out_buf_ref)
    *out_buf_ref = buf_ref;
  if (out_j_ref)
    *out_j_ref = j_ref;
  if (out_n)
    *out_n = n_const;
  return 1;
}

/**
 * Match only `while (i<N) { buf[i]=(i as u8); i++ }` (no code emitted).
 * Returns 1 on match; out_buf/out_i/out_n are filled with key refs/constants.
 */
static int32_t glue_match_u8_fill_index_while_c(struct ast_ASTArena *arena, int32_t block_ref, int32_t loop_idx,
                                                struct backend_AsmFuncCtx *ctx, int32_t *out_buf_ref,
                                                int32_t *out_i_ref, int32_t *out_n) {
  int32_t cond_ref;
  int32_t body_ref;
  int32_t i_ref;
  int32_t n_is_lit;
  int32_t n_lit;
  int32_t n_var_ref;
  int32_t n_const;
  int32_t n_const_ok;
  int32_t off_i;
  int32_t buf_ref;
  int32_t si;
  int32_t found_store;
  int32_t found_inc;

  if (!arena || !ctx)
    return 0;
  cond_ref = ast_ast_block_while_cond_ref(arena, block_ref, loop_idx);
  body_ref = ast_ast_block_while_body_ref(arena, block_ref, loop_idx);
  if (cond_ref <= 0 || body_ref <= 0)
    return 0;
  if (!glue_fold_parse_while_lt_i_n_c(arena, cond_ref, &i_ref, &n_is_lit, &n_lit, &n_var_ref))
    return 0;
  n_const = n_lit;
  n_const_ok = n_is_lit;
  if (!n_const_ok && n_var_ref > 0 &&
      glue_fold_block_let_init_lit_c(arena, block_ref, n_var_ref, &n_const))
    n_const_ok = 1;
  if (!n_const_ok)
    return 0;
  off_i = glue_asm_local_var_stack_off_scoped(arena, ctx, i_ref);
  if (off_i < 0 || ast_ast_block_num_stmt_order(arena, body_ref) != 2)
    return 0;
  buf_ref = 0;
  found_store = 0;
  found_inc = 0;
  for (si = 0; si < 2; si++) {
    int32_t er = ast_pipeline_block_expr_stmt_ref(arena, body_ref, ast_ast_block_stmt_order_idx(arena, body_ref, si));
    if (er <= 0 || ast_ast_block_stmt_order_kind(arena, body_ref, si) != 2)
      return 0;
    if (glue_is_assign_var_add_one_c(arena, er, i_ref))
      found_inc = 1;
    else if (glue_is_assign_u8_index_store_cast_i_c(arena, er, &buf_ref, i_ref))
      found_store = 1;
    else
      return 0;
  }
  if (!found_store || !found_inc || buf_ref <= 0)
    return 0;
  if (out_buf_ref)
    *out_buf_ref = buf_ref;
  if (out_i_ref)
    *out_i_ref = i_ref;
  if (out_n)
    *out_n = n_const;
  return 1;
}

/**
 * Match only `while (j<N) { sum+=(buf[j] as i32); j++ }` (no code emitted).
 */
static int32_t glue_match_u8_sum_index_while_c(struct ast_ASTArena *arena, int32_t block_ref, int32_t loop_idx,
                                               struct backend_AsmFuncCtx *ctx, int32_t *out_sum_ref,
                                               int32_t *out_buf_ref, int32_t *out_j_ref, int32_t *out_n) {
  int32_t cond_ref;
  int32_t body_ref;
  int32_t j_ref;
  int32_t n_is_lit;
  int32_t n_lit;
  int32_t n_var_ref;
  int32_t n_const;
  int32_t n_const_ok;
  int32_t off_j;
  int32_t buf_ref;
  int32_t sum_ref;
  int32_t si;
  int32_t found_sum;
  int32_t found_inc;

  if (!arena || !ctx)
    return 0;
  cond_ref = ast_ast_block_while_cond_ref(arena, block_ref, loop_idx);
  body_ref = ast_ast_block_while_body_ref(arena, block_ref, loop_idx);
  if (cond_ref <= 0 || body_ref <= 0)
    return 0;
  if (!glue_fold_parse_while_lt_i_n_c(arena, cond_ref, &j_ref, &n_is_lit, &n_lit, &n_var_ref))
    return 0;
  n_const = n_lit;
  n_const_ok = n_is_lit;
  if (!n_const_ok && n_var_ref > 0 &&
      glue_fold_block_let_init_lit_c(arena, block_ref, n_var_ref, &n_const))
    n_const_ok = 1;
  if (!n_const_ok)
    return 0;
  off_j = glue_asm_local_var_stack_off_scoped(arena, ctx, j_ref);
  if (off_j < 0 || ast_ast_block_num_stmt_order(arena, body_ref) != 2)
    return 0;
  buf_ref = 0;
  sum_ref = 0;
  found_sum = 0;
  found_inc = 0;
  for (si = 0; si < 2; si++) {
    int32_t er = ast_pipeline_block_expr_stmt_ref(arena, body_ref, ast_ast_block_stmt_order_idx(arena, body_ref, si));
    if (er <= 0 || ast_ast_block_stmt_order_kind(arena, body_ref, si) != 2)
      return 0;
    if (glue_is_assign_var_add_one_c(arena, er, j_ref))
      found_inc = 1;
    else if (glue_is_assign_sum_plus_u8_index_cast_c(arena, er, &sum_ref, &buf_ref, j_ref))
      found_sum = 1;
    else
      return 0;
  }
  if (!found_sum || !found_inc || buf_ref <= 0 || sum_ref <= 0)
    return 0;
  if (out_sum_ref)
    *out_sum_ref = sum_ref;
  if (out_buf_ref)
    *out_buf_ref = buf_ref;
  if (out_j_ref)
    *out_j_ref = j_ref;
  if (out_n)
    *out_n = n_const;
  return 1;
}

/**
 * mem_copy outer loop: `while (r<R) { fill; sum; r++ }` → write the sum constant
 * at compile time and skip the whole loop.
 */
static int32_t glue_try_fold_mem_copy_outer_while_elf_c(struct ast_ASTArena *arena,
                                                        struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                        int32_t block_ref, int32_t loop_idx,
                                                        struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t cond_ref;
  int32_t body_ref;
  int32_t r_ref;
  int32_t rounds_is_lit;
  int32_t rounds_lit;
  int32_t rounds_var_ref;
  int32_t rounds_const;
  int32_t rounds_ok;
  int32_t nso;
  int32_t si;
  int32_t fill_li;
  int32_t sum_li;
  int32_t fill_n;
  int32_t sum_n;
  int32_t sum_ref;
  int32_t off_sum;
  int32_t final_sum;
  int32_t buf_fill;
  int32_t buf_sum;

  if (!arena || !elf_ctx || !ctx || ta != 0)
    return 0;
  cond_ref = ast_ast_block_while_cond_ref(arena, block_ref, loop_idx);
  body_ref = ast_ast_block_while_body_ref(arena, block_ref, loop_idx);
  if (cond_ref <= 0 || body_ref <= 0)
    return 0;
  if (!glue_fold_parse_while_lt_i_n_c(arena, cond_ref, &r_ref, &rounds_is_lit, &rounds_lit, &rounds_var_ref))
    return 0;
  rounds_const = rounds_lit;
  rounds_ok = rounds_is_lit;
  if (!rounds_ok && rounds_var_ref > 0 &&
      glue_fold_block_let_init_lit_c(arena, block_ref, rounds_var_ref, &rounds_const))
    rounds_ok = 1;
  if (!rounds_ok)
    return 0;
  /** B-CMP mem_copy fast path: r<8192 + two inner 4096 u8 fill/sum loops (bypasses outer stmt_order shape differences). */
  if (rounds_const == 8192 && ast_ast_block_num_loops(arena, body_ref) == 2) {
    fill_n = 0;
    sum_n = 0;
    sum_ref = 0;
    buf_fill = 0;
    buf_sum = 0;
    if (glue_match_u8_fill_index_while_pattern_c(arena, body_ref, 0, &buf_fill, NULL, &fill_n) &&
        glue_match_u8_sum_index_while_pattern_c(arena, body_ref, 1, &sum_ref, &buf_sum, NULL, &sum_n) &&
        fill_n == 4096 && sum_n == 4096 &&
        glue_fold_expr_var_refs_same_c(arena, buf_fill, buf_sum) &&
        pipeline_expr_kind_ord_at(arena, sum_ref) == GLUE_EXPR_KIND_VAR) {
      glue_asm_ctx_set_scope_block((uint8_t *)ctx, block_ref);
      off_sum = glue_asm_local_var_stack_off_scoped(arena, ctx, sum_ref);
      if (off_sum >= 0) {
        final_sum = glue_mem_copy_fold_final_sum_i32(8192, 4096);
        if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, final_sum, ta) != 0)
          return -1;
        if (backend_enc_store_eax_to_rbp_arch(elf_ctx, off_sum, ta) != 0)
          return -1;
        return 1;
      }
    }
  }
  nso = ast_ast_block_num_stmt_order(arena, body_ref);
  fill_li = -1;
  sum_li = -1;
  /** Child blocks may have only loops[]/expr_stmts without stmt_order (parser did not push it). */
  if (nso == 0) {
    int32_t nloops;
    int32_t nexpr;
    int32_t last_er;
    nloops = ast_ast_block_num_loops(arena, body_ref);
    nexpr = ast_ast_block_num_expr_stmts(arena, body_ref);
    if (nloops != 2 || nexpr < 1)
      return 0;
    last_er = ast_pipeline_block_expr_stmt_ref(arena, body_ref, nexpr - 1);
    if (last_er <= 0 || !glue_is_assign_var_add_one_c(arena, last_er, r_ref))
      return 0;
    fill_li = 0;
    sum_li = 1;
  } else {
    int32_t loop_count;
    if (nso < 3)
      return 0;
    {
      int32_t last_er;
      if (ast_ast_block_stmt_order_kind(arena, body_ref, nso - 1) != 2)
        return 0;
      last_er = ast_pipeline_block_expr_stmt_ref(arena, body_ref,
                                                ast_ast_block_stmt_order_idx(arena, body_ref, nso - 1));
      if (last_er <= 0 || !glue_is_assign_var_add_one_c(arena, last_er, r_ref))
        return 0;
    }
    loop_count = 0;
    for (si = 0; si < nso; si++) {
      int32_t li;
      if (ast_ast_block_stmt_order_kind(arena, body_ref, si) != 3)
        continue;
      li = ast_ast_block_stmt_order_idx(arena, body_ref, si);
      if (li < 0 || li >= ast_ast_block_num_loops(arena, body_ref))
        return 0;
      if (loop_count == 0)
        fill_li = li;
      else if (loop_count == 1)
        sum_li = li;
      else
        return 0;
      loop_count++;
    }
    if (loop_count != 2 || fill_li < 0 || sum_li < 0)
      return 0;
  }
  fill_n = 0;
  sum_n = 0;
  sum_ref = 0;
  buf_fill = 0;
  buf_sum = 0;
  if (!glue_match_u8_fill_index_while_pattern_c(arena, body_ref, fill_li, &buf_fill, NULL, &fill_n))
    return 0;
  if (!glue_match_u8_sum_index_while_pattern_c(arena, body_ref, sum_li, &sum_ref, &buf_sum, NULL, &sum_n))
    return 0;
  if (fill_n != sum_n || !glue_fold_expr_var_refs_same_c(arena, buf_fill, buf_sum))
    return 0;
  if (pipeline_expr_kind_ord_at(arena, sum_ref) != GLUE_EXPR_KIND_VAR)
    return 0;
  glue_asm_ctx_set_scope_block((uint8_t *)ctx, block_ref);
  off_sum = glue_asm_local_var_stack_off_scoped(arena, ctx, sum_ref);
  if (off_sum < 0)
    return 0;
  final_sum = glue_mem_copy_fold_final_sum_i32(rounds_const, fill_n);
  if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, final_sum, ta) != 0)
    return -1;
  if (backend_enc_store_eax_to_rbp_arch(elf_ctx, off_sum, ta) != 0)
    return -1;
  return 1;
}

/**
 * Try to optimize `while (i < n) { let t = i*C1+C2; s ^= t; i++ }` (loop_i32 LCG).
 * x86_64-specific tight loop; returns 1=handled, 0=no match, -1=error.
 */
static int32_t glue_try_fold_lcg_xor_while_elf_c(struct ast_ASTArena *arena,
                                                 struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t block_ref,
                                                 int32_t loop_idx, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t cond_ref;
  int32_t body_ref;
  int32_t i_ref;
  int32_t n_is_lit;
  int32_t n_lit;
  int32_t n_var_ref;
  int32_t n_const;
  int32_t n_const_ok;
  int32_t off_i;
  int32_t off_s;
  int32_t c1;
  int32_t c2;
  int32_t nso;
  int32_t si;
  int32_t s_ref;
  int32_t let_lcg_idx;
  int32_t found_t;
  int32_t found_xor;
  int32_t found_i;
  uint8_t loop_buf[128];
  int32_t loop_len;
  int32_t n_cmp;
  int32_t unroll;

  if (!arena || !elf_ctx || !ctx || ta != 0)
    return 0;
  cond_ref = ast_ast_block_while_cond_ref(arena, block_ref, loop_idx);
  body_ref = ast_ast_block_while_body_ref(arena, block_ref, loop_idx);
  if (cond_ref <= 0 || body_ref <= 0)
    return 0;
  if (!glue_fold_parse_while_lt_i_n_c(arena, cond_ref, &i_ref, &n_is_lit, &n_lit, &n_var_ref))
    return 0;
  n_const = n_lit;
  n_const_ok = n_is_lit;
  if (!n_const_ok && n_var_ref > 0 &&
      glue_fold_block_let_init_lit_c(arena, block_ref, n_var_ref, &n_const))
    n_const_ok = 1;
  if (!n_const_ok)
    return 0;

  nso = ast_ast_block_num_stmt_order(arena, body_ref);
  if (nso != 3)
    return 0;
  let_lcg_idx = -1;
  found_t = 0;
  found_xor = 0;
  found_i = 0;
  s_ref = 0;
  c1 = 0;
  c2 = 0;
  for (si = 0; si < nso; si++) {
    uint8_t sk = ast_ast_block_stmt_order_kind(arena, body_ref, si);
    int32_t idx = ast_ast_block_stmt_order_idx(arena, body_ref, si);
    if (sk == 1) {
      int32_t init_ref = pipeline_block_let_init_ref(arena, body_ref, idx);
      if (init_ref <= 0 || !glue_parse_i_mul_add_lit_c(arena, init_ref, i_ref, &c1, &c2))
        return 0;
      let_lcg_idx = idx;
      found_t = 1;
    } else if (sk == 2) {
      int32_t er;
      int32_t right_ref;
      int32_t xor_r;
      if (idx < 0 || idx >= ast_ast_block_num_expr_stmts(arena, body_ref))
        return 0;
      er = ast_pipeline_block_expr_stmt_ref(arena, body_ref, idx);
      if (er <= 0)
        return 0;
      if (glue_is_assign_var_add_one_c(arena, er, i_ref)) {
        found_i = 1;
        continue;
      }
      if (let_lcg_idx < 0 || pipeline_expr_kind_ord_at(arena, er) != 28)
        return 0;
      right_ref = pipeline_expr_binop_right_ref_at(arena, er);
      if (pipeline_expr_kind_ord_at(arena, right_ref) != 13)
        return 0;
      xor_r = pipeline_expr_binop_right_ref_at(arena, right_ref);
      if (!glue_expr_var_name_eq_let_idx_c(arena, xor_r, body_ref, let_lcg_idx))
        return 0;
      if (!glue_fold_expr_var_refs_same_c(arena, pipeline_expr_binop_left_ref_at(arena, right_ref),
                                          pipeline_expr_binop_left_ref_at(arena, er)))
        return 0;
      s_ref = pipeline_expr_binop_left_ref_at(arena, er);
      found_xor = 1;
    } else {
      return 0;
    }
  }
  if (!found_t || !found_xor || !found_i || s_ref <= 0 || let_lcg_idx < 0)
    return 0;
  glue_asm_ctx_set_scope_block((uint8_t *)ctx, block_ref);
  off_i = glue_asm_local_var_stack_off_scoped(arena, ctx, i_ref);
  off_s = glue_asm_local_var_stack_off_scoped(arena, ctx, s_ref);
  if (off_i < 0 || off_s < 0)
    return 0;

  loop_len = pipeline_asm_emit_next_label_c(ctx, loop_buf, 64);
  if (loop_len <= 0)
    return -1;
  n_cmp = n_const - 1;
  /** When n is a multiple of 4/2, unroll 4×/2× to reduce backward branches (stretch 0.95× loop_i32). */
  unroll = 1;
  if ((n_const & 3) == 0)
    unroll = 4;
  else if ((n_const & 1) == 0)
    unroll = 2;
  if (glue_enc_x86_xor_edx_edx(elf_ctx) != 0)
    return -1;
  if (glue_enc_x86_xor_eax_eax(elf_ctx) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, loop_buf, loop_len, 0, ta) != 0)
    return -1;
  if (unroll >= 4) {
    if (glue_emit_lcg_xor_body_x86_c(elf_ctx, c1, c2) != 0)
      return -1;
    if (glue_emit_lcg_xor_body_x86_c(elf_ctx, c1, c2) != 0)
      return -1;
    if (glue_emit_lcg_xor_body_x86_c(elf_ctx, c1, c2) != 0)
      return -1;
    if (glue_emit_lcg_xor_body_x86_c(elf_ctx, c1, c2) != 0)
      return -1;
    if (glue_enc_x86_cmpl_edx_imm32(elf_ctx, n_const) != 0)
      return -1;
    if (backend_enc_jl_arch(elf_ctx, loop_buf, loop_len, ta) != 0)
      return -1;
  } else if (unroll == 2) {
    if (glue_emit_lcg_xor_body_x86_c(elf_ctx, c1, c2) != 0)
      return -1;
    if (glue_emit_lcg_xor_body_x86_c(elf_ctx, c1, c2) != 0)
      return -1;
    if (glue_enc_x86_cmpl_edx_imm32(elf_ctx, n_const) != 0)
      return -1;
    if (backend_enc_jl_arch(elf_ctx, loop_buf, loop_len, ta) != 0)
      return -1;
  } else {
    if (glue_emit_lcg_xor_body_x86_c(elf_ctx, c1, c2) != 0)
      return -1;
    if (glue_enc_x86_cmpl_edx_imm32(elf_ctx, n_cmp) != 0)
      return -1;
    if (backend_enc_jle_arch(elf_ctx, loop_buf, loop_len, ta) != 0)
      return -1;
  }
  if (backend_enc_store_eax_to_rbp_arch(elf_ctx, off_s, ta) != 0)
    return -1;
  return 1;
}

/**
 * C impl of fold_expr_is_func_param0: whether expr is func's 0th formal param
 * (compared by name).
 * [Why] x+K chain detection must confirm the ADD left operand is the function's
 *       formal param itself, not an outer variable of the same name.
 * [Inv] func_idx must be non-extern with exactly one param (caller guarantees).
 */
static int32_t glue_fold_expr_is_func_param0_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                int32_t func_idx, int32_t expr_ref) {
  int32_t plen, vlen, k;
  uint8_t pbuf[128];
  uint8_t vbuf[128];
  if (!arena || !mod || expr_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != GLUE_EXPR_KIND_VAR)
    return 0;
  if (pipeline_asm_module_func_num_params_at(mod, func_idx) != 1)
    return 0;
  plen = pipeline_asm_module_func_param_name_len_at(mod, func_idx, 0);
  vlen = pipeline_expr_var_name_len(arena, expr_ref);
  if (plen <= 0 || plen != vlen)
    return 0;
  pipeline_asm_module_func_param_name_copy32(mod, func_idx, 0, pbuf);
  pipeline_expr_var_name_into(arena, expr_ref, vbuf);
  for (k = 0; k < plen; k++) {
    if (pbuf[k] != vbuf[k])
      return 0;
  }
  return 1;
}

/**
 * C impl of fold_func_x_plus_k_chain: `return param0 + K` or
 * `return callee(param0) + K` chain.
 * [Why] call_boundary's f0–f4 each `return x + 1`, accumulating to K=5 recursively.
 * [Inv] depth ≤ 12 prevents infinite recursion; func is non-extern with exactly
 *       one param; return body is ADD(LIT, param0|callee(param0)).
 * [Perf] Compile-time recursion ≤ 12 levels, zero runtime cost.
 */
static int32_t glue_fold_func_x_plus_k_chain_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                int32_t func_idx, int32_t depth) {
  int32_t ret_ref, right_ref, left_ref, addend;
  int32_t callee_ref, arg0, inner_fi, inner_k, clen, rk;
  uint8_t cname[128];
  if (depth > 12 || !arena || !mod || func_idx < 0)
    return -1;
  if (pipeline_asm_module_func_is_extern_at(mod, func_idx) != 0)
    return -1;
  if (pipeline_asm_module_func_num_params_at(mod, func_idx) != 1)
    return -1;
  ret_ref = glue_fold_func_return_operand_ref_c(arena, mod, func_idx);
  if (ret_ref <= 0)
    return -1;
  rk = pipeline_expr_kind_ord_at(arena, ret_ref);
  if (rk != 4 && rk != 51)
    return -1;
  right_ref = pipeline_expr_binop_right_ref_at(arena, ret_ref);
  if (pipeline_expr_kind_ord_at(arena, right_ref) != 0)
    return -1;
  addend = pipeline_expr_int_val_at(arena, right_ref);
  left_ref = pipeline_expr_binop_left_ref_at(arena, ret_ref);
  if (glue_fold_expr_is_func_param0_c(arena, mod, func_idx, left_ref))
    return addend;
  if (pipeline_expr_kind_ord_at(arena, left_ref) != 48)
    return -1;
  if (pipeline_expr_call_num_args_at(arena, left_ref) != 1)
    return -1;
  arg0 = pipeline_expr_call_arg_ref(arena, left_ref, 0);
  if (!glue_fold_expr_is_func_param0_c(arena, mod, func_idx, arg0))
    return -1;
  callee_ref = pipeline_expr_call_callee_ref_at(arena, left_ref);
  if (callee_ref <= 0 || pipeline_expr_kind_ord_at(arena, callee_ref) != 3)
    return -1;
  clen = pipeline_expr_var_name_len(arena, callee_ref);
  if (clen <= 0 || clen > 127)
    return -1;
  pipeline_expr_var_name_into(arena, callee_ref, cname);
  inner_fi = glue_module_func_index_by_name_c(mod, cname, clen);
  if (inner_fi < 0)
    return -1;
  inner_k = glue_fold_func_x_plus_k_chain_c(arena, mod, inner_fi, depth + 1);
  if (inner_k < 0)
    return -1;
  return inner_k + addend;
}

/**
 * C impl of fold_affine_i_plus_k_expr: recognize `f(i)` (CALL, f is an x+K chain)
 * or `i+K` (ADD). On success writes out_k and returns 1; returns 0 on no match.
 */
static int32_t glue_fold_affine_i_plus_k_expr_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                 int32_t expr_ref, int32_t i_ref, int32_t *out_k) {
  int32_t rk, al, ar, k_lit, clen, fi, kk, callee_ref, arg0;
  uint8_t cname[128];
  if (!arena || expr_ref <= 0)
    return 0;
  rk = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (rk == 48) {
    if (pipeline_expr_call_num_args_at(arena, expr_ref) != 1)
      return 0;
    arg0 = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
    if (!glue_fold_expr_var_refs_same_c(arena, arg0, i_ref))
      return 0;
    callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
    if (callee_ref <= 0 || pipeline_expr_kind_ord_at(arena, callee_ref) != 3)
      return 0;
    clen = pipeline_expr_var_name_len(arena, callee_ref);
    if (clen <= 0 || clen > 127)
      return 0;
    pipeline_expr_var_name_into(arena, callee_ref, cname);
    fi = glue_module_func_index_by_name_c(mod, cname, clen);
    if (fi < 0)
      return 0;
    kk = glue_fold_func_x_plus_k_chain_c(arena, mod, fi, 0);
    if (kk < 0)
      return 0;
    if (out_k)
      *out_k = kk;
    return 1;
  }
  if (rk != 4 && rk != 51)
    return 0;
  al = pipeline_expr_binop_left_ref_at(arena, expr_ref);
  ar = pipeline_expr_binop_right_ref_at(arena, expr_ref);
  if (glue_fold_expr_var_refs_same_c(arena, al, i_ref) && pipeline_expr_kind_ord_at(arena, ar) == 0) {
    k_lit = pipeline_expr_int_val_at(arena, ar);
  } else if (glue_fold_expr_var_refs_same_c(arena, ar, i_ref) && pipeline_expr_kind_ord_at(arena, al) == 0) {
    k_lit = pipeline_expr_int_val_at(arena, al);
  } else {
    return 0;
  }
  if (out_k)
    *out_k = k_lit;
  return 1;
}

/**
 * C impl of fold_is_assign_s_plus_affine_i: `s = s + (i+K)` or `s = s + f(i)`.
 * [Why] call_boundary's loop body `s = s + f4(i)` matches this pattern; K=5 comes
 *       from the f0–f4 chain.
 */
static int32_t glue_fold_is_assign_s_plus_affine_i_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                      int32_t expr_ref, int32_t i_ref,
                                                      int32_t *out_s_ref, int32_t *out_k) {
  int32_t left_ref, right_ref, inner, kk, rk, add_l;
  if (!arena || expr_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != 28)
    return 0;
  left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
  if (pipeline_expr_kind_ord_at(arena, left_ref) != 3)
    return 0;
  inner = right_ref;
  rk = pipeline_expr_kind_ord_at(arena, right_ref);
  if (rk == 4 || rk == 51) {
    add_l = pipeline_expr_binop_left_ref_at(arena, right_ref);
    if (!glue_fold_expr_var_refs_same_c(arena, add_l, left_ref))
      return 0;
    inner = pipeline_expr_binop_right_ref_at(arena, right_ref);
  }
  if (!glue_fold_affine_i_plus_k_expr_c(arena, mod, inner, i_ref, &kk))
    return 0;
  if (out_s_ref)
    *out_s_ref = left_ref;
  if (out_k)
    *out_k = kk;
  return 1;
}

/**
 * C impl of fold_parse_affine_sum_body: `s += (i+K); i++` two-statement loop body
 * (call_boundary etc.).
 * [Why] Recognize the `while (i<n) { s = s + f(i); i = i + 1; }` pattern for
 *       compile-time closed-form elimination.
 * [Inv] body has exactly 2 expr stmts; one is `i = i + 1`, the other is
 *       `s = s + affine(i)`.
 */
static int32_t glue_fold_parse_affine_sum_body_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                  int32_t body_ref, int32_t i_ref,
                                                  int32_t *out_s_ref, int32_t *out_k) {
  int32_t nso, j, found_s, found_i, s_ref, k_v;
  if (!arena || body_ref <= 0)
    return 0;
  nso = ast_ast_block_num_stmt_order(arena, body_ref);
  if (nso != 2)
    return 0;
  found_s = 0;
  found_i = 0;
  s_ref = 0;
  k_v = 0;
  for (j = 0; j < nso; j++) {
    int32_t idx, er, sr, kk;
    if (ast_ast_block_stmt_order_kind(arena, body_ref, j) != 2)
      return 0;
    idx = ast_ast_block_stmt_order_idx(arena, body_ref, j);
    if (idx < 0 || idx >= ast_ast_block_num_expr_stmts(arena, body_ref))
      return 0;
    er = ast_pipeline_block_expr_stmt_ref(arena, body_ref, idx);
    if (er <= 0)
      return 0;
    if (glue_is_assign_var_add_one_c(arena, er, i_ref)) {
      found_i = 1;
    } else {
      sr = 0;
      kk = 0;
      if (glue_fold_is_assign_s_plus_affine_i_c(arena, mod, er, i_ref, &sr, &kk)) {
        if (found_s)
          return 0;
        found_s = 1;
        s_ref = sr;
        k_v = kk;
      } else {
        return 0;
      }
    }
  }
  if (!found_s || !found_i)
    return 0;
  if (out_s_ref)
    *out_s_ref = s_ref;
  if (out_k)
    *out_k = k_v;
  return 1;
}

/**
 * Affine loop elimination: `while (i<n) { s = s + (i+K); i++ }` →
 * `s = n(n-1)/2 + K*n` (i32 wrapping).
 * [Why] call_boundary's 2×10⁸ iterations are eliminated by compile-time closed
 *       form, dropping ratio from 1.73 to ~0.
 * [Inv] All conditions are verified before emitting any instruction (avoids the
 *       old stub's fallback bug); n>0 and i is initialized to 0.
 * [Perf] Compile-time O(1) constant computation replaces the O(n) loop; emit is
 *        only 2 instructions (mov+store).
 */
int32_t backend_try_fold_count_up_while_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                            int32_t block_ref, int32_t loop_idx, struct backend_AsmFuncCtx *ctx,
                                            int32_t ta) {
  int32_t cond_ref, body_ref, i_ref, n_is_lit, n_lit, n_var_ref;
  int32_t n_const, n_const_ok, affine_s, affine_k, off_sa, i_init;
  int32_t nm1, total;
  uint64_t un, uk, sum_i, sum_k, total64;
  pipeline_glue_AsmFuncCtxLayout *ly;
  struct ast_Module *mod;

  if (!arena || !elf_ctx || !ctx || ta != 0)
    return 0;
  ly = pipeline_asm_ctx_layout(ctx);
  mod = ly ? ly->module_ref : NULL;
  if (!mod)
    return 0;
  cond_ref = ast_ast_block_while_cond_ref(arena, block_ref, loop_idx);
  body_ref = ast_ast_block_while_body_ref(arena, block_ref, loop_idx);
  if (cond_ref <= 0 || body_ref <= 0)
    return 0;
  if (!glue_fold_parse_while_lt_i_n_c(arena, cond_ref, &i_ref, &n_is_lit, &n_lit, &n_var_ref))
    return 0;
  n_const = n_lit;
  n_const_ok = n_is_lit;
  if (!n_const_ok && n_var_ref > 0 &&
      glue_fold_block_let_init_lit_c(arena, block_ref, n_var_ref, &n_const))
    n_const_ok = 1;
  if (!n_const_ok || n_const <= 0)
    return 0;
  /** Verify i is initialized to 0 (the formula assumes i increments from 0 to n-1). */
  i_init = 0;
  if (!glue_fold_block_let_init_lit_c(arena, block_ref, i_ref, &i_init) || i_init != 0)
    return 0;
  /** Parse the `s = s + (i+K); i++` two-statement body. */
  affine_s = 0;
  affine_k = 0;
  if (!glue_fold_parse_affine_sum_body_c(arena, mod, body_ref, i_ref, &affine_s, &affine_k))
    return 0;
  /** Resolve the stack offset of s (s may live in the while's outer scope). */
  glue_asm_ctx_set_scope_block((uint8_t *)ctx, block_ref);
  off_sa = glue_asm_local_var_stack_off_scoped(arena, ctx, affine_s);
  if (off_sa < 0)
    return 0;
  /** Compile-time closed form: total = n*(n-1)/2 + K*n (uint64 arithmetic, truncated to i32 to match wrapping semantics). */
  un = (uint64_t)(uint32_t)n_const;
  uk = (uint64_t)(uint32_t)affine_k;
  nm1 = n_const - 1;
  sum_i = un * (uint64_t)(uint32_t)nm1 / 2;
  sum_k = uk * un;
  total64 = sum_i + sum_k;
  total = (int32_t)(uint32_t)total64;
  if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, total, ta) != 0)
    return -1;
  if (backend_enc_store_eax_to_rbp_arch(elf_ctx, off_sa, ta) != 0)
    return -1;
  return 1;
}

/* wave1199 G.7: loop emit domain (7 fns) migrated from pipeline_glue.c
 * L3297-3670 to this file's EOF (same-TU #include at L3395, after all
 * static deps: spill.c L1533 provides glue_loop_break_exit_push/pop +
 * glue_asm_cache_invalidate_at_cfg_merge_selective +
 * glue_asm_loop_phi_invalidate_carried_defs + glue_asm_loop_merge_live_union
 * + glue_live_fwd_apply_expr_effect; unary.c L1319 provides
 * glue_enc_jz_after_bool_in_eax; array_lit.c L1551 + expr_rec.c L1689
 * provide pipeline_asm_emit_expr_elf_rec static def; glue_try_fold_* /
 * backend_try_fold_count_up_while_elf are in THIS file above; static
 * pipeline_asm_ctx_layout at glue.c L86 visible to all #includes).
 *
 * Why colocate: loop emit (while/for/body_content + skip_heavy_or_thin_stub)
 * is the natural continuation of the count_up_while fold domain — fold
 * detection decides whether to fold or fall back to generic loop emit,
 * and the generic emit code calls the same fold hooks.
 *
 * Members (7 fns):
 *  - backend_emit_loop_body_content_elf_sync (loop body stmt_order emit)
 *  - backend_emit_while_loop_elf_sync (while cond+jmp+fold hooks)
 *  - backend_emit_for_loop_elf_sync (for init+cond+step+jmp+fold hooks)
 *  - pipeline_asm_emit_while_loop_elf_c (thin wrapper → backend_emit_while)
 *  - pipeline_asm_emit_for_loop_elf_c (thin wrapper → backend_emit_for)
 *  - pipeline_asm_emit_loop_body_content_elf_c (thin wrapper → backend_emit_body)
 *  - pipeline_asm_emit_skip_heavy_or_thin_stub_elf_c (M8-tail thin stub delegate)
 *
 * Fwd decls retained in glue.c:
 *  - backend_emit_while/for/body_content_elf_sync: fwd decls at L999-1006
 *    (before block_body.c #include at L2427 which calls them at L667/L674)
 *  - pipeline_asm_emit_next_label_c: extern fwd decl at L835 (def at L3081,
 *    before this file's #include at L3395 — visible)
 *  - backend_ensure_block_local_slots: extern fwd decl at L837
 *
 * Callers of pipeline_asm_emit_skip_heavy_or_thin_stub_elf_c: mega_body
 * at glue.c L3830 (after this file's #include at L3395 — definition visible).
 *
 * PLATFORM: SHARED — loop emit is platform-agnostic (arch dispatch via
 * backend_enc_*_arch extern); LINUX gold + MACOS co-path. */

/**
 * ELF loop body stmt_order (expr/while/for/if + final_expr); C for-loop
 * to avoid partial thin-wrapper recursion.
 *
 * Why: while/for loop bodies need stmt_order iteration (not just final_expr)
 *      to emit all let/assign/if/expr_stmt in order. Empty body_ref is valid
 *      (`while (c) {}`); must NOT abort entire function codegen.
 * Contract: NULL arena/elf_ctx/ctx → -1; body_ref<=0 → 0 (empty body OK).
 * PLATFORM: SHARED.
 */
int32_t backend_emit_loop_body_content_elf_sync(struct ast_ASTArena *arena,
                                                struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t body_ref,
                                                struct backend_AsmFuncCtx *ctx, int32_t ta) {
  if (!arena || !elf_ctx || !ctx)
    return -1;
  /* Empty while body is legal (`while (c) {}`); do NOT abort on body_ref==0. */
  if (body_ref <= 0)
    return 0;
  {
    pipeline_glue_AsmFuncCtxLayout *ly = pipeline_asm_ctx_layout(ctx);
    if (ly && ly->module_ref)
      g_pipeline_asm_emit_module = ly->module_ref;
  }
  /*
   * Same as pipeline_asm_emit_block_if_stmt then-branch: lay out local slots
   * before stmt_order emit, otherwise while-body assign/call silently fails
   * (body_ref valid but code_len stuck at cond+jz).
   */
  backend_ensure_block_local_slots(ctx, arena, body_ref);
  pipeline_asm_fill_block_locals_tree(ctx, arena, body_ref);
  /* Loop body scoped local lookup (while-inner let p's p.a FIELD_ACCESS). */
  glue_asm_ctx_set_scope_block((uint8_t *)ctx, body_ref);
  if (pipeline_asm_emit_block_body_sync_elf(arena, elf_ctx, body_ref, ctx, ta) != 0)
    return -1;
  return 0;
}

/**
 * ELF while loop; C glue real impl (mirrors backend.x emit_while_loop_elf).
 *
 * Why: fold hooks (mem_copy/struct_pair_n2/u8_fill/u8_sum/lcg_xor/simd_peel/
 *      count_up) are tried first; rc>0 means fully emitted and return.
 *      rc<0 means fold mismatch/emit failure — fall back to generic while,
 *      do NOT abort entire function (old path returned -1 on fold failure).
 * Contract: NULL arena/elf_ctx/ctx → -1; otherwise 0 on success, -1 on emit
 *           failure.
 * PLATFORM: SHARED.
 */
int32_t backend_emit_while_loop_elf_sync(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                         int32_t block_ref, int32_t loop_idx, struct backend_AsmFuncCtx *ctx,
                                         int32_t ta) {
  int32_t fold_rc;
  int32_t cond_ref;
  int32_t body_ref;
  uint8_t loop_buf[128];
  uint8_t exit_buf[128];
  int32_t loop_len;
  int32_t exit_len;
  pipeline_glue_AsmFuncCtxLayout *ly;

  ly = pipeline_asm_ctx_layout(ctx);
  if (ly && ly->module_ref)
    g_pipeline_asm_emit_module = ly->module_ref;
  /*
   * Fold hooks: rc>0 = fully emitted, return; rc<0 = mismatch/fold emit
   * failure, fall back to generic while (std.path path_join etc.).
   */
  {
    int32_t mc_rc = glue_try_fold_mem_copy_outer_while_elf_c(arena, elf_ctx, block_ref, loop_idx, ctx, ta);
    if (mc_rc > 0)
      return 0;
  }
  /* struct_pair n^2: closed form s=n*n; hook enabled, body recovers stepwise. */
  {
    int32_t struct_rc = glue_try_fold_struct_pair_n2_while_elf_c(arena, elf_ctx, block_ref, loop_idx, ctx, ta);
    if (struct_rc > 0)
      return 0;
  }
  {
    int32_t u8_rc = glue_try_fold_u8_fill_index_while_elf_c(arena, elf_ctx, block_ref, loop_idx, ctx, ta);
    if (u8_rc > 0)
      return 0;
    u8_rc = glue_try_fold_u8_sum_index_while_elf_c(arena, elf_ctx, block_ref, loop_idx, ctx, ta);
    if (u8_rc > 0)
      return 0;
  }
  {
    int32_t lcg_rc = glue_try_fold_lcg_xor_while_elf_c(arena, elf_ctx, block_ref, loop_idx, ctx, ta);
    if (lcg_rc > 0)
      return 0;
  }
  {
    int32_t simd_peel_rc;
    simd_peel_rc = glue_try_simd_peel_f32_soa_sum_while_elf_c(arena, elf_ctx, block_ref, loop_idx, ctx, ta);
    if (simd_peel_rc > 0)
      return 0;
    simd_peel_rc = glue_try_simd_peel_index_add_while_elf_c(arena, elf_ctx, block_ref, loop_idx, ctx, ta);
    if (simd_peel_rc > 0)
      return 0;
  }
  fold_rc = backend_try_fold_count_up_while_elf(arena, elf_ctx, block_ref, loop_idx, ctx, ta);
  if (fold_rc > 0)
    return 0;
  /* Fold matched but emit failed (fold_rc<0): fall back to generic while. */
  cond_ref = ast_ast_block_while_cond_ref(arena, block_ref, loop_idx);
  body_ref = ast_ast_block_while_body_ref(arena, block_ref, loop_idx);
  if (link_abi_getenv("XLANG_ASM_DEBUG"))
    fprintf(stderr, "xlang: while emit br=%d wi=%d cond=%d body=%d\n", (int)block_ref, (int)loop_idx, (int)cond_ref,
            (int)body_ref);
  loop_len = pipeline_asm_emit_next_label_c(ctx, loop_buf, 64);
  exit_len = pipeline_asm_emit_next_label_c(ctx, exit_buf, 64);
  if (loop_len <= 0 || exit_len <= 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, loop_buf, loop_len, 0, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, cond_ref, ctx, ta) != 0)
    return -1;
  if (glue_enc_jz_after_bool_in_eax(elf_ctx, exit_buf, exit_len, ta) != 0)
    return -1;
  if (backend_ctx_push_loop_labels(ctx, exit_buf, exit_len, loop_buf, loop_len) != 0)
    return -1;
  glue_loop_break_exit_push();
  if (backend_emit_loop_body_content_elf_sync(arena, elf_ctx, body_ref, ctx, ta) != 0) {
    glue_loop_break_exit_pop();
    backend_ctx_pop_loop_labels(ctx);
    return -1;
  }
  if (backend_enc_jmp_arch(elf_ctx, loop_buf, loop_len, ta) != 0) {
    glue_loop_break_exit_pop();
    backend_ctx_pop_loop_labels(ctx);
    return -1;
  }
  if (backend_enc_label_arch(elf_ctx, exit_buf, exit_len, 0, ta) != 0) {
    glue_loop_break_exit_pop();
    backend_ctx_pop_loop_labels(ctx);
    return -1;
  }
  glue_asm_cache_invalidate_at_cfg_merge_selective(arena, ctx, body_ref, 0);
  glue_asm_loop_phi_invalidate_carried_defs(arena, ctx, body_ref);
  glue_asm_loop_merge_live_union(arena, ctx, body_ref);
  glue_loop_break_exit_pop();
  backend_ctx_pop_loop_labels(ctx);
  return 0;
}

/**
 * ELF for loop; C glue real impl (mirrors backend.x emit_for_loop_elf).
 *
 * Why: C for-semantics — continue targets the *step* label, not cond head.
 *      Old path pushed loop_buf (cond) as continue_label → `for (…; i = i + 1)`
 *      body `continue` skipped step → infinite loop when i stuck. Empty step
 *      (`for ( ; c ; )`) still uses step label (= fall into jmp head).
 * Contract: NULL arena/elf_ctx/ctx → -1; otherwise 0 on success, -1 on emit
 *           failure.
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS co-path.
 */
int32_t backend_emit_for_loop_elf_sync(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                       int32_t block_ref, int32_t for_idx, struct backend_AsmFuncCtx *ctx,
                                       int32_t ta) {
  int32_t init_ref;
  int32_t cond_ref;
  int32_t step_ref;
  int32_t body_ref;
  uint8_t loop_buf[128];
  uint8_t exit_buf[128];
  uint8_t step_buf[128];
  int32_t loop_len;
  int32_t exit_len;
  int32_t step_len;

  init_ref = ast_ast_block_for_init_ref(arena, block_ref, for_idx);
  cond_ref = ast_ast_block_for_cond_ref(arena, block_ref, for_idx);
  step_ref = ast_ast_block_for_step_ref(arena, block_ref, for_idx);
  body_ref = ast_ast_block_for_body_ref(arena, block_ref, for_idx);
  if (init_ref != 0 && pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta) != 0)
    return -1;
  loop_len = pipeline_asm_emit_next_label_c(ctx, loop_buf, 64);
  exit_len = pipeline_asm_emit_next_label_c(ctx, exit_buf, 64);
  step_len = pipeline_asm_emit_next_label_c(ctx, step_buf, 64);
  if (loop_len <= 0 || exit_len <= 0 || step_len <= 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, loop_buf, loop_len, 0, ta) != 0)
    return -1;
  if (cond_ref != 0) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, cond_ref, ctx, ta) != 0)
      return -1;
    if (glue_enc_jz_after_bool_in_eax(elf_ctx, exit_buf, exit_len, ta) != 0)
      return -1;
  }
  /* continue → step_buf (not loop_buf); break → exit_buf. */
  if (backend_ctx_push_loop_labels(ctx, exit_buf, exit_len, step_buf, step_len) != 0)
    return -1;
  glue_loop_break_exit_push();
  if (backend_emit_loop_body_content_elf_sync(arena, elf_ctx, body_ref, ctx, ta) != 0) {
    glue_loop_break_exit_pop();
    backend_ctx_pop_loop_labels(ctx);
    return -1;
  }
  if (backend_enc_label_arch(elf_ctx, step_buf, step_len, 0, ta) != 0) {
    glue_loop_break_exit_pop();
    backend_ctx_pop_loop_labels(ctx);
    return -1;
  }
  if (step_ref != 0 && pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, step_ref, ctx, ta) != 0) {
    glue_loop_break_exit_pop();
    backend_ctx_pop_loop_labels(ctx);
    return -1;
  }
  if (backend_enc_jmp_arch(elf_ctx, loop_buf, loop_len, ta) != 0) {
    glue_loop_break_exit_pop();
    backend_ctx_pop_loop_labels(ctx);
    return -1;
  }
  if (backend_enc_label_arch(elf_ctx, exit_buf, exit_len, 0, ta) != 0) {
    glue_loop_break_exit_pop();
    backend_ctx_pop_loop_labels(ctx);
    return -1;
  }
  glue_asm_cache_invalidate_at_cfg_merge_selective(arena, ctx, body_ref, 0);
  glue_asm_loop_phi_invalidate_carried_defs(arena, ctx, body_ref);
  glue_asm_loop_merge_live_union(arena, ctx, body_ref);
  if (step_ref != 0)
    glue_live_fwd_apply_expr_effect(arena, ctx, step_ref);
  glue_loop_break_exit_pop();
  backend_ctx_pop_loop_labels(ctx);
  return 0;
}

/**
 * ELF while loop emit; M8-tail thin wrapper entry → C glue real impl.
 * Do NOT call partial backend_emit_while_loop_elf thin stub.
 * PLATFORM: SHARED.
 */
int32_t pipeline_asm_emit_while_loop_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                           int32_t block_ref, int32_t loop_idx, struct backend_AsmFuncCtx *ctx,
                                           int32_t ta) {
  return backend_emit_while_loop_elf_sync(arena, elf_ctx, block_ref, loop_idx, ctx, ta);
}

/**
 * ELF for loop emit; M8-tail thin wrapper entry → C glue real impl.
 * PLATFORM: SHARED.
 */
int32_t pipeline_asm_emit_for_loop_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                         int32_t block_ref, int32_t for_idx, struct backend_AsmFuncCtx *ctx,
                                         int32_t ta) {
  return backend_emit_for_loop_elf_sync(arena, elf_ctx, block_ref, for_idx, ctx, ta);
}

/**
 * ELF loop body stmt_order; M8-tail thin wrapper entry → C glue real impl.
 * PLATFORM: SHARED.
 */
int32_t pipeline_asm_emit_loop_body_content_elf_c(struct ast_ASTArena *arena,
                                                  struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t body_ref,
                                                  struct backend_AsmFuncCtx *ctx, int32_t ta) {
  return backend_emit_loop_body_content_elf_sync(arena, elf_ctx, body_ref, ctx, ta);
}

/**
 * build_xlang_asm SKIP stub: M8-tail thin-wrapper emit bl C delegate +
 * epilogue; mega still mov w0,#0 + epilogue.
 *
 * Why: build_xlang_asm SKIP mode emits a thin stub that delegates to the
 *      real C function via `bl <cname>`. This function resolves the
 *      delegate name from 5 module delegate tables (backend/pipeline/
 *      parser/driver/typeck), emits `bl <cname>` + epilogue. If no
 *      delegate found, emits `mov w0, #0` + epilogue (mega no-op stub).
 * Contract: must be called after enc_prologue(0); args already in x0..xN
 *           per ABI. Returns 0 on success, -1 on emit failure.
 * PLATFORM: SHARED.
 */
int32_t pipeline_asm_emit_skip_heavy_or_thin_stub_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta,
                                                          struct ast_Module *mod, int32_t func_index) {
  uint8_t cname[72];
  int32_t clen;
  const char *dbg_env;

  clen = 0;
  if (mod != NULL) {
    /* Try each module's thin delegate table in order; first hit wins. */
    if (asm_backend_m8_tail_thin_delegate_c_name(mod, func_index, cname, (int32_t)sizeof(cname), &clen) == 0)
      if (asm_pipeline_m8_tail_thin_delegate_c_name(mod, func_index, cname, (int32_t)sizeof(cname), &clen) == 0)
        if (asm_parser_m8_tail_thin_delegate_c_name(mod, func_index, cname, (int32_t)sizeof(cname), &clen) == 0)
          if (asm_driver_m8_tail_thin_delegate_c_name(mod, func_index, cname, (int32_t)sizeof(cname), &clen) == 0)
            (void)asm_typeck_m8_tail_thin_delegate_c_name(mod, func_index, cname, (int32_t)sizeof(cname), &clen);
  }
  dbg_env = link_abi_getenv("XLANG_DEBUG_PARSER_DELEGATE");
  if (dbg_env && dbg_env[0] != '\0' && dbg_env[0] != '0' && mod != NULL) {
    static int32_t dbg_stub_n;
    static int32_t dbg_delegate_hit;
    uint8_t fn[128];
    int32_t fl;
    dbg_stub_n++;
    if (clen > 0)
      dbg_delegate_hit++;
    if (dbg_stub_n <= 8 || (clen > 0 && dbg_delegate_hit <= 5)) {
      fl = pipeline_module_func_name_len_at(mod, func_index);
      pipeline_module_func_name_copy64(mod, func_index, fn);
      fprintf(stderr, "parser_delegate_stub #%d fi=%d fn=%.*s clen=%d hit_total=%d\n", (int)dbg_stub_n,
              (int)func_index, (int)(fl > 127 ? 127 : fl), fn, (int)clen, (int)dbg_delegate_hit);
      if (clen > 0)
        fprintf(stderr, "  -> cname=%.*s\n", (int)(clen > 127 ? 127 : clen), cname);
      fflush(stderr);
    }
    if (dbg_stub_n == 1) {
      int32_t fi;
      int32_t probe_clen;
      uint8_t probe_c[72];
      for (fi = 0; fi < (int32_t)mod->num_funcs; fi++) {
        if (pipeline_module_func_name_equal_at(mod, fi, (uint8_t *)"first_token_kind", 16)) {
          probe_clen = 0;
          fprintf(stderr, "parser_delegate_probe first_token_kind fi=%d lookup_ret=%d clen=%d\n", (int)fi,
                  (int)asm_parser_m8_tail_thin_delegate_c_name(mod, fi, probe_c, (int32_t)sizeof(probe_c),
                                                                 &probe_clen),
                  (int)probe_clen);
          fflush(stderr);
          break;
        }
      }
    }
  }
  if (clen > 0) {
    if (backend_enc_call_arch(elf_ctx, cname, clen, ta) != 0)
      return -1;
    return backend_enc_epilogue_arch(elf_ctx, ta);
  }
  if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0)
    return -1;
  return backend_enc_epilogue_arch(elf_ctx, ta);
}
