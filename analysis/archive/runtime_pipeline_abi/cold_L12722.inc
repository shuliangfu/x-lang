/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */

int32_t pipeline_asm_emit_neg_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
  int32_t op;
  int32_t use_i64_neg = 0;
  int32_t tr;
  int32_t kind_ord = -1;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return -1;
  op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (op == 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, op, ctx, ta) != 0)
    return -1;
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, op)) {
    if (ta == 1) {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x52b00001u) != 0)
        return -1;
      return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x4a010000u);
    }
    {
      static const uint8_t btc_eax_31[4] = {0x0f, 0xba, 0xf8, 0x1f};
      return pipeline_elf_ctx_append_bytes(elf_ctx, (uint8_t *)btc_eax_31, 4);
    }
  }
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, op)) {
    if (ta == 1) {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0xd2f00001u) != 0)
        return -1;
      return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0xca010000u);
    }
    {
      static const uint8_t btc_rax_63[5] = {0x48, 0x0f, 0xba, 0xf8, 0x3f};
      return pipeline_elf_ctx_append_bytes(elf_ctx, (uint8_t *)btc_rax_63, 5);
    }
  }
  tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
  if (tr <= 0)
    tr = pipeline_expr_resolved_type_ref(arena, op);
  if (tr <= 0)
    tr = glue_var_decl_type_ref_elf_c(arena, ctx, op);
  if (tr > 0)
    kind_ord = pipeline_type_kind_ord_at(arena, tr);
  if (kind_ord == 4 || kind_ord == 5 || kind_ord == 6 || kind_ord == 7 || kind_ord == 9)
    use_i64_neg = 1;
  if (!use_i64_neg && pipeline_expr_kind_ord_at(arena, op) == 0) {
    int64_t v64 = pipeline_expr_int64_val_at(arena, op);
    if (v64 < (int64_t)INT32_MIN || v64 > (int64_t)INT32_MAX)
      use_i64_neg = 1;
  }
  if (use_i64_neg) {
    if (ta == 0) {
      static const uint8_t neg_rax[3] = {0x48, 0xf7, 0xd8};
      return pipeline_elf_ctx_append_bytes(elf_ctx, (uint8_t *)neg_rax, 3);
    }
    if (ta == 1) {
      static const uint8_t neg_x0[4] = {0xe0, 0x03, 0x00, 0xcb};
      return pipeline_elf_ctx_append_bytes(elf_ctx, (uint8_t *)neg_x0, 4);
    }
  }
  if (backend_enc_neg_eax_arch(elf_ctx, ta) != 0)
    return -1;
  {
    int32_t tr_n = pipeline_expr_resolved_type_ref(arena, expr_ref);
    int32_t k_n = (tr_n > 0) ? pipeline_type_kind_ord_at(arena, tr_n) : -1;
    if (k_n == 0)
      return glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx, ta);
    if (k_n == 2 && ta == 0) {
      static const uint8_t and_eax_ff[5] = {0x25, 0xff, 0x00, 0x00, 0x00};
      return pipeline_elf_ctx_append_bytes(elf_ctx, (uint8_t *)and_eax_ff, 5);
    }
    if (k_n == 8) {
      uint8_t nm[256];
      int32_t nlen = pipeline_type_named_name_into(arena, tr_n, nm);
      if (nlen == 3 && nm[0] == (uint8_t)'u' && nm[1] == (uint8_t)'1' && nm[2] == (uint8_t)'6' && ta == 0) {
        static const uint8_t and_eax_ffff[5] = {0x25, 0xff, 0xff, 0x00, 0x00};
        return pipeline_elf_ctx_append_bytes(elf_ctx, (uint8_t *)and_eax_ffff, 5);
      }
    }
  }
  return 0;
}

int32_t pipeline_asm_emit_lognot_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
  int32_t op;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return -1;
  op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (op == 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, op, ctx, ta) != 0)
    return -1;
  if (backend_enc_test_eax_eax_arch(elf_ctx, ta) != 0)
    return -1;
  return backend_enc_setz_movzbl_eax_arch(elf_ctx, ta);
}

int32_t pipeline_asm_emit_bitnot_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
  int32_t op;
  int32_t use_i64_not = 0;
  int32_t tr;
  int32_t kind_ord = -1;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return -1;
  op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (op == 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, op, ctx, ta) != 0)
    return -1;
  tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
  if (tr <= 0)
    tr = pipeline_expr_resolved_type_ref(arena, op);
  if (tr <= 0)
    tr = glue_var_decl_type_ref_elf_c(arena, ctx, op);
  if (tr > 0)
    kind_ord = pipeline_type_kind_ord_at(arena, tr);
  if (kind_ord == 4 || kind_ord == 5 || kind_ord == 6 || kind_ord == 7 || kind_ord == 9)
    use_i64_not = 1;
  if (use_i64_not) {
    if (ta == 0) {
      static const uint8_t not_rax[3] = {0x48, 0xf7, 0xd0};
      return pipeline_elf_ctx_append_bytes(elf_ctx, (uint8_t *)not_rax, 3);
    }
    if (ta == 1) {
      static const uint8_t mvn_x0[4] = {0xe0, 0x03, 0x20, 0xaa};
      return pipeline_elf_ctx_append_bytes(elf_ctx, (uint8_t *)mvn_x0, 4);
    }
  }
  if (backend_enc_not_eax_arch(elf_ctx, ta) != 0)
    return -1;
  if (kind_ord == 0)
    return glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx, ta);
  return 0;
}

