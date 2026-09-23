/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
/** Whether two VAR expr refs refer to the same variable name (B-CMP LCG xor while pattern match). */
int32_t glue_fold_expr_var_refs_same_c(struct ast_ASTArena *arena, int32_t a_ref, int32_t b_ref) {
  int32_t alen;
  int32_t blen;
  uint8_t abuf[256];
  uint8_t bbuf[256];
  int32_t k;
  if (a_ref <= 0 || b_ref <= 0 || !arena)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, a_ref) != 3 ||
      pipeline_expr_kind_ord_at(arena, b_ref) != 3)
    return 0;
  alen = pipeline_expr_var_name_len(arena, a_ref);
  blen = pipeline_expr_var_name_len(arena, b_ref);
  if (alen <= 0 || blen <= 0 || alen != blen || alen > 255)
    return 0;
  pipeline_expr_var_name_into(arena, a_ref, abuf);
  pipeline_expr_var_name_into(arena, b_ref, bbuf);
  k = 0;
  while (k < alen) {
    if (abuf[k] != bbuf[k])
      return 0;
    k++;
  }
  return 1;
}

/** Parse `while (i < n)`: left VAR i, right LIT or VAR n. */
int32_t glue_fold_parse_while_lt_i_n_c(struct ast_ASTArena *arena, int32_t cond_ref, int32_t *out_i_ref,
                                              int32_t *out_n_is_lit, int32_t *out_n_lit, int32_t *out_n_ref) {
  int32_t i_ref;
  int32_t n_side;
  if (!arena || cond_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, cond_ref) != 16)
    return 0;
  i_ref = pipeline_expr_binop_left_ref_at(arena, cond_ref);
  n_side = pipeline_expr_binop_right_ref_at(arena, cond_ref);
  if (pipeline_expr_kind_ord_at(arena, i_ref) != 3)
    return 0;
  if (out_i_ref)
    *out_i_ref = i_ref;
  if (pipeline_expr_kind_ord_at(arena, n_side) == 0) {
    if (out_n_is_lit)
      *out_n_is_lit = 1;
    if (out_n_lit)
      *out_n_lit = pipeline_expr_int_val_at(arena, n_side);
    if (out_n_ref)
      *out_n_ref = 0;
    return 1;
  }
  if (pipeline_expr_kind_ord_at(arena, n_side) == 3) {
    if (out_n_is_lit)
      *out_n_is_lit = 0;
    if (out_n_lit)
      *out_n_lit = 0;
    if (out_n_ref)
      *out_n_ref = n_side;
    return 1;
  }
  return 0;
}

/** Same-block let binding integer literal init (`let n: i32 = 100000000`). */
int32_t glue_fold_block_let_init_lit_c(struct ast_ASTArena *arena, int32_t block_ref, int32_t var_ref,
                                              int32_t *out_lit) {
  int32_t vlen;
  int32_t nlet;
  int32_t li;
  uint8_t vbuf[256];
  if (!arena || block_ref <= 0 || var_ref <= 0 || pipeline_expr_kind_ord_at(arena, var_ref) != 3)
    return 0;
  vlen = pipeline_expr_var_name_len(arena, var_ref);
  if (vlen <= 0 || vlen > 255)
    return 0;
  pipeline_expr_var_name_into(arena, var_ref, vbuf);
  nlet = ast_ast_block_num_lets(arena, block_ref);
  li = 0;
  while (li < nlet) {
    int32_t llen = pipeline_block_let_name_len(arena, block_ref, li);
    if (llen == vlen) {
      int32_t is_match = 1;
      uint8_t lb[256];
      int32_t kk;
      int32_t init_ref;
      pipeline_block_let_name_copy64(arena, block_ref, li, lb);
      kk = 0;
      while (kk < vlen) {
        if (lb[kk] != vbuf[kk])
          is_match = 0;
        kk++;
      }
      if (is_match) {
        init_ref = pipeline_block_let_init_ref(arena, block_ref, li);
        if (init_ref > 0 && pipeline_expr_kind_ord_at(arena, init_ref) == 0) {
          if (out_lit)
            *out_lit = pipeline_expr_int_val_at(arena, init_ref);
          return 1;
        }
        return 0;
      }
    }
    li++;
  }
  return 0;
}

