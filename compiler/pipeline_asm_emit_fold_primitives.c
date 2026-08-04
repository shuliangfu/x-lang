/**
 * pipeline_asm_emit_fold_primitives.c — fold pattern detection primitives domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via #include).
 * Authority for AST shape detection primitives used by the count_up_while loop
 * folding pipeline (struct_pair_n2 / u8_fill / u8_sum / lcg_xor / affine):
 * - VAR identity / while-cond parsing / let-init literal extraction
 * - assign-shape matchers (var+1 / field=var / field=i+1 / s+=call / buf[i]=cast / sum+=cast)
 * - param0 field-access helpers / func-returns-param0-field-sum detector
 * - var-name-vs-let-idx equality
 *
 * These primitives only READ the AST and return 0/1 (or extract refs/lits).
 * They do NOT emit code — callers (matchers / emitters in pipeline_glue.c)
 * consume their results to decide whether to fold.
 *
 * Same-TU #include contract:
 * - MUST be #included AFTER pipeline_asm_emit_vector_simd.c (provides static
 *   glue_expr_is_func_param_at_c + glue_fold_func_return_operand_ref_c via its
 *   own same-TU #include at glue.c L2218 < this file's #include point).
 * - MUST be #included AFTER pipeline_asm_emit_as.c (provides static
 *   glue_expr_is_x_as_cast_at_c via its own same-TU #include at L1938).
 * - MUST be #included BEFORE pipeline_asm_emit_x86_enc_helpers.c (L6032) —
 *   the x86 encoders are consumed by fold EMITTERS that follow, and the
 *   primitives must be visible to those emitters.
 * - Consumers (glue_match_* / glue_try_fold_* / backend_try_fold_count_up_while_elf)
 *   all follow this #include point in pipeline_glue.c.
 *
 * Internal dependency graph (all static, resolved within this file):
 * - glue_parse_i_mul_add_lit_c → glue_fold_expr_var_refs_same_c
 * - glue_is_assign_var_add_one_c → glue_fold_expr_var_refs_same_c
 * - glue_expr_is_param0_field_access_c → glue_expr_is_func_param_at_c (extern,
 *   from pipeline_asm_emit_vector_simd.c)
 * - glue_fold_func_returns_param0_field_sum_c → glue_fold_func_return_operand_ref_c
 *   (extern, from vector_simd.c) + glue_expr_is_param0_field_access_c (local)
 * - glue_is_field_assign_from_var_c → glue_fold_expr_var_refs_same_c
 * - glue_is_field_assign_i_plus_one_c → glue_fold_expr_var_refs_same_c
 * - glue_is_assign_s_plus_pair_field_sum_call_c → glue_fold_expr_var_refs_same_c
 * - glue_is_assign_u8_index_store_cast_i_c → glue_fold_expr_var_refs_same_c
 *   + glue_expr_is_x_as_cast_at_c (extern, from pipeline_asm_emit_as.c)
 * - glue_is_assign_sum_plus_u8_index_cast_c → glue_fold_expr_var_refs_same_c
 *   + glue_expr_is_x_as_cast_at_c (extern, from pipeline_asm_emit_as.c)
 *
 * External deps (all public pool accessors, visible at #include point):
 * - pipeline_expr_kind_ord_at / pipeline_expr_var_name_len / pipeline_expr_var_name_into
 * - pipeline_expr_binop_left_ref_at / pipeline_expr_binop_right_ref_at
 * - pipeline_expr_int_val_at / pipeline_expr_field_access_base_ref
 * - pipeline_expr_field_access_name_len / pipeline_expr_field_access_name_into
 * - pipeline_expr_index_base_ref / pipeline_expr_index_index_ref
 * - pipeline_expr_as_operand_ref_at / pipeline_expr_call_num_args_at
 * - pipeline_expr_call_arg_ref / pipeline_expr_call_callee_ref_at
 * - pipeline_block_let_name_len / pipeline_block_let_name_copy64
 * - pipeline_block_let_init_ref / ast_ast_block_num_lets
 * - GLUE_EXPR_KIND_VAR (macro, defined earlier in glue.c)
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

/** Whether two VAR expr refs refer to the same variable name (B-CMP LCG xor while pattern match). */
static int32_t glue_fold_expr_var_refs_same_c(struct ast_ASTArena *arena, int32_t a_ref, int32_t b_ref) {
  int32_t alen;
  int32_t blen;
  uint8_t abuf[128];
  uint8_t bbuf[128];
  int32_t k;
  if (a_ref <= 0 || b_ref <= 0 || !arena)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, a_ref) != GLUE_EXPR_KIND_VAR ||
      pipeline_expr_kind_ord_at(arena, b_ref) != GLUE_EXPR_KIND_VAR)
    return 0;
  alen = pipeline_expr_var_name_len(arena, a_ref);
  blen = pipeline_expr_var_name_len(arena, b_ref);
  if (alen <= 0 || blen <= 0 || alen != blen || alen > 127)
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
static int32_t glue_fold_parse_while_lt_i_n_c(struct ast_ASTArena *arena, int32_t cond_ref, int32_t *out_i_ref,
                                              int32_t *out_n_is_lit, int32_t *out_n_lit, int32_t *out_n_ref) {
  int32_t i_ref;
  int32_t n_side;
  if (!arena || cond_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, cond_ref) != 16)
    return 0;
  i_ref = pipeline_expr_binop_left_ref_at(arena, cond_ref);
  n_side = pipeline_expr_binop_right_ref_at(arena, cond_ref);
  if (pipeline_expr_kind_ord_at(arena, i_ref) != GLUE_EXPR_KIND_VAR)
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
  if (pipeline_expr_kind_ord_at(arena, n_side) == GLUE_EXPR_KIND_VAR) {
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
static int32_t glue_fold_block_let_init_lit_c(struct ast_ASTArena *arena, int32_t block_ref, int32_t var_ref,
                                              int32_t *out_lit) {
  int32_t vlen;
  int32_t nlet;
  int32_t li;
  uint8_t vbuf[128];
  if (!arena || block_ref <= 0 || var_ref <= 0 || pipeline_expr_kind_ord_at(arena, var_ref) != GLUE_EXPR_KIND_VAR)
    return 0;
  vlen = pipeline_expr_var_name_len(arena, var_ref);
  if (vlen <= 0 || vlen > 127)
    return 0;
  pipeline_expr_var_name_into(arena, var_ref, vbuf);
  nlet = ast_ast_block_num_lets(arena, block_ref);
  li = 0;
  while (li < nlet) {
    int32_t llen = pipeline_block_let_name_len(arena, block_ref, li);
    if (llen == vlen) {
      int32_t is_match = 1;
      uint8_t lb[128];
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
static int32_t glue_parse_i_mul_add_lit_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t i_ref,
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
static int32_t glue_is_assign_var_add_one_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t target_ref) {
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
static int32_t glue_expr_is_param0_field_access_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                  int32_t func_idx, int32_t expr_ref) {
  if (!arena || !mod || func_idx < 0 || expr_ref <= 0 || pipeline_expr_kind_ord_at(arena, expr_ref) != 44)
    return 0;
  return glue_expr_is_func_param_at_c(arena, mod, func_idx,
                                     pipeline_expr_field_access_base_ref(arena, expr_ref), 0);
}

/** Whether func body is `return p.a + p.b` (param0 field sum). */
static int32_t glue_fold_func_returns_param0_field_sum_c(struct ast_ASTArena *arena, struct ast_Module *mod,
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
static int32_t glue_is_field_assign_from_var_c(struct ast_ASTArena *arena, int32_t er, int32_t pair_ref,
                                               uint8_t field_ch, int32_t src_ref) {
  int32_t left_ref;
  int32_t right_ref;
  uint8_t fn[128];
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
static int32_t glue_is_field_assign_i_plus_one_c(struct ast_ASTArena *arena, int32_t er, int32_t pair_ref,
                                                 int32_t i_ref) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t add_l;
  int32_t add_r;
  uint8_t fn[128];
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
static int32_t glue_is_assign_s_plus_pair_field_sum_call_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                           int32_t er, int32_t *out_s_ref, int32_t pair_ref) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t add_l;
  int32_t inner;
  int32_t callee_ref;
  int32_t arg0;
  uint8_t cname[128];
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
  if (callee_ref <= 0 || pipeline_expr_kind_ord_at(arena, callee_ref) != GLUE_EXPR_KIND_VAR)
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
static int32_t glue_is_assign_u8_index_store_cast_i_c(struct ast_ASTArena *arena, int32_t er, int32_t *out_buf_ref,
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
  if (pipeline_expr_kind_ord_at(arena, pipeline_expr_index_base_ref(arena, left_ref)) != GLUE_EXPR_KIND_VAR)
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
static int32_t glue_is_assign_sum_plus_u8_index_cast_c(struct ast_ASTArena *arena, int32_t er, int32_t *out_sum_ref,
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
  if (pipeline_expr_kind_ord_at(arena, pipeline_expr_index_base_ref(arena, ix_ref)) != GLUE_EXPR_KIND_VAR)
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
static int32_t glue_expr_var_name_eq_let_idx_c(struct ast_ASTArena *arena, int32_t var_expr_ref,
                                               int32_t body_ref, int32_t let_idx) {
  uint8_t vname[128];
  uint8_t lname[128];
  int32_t vlen;
  int32_t llen;
  int32_t k;
  if (!arena || var_expr_ref <= 0 || body_ref <= 0 || let_idx < 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, var_expr_ref) != GLUE_EXPR_KIND_VAR)
    return 0;
  vlen = pipeline_expr_var_name_len(arena, var_expr_ref);
  llen = pipeline_block_let_name_len(arena, body_ref, let_idx);
  if (vlen <= 0 || llen <= 0 || vlen != llen || vlen > 127)
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