/*
 * wave134: pipeline_asm_emit_match pure-owned leave cold twins.
 * PREFER pure; cold path when PREFER!=1 / hybrid fail.
 * Faces: match_elf + expr_if_elf + match subject context + name_is_subject_field.
 */
extern int32_t pipeline_expr_match_matched_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_match_num_arms_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_match_arm_is_wildcard(void *arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_guard_ref(void *arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_result_ref(void *arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_is_enum_variant(void *arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_variant_index(void *arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_lit_val(void *arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_if_cond_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_if_then_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_if_else_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_expr_if_arm_elf_c(void *arena, void *elf_ctx, int32_t arm_ref, void *ctx,
                                                   int32_t ta);
extern int32_t pipeline_asm_emit_next_label_c(void *ctx, uint8_t *buf, int32_t buf_size);
extern int32_t glue_enc_jz_after_bool_in_eax(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_jmp_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_label_arch(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_global, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_imm32_to_w0_arch(void *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_cmp_rbx_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_jne_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern void *pipeline_asm_emit_module_ref_c(void);
extern int32_t pipeline_asm_emit_func_index_c(void);
extern int32_t pipeline_expr_var_name_len(void *arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(void *arena, int32_t expr_ref, uint8_t *out64);
extern int32_t pipeline_module_func_param_type_ref_for_name(void *module, int32_t func_index, uint8_t *var_name,
                                                           int32_t name_len);
extern int32_t pipeline_module_num_struct_layouts_at(void *module);
extern int32_t pipeline_module_struct_layout_name_len(void *module, int32_t idx);
extern int32_t pipeline_module_struct_layout_name_byte_at(void *module, int32_t idx, int32_t off);
extern int32_t pipeline_module_struct_layout_num_fields(void *module, int32_t layout_idx);
extern int32_t pipeline_module_struct_layout_field_name_len(void *module, int32_t layout_idx, int32_t fi);
extern void pipeline_module_struct_layout_field_name_into(void *module, int32_t layout_idx, int32_t fi, uint8_t *out64);

static int32_t g_codegen_match_matched_ref = 0;
static int32_t g_codegen_match_subject_ty = 0;
static void *g_codegen_match_mod = 0;

void pipeline_codegen_match_set_subject_c(void *module, int32_t matched_ref, int32_t subject_ty) {
  g_codegen_match_mod = module;
  g_codegen_match_matched_ref = matched_ref;
  g_codegen_match_subject_ty = subject_ty;
}

void pipeline_codegen_match_clear_subject_c(void) {
  g_codegen_match_mod = 0;
  g_codegen_match_matched_ref = 0;
  g_codegen_match_subject_ty = 0;
}

int32_t pipeline_codegen_match_matched_ref_c(void) {
  return g_codegen_match_matched_ref;
}

int32_t pipeline_codegen_match_subject_ty_c(void) {
  return g_codegen_match_subject_ty;
}

void *pipeline_codegen_match_mod_c(void) {
  return g_codegen_match_mod;
}

int32_t pipeline_codegen_match_name_is_subject_field_c(void *module, void *arena, uint8_t *name, int32_t name_len) {
  int32_t ty;
  int32_t k;
  int32_t nsl;
  int32_t fi;
  int32_t nf;
  int32_t fl;
  int32_t j;
  uint8_t tnm[256];
  uint8_t fnm[256];
  int32_t tnl;
  if (!module || !arena || !name || name_len <= 0)
    return 0;
  ty = g_codegen_match_subject_ty;
  if (ty <= 0 || g_codegen_match_mod != module || g_codegen_match_matched_ref <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, ty) != 8)
    return 0;
  tnl = pipeline_type_named_name_into(arena, ty, tnm);
  if (tnl <= 0)
    return 0;
  nsl = pipeline_module_num_struct_layouts_at(module);
  for (k = 0; k < nsl; k++) {
    fl = pipeline_module_struct_layout_name_len(module, k);
    if (fl != tnl)
      continue;
    {
      int32_t match = 1;
      int32_t bi;
      for (bi = 0; bi < fl && match; bi++) {
        if (pipeline_module_struct_layout_name_byte_at(module, k, bi) != (int32_t)tnm[bi])
          match = 0;
      }
      if (!match)
        continue;
    }
    nf = pipeline_module_struct_layout_num_fields(module, k);
    for (fi = 0; fi < nf; fi++) {
      int32_t fnl = pipeline_module_struct_layout_field_name_len(module, k, fi);
      if (fnl != name_len)
        continue;
      memset(fnm, 0, sizeof(fnm));
      pipeline_module_struct_layout_field_name_into(module, k, fi, fnm);
      {
        int32_t match = 1;
        for (j = 0; j < fnl && match; j++) {
          if (fnm[j] != name[j])
            match = 0;
        }
        if (match)
          return 1;
      }
    }
  }
  return 0;
}