/** Parse `i * c1 + c2` or `c1 * i + c2` (loop_i32 LCG mixed term). */
int32_t glue_parse_i_mul_add_lit_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t i_ref,
                                          int32_t *out_c1, int32_t *out_c2) {
  int32_t ko;
  int32_t left;
  int32_t right;
  int32_t mul_ref;
  int32_t lit_ref;
  int32_t ml;
  int32_t mr;
  if (!arena || expr_ref <= 0 || i_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == 6) {
    ml = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    mr = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    if (glue_fold_expr_var_refs_same_c(arena, ml, i_ref) && pipeline_expr_kind_ord_at(arena, mr) == 0) {
      if (out_c1)
        *out_c1 = pipeline_expr_int_val_at(arena, mr);
      if (out_c2)
        *out_c2 = 0;
      return 1;
    }
    return 0;
  }
  if (ko != 4)
    return 0;
  left = pipeline_expr_binop_left_ref_at(arena, expr_ref);
  right = pipeline_expr_binop_right_ref_at(arena, expr_ref);
  if (pipeline_expr_kind_ord_at(arena, left) == 6 && pipeline_expr_kind_ord_at(arena, right) == 0) {
    mul_ref = left;
    lit_ref = right;
  } else {
    return 0;
  }
  ml = pipeline_expr_binop_left_ref_at(arena, mul_ref);
  mr = pipeline_expr_binop_right_ref_at(arena, mul_ref);
  if (glue_fold_expr_var_refs_same_c(arena, ml, i_ref) && pipeline_expr_kind_ord_at(arena, mr) == 0) {
    if (out_c1)
      *out_c1 = pipeline_expr_int_val_at(arena, mr);
    if (out_c2)
      *out_c2 = pipeline_expr_int_val_at(arena, lit_ref);
    return 1;
  }
  if (glue_fold_expr_var_refs_same_c(arena, mr, i_ref) && pipeline_expr_kind_ord_at(arena, ml) == 0) {
    if (out_c1)
      *out_c1 = pipeline_expr_int_val_at(arena, ml);
    if (out_c2)
      *out_c2 = pipeline_expr_int_val_at(arena, lit_ref);
    return 1;
  }
  return 0;
}

/** Whether expr is `target = target + 1`. */
int32_t glue_is_assign_var_add_one_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t target_ref) {
  int32_t left_ref;
  int32_t add_l;
  int32_t add_r;
  if (!arena || expr_ref <= 0 || pipeline_expr_kind_ord_at(arena, expr_ref) != 28)
    return 0;
  left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
  add_l = pipeline_expr_binop_left_ref_at(arena, pipeline_expr_binop_right_ref_at(arena, expr_ref));
  add_r = pipeline_expr_binop_right_ref_at(arena, pipeline_expr_binop_right_ref_at(arena, expr_ref));
  if (!glue_fold_expr_var_refs_same_c(arena, left_ref, target_ref))
    return 0;
  if (pipeline_expr_kind_ord_at(arena, pipeline_expr_binop_right_ref_at(arena, expr_ref)) != 4)
    return 0;
  if (!glue_fold_expr_var_refs_same_c(arena, add_l, target_ref))
    return 0;
  if (pipeline_expr_kind_ord_at(arena, add_r) != 0 || pipeline_expr_int_val_at(arena, add_r) != 1)
    return 0;
  return 1;
}

/** Whether expr is a field access on func's 0th formal parameter. */
int32_t glue_expr_is_param0_field_access_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                  int32_t func_idx, int32_t expr_ref) {
  if (!arena || !mod || func_idx < 0 || expr_ref <= 0 || pipeline_expr_kind_ord_at(arena, expr_ref) != 44)
    return 0;
  return glue_expr_is_func_param_at_c(arena, mod, func_idx,
                                     pipeline_expr_field_access_base_ref(arena, expr_ref), 0);
}

/** Whether func body is `return p.a + p.b` (param0 field sum). */
int32_t glue_fold_func_returns_param0_field_sum_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                         int32_t func_idx) {
  int32_t ret_ref;
  int32_t al;
  int32_t ar;
  ret_ref = glue_fold_func_return_operand_ref_c(arena, mod, func_idx);
  if (ret_ref <= 0 || pipeline_expr_kind_ord_at(arena, ret_ref) != 4)
    return 0;
  al = pipeline_expr_binop_left_ref_at(arena, ret_ref);
  ar = pipeline_expr_binop_right_ref_at(arena, ret_ref);
  if (!glue_expr_is_param0_field_access_c(arena, mod, func_idx, al))
    return 0;
  return glue_expr_is_param0_field_access_c(arena, mod, func_idx, ar) ? 1 : 0;
}

/** Whether expr is `pair.field = src_ref` (single-char field name). */
int32_t glue_is_field_assign_from_var_c(struct ast_ASTArena *arena, int32_t er, int32_t pair_ref,
                                               uint8_t field_ch, int32_t src_ref) {
  int32_t left_ref;
  int32_t right_ref;
  uint8_t fn[256];
  if (!arena || er <= 0 || pair_ref <= 0 || src_ref <= 0 || pipeline_expr_kind_ord_at(arena, er) != 28)
    return 0;
  left_ref = pipeline_expr_binop_left_ref_at(arena, er);
  right_ref = pipeline_expr_binop_right_ref_at(arena, er);
  if (pipeline_expr_kind_ord_at(arena, left_ref) != 44)
    return 0;
  if (!glue_fold_expr_var_refs_same_c(arena, pipeline_expr_field_access_base_ref(arena, left_ref), pair_ref))
    return 0;
  if (pipeline_expr_field_access_name_len(arena, left_ref) != 1)
    return 0;
  pipeline_expr_field_access_name_into(arena, left_ref, fn);
  if (fn[0] != field_ch)
    return 0;
  return glue_fold_expr_var_refs_same_c(arena, right_ref, src_ref) ? 1 : 0;
}

/** Whether expr is `pair.b = i + 1`. */
int32_t glue_is_field_assign_i_plus_one_c(struct ast_ASTArena *arena, int32_t er, int32_t pair_ref,
                                                 int32_t i_ref) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t add_l;
  int32_t add_r;
  uint8_t fn[256];
  if (!arena || er <= 0 || pipeline_expr_kind_ord_at(arena, er) != 28)
    return 0;
  left_ref = pipeline_expr_binop_left_ref_at(arena, er);
  right_ref = pipeline_expr_binop_right_ref_at(arena, er);
  if (pipeline_expr_kind_ord_at(arena, left_ref) != 44)
    return 0;
  if (!glue_fold_expr_var_refs_same_c(arena, pipeline_expr_field_access_base_ref(arena, left_ref), pair_ref))
    return 0;
  if (pipeline_expr_field_access_name_len(arena, left_ref) != 1)
    return 0;
  pipeline_expr_field_access_name_into(arena, left_ref, fn);
  if (fn[0] != (uint8_t)'b')
    return 0;
  if (pipeline_expr_kind_ord_at(arena, right_ref) != 4)
    return 0;
  add_l = pipeline_expr_binop_left_ref_at(arena, right_ref);
  add_r = pipeline_expr_binop_right_ref_at(arena, right_ref);
  if (!glue_fold_expr_var_refs_same_c(arena, add_l, i_ref))
    return 0;
  if (pipeline_expr_kind_ord_at(arena, add_r) != 0 || pipeline_expr_int_val_at(arena, add_r) != 1)
    return 0;
  return 1;
}

/** Whether expr is `s = s + add_pair(pair)`. */
int32_t glue_is_assign_s_plus_pair_field_sum_call_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                           int32_t er, int32_t *out_s_ref, int32_t pair_ref) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t add_l;
  int32_t inner;
  int32_t callee_ref;
  int32_t arg0;
  uint8_t cname[256];
  int32_t clen;
  if (!arena || !mod || er <= 0 || pair_ref <= 0 || pipeline_expr_kind_ord_at(arena, er) != 28)
    return 0;
  left_ref = pipeline_expr_binop_left_ref_at(arena, er);
  right_ref = pipeline_expr_binop_right_ref_at(arena, er);
  if (pipeline_expr_kind_ord_at(arena, right_ref) != 4)
    return 0;
  add_l = pipeline_expr_binop_left_ref_at(arena, right_ref);
  inner = pipeline_expr_binop_right_ref_at(arena, right_ref);
  if (!glue_fold_expr_var_refs_same_c(arena, add_l, left_ref))
    return 0;
  if (pipeline_expr_kind_ord_at(arena, inner) != 48 || pipeline_expr_call_num_args_at(arena, inner) != 1)
    return 0;
  arg0 = pipeline_expr_call_arg_ref(arena, inner, 0);
  if (!glue_fold_expr_var_refs_same_c(arena, arg0, pair_ref))
    return 0;
  callee_ref = pipeline_expr_call_callee_ref_at(arena, inner);
  if (callee_ref <= 0 || pipeline_expr_kind_ord_at(arena, callee_ref) != 3)
    return 0;
  clen = pipeline_expr_var_name_len(arena, callee_ref);
  if (clen != 8)
    return 0;
  pipeline_expr_var_name_into(arena, callee_ref, cname);
  if (cname[0] != (uint8_t)'a' || cname[1] != (uint8_t)'d' || cname[2] != (uint8_t)'d' || cname[3] != (uint8_t)'_' ||
      cname[4] != (uint8_t)'p' || cname[5] != (uint8_t)'a' || cname[6] != (uint8_t)'i' || cname[7] != (uint8_t)'r')
    return 0;
  if (out_s_ref)
    *out_s_ref = left_ref;
  return 1;
}

/** Whether expr is `buf[i] = (i as u8)`. */
int32_t glue_is_assign_u8_index_store_cast_i_c(struct ast_ASTArena *arena, int32_t er, int32_t *out_buf_ref,
                                                      int32_t i_ref) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t as_op;
  if (!arena || er <= 0 || pipeline_expr_kind_ord_at(arena, er) != 28)
    return 0;
  left_ref = pipeline_expr_binop_left_ref_at(arena, er);
  right_ref = pipeline_expr_binop_right_ref_at(arena, er);
  if (pipeline_expr_kind_ord_at(arena, left_ref) != 47)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, pipeline_expr_index_base_ref(arena, left_ref)) != 3)
    return 0;
  if (!glue_fold_expr_var_refs_same_c(arena, pipeline_expr_index_index_ref(arena, left_ref), i_ref))
    return 0;
  if (!glue_expr_is_x_as_cast_at_c(arena, right_ref))
    return 0;
  as_op = pipeline_expr_as_operand_ref_at(arena, right_ref);
  if (!glue_fold_expr_var_refs_same_c(arena, as_op, i_ref))
    return 0;
  if (out_buf_ref)
    *out_buf_ref = pipeline_expr_index_base_ref(arena, left_ref);
  return 1;
}

/** Whether expr is `sum = sum + (buf[j] as i32)`. */
int32_t glue_is_assign_sum_plus_u8_index_cast_c(struct ast_ASTArena *arena, int32_t er, int32_t *out_sum_ref,
                                                       int32_t *out_buf_ref, int32_t j_ref) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t add_l;
  int32_t as_op;
  int32_t ix_ref;
  if (!arena || er <= 0 || pipeline_expr_kind_ord_at(arena, er) != 28)
    return 0;
  left_ref = pipeline_expr_binop_left_ref_at(arena, er);
  right_ref = pipeline_expr_binop_right_ref_at(arena, er);
  if (pipeline_expr_kind_ord_at(arena, right_ref) != 4)
    return 0;
  add_l = pipeline_expr_binop_left_ref_at(arena, right_ref);
  as_op = pipeline_expr_binop_right_ref_at(arena, right_ref);
  if (!glue_fold_expr_var_refs_same_c(arena, add_l, left_ref))
    return 0;
  if (!glue_expr_is_x_as_cast_at_c(arena, as_op))
    return 0;
  ix_ref = pipeline_expr_as_operand_ref_at(arena, as_op);
  if (pipeline_expr_kind_ord_at(arena, ix_ref) != 47)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, pipeline_expr_index_base_ref(arena, ix_ref)) != 3)
    return 0;
  if (!glue_fold_expr_var_refs_same_c(arena, pipeline_expr_index_index_ref(arena, ix_ref), j_ref))
    return 0;
  if (out_sum_ref)
    *out_sum_ref = left_ref;
  if (out_buf_ref)
    *out_buf_ref = pipeline_expr_index_base_ref(arena, ix_ref);
  return 1;
}

/** Whether VAR expr name equals the name of body's let_idx-th let. */
int32_t glue_expr_var_name_eq_let_idx_c(struct ast_ASTArena *arena, int32_t var_expr_ref,
                                               int32_t body_ref, int32_t let_idx) {
  uint8_t vname[256];
  uint8_t lname[256];
  int32_t vlen;
  int32_t llen;
  int32_t k;
  if (!arena || var_expr_ref <= 0 || body_ref <= 0 || let_idx < 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, var_expr_ref) != 3)
    return 0;
  vlen = pipeline_expr_var_name_len(arena, var_expr_ref);
  llen = pipeline_block_let_name_len(arena, body_ref, let_idx);
  if (vlen <= 0 || llen <= 0 || vlen != llen || vlen > 255)
    return 0;
  pipeline_expr_var_name_into(arena, var_expr_ref, vname);
  pipeline_block_let_name_copy64(arena, body_ref, let_idx, lname);
  k = 0;
  while (k < vlen) {
    if (vname[k] != lname[k])
      return 0;
    k++;
  }
  return 1;
}


/*
 * wave137: pipeline_asm_emit_cmp pure-owned leave cold twins.
 * PREFER pure; cold path when PREFER!=1 / hybrid fail.
 * Faces: cmp_cc + arm64_cset + typekind_variant_tag + emit_cmp_elf.
 * Cap residual symbols remain host-cc (try_binop_cmp, enc_*, pool).
 */
extern int32_t pipeline_expr_const_folded_valid_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_const_folded_val_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_binop_left_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_binop_right_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t ref);
extern int32_t pipeline_expr_int_val_at(void *arena, int32_t expr_ref);
extern int64_t pipeline_expr_int64_val_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_var_name_len(void *arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(void *arena, int32_t expr_ref, uint8_t *out64);
extern int32_t pipeline_expr_field_access_base_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_name_len(void *arena, int32_t expr_ref);
extern void pipeline_expr_field_access_name_into(void *arena, int32_t expr_ref, uint8_t *out);
extern int32_t pipeline_expr_enum_namespace_field_tag(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_call_return_type_kind_ord_c(void *arena, int32_t call_expr_ref);
extern int32_t glue_try_binop_cmp_rbx_rax_elf_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, void *ctx, int32_t ta);
extern int32_t glue_var_expr_stack_off_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
extern void glue_binop_var_slot_cache_invalidate_rbx(void);
extern int32_t glue_binop_operand_is_scalar_f32_elf_c(void *arena, void *ctx, int32_t expr_ref);
extern int32_t glue_binop_operand_is_scalar_f64_elf_c(void *arena, void *ctx, int32_t expr_ref);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_elf_ctx_append_bytes(void *ctx, uint8_t *ptr, int32_t n);
extern int32_t backend_enc_mov_imm32_to_w0_arch(void *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_mov_imm32_to_rbx_arch(void *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rbx_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rax_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_push_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_test_eax_eax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_cmp_rbx_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_cmp_setcc_movzbl_arch(void *elf_ctx, int32_t cc, int32_t ta);
extern int32_t glue_binop_operand_is_unsigned_elf_c(void *arena, void *ctx, int32_t left_ref, int32_t right_ref);
extern int32_t backend_enc_ucomisd_rbx_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_ucomiss_rbx_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_fp_cmp_setcc_movzbl_arch(void *elf_ctx, int32_t cc, int32_t ta);

int32_t pipeline_asm_cmp_cc_for_expr_kind_ord(int32_t kind_ord) {
  switch (kind_ord) {
  case 14: return 0;
  case 15: return 1;
  case 16: return 2;
  case 17: return 3;
  case 18: return 4;
  case 19: return 5;
  default: return -1;
  }
}

int32_t pipeline_asm_arm64_cset_cond_enc_from_cc(int32_t cc) {
  switch (cc) {
  case 0: return 1;
  case 1: return 0;
  case 2: return 10;
  case 3: return 12;
  case 4: return 13;
  case 5: return 11;
  /* Unsigned 6..9: invert(LO/LS/HI/HS) → HS/HI/LS/LO. Twin of .x. */
  case 6: return 2;
  case 7: return 8;
  case 8: return 9;
  case 9: return 3;
  default: return 0;
  }
}

int32_t pipeline_asm_typekind_variant_tag(const uint8_t *field_buf, int32_t flen) {
  if (!field_buf || flen < 7)
    return -1;
  if (flen >= 7 && memcmp(field_buf, "TYPE_I32", 7) == 0)
    return 0;
  if (flen >= 8 && memcmp(field_buf, "TYPE_BOOL", 8) == 0)
    return 1;
  if (flen >= 6 && memcmp(field_buf, "TYPE_U8", 6) == 0) {
    if (flen >= 9 && memcmp(field_buf, "TYPE_USIZE", 9) == 0)
      return 6;
    if (flen >= 7 && memcmp(field_buf, "TYPE_U32", 7) == 0)
      return 3;
    if (flen >= 7 && memcmp(field_buf, "TYPE_U64", 7) == 0)
      return 4;
    return 2;
  }
  if (flen >= 7 && memcmp(field_buf, "TYPE_U32", 7) == 0)
    return 3;
  if (flen >= 7 && memcmp(field_buf, "TYPE_U64", 7) == 0)
    return 4;
  if (flen >= 7 && memcmp(field_buf, "TYPE_I64", 7) == 0)
    return 5;
  if (flen >= 9 && memcmp(field_buf, "TYPE_USIZE", 9) == 0)
    return 6;
  if (flen >= 9 && memcmp(field_buf, "TYPE_ISIZE", 9) == 0)
    return 7;
  if (flen >= 9 && memcmp(field_buf, "TYPE_NAMED", 9) == 0)
    return 8;
  if (flen >= 7 && memcmp(field_buf, "TYPE_PTR", 7) == 0)
    return 9;
  if (flen >= 9 && memcmp(field_buf, "TYPE_ARRAY", 9) == 0)
    return 10;
  if (flen >= 9 && memcmp(field_buf, "TYPE_SLICE", 9) == 0)
    return 11;
  if (flen >= 11 && memcmp(field_buf, "TYPE_VECTOR", 11) == 0)
    return 12;
  if (flen >= 7 && memcmp(field_buf, "TYPE_F32", 7) == 0)
    return 13;
  if (flen >= 7 && memcmp(field_buf, "TYPE_F64", 7) == 0)
    return 14;
  if (flen >= 8 && memcmp(field_buf, "TYPE_VOID", 8) == 0)
    return 15;
  return -1;
}

static int32_t glue_type_kind_is_64bit_int_seed(int32_t kind) {
  return kind == 4 || kind == 5 || kind == 6 || kind == 7 || kind == 9;
}

static int32_t glue_emit_rex_w_if_64bit_seed(void *elf_ctx, int32_t is_64bit, int32_t ta) {
  if (is_64bit && ta == 0) {
    uint8_t rex_w[1] = { 0x48 };
    return pipeline_elf_ctx_append_bytes(elf_ctx, rex_w, 1);
  }
  return 0;
}

static int32_t pipeline_asm_cmp_enum_rhs_tag_seed(void *arena, int32_t expr_ref) {
  uint8_t base_buf[32];
  uint8_t field_buf[256];
  int32_t blen, flen, tag, base_ref;
  if (!arena || expr_ref <= 0 || pipeline_expr_kind_ord_at(arena, expr_ref) != 44)
    return -1;
  base_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
  if (base_ref <= 0 || pipeline_expr_kind_ord_at(arena, base_ref) != 3)
    return -1;
  blen = pipeline_expr_var_name_len(arena, base_ref);
  if (blen != 8)
    return -1;
  pipeline_expr_var_name_into(arena, base_ref, base_buf);
  flen = pipeline_expr_field_access_name_len(arena, expr_ref);
  if (flen <= 0 || flen > 255)
    return -1;
  pipeline_expr_field_access_name_into(arena, expr_ref, field_buf);
  if (memcmp(base_buf, "TypeKind", 8) == 0)
    return pipeline_asm_typekind_variant_tag(field_buf, flen);
  if (memcmp(base_buf, "ExprKind", 8) != 0)
    return -1;
  tag = pipeline_expr_enum_namespace_field_tag(arena, expr_ref);
  return tag;
}

static int32_t glue_emit_cmp_finish_seed(void *arena, void *ctx, void *elf_ctx, int32_t left_ref,
                                         int32_t right_ref, int32_t is_cmp_64bit, int32_t cc, int32_t ta) {
  if ((ta == 0 || ta == 1) && left_ref > 0 && right_ref > 0 &&
      glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref)) {
    if (backend_enc_ucomisd_rbx_rax_arch(elf_ctx, ta) != 0)
      return -1;
    return backend_enc_fp_cmp_setcc_movzbl_arch(elf_ctx, cc, ta);
  }
  if ((ta == 0 || ta == 1) && left_ref > 0 && right_ref > 0 &&
      glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref)) {
    if (backend_enc_ucomiss_rbx_rax_arch(elf_ctx, ta) != 0)
      return -1;
    return backend_enc_fp_cmp_setcc_movzbl_arch(elf_ctx, cc, ta);
  }
  /* PLATFORM: SHARED — u8/u32/u64/usize relational cmp uses unsigned setcc
   * (same glue_binop_operand_is_unsigned_elf_c as SHR/DIV). Twin of .x. */
  if (cc >= 2 && cc <= 5 &&
      glue_binop_operand_is_unsigned_elf_c(arena, ctx, left_ref, right_ref) != 0)
    cc = cc + 4;
  if (glue_emit_rex_w_if_64bit_seed(elf_ctx, is_cmp_64bit, ta) != 0)
    return -1;
  if (backend_enc_cmp_rbx_rax_arch(elf_ctx, ta) != 0)
    return -1;
  return backend_enc_cmp_setcc_movzbl_arch(elf_ctx, cc, ta);
}

static int32_t cmp_expr_lit_i32_seed(void *arena, int32_t expr_ref, int32_t *out_imm) {
  int32_t ko;
  int64_t v64;
  if (expr_ref == 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == 0 || ko == 2) {
    /* PLATFORM: SHARED — wide INT_LIT is not an i32 imm (2^32 → 0). Twin of
     * pipeline_asm_cmp_expr_lit_i32_at + glue_binop_expr_is_wide_int_lit. */
    if (ko == 0) {
      v64 = pipeline_expr_int64_val_at(arena, expr_ref);
      if (v64 < (int64_t)(-2147483647 - 1) || v64 > (int64_t)2147483647)
        return 0;
    }
    if (out_imm)
      *out_imm = pipeline_expr_int_val_at(arena, expr_ref);
    return 1;
  }
  return 0;
}

int32_t pipeline_asm_emit_cmp_elf(void *arena, void *elf_ctx, int32_t cmp_expr_ref, void *ctx, int32_t ta) {
  int32_t right_ref, left_ref, lit_imm, cc, enum_tag, cmp_ko, is_cmp_64bit, lt_ref, lt_kind, rt_ref, rt_kind, rk, var_off, left_ref2, vr;
  if (!arena || cmp_expr_ref <= 0)
    return -1;
  if (pipeline_expr_const_folded_valid_at(arena, cmp_expr_ref) != 0)
    return backend_enc_mov_imm32_to_w0_arch(elf_ctx, pipeline_expr_const_folded_val_at(arena, cmp_expr_ref), ta);
  cmp_ko = pipeline_expr_kind_ord_at(arena, cmp_expr_ref);
  left_ref = pipeline_expr_binop_left_ref_at(arena, cmp_expr_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, cmp_expr_ref);
  is_cmp_64bit = 0;
  if (left_ref > 0) {
    lt_ref = pipeline_expr_resolved_type_ref(arena, left_ref);
    /* PLATFORM: SHARED — dep decl fallback (parse-only has no typeck stamp;
     * u64 `t == 0` else compares 32-bit). Mirrors the .x twin. */
    if (lt_ref <= 0 && pipeline_expr_kind_ord_at(arena, left_ref) == 3)
      lt_ref = glue_var_expr_type_ref_with_decl_fallback_c(arena, left_ref);
    if (lt_ref > 0) {
      lt_kind = pipeline_type_kind_ord_at(arena, lt_ref);
      is_cmp_64bit = glue_type_kind_is_64bit_int_seed(lt_kind);
    }
    if (is_cmp_64bit == 0 && pipeline_expr_kind_ord_at(arena, left_ref) == 48) {
      rk = pipeline_asm_call_return_type_kind_ord_c(arena, left_ref);
      if (rk == 5 || rk == 4 || rk == 6 || rk == 7 || rk == 9)
        is_cmp_64bit = 1;
    }
  }
  if (is_cmp_64bit == 0 && right_ref > 0) {
    rt_ref = pipeline_expr_resolved_type_ref(arena, right_ref);
    /* PLATFORM: SHARED — dep decl fallback (see left side note). */
    if (rt_ref <= 0 && pipeline_expr_kind_ord_at(arena, right_ref) == 3)
      rt_ref = glue_var_expr_type_ref_with_decl_fallback_c(arena, right_ref);
    if (rt_ref > 0) {
      rt_kind = pipeline_type_kind_ord_at(arena, rt_ref);
      is_cmp_64bit = glue_type_kind_is_64bit_int_seed(rt_kind);
    }
    if (is_cmp_64bit == 0 && pipeline_expr_kind_ord_at(arena, right_ref) == 48) {
      rk = pipeline_asm_call_return_type_kind_ord_c(arena, right_ref);
      if (rk == 5 || rk == 4 || rk == 6 || rk == 7 || rk == 9)
        is_cmp_64bit = 1;
    }
  }
  if (left_ref > 0 && right_ref > 0 && pipeline_expr_kind_ord_at(arena, left_ref) == 48 &&
      cmp_expr_lit_i32_seed(arena, right_ref, &lit_imm) && lit_imm == 0 && (cmp_ko == 14 || cmp_ko == 15)) {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    cc = pipeline_asm_cmp_cc_for_expr_kind_ord(cmp_ko);
    if (cc < 0)
      return -1;
    if (glue_emit_rex_w_if_64bit_seed(elf_ctx, is_cmp_64bit, ta) != 0)
      return -1;
    if (backend_enc_test_eax_eax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_cmp_setcc_movzbl_arch(elf_ctx, cc, ta) != 0)
      return -1;
    return 0;
  }
  if (right_ref > 0 && (enum_tag = pipeline_asm_cmp_enum_rhs_tag_seed(arena, right_ref)) >= 0) {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, cmp_expr_ref), ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, enum_tag, ta) != 0)
      return -1;
    cc = pipeline_asm_cmp_cc_for_expr_kind_ord(pipeline_expr_kind_ord_at(arena, cmp_expr_ref));
    if (cc < 0)
      return -1;
    return glue_emit_cmp_finish_seed(arena, ctx, elf_ctx, left_ref, right_ref, is_cmp_64bit, cc, ta);
  }
  if (left_ref > 0 && right_ref > 0 && pipeline_expr_kind_ord_at(arena, left_ref) == 3 &&
      !glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) &&
      !glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) &&
      cmp_expr_lit_i32_seed(arena, right_ref, &lit_imm)) {
    var_off = glue_var_expr_stack_off_elf_c(arena, ctx, left_ref);
    if (var_off >= 0) {
      cc = pipeline_asm_cmp_cc_for_expr_kind_ord(cmp_ko);
      if (cc < 0)
        return -1;
      if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, var_off, ta) != 0)
        return -1;
      if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, lit_imm, ta) != 0)
        return -1;
      return glue_emit_cmp_finish_seed(arena, ctx, elf_ctx, left_ref, right_ref, is_cmp_64bit, cc, ta);
    }
  }
  if (right_ref != 0 && !glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) &&
      !glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) &&
      cmp_expr_lit_i32_seed(arena, right_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, cmp_expr_ref), ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    cc = pipeline_asm_cmp_cc_for_expr_kind_ord(pipeline_expr_kind_ord_at(arena, cmp_expr_ref));
    if (cc < 0)
      return -1;
    return glue_emit_cmp_finish_seed(arena, ctx, elf_ctx, left_ref, right_ref, is_cmp_64bit, cc, ta);
  }
  if (left_ref > 0 && right_ref > 0 &&
      !glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref) &&
      !glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref) &&
      !glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) &&
      !glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) &&
      cmp_expr_lit_i32_seed(arena, left_ref, &lit_imm)) {
    var_off = -1;
    if (pipeline_expr_kind_ord_at(arena, right_ref) == 3)
      var_off = glue_var_expr_stack_off_elf_c(arena, ctx, right_ref);
    cc = pipeline_asm_cmp_cc_for_expr_kind_ord(cmp_ko);
    if (cc < 0)
      return -1;
    if (var_off >= 0) {
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, var_off, ta) != 0)
        return -1;
    } else {
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
        return -1;
    }
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rbx();
    return glue_emit_cmp_finish_seed(arena, ctx, elf_ctx, left_ref, right_ref, is_cmp_64bit, cc, ta);
  }
  left_ref2 = pipeline_expr_binop_left_ref_at(arena, cmp_expr_ref);
  vr = glue_try_binop_cmp_rbx_rax_elf_c(arena, elf_ctx, left_ref2, right_ref, ctx, ta);
  if (vr == -1)
    return -1;
  if (vr == -2) {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref2, ctx, ta) != 0)
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
      return -1;
  }
  cc = pipeline_asm_cmp_cc_for_expr_kind_ord(pipeline_expr_kind_ord_at(arena, cmp_expr_ref));
  if (cc < 0)
    return -1;
  return glue_emit_c

/*
 * wave138: pipeline_asm_emit_as pure-owned leave cold twins.
 * PREFER pure; cold path when PREFER!=1 / hybrid fail.
 * Faces: is_await / is_x_as_cast / await_sync / try_propagate /
 *   float_lit / array_scalar / as_elf_impl / as_elf_c.
 * Cap residual: float_bits, IEEE pack, cast encoders, emit_expr, cleanup.
 */
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_unary_operand_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_as_operand_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_as_target_type_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t ref);
extern int32_t pipeline_expr_float_bits_lo_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_float_bits_hi_at(void *arena, int32_t expr_ref);
extern int32_t glue_ieee_f64_bits_to_f32_bits(int32_t lo, int32_t hi);
extern int32_t glue_ieee_f32_bits_to_f64_lo(int32_t fb);
extern int32_t glue_ieee_f32_bits_to_f64_hi(int32_t fb);
extern int32_t pipeline_asm_array_lit_elem_type_ref(void *arena, int32_t array_lit_expr_ref);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_next_label_c(void *ctx, uint8_t *buf, int32_t buf_size);
extern int32_t glue_index_scratch_spills_cleanup_all_elf_c(void *elf_ctx, int32_t ta);
extern int32_t glue_async_cps_emit_phase_reset(void *elf_ctx, int32_t ta);
extern void *pipeline_asm_ctx_layout(void *ctx);
extern int32_t arch_x86_64_enc_enc_test_edx_edx(void *elf_ctx);
extern int32_t backend_enc_test_rbx_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_jz_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_jmp_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_label_arch(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_global, int32_t ta);
extern int32_t backend_enc_mov_imm32_to_w0_arch(void *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_mov_imm64_to_rax_arch(void *elf_ctx, int32_t lo, int32_t hi, int32_t ta);
extern int32_t pipeline_elf_ctx_append_bytes(void *ctx, uint8_t *ptr, int32_t n);
extern int32_t glue_binop_operand_is_scalar_f64_elf_c(void *arena, void *ctx, int32_t expr_ref);
extern int32_t backend_enc_cvttss2si_eax_from_f32_bits_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_cvttsd2si_eax_from_f64_bits_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_cvttss2si_rax_from_f32_bits_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_cvttsd2si_rax_from_f64_bits_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_cvtsi2ss_eax_from_i32_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_cvtsi2ss_eax_from_i64_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_cvtsi2ss_eax_from_u64_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_cvtsd2ss_eax_from_f64_bits_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_cvtsi2sd_rax_from_u64_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_cvtsi2sd_rax_from_i64_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_cvtsi2sd_rax_from_i32_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_cvtss2sd_rax_from_f32_bits_arch(void *elf_ctx, int32_t ta);
  /* Cap-fn-ptr (10.3.2): LEA encoder + module lookup faces used by emit_as Cap path. */
extern int32_t backend_enc_lea_sym_to_reg_arch(void *elf_ctx, int32_t reg, uint8_t *name, int32_t name_len, int32_t ta);
extern void *glue_emit_module_from_ctx(void *ctx);
extern int32_t glue_module_func_index_by_name_c(void *mod, uint8_t *name, int32_t name_len);
extern int32_t glue_var_expr_stack_off_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t pipeline_expr_var_name_len(void *arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(void *arena, int32_t expr_ref, uint8_t *out64);
extern int32_t pipeline_module_func_is_no_mangle_at(void *m, int32_t fi);
extern int32_t pipeline_elf_ctx_macho_leading_underscore(uint8_t *ctx_bytes);
/* 9.4.2: fn-symbol LEA authority cold twin (defined in the modlet cluster). */
static int32_t pipe_modlet_lea_fn_sym_to_rax_cold(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t ta);

