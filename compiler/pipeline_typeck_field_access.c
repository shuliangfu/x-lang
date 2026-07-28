/**
 * pipeline_typeck_field_access.c — EXPR_FIELD_ACCESS 类型检查的 C glue（从 typeck.x 机械移植）。
 *
 * 由 pipeline_glue.c #include 并入同一翻译单元；不单独编译。
 * 子逻辑导出 pipeline_typeck_field_*_c 供 typeck.x EMIT_HEAVY 编排；仍保留 pipeline_typeck_check_expr_field_access_c（strict_glue）。
 * 依赖 typeck_x_no_layout_partial 导出的 typeck_* helper 与 pipeline_* 池访问器。
 */

/* typeck_x_no_layout_partial 符号（X 经 C gen 带 typeck_ 前缀）；find_or_alloc_ptr 见 typeck_x_link_alias.c。 */
extern int32_t typeck_name_equal(uint8_t *a, int32_t a_len, uint8_t *b, int32_t b_len);
extern int32_t typeck_find_or_alloc_named_type_ref(struct ast_ASTArena *arena, uint8_t *name, int32_t name_len);
extern int32_t typeck_ensure_i32_type_ref(struct ast_ASTArena *arena);
extern int32_t typeck_ensure_u8_type_ref(struct ast_ASTArena *arena);
extern int32_t typeck_ensure_usize_type_ref(struct ast_ASTArena *arena);
extern int32_t typeck_ensure_array_type_ref_named_elem(struct ast_ASTArena *arena, uint8_t *elem_nm,
                                                       int32_t elem_nm_len, int32_t array_size);
extern int32_t typeck_find_or_alloc_array_type_ref(struct ast_ASTArena *arena, int32_t elem_ref, int32_t array_size);
extern int32_t find_or_alloc_ptr_type_ref(struct ast_ASTArena *arena, int32_t elem_ref);
extern int32_t typeck_get_field_offset_from_layout_deps(struct ast_Module *module, struct ast_PipelineDepCtx *ctx,
                                                        uint8_t *type_name, int32_t type_name_len, uint8_t *field_name,
                                                        int32_t field_name_len);
extern int32_t typeck_get_field_type_ref_from_layout_deps(struct ast_Module *module, struct ast_ASTArena *arena,
                                                            struct ast_PipelineDepCtx *ctx, uint8_t *type_name,
                                                            int32_t type_name_len, uint8_t *field_name,
                                                            int32_t field_name_len);
extern int32_t typeck_inline_u8_64_array_field_type_ref(struct ast_ASTArena *arena, uint8_t *field_name,
                                                        int32_t field_name_len);
extern int32_t typeck_expr_inline_array_field_type_ref(struct ast_ASTArena *arena, uint8_t *field_name,
                                                       int32_t field_name_len);
extern int32_t pipeline_module_top_level_let_is_const(struct ast_Module *m, int32_t idx);
extern int32_t pipeline_module_top_level_let_type_ref(struct ast_Module *m, int32_t idx);
extern int32_t typeck_top_level_let_name_equal(struct ast_Module *module, int32_t tl_idx, uint8_t *name,
                                               int32_t name_len);
extern void lsp_diag_report_typeck(int line, int col, const char *fmt, ...);
extern int32_t pipeline_expr_line_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_col_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern int32_t pipeline_module_import_binding_name_len(struct ast_Module *module, int32_t idx);
extern uint8_t pipeline_module_import_binding_name_byte_at(struct ast_Module *module, int32_t idx, int32_t off);
extern int32_t pipeline_typeck_field_soa_index_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                                int32_t base_ref);

/** dep 模块顶层 const 是否匹配 name；命中时写出 type_ref。 */
static int32_t pipeline_typeck_dep_top_level_const_match(struct ast_Module *dep_mod, uint8_t *name, int32_t name_len,
                                                         int32_t *out_type_ref) {
  int32_t tl;
  int32_t ntl;
  int32_t tr;
  if (!dep_mod || name_len <= 0 || !out_type_ref)
    return 0;
  ntl = dep_mod->num_top_level_lets;
  for (tl = 0; tl < ntl; tl++) {
    if (!pipeline_module_top_level_let_is_const(dep_mod, tl))
      continue;
    if (!typeck_top_level_let_name_equal(dep_mod, tl, name, name_len))
      continue;
    tr = pipeline_module_top_level_let_type_ref(dep_mod, tl);
    if (tr <= 0)
      continue;
    *out_type_ref = tr;
    return 1;
  }
  return 0;
}

/** 写出含 const 的 import binding 名，供裸名 const 报错提示。 */
static int32_t pipeline_typeck_import_const_binding_hint(struct ast_Module *module, struct ast_PipelineDepCtx *ctx,
                                                         uint8_t *const_name, int32_t const_name_len, uint8_t *bind_out,
                                                         int32_t bind_cap) {
  int32_t di;
  int32_t nd;
  int32_t tr;
  if (!module || !ctx || const_name_len <= 0 || !bind_out || bind_cap <= 0)
    return 0;
  bind_out[0] = '\0';
  nd = pipeline_dep_ctx_ndep(ctx);
  for (di = 0; di < nd && di < module->num_imports; di++) {
    struct ast_Module *dm = pipeline_dep_ctx_module_at(ctx, di);
    if (!dm || !pipeline_typeck_dep_top_level_const_match(dm, const_name, const_name_len, &tr))
      continue;
    {
      int32_t bl = pipeline_module_import_binding_name_len(module, di);
      int32_t k;
      if (bl > 0 && bl < bind_cap) {
        for (k = 0; k < bl; k++)
          bind_out[k] = pipeline_module_import_binding_name_byte_at(module, di, k);
        bind_out[bl] = '\0';
        return 1;
      }
    }
  }
  return 0;
}

/**
 * 裸名访问 dep 模块顶层 const 时报错（须 binding.CONST）；返回 1 表示已报错。
 */
int32_t pipeline_typeck_reject_bare_import_const_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   int32_t expr_ref, struct ast_PipelineDepCtx *ctx, uint8_t *vbuf,
                                                   int32_t vnlen) {
  int32_t di;
  int32_t nd;
  int32_t tr;
  int32_t line;
  int32_t col;
  uint8_t hint[128];
  if (!module || !arena || !ctx || vnlen <= 0 || !vbuf)
    return 0;
  nd = pipeline_dep_ctx_ndep(ctx);
  for (di = 0; di < nd; di++) {
    struct ast_Module *dm = pipeline_dep_ctx_module_at(ctx, di);
    if (!dm || !pipeline_typeck_dep_top_level_const_match(dm, vbuf, vnlen, &tr))
      continue;
    line = pipeline_expr_line_at(arena, expr_ref);
    col = pipeline_expr_col_at(arena, expr_ref);
    hint[0] = '\0';
    if (pipeline_typeck_import_const_binding_hint(module, ctx, vbuf, vnlen, hint, (int32_t)sizeof(hint))) {
      lsp_diag_report_typeck((int)line, (int)col, "import constant '%.*s' must be qualified; use %s.%.*s",
                             (int)vnlen, vbuf, hint, (int)vnlen, vbuf);
    } else {
      lsp_diag_report_typeck((int)line, (int)col, "import constant '%.*s' must be qualified as binding.%.*s",
                             (int)vnlen, vbuf, (int)vnlen, vbuf);
    }
    return 1;
  }
  return 0;
}

extern int32_t typeck_expr_field_access_fallback_scalar_type_ref(struct ast_ASTArena *arena, uint8_t *field_name,
                                                                 int32_t field_name_len);
extern int32_t typeck_field_access_lexer_wrapper_fallback(struct ast_ASTArena *arena, int32_t base_type_ref,
                                                          uint8_t *field_name, int32_t field_name_len);
/* wave465: module concrete-type probe for type-param field ambient fill */
extern int32_t pipeline_module_struct_layout_name_len(struct ast_Module *module, int32_t idx);
extern void pipeline_module_struct_layout_name_into(struct ast_Module *module, int32_t idx, uint8_t *out);
extern int32_t pipeline_module_enum_name_len(struct ast_Module *module, int32_t idx);
extern uint8_t pipeline_module_enum_name_byte_at(struct ast_Module *module, int32_t idx, int32_t off);
extern int32_t pipeline_type_named_name_into(struct ast_ASTArena *arena, int32_t type_ref, uint8_t *out);
extern void driver_diagnostic_typeck_ptr_field(int32_t bt_kind, int32_t inner_kind, int32_t inner_nlen,
                                               int32_t base_resolved_ref, int32_t num_struct_layouts);

/** 递归检查子表达式；定义于 pipeline_glue.c（本文件在其之前 include）。 */
extern int32_t pipeline_typeck_check_expr_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                            int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);

/**
 * EXPR_FIELD_ACCESS：base VAR 未绑定时按命名类型预绑定（glue 读 var 池）。
 */
void pipeline_typeck_field_prebind_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                            struct ast_PipelineDepCtx *ctx) {
  int32_t base_ref;
  int32_t vnlen;
  uint8_t vbuf[128] /* wave577 Cap name into */;
  int32_t param_pre;
  int32_t nt_pre;

  base_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
  if (ast_ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena->num_exprs)
    return;
  if (pipeline_expr_kind_ord_at(arena, base_ref) != (int32_t)ast_ExprKind_EXPR_VAR)
    return;
  if (!ast_ref_is_null(pipeline_expr_resolved_type_ref(arena, base_ref)))
    return;
  vnlen = pipeline_expr_var_name_len(arena, base_ref);
  if (vnlen <= 0)
    return;
  pipeline_expr_var_name_into(arena, base_ref, &vbuf[0]);
  if (ctx->current_func_index >= 0 && ctx->current_func_index < module->num_funcs) {
    param_pre = pipeline_module_func_param_type_ref_for_name(module, ctx->current_func_index, &vbuf[0], vnlen);
    if (!ast_ref_is_null(param_pre))
      return;
  }
  nt_pre = typeck_find_or_alloc_named_type_ref(arena, &vbuf[0], vnlen);
  if (nt_pre != 0)
    pipeline_expr_set_resolved_type_ref(arena, base_ref, nt_pre);
}

/**
 * EXPR_FIELD_ACCESS：*ASTArena / *Module 已知字段特判。
 * 返回 1 表示已写入 resolved_type_ref+offset，0 表示未命中。
 */
int32_t pipeline_typeck_field_known_ptr_types_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                       int32_t expr_ref, int32_t base_ref,
                                                       int32_t num_struct_layouts) {
  int32_t base_ty;
  int32_t bt_kind;
  int32_t elem_ty;
  uint8_t inner_nm_buf[128] /* wave577 Cap name into */;
  int32_t inner_nm_len;
  int32_t inner_ord;
  int32_t fl;
  uint8_t fn_buf[128] /* wave577 Cap name into */;
  static const uint8_t nm_astarena[8] = {65, 83, 84, 65, 114, 101, 110, 97};
  static const uint8_t nm_types[5] = {116, 121, 112, 101, 115};
  static const uint8_t nm_num_types[9] = {110, 117, 109, 95, 116, 121, 112, 101, 115};
  static const uint8_t nm_exprs[5] = {101, 120, 112, 114, 115};
  static const uint8_t nm_num_exprs[9] = {110, 117, 109, 95, 101, 120, 112, 114, 115};
  static const uint8_t nm_blocks[6] = {98, 108, 111, 99, 107, 115};
  static const uint8_t nm_num_blocks[10] = {110, 117, 109, 95, 98, 108, 111, 99, 107, 115};
  static const uint8_t nm_funcs[5] = {102, 117, 110, 99, 115};
  static const uint8_t nm_num_funcs[9] = {110, 117, 109, 95, 102, 117, 110, 99, 115};
  static const uint8_t nm_ty[4] = {84, 121, 112, 101};
  static const uint8_t nm_ex[4] = {69, 120, 112, 114};
  static const uint8_t nm_bl[5] = {66, 108, 111, 99, 107};
  static const uint8_t nm_fu[4] = {70, 117, 110, 99};
  static const uint8_t nm_module[6] = {77, 111, 100, 117, 108, 101};
  static const uint8_t nm_funcs_m[5] = {102, 117, 110, 99, 115};
  static const uint8_t nm_num_funcs_m[9] = {110, 117, 109, 95, 102, 117, 110, 99, 115};
  static const uint8_t nm_struct_layouts_m[14] = {115, 116, 114, 117, 99, 116, 95, 108, 97, 121, 111, 117, 116, 115};
  static const uint8_t nm_num_struct_layouts_m[18] = {110, 117, 109, 95, 115, 116, 114, 117, 99, 116, 95, 108, 97,
                                                     121, 111, 117, 116, 115};
  static const uint8_t nm_fu_m[4] = {70, 117, 110, 99};
  static const uint8_t nm_sl_m[12] = {83, 116, 114, 117, 99, 116, 76, 97, 121, 111, 117, 116};
  int32_t i32r_at;
  int32_t i32r_mod;
  int32_t matched;
  int32_t arr_ty;

  if (ast_ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena->num_exprs)
    return 0;
  base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
  if (ast_ref_is_null(base_ty) || base_ty <= 0 || base_ty > arena->num_types)
    return 0;
  bt_kind = pipeline_type_kind_ord_at(arena, base_ty);
  if (bt_kind != (int32_t)ast_TypeKind_TYPE_PTR)
    return 0;
  elem_ty = pipeline_type_elem_ref_at(arena, base_ty);
  if (ast_ref_is_null(elem_ty))
    return 0;
  inner_nm_len = pipeline_type_named_name_into(arena, elem_ty, &inner_nm_buf[0]);
  inner_ord = pipeline_type_kind_ord_at(arena, elem_ty);
  driver_diagnostic_typeck_ptr_field((int32_t)ast_TypeKind_TYPE_PTR, inner_ord, inner_nm_len, base_ty,
                                     num_struct_layouts);
  fl = pipeline_expr_field_access_name_len(arena, expr_ref);
  if (fl <= 0 || fl > 127)
    return 0;
  pipeline_expr_field_access_name_into(arena, expr_ref, &fn_buf[0]);
  i32r_at = typeck_ensure_i32_type_ref(arena);
  i32r_mod = typeck_ensure_i32_type_ref(arena);
  matched = 0;
  if (inner_ord == (int32_t)ast_TypeKind_TYPE_NAMED && inner_nm_len == 8 &&
      typeck_name_equal(&inner_nm_buf[0], inner_nm_len, (uint8_t *)&nm_astarena[0], 8)) {
    if (fl == 5 && typeck_name_equal(&fn_buf[0], fl, (uint8_t *)&nm_types[0], 5)) {
      pipeline_expr_set_field_access_offset(arena, expr_ref, 0);
      arr_ty = typeck_ensure_array_type_ref_named_elem(arena, (uint8_t *)&nm_ty[0], 4, 512);
      if (arr_ty != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, arr_ty);
        matched = 1;
      }
    }
    if (matched == 0 && fl == 9 && typeck_name_equal(&fn_buf[0], fl, (uint8_t *)&nm_num_types[0], 9)) {
      pipeline_expr_set_field_access_offset(arena, expr_ref, 40960);
      if (i32r_at != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, i32r_at);
        matched = 1;
      }
    }
    if (matched == 0 && fl == 5 && typeck_name_equal(&fn_buf[0], fl, (uint8_t *)&nm_exprs[0], 5)) {
      pipeline_expr_set_field_access_offset(arena, expr_ref, 40968);
      arr_ty = typeck_ensure_array_type_ref_named_elem(arena, (uint8_t *)&nm_ex[0], 4, 32768);
      if (arr_ty != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, arr_ty);
        matched = 1;
      }
    }
    if (matched == 0 && fl == 9 && typeck_name_equal(&fn_buf[0], fl, (uint8_t *)&nm_num_exprs[0], 9)) {
      pipeline_expr_set_field_access_offset(arena, expr_ref, 6234120);
      if (i32r_at != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, i32r_at);
        matched = 1;
      }
    }
    if (matched == 0 && fl == 6 && typeck_name_equal(&fn_buf[0], fl, (uint8_t *)&nm_blocks[0], 6)) {
      pipeline_expr_set_field_access_offset(arena, expr_ref, 6234124);
      arr_ty = typeck_ensure_array_type_ref_named_elem(arena, (uint8_t *)&nm_bl[0], 5, 8192);
      if (arr_ty != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, arr_ty);
        matched = 1;
      }
    }
    if (matched == 0 && fl == 10 && typeck_name_equal(&fn_buf[0], fl, (uint8_t *)&nm_num_blocks[0], 10)) {
      pipeline_expr_set_field_access_offset(arena, expr_ref, 17184780);
      if (i32r_at != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, i32r_at);
        matched = 1;
      }
    }
    if (matched == 0 && fl == 5 && typeck_name_equal(&fn_buf[0], fl, (uint8_t *)&nm_funcs[0], 5)) {
      pipeline_expr_set_field_access_offset(arena, expr_ref, 17184784);
      arr_ty = typeck_ensure_array_type_ref_named_elem(arena, (uint8_t *)&nm_fu[0], 4, 256);
      if (arr_ty != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, arr_ty);
        matched = 1;
      }
    }
    if (matched == 0 && fl == 9 && typeck_name_equal(&fn_buf[0], fl, (uint8_t *)&nm_num_funcs[0], 9)) {
      pipeline_expr_set_field_access_offset(arena, expr_ref, 17371152);
      if (i32r_at != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, i32r_at);
        matched = 1;
      }
    }
    if (matched != 0)
      return 1;
  }
  if (inner_ord == (int32_t)ast_TypeKind_TYPE_NAMED && inner_nm_len == 6 &&
      typeck_name_equal(&inner_nm_buf[0], inner_nm_len, (uint8_t *)&nm_module[0], 6)) {
    matched = 0;
    if (fl == 5 && typeck_name_equal(&fn_buf[0], fl, (uint8_t *)&nm_funcs_m[0], 5)) {
      arr_ty = typeck_ensure_array_type_ref_named_elem(arena, (uint8_t *)&nm_fu_m[0], 4, 256);
      if (arr_ty != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, arr_ty);
        matched = 1;
      }
    }
    if (matched == 0 && fl == 14 && typeck_name_equal(&fn_buf[0], fl, (uint8_t *)&nm_struct_layouts_m[0], 14)) {
      arr_ty = typeck_ensure_array_type_ref_named_elem(arena, (uint8_t *)&nm_sl_m[0], 12, 32);
      if (arr_ty != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, arr_ty);
        matched = 1;
      }
    }
    if (matched == 0 && fl == 9 && typeck_name_equal(&fn_buf[0], fl, (uint8_t *)&nm_num_funcs_m[0], 9)) {
      if (i32r_mod != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, i32r_mod);
        matched = 1;
      }
    }
    if (matched == 0 && fl == 18 && typeck_name_equal(&fn_buf[0], fl, (uint8_t *)&nm_num_struct_layouts_m[0], 18)) {
      if (i32r_mod != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, i32r_mod);
        matched = 1;
      }
    }
  }
  if (matched != 0)
    return 1;
  return 0;
}

/**
 * EXPR_FIELD_ACCESS：具名类型 layout/enum/TypeKind/TokenKind 字段。
 * 返回 2 表示用户 enum 已解析完毕（caller 应 return 0）；0 表示继续 field 回落逻辑。
 */
int32_t pipeline_typeck_field_layout_named_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    int32_t expr_ref, int32_t base_ref,
                                                    struct ast_PipelineDepCtx *ctx) {
  int32_t base_ty;
  int32_t bt_kind;
  int32_t layout_named_ref;
  uint8_t layout_nm_buf[128] /* wave577 Cap name into */;
  int32_t layout_nm_len;
  uint8_t fn_buf[128] /* wave577 Cap name into */;
  int32_t fl2;
  int32_t user_ev_tag;
  static const uint8_t nm_type_kind_ty[8] = {84, 121, 112, 101, 75, 105, 110, 100};
  int32_t skip_layout_for_type_kind;
  int32_t vv;
  int32_t off;
  int32_t ftr;
  int32_t i32r_ev;
  int32_t i32r_tk;
  int32_t i32r_eof;
  static const uint8_t nm_tok_kind_ty[9] = {84, 111, 107, 101, 110, 75, 105, 110, 100};
  static const uint8_t nm_eof_variant[9] = {84, 79, 75, 69, 78, 95, 69, 79, 70};
  int32_t elem_ty;

  if (ast_ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena->num_exprs)
    return 0;
  base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
  if (ast_ref_is_null(base_ty) || base_ty <= 0 || base_ty > arena->num_types)
    return 0;
  bt_kind = pipeline_type_kind_ord_at(arena, base_ty);
  layout_named_ref = 0;
  if (bt_kind == (int32_t)ast_TypeKind_TYPE_PTR) {
    elem_ty = pipeline_type_elem_ref_at(arena, base_ty);
    if (!ast_ref_is_null(elem_ty) && pipeline_type_kind_ord_at(arena, elem_ty) == (int32_t)ast_TypeKind_TYPE_NAMED)
      layout_named_ref = elem_ty;
  } else if (bt_kind == (int32_t)ast_TypeKind_TYPE_NAMED) {
    layout_named_ref = base_ty;
  }
  if (layout_named_ref == 0)
    return 0;
  layout_nm_len = pipeline_type_named_name_into(arena, layout_named_ref, &layout_nm_buf[0]);
  if (layout_nm_len <= 0 || pipeline_type_kind_ord_at(arena, layout_named_ref) != (int32_t)ast_TypeKind_TYPE_NAMED)
    return 0;
  fl2 = pipeline_expr_field_access_name_len(arena, expr_ref);
  /* wave582 Cap residual: field name content ≤127. */
  if (fl2 <= 0 || fl2 > 127)
    return 0;
  pipeline_expr_field_access_name_into(arena, expr_ref, &fn_buf[0]);
  user_ev_tag = pipeline_module_enum_variant_tag_for_names(module, &layout_nm_buf[0], layout_nm_len, &fn_buf[0], fl2);
  if (user_ev_tag >= 0) {
    /* 用户 enum 变体：resolved 为枚举 TYPE_NAMED（非 i32 tag），使 return Method.GET 等与签名匹配。
     * codegen 仍读 field_access_is_enum_variant + enum_variant_tag 发射整型判别值。 */
    pipeline_expr_set_field_access_enum_variant(arena, expr_ref, user_ev_tag);
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, layout_named_ref);
    return 2;
  }
  vv = -1;
  skip_layout_for_type_kind = 0;
  if (layout_nm_len == 8 && typeck_name_equal(&layout_nm_buf[0], layout_nm_len, (uint8_t *)&nm_type_kind_ty[0], 8)) {
    static const uint8_t s_i32[8] = {84, 121, 112, 101, 95, 73, 51, 50};
    static const uint8_t s_bool[9] = {84, 121, 112, 101, 95, 66, 79, 79, 76};
    static const uint8_t s_u8[7] = {84, 121, 112, 101, 95, 85, 56};
    static const uint8_t s_u32[8] = {84, 121, 112, 101, 95, 85, 51, 50};
    static const uint8_t s_u64[8] = {84, 121, 112, 101, 95, 85, 54, 52};
    static const uint8_t s_i64[8] = {84, 121, 112, 101, 95, 73, 54, 52};
    static const uint8_t s_usize[10] = {84, 121, 112, 101, 95, 85, 83, 73, 90, 69};
    static const uint8_t s_isize[10] = {84, 121, 112, 101, 95, 73, 83, 73, 90, 69};
    static const uint8_t s_named[10] = {84, 121, 112, 101, 95, 78, 65, 77, 69, 68};
    static const uint8_t s_ptr[8] = {84, 121, 112, 101, 95, 80, 84, 82};
    static const uint8_t s_arr[10] = {84, 121, 112, 101, 95, 65, 82, 82, 65, 89};
    static const uint8_t s_sli[10] = {84, 121, 112, 101, 95, 83, 76, 73, 67, 69};
    static const uint8_t s_vec[11] = {84, 121, 112, 101, 95, 86, 69, 67, 84, 79, 82};
    static const uint8_t s_f32[8] = {84, 121, 112, 101, 95, 70, 51, 50};
    static const uint8_t s_f64[8] = {84, 121, 112, 101, 95, 70, 54, 52};
    static const uint8_t s_void[9] = {84, 121, 112, 101, 95, 86, 79, 73, 68};
    if (vv < 0 && fl2 == 8 && typeck_name_equal(&fn_buf[0], fl2, (uint8_t *)&s_i32[0], 8))
      vv = 0;
    if (vv < 0 && fl2 == 9 && typeck_name_equal(&fn_buf[0], fl2, (uint8_t *)&s_bool[0], 9))
      vv = 1;
    if (vv < 0 && fl2 == 7 && typeck_name_equal(&fn_buf[0], fl2, (uint8_t *)&s_u8[0], 7))
      vv = 2;
    if (vv < 0 && fl2 == 8 && typeck_name_equal(&fn_buf[0], fl2, (uint8_t *)&s_u32[0], 8))
      vv = 3;
    if (vv < 0 && fl2 == 8 && typeck_name_equal(&fn_buf[0], fl2, (uint8_t *)&s_u64[0], 8))
      vv = 4;
    if (vv < 0 && fl2 == 8 && typeck_name_equal(&fn_buf[0], fl2, (uint8_t *)&s_i64[0], 8))
      vv = 5;
    if (vv < 0 && fl2 == 10 && typeck_name_equal(&fn_buf[0], fl2, (uint8_t *)&s_usize[0], 10))
      vv = 6;
    if (vv < 0 && fl2 == 10 && typeck_name_equal(&fn_buf[0], fl2, (uint8_t *)&s_isize[0], 10))
      vv = 7;
    if (vv < 0 && fl2 == 10 && typeck_name_equal(&fn_buf[0], fl2, (uint8_t *)&s_named[0], 10))
      vv = 8;
    if (vv < 0 && fl2 == 8 && typeck_name_equal(&fn_buf[0], fl2, (uint8_t *)&s_ptr[0], 8))
      vv = 9;
    if (vv < 0 && fl2 == 10 && typeck_name_equal(&fn_buf[0], fl2, (uint8_t *)&s_arr[0], 10))
      vv = 10;
    if (vv < 0 && fl2 == 10 && typeck_name_equal(&fn_buf[0], fl2, (uint8_t *)&s_sli[0], 10))
      vv = 11;
    if (vv < 0 && fl2 == 11 && typeck_name_equal(&fn_buf[0], fl2, (uint8_t *)&s_vec[0], 11))
      vv = 12;
    if (vv < 0 && fl2 == 8 && typeck_name_equal(&fn_buf[0], fl2, (uint8_t *)&s_f32[0], 8))
      vv = 13;
    if (vv < 0 && fl2 == 8 && typeck_name_equal(&fn_buf[0], fl2, (uint8_t *)&s_f64[0], 8))
      vv = 14;
    if (vv < 0 && fl2 == 9 && typeck_name_equal(&fn_buf[0], fl2, (uint8_t *)&s_void[0], 9))
      vv = 15;
    if (vv >= 0) {
      i32r_tk = typeck_ensure_i32_type_ref(arena);
      if (i32r_tk != 0) {
        pipeline_expr_set_field_access_enum_variant(arena, expr_ref, vv);
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, i32r_tk);
      }
      skip_layout_for_type_kind = 1;
    }
  }
  off = -1;
  ftr = 0;
  if (skip_layout_for_type_kind == 0) {
    off = typeck_get_field_offset_from_layout_deps(module, ctx, &layout_nm_buf[0], layout_nm_len, &fn_buf[0], fl2);
    if (off >= 0)
      pipeline_expr_set_field_access_offset(arena, expr_ref, off);
    ftr = typeck_get_field_type_ref_from_layout_deps(module, arena, ctx, &layout_nm_buf[0], layout_nm_len, &fn_buf[0], fl2);
    if (ftr != 0)
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, ftr);
  }
  if (off < 0 && ftr == 0 && layout_nm_len == 9 &&
      typeck_name_equal(&layout_nm_buf[0], layout_nm_len, (uint8_t *)&nm_tok_kind_ty[0], 9) && fl2 == 9 &&
      typeck_name_equal(&fn_buf[0], fl2, (uint8_t *)&nm_eof_variant[0], 9)) {
    i32r_eof = typeck_ensure_i32_type_ref(arena);
    if (i32r_eof != 0) {
      pipeline_expr_set_field_access_enum_variant(arena, expr_ref, 0);
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, i32r_eof);
    }
  }
  return 0;
}

/**
 * EXPR_FIELD_ACCESS：T[] 的 .length（usize）与 .data（*elem for any T）.
 *
 * Fat layout (PLATFORM: SHARED / SysV dual-GP home): { .data @ +0, .length @ +8 }.
 * Asm stack homes register byte0 at slot_off; high half at slot_off-8 (see
 * asm_local_slot_reg_offset / param dual-home). Emit must use field_access_offset so
 * lea base + add offset hits the correct half — previously offset stayed 0 and
 * s.length loaded .data (tests/slice/data_field.x exit 2).
 *
 * G.7 complete: .data must resolve to TYPE_PTR(elem) for i32/u8/u64/… — not only U8.
 * Old U8-only gate left s.data untyped for i32[] → INDEX `s.data[i]` T001 on Ubuntu
 * (formal core/slice/mod.x get_i32 / length.x co-emit typeck). mac often soft-pathed.
 *
 * wave346 Cap residual pure: TYPE_ARRAY / TYPE_VECTOR `.length` is also usize (compile-time
 * N). Prior: only TYPE_SLICE → fixed `a.length` never stamped; host C emitted `a.length`
 * on a C array (illegal); freestanding loaded slot[0] as length (run=10 not 3).
 * G.7: extend this authority — no second field_array helper. Emit paths use array_size_at.
 * PLATFORM: SHARED — typeck; host+fs emit co-land same wave.
 */
void pipeline_typeck_field_slice_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t base_ref) {
  int32_t base_ty;
  int32_t elem_ty;
  int32_t fl;
  int32_t bt_kind;
  uint8_t fn_buf[128] /* wave577 Cap name into */;
  static const uint8_t len_nm[6] = {108, 101, 110, 103, 116, 104};
  static const uint8_t dat_nm[4] = {100, 97, 116, 97};
  int32_t ut;
  int32_t ptr_ref;

  if (ast_ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena->num_exprs)
    return;
  base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
  if (ast_ref_is_null(base_ty) || base_ty <= 0 || base_ty > arena->num_types)
    return;
  bt_kind = pipeline_type_kind_ord_at(arena, base_ty);
  fl = pipeline_expr_field_access_name_len(arena, expr_ref);
  if (fl <= 0 || fl > 127)
    return;
  pipeline_expr_field_access_name_into(arena, expr_ref, &fn_buf[0]);
  /* wave346: fixed T[N] / SIMD vector lanes — `.length` is compile-time N as usize.
   * No fat-pointer offset (emit must not load from stack); stamp type only. */
  if ((bt_kind == (int32_t)ast_TypeKind_TYPE_ARRAY || bt_kind == (int32_t)ast_TypeKind_TYPE_VECTOR)
      && fl == 6 && typeck_name_equal(&fn_buf[0], fl, (uint8_t *)&len_nm[0], 6)) {
    if (pipeline_type_array_size_at(arena, base_ty) <= 0)
      return;
    ut = typeck_ensure_usize_type_ref(arena);
    if (ut != 0)
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, ut);
    return;
  }
  if (bt_kind != (int32_t)ast_TypeKind_TYPE_SLICE)
    return;
  elem_ty = pipeline_type_elem_ref_at(arena, base_ty);
  if (ast_ref_is_null(elem_ty))
    return;
  if (fl == 6 && typeck_name_equal(&fn_buf[0], fl, (uint8_t *)&len_nm[0], 6)) {
    ut = typeck_ensure_usize_type_ref(arena);
    if (ut != 0)
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, ut);
    /** G.7 authority: fat pointer second word at +8 (layout half, not rbp-distance). */
    pipeline_expr_set_field_access_offset(arena, expr_ref, 8);
    return;
  }
  if (fl == 4 && typeck_name_equal(&fn_buf[0], fl, (uint8_t *)&dat_nm[0], 4)) {
    /** G.7 authority: .data is *elem for every slice element kind (i32/u8/u64/…). */
    pipeline_expr_set_field_access_offset(arena, expr_ref, 0);
    ptr_ref = find_or_alloc_ptr_type_ref(arena, elem_ty);
    if (ptr_ref != 0)
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, ptr_ref);
  }
}

/**
 * EXPR_FIELD_ACCESS：layout 未命中时的字段名回落（CodegenOutBuf/inline array/scalar）。
 */
void pipeline_typeck_field_name_fallback_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t base_ref) {
  int32_t fl;
  uint8_t fn_buf[128] /* wave577 Cap name into */;
  int32_t base_ty;
  int32_t bt_kind;
  int32_t named_ref;
  uint8_t cob_nm[128] /* wave577 Cap name into */;
  int32_t cob_len;
  static const uint8_t nm_dat[4] = {100, 97, 116, 97};
  static const uint8_t nm_cob[13] = {67, 111, 100, 101, 103, 101, 110, 79, 117, 116, 66, 117, 102};
  int32_t u8r_cob;
  int32_t arr_cob;
  int32_t u8_fb;
  int32_t arr_fb;
  int32_t scalar_fb;
  int32_t elem_r;

  if (!ast_ref_is_null(pipeline_expr_resolved_type_ref(arena, expr_ref)))
    return;
  fl = pipeline_expr_field_access_name_len(arena, expr_ref);
  if (fl <= 0 || fl > 127)
    return;
  pipeline_expr_field_access_name_into(arena, expr_ref, &fn_buf[0]);
  if (fl == 4 && !ast_ref_is_null(base_ref) && base_ref > 0 && base_ref <= arena->num_exprs) {
    base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
    if (!ast_ref_is_null(base_ty) && base_ty > 0 && base_ty <= arena->num_types) {
      bt_kind = pipeline_type_kind_ord_at(arena, base_ty);
      named_ref = 0;
      if (bt_kind == (int32_t)ast_TypeKind_TYPE_PTR) {
        elem_r = pipeline_type_elem_ref_at(arena, base_ty);
        if (!ast_ref_is_null(elem_r) && pipeline_type_kind_ord_at(arena, elem_r) == (int32_t)ast_TypeKind_TYPE_NAMED)
          named_ref = elem_r;
      } else if (bt_kind == (int32_t)ast_TypeKind_TYPE_NAMED) {
        named_ref = base_ty;
      }
      if (named_ref != 0 && typeck_name_equal(&fn_buf[0], fl, (uint8_t *)&nm_dat[0], 4)) {
        cob_len = pipeline_type_named_name_into(arena, named_ref, &cob_nm[0]);
        if (cob_len == 13 && typeck_name_equal(&cob_nm[0], cob_len, (uint8_t *)&nm_cob[0], 13)) {
          u8r_cob = typeck_ensure_u8_type_ref(arena);
          if (u8r_cob != 0) {
            arr_cob = typeck_find_or_alloc_array_type_ref(arena, u8r_cob, 8388608);
            if (arr_cob != 0) {
              pipeline_expr_set_resolved_type_ref(arena, expr_ref, arr_cob);
              return;
            }
          }
        }
      }
    }
  }
  if (!ast_ref_is_null(pipeline_expr_resolved_type_ref(arena, expr_ref)))
    return;
  u8_fb = typeck_inline_u8_64_array_field_type_ref(arena, &fn_buf[0], fl);
  if (u8_fb != 0) {
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, u8_fb);
    return;
  }
  arr_fb = typeck_expr_inline_array_field_type_ref(arena, &fn_buf[0], fl);
  if (arr_fb != 0) {
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, arr_fb);
    return;
  }
  scalar_fb = typeck_expr_field_access_fallback_scalar_type_ref(arena, &fn_buf[0], fl);
  if (scalar_fb != 0)
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, scalar_fb);
}

/**
 * EXPR_FIELD_ACCESS：LexerResult 等 lexer wrapper 字段名语义回落。
 */
void pipeline_typeck_field_lexer_fallback_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                 int32_t expr_ref, int32_t base_ref, struct ast_PipelineDepCtx *ctx) {
  int32_t base_ty;
  int32_t elem_ty;
  int32_t fl;
  uint8_t fn_buf[128] /* wave577 Cap name into */;
  uint8_t vbuf[128] /* wave577 Cap name into */;
  int32_t vnlen;
  int32_t pr_fb;
  int32_t lx_fb;

  if (!ast_ref_is_null(pipeline_expr_resolved_type_ref(arena, expr_ref)))
    return;
  if (ast_ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena->num_exprs)
    return;
  fl = pipeline_expr_field_access_name_len(arena, expr_ref);
  if (fl <= 0 || fl > 127)
    return;
  pipeline_expr_field_access_name_into(arena, expr_ref, &fn_buf[0]);
  base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
  if (!ast_ref_is_null(base_ty) && base_ty > 0 && base_ty <= arena->num_types) {
    lx_fb = typeck_field_access_lexer_wrapper_fallback(arena, base_ty, &fn_buf[0], fl);
    if (lx_fb != 0) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, lx_fb);
      return;
    }
    if (pipeline_type_kind_ord_at(arena, base_ty) == (int32_t)ast_TypeKind_TYPE_PTR) {
      elem_ty = pipeline_type_elem_ref_at(arena, base_ty);
      if (!ast_ref_is_null(elem_ty)) {
        lx_fb = typeck_field_access_lexer_wrapper_fallback(arena, elem_ty, &fn_buf[0], fl);
        if (lx_fb != 0) {
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, lx_fb);
          return;
        }
      }
    }
  }
  if (!ast_ref_is_null(pipeline_expr_resolved_type_ref(arena, expr_ref)))
    return;
  if (pipeline_expr_kind_ord_at(arena, base_ref) != (int32_t)ast_ExprKind_EXPR_VAR)
    return;
  vnlen = pipeline_expr_var_name_len(arena, base_ref);
  if (vnlen <= 0 || vnlen > 127)
    return;
  if (ctx->current_func_index < 0 || ctx->current_func_index >= module->num_funcs)
    return;
  pipeline_expr_var_name_into(arena, base_ref, &vbuf[0]);
  pr_fb = pipeline_module_func_param_type_ref_for_name(module, ctx->current_func_index, &vbuf[0], vnlen);
  if (ast_ref_is_null(pr_fb))
    return;
  lx_fb = typeck_field_access_lexer_wrapper_fallback(arena, pr_fb, &fn_buf[0], fl);
  if (lx_fb != 0)
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, lx_fb);
}

/**
 * typeck.x::typeck_check_expr_field_access 的 C 委托：prebind → check base → known_ptr/layout/slice/fallback。
 */
/**
 * Import binding 特判：base 是 import binding（如 `backend`），field name 是 dep 模块中的函数名。
 * 从 dep 模块中查找函数，设置 field access 表达式的 resolved type 为函数返回类型。
 * 返回 1 表示命中（已处理），0 表示未命中（继续常规 field access typeck）。
 */
int32_t pipeline_typeck_field_import_binding_resolve_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                        int32_t expr_ref, int32_t base_ref,
                                                        struct ast_PipelineDepCtx *ctx) {
  uint8_t base_name[128]; /* wave577 Cap */
  int32_t base_name_len;
  uint8_t field_name[128]; /* wave577 Cap */
  int32_t field_name_len;
  int32_t i;
  int32_t n_imp;

  if (!module || !arena || base_ref <= 0 || !ctx)
    return 0;

  /* base 必须是 EXPR_VAR */
  if (pipeline_expr_kind_ord_at(arena, base_ref) != (int32_t)ast_ExprKind_EXPR_VAR)
    return 0;

  base_name_len = pipeline_expr_var_name_len(arena, base_ref);
  if (base_name_len <= 0 || base_name_len > 127)
    return 0;
  pipeline_expr_var_name_into(arena, base_ref, &base_name[0]);

  field_name_len = pipeline_expr_field_access_name_len(arena, expr_ref);
  if (field_name_len <= 0 || field_name_len > 127)
    return 0;
  pipeline_expr_field_access_name_into(arena, expr_ref, &field_name[0]);

  /* 检查 base_name 是否匹配某个 import binding */
  n_imp = module->num_imports;
  for (i = 0; i < n_imp; i++) {
    int32_t bind_len;
    struct ast_Module *dep_mod;
    int32_t j;
    int32_t nf;
    int32_t nd;

    bind_len = pipeline_module_import_binding_name_len(module, i);
    if (bind_len <= 0 || bind_len != base_name_len)
      continue;

    /* 逐字节比较 binding name 与 base_name */
    {
      int32_t k;
      int32_t match = 1;
      for (k = 0; k < bind_len && match; k++) {
        if (pipeline_module_import_binding_name_byte_at(module, i, k) != base_name[k])
          match = 0;
      }
      if (!match)
        continue;
    }

    /* 找到匹配的 import binding；dep 槽与 import 下标对齐 */
    dep_mod = 0;
    if (ctx) {
      nd = pipeline_dep_ctx_ndep(ctx);
      if (i < nd)
        dep_mod = pipeline_dep_ctx_module_at(ctx, i);
    }
    if (!dep_mod)
      continue;

    /* 在 dep 模块中查找函数 field_name */
    nf = pipeline_module_num_funcs(dep_mod);
    for (j = 0; j < nf; j++) {
      int32_t fn_len;
      int32_t k;
      int32_t match = 1;
      fn_len = pipeline_module_func_name_len_at(dep_mod, j);
      if (fn_len != field_name_len)
        continue;
      for (k = 0; k < fn_len && match; k++) {
        /* 用 scratch buffer 比较 */
        uint8_t fn_buf[128] /* wave577 Cap name into */;
        pipeline_module_func_name_copy64(dep_mod, j, fn_buf);
        if (fn_buf[k] != field_name[k])
          match = 0;
      }
      if (match) {
        /* 找到函数；设置 resolved type */
        int32_t ret_ty = pipeline_module_func_return_type_at(dep_mod, j);
        if (ret_ty > 0) {
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, ret_ty);
        }
        /* 也设置 base 的 resolved type 为 named type */
        if (ast_ref_is_null(pipeline_expr_resolved_type_ref(arena, base_ref))) {
          int32_t nt = typeck_find_or_alloc_named_type_ref(arena, &base_name[0], base_name_len);
          if (nt != 0)
            pipeline_expr_set_resolved_type_ref(arena, base_ref, nt);
        }
        return 1;
      }
    }

    /* 在 dep 模块中查找顶层 const field_name（如 async_mod.POLL_PENDING） */
    {
      int32_t const_ty = 0;
      if (pipeline_typeck_dep_top_level_const_match(dep_mod, &field_name[0], field_name_len, &const_ty)) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, const_ty);
        if (ast_ref_is_null(pipeline_expr_resolved_type_ref(arena, base_ref))) {
          int32_t nt = typeck_find_or_alloc_named_type_ref(arena, &base_name[0], base_name_len);
          if (nt != 0)
            pipeline_expr_set_resolved_type_ref(arena, base_ref, nt);
        }
        return 1;
      }
    }
  }
  return 0;
}

/**
 * wave454: reverse-infer the owner type of a FIELD_ACCESS from the field name
 * (and optional outer expected field type) among module struct layouts.
 *
 * Why: the ambient expected type of `base.field` is the *field result* type
 * (e.g. i32 for `.v`), not the base type. Passing that expected into base
 * typeck made wave453 bare ret-only generic inference pin T=i32 for
 * `return mk_default().v`, so the CALL typed as i32 and `.v` became `?`.
 *
 * When exactly one module struct owns field `name` (and, when outer_expected
 * is a concrete type, that field's type equals outer_expected), return the
 * named type_ref for that struct so a bare generic CALL base can use it as
 * expected_ret (`mk_default()` → A). Zero or multiple hits → 0 (fail-closed;
 * caller still checks base without a wrong ambient).
 *
 * @param module module with struct layouts
 * @param arena type/name pool
 * @param expr_ref FIELD_ACCESS expr
 * @param outer_expected ambient expected of the field expression (0 if none)
 * @return unique owner TYPE_NAMED ref, or 0
 * PLATFORM: SHARED — typeck; rebuild pipeline_glue_standalone.o after edit.
 */
static int32_t pipeline_typeck_field_reverse_infer_base_type_c(struct ast_Module *module,
                                                              struct ast_ASTArena *arena,
                                                              int32_t expr_ref,
                                                              int32_t outer_expected) {
  uint8_t fn_buf[128] /* wave577 Cap name into */;
  int32_t fl;
  int32_t nsl;
  int32_t k;
  int32_t hits;
  int32_t unique_ty;

  if (!module || !arena || expr_ref <= 0)
    return 0;
  fl = pipeline_expr_field_access_name_len(arena, expr_ref);
  if (fl <= 0 || fl > 127)
    return 0;
  memset(fn_buf, 0, sizeof(fn_buf));
  pipeline_expr_field_access_name_into(arena, expr_ref, &fn_buf[0]);
  nsl = module->num_struct_layouts;
  if (nsl <= 0)
    return 0;
  /* Field-name uniqueness among module layouts (outer_expected reserved). */
  (void)outer_expected;
  hits = 0;
  unique_ty = 0;
  for (k = 0; k < nsl; k++) {
    int32_t nf = pipeline_module_struct_layout_num_fields(module, k);
    int32_t j;
    for (j = 0; j < nf; j++) {
      int32_t fjl;
      uint8_t fjn[128] /* wave577 Cap name into */;
      int32_t bi;
      int32_t match;
      uint8_t lnm[128] /* wave577 Cap name into */;
      int32_t lnl;
      int32_t nty;

      fjl = pipeline_module_struct_layout_field_name_len(module, k, j);
      if (fjl != fl)
        continue;
      memset(fjn, 0, sizeof(fjn));
      pipeline_module_struct_layout_field_name_into(module, k, j, &fjn[0]);
      match = 1;
      for (bi = 0; bi < fl; bi++) {
        if (fjn[bi] != fn_buf[bi]) {
          match = 0;
          break;
        }
      }
      if (!match)
        continue;
      lnl = pipeline_module_struct_layout_name_len(module, k);
      if (lnl <= 0 || lnl > 127)
        continue;
      memset(lnm, 0, sizeof(lnm));
      pipeline_module_struct_layout_name_into(module, k, &lnm[0]);
      nty = typeck_find_or_alloc_named_type_ref(arena, &lnm[0], lnl);
      if (nty <= 0)
        continue;
      /* Dedup same owner type (multiple fields same name should not happen). */
      if (hits == 1 && unique_ty == nty)
        continue;
      hits++;
      unique_ty = nty;
      if (hits > 1)
        return 0; /* ambiguous owner — leave bare CALL unconstrained */
    }
  }
  return hits == 1 ? unique_ty : 0;
}

/**
 * wave465: TYPE_NAMED is a module concrete type (struct layout or enum) iff a
 * matching name exists. Otherwise it is treated as an unconstrained type
 * parameter (e.g. field `v: T` on `struct Wrap<T>`).
 * PLATFORM: SHARED — used only to decide ambient fill of field results.
 */
static int32_t pipeline_typeck_named_is_module_concrete_c(struct ast_Module *module, uint8_t *name,
                                                          int32_t name_len) {
  int32_t k;
  int32_t nsl;
  int32_t ne;
  if (!module || !name || name_len <= 0 || name_len > 127)
    return 0;
  nsl = module->num_struct_layouts;
  for (k = 0; k < nsl; k++) {
    int32_t sl = pipeline_module_struct_layout_name_len(module, k);
    uint8_t snm[128] /* wave577 Cap name into */;
    if (sl != name_len)
      continue;
    memset(snm, 0, sizeof(snm));
    pipeline_module_struct_layout_name_into(module, k, &snm[0]);
    if (typeck_name_equal(&snm[0], sl, name, name_len))
      return 1;
  }
  ne = module->num_module_enums;
  for (k = 0; k < ne; k++) {
    int32_t el = pipeline_module_enum_name_len(module, k);
    int32_t bi;
    if (el != name_len)
      continue;
    for (bi = 0; bi < el; bi++) {
      if (pipeline_module_enum_name_byte_at(module, k, bi) != name[bi])
        break;
    }
    if (bi == el)
      return 1;
  }
  return 0;
}

/**
 * wave465 Cap residual pure: after layout/fallback, if the field result is still
 * a TYPE_NAMED type-param (name not a module concrete struct/enum) and ambient
 * expected is present, stamp ambient onto the field access.
 *
 * wave472 L4: do NOT stamp ambient when the field type is still null/unknown.
 * Null meant layout did not resolve (enum fields / missing type_ref). Stamping
 * ambient onto null rewrote assign LHS with function return (expected S/?) and
 * polluted dual-overload scoring. Type-param fields keep TYPE_NAMED `T` in
 * layout (not null), so Wrap.v still fills. PLATFORM: SHARED.
 */
static void pipeline_typeck_field_apply_ambient_for_type_param_c(struct ast_Module *module,
                                                                struct ast_ASTArena *arena,
                                                                int32_t expr_ref,
                                                                int32_t ambient_ty) {
  int32_t got_ty;
  int32_t use_ambient;
  uint8_t gnm[128] /* wave577 Cap name into */;
  int32_t gnl;

  if (!module || !arena || expr_ref <= 0)
    return;
  if (ambient_ty <= 0 || ambient_ty > arena->num_types)
    return;
  got_ty = pipeline_expr_resolved_type_ref(arena, expr_ref);
  use_ambient = 0;
  /* wave472: null/unknown field type → leave unresolved; never invent ambient. */
  if (ast_ref_is_null(got_ty) || got_ty <= 0 || got_ty > arena->num_types) {
    return;
  } else if (pipeline_type_kind_ord_at(arena, got_ty) == (int32_t)ast_TypeKind_TYPE_NAMED) {
    memset(gnm, 0, sizeof(gnm));
    gnl = pipeline_type_named_name_into(arena, got_ty, &gnm[0]);
    if (gnl > 0 && gnl <= 63 && !pipeline_typeck_named_is_module_concrete_c(module, &gnm[0], gnl))
      use_ambient = 1;
  }
  if (use_ambient)
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, ambient_ty);
}

/**
 * wave466/467 Cap residual pure: generic struct mono for type-param fields.
 *
 * When the base type is TYPE_NAMED with type-position args (`Wrap<i32>` /
 * `Pair<A,B>`) and the field result is still an unconstrained TYPE_NAMED
 * type-param (`v: T` / `b: U` from layout), stamp the matching type arg:
 *   - wave467: map field type name → layout type-param slot → type_arg[slot]
 *   - wave466: slot0 via elem_type_ref when no type-param registry
 * Prefer this over ambient so `take(w.v)` / return without expected still resolve.
 * PLATFORM: SHARED.
 */
extern int32_t pipeline_type_type_arg_ref_at(struct ast_ASTArena *a, int32_t type_ref, int32_t idx);
extern int32_t pipeline_module_struct_layout_num_type_params_at(struct ast_Module *m, int32_t li);
extern int32_t pipeline_module_struct_layout_type_param_name_len(struct ast_Module *m, int32_t li, int32_t j);
extern void pipeline_module_struct_layout_type_param_name_into(struct ast_Module *m, int32_t li, int32_t j,
                                                              uint8_t *out64);

static void pipeline_typeck_field_apply_mono_type_arg_c(struct ast_Module *module,
                                                       struct ast_ASTArena *arena,
                                                       int32_t expr_ref,
                                                       int32_t base_ty) {
  int32_t got_ty;
  int32_t mono_ty;
  int32_t bt_kind;
  uint8_t gnm[128] /* wave577 Cap name into */;
  int32_t gnl;
  uint8_t bnm[128] /* wave577 Cap name into */;
  int32_t bnl;
  int32_t sk;
  int32_t tp_slot;

  if (!module || !arena || expr_ref <= 0)
    return;
  if (base_ty <= 0 || base_ty > arena->num_types)
    return;
  bt_kind = pipeline_type_kind_ord_at(arena, base_ty);
  if (bt_kind == (int32_t)ast_TypeKind_TYPE_PTR) {
    int32_t elem = pipeline_type_elem_ref_at(arena, base_ty);
    if (elem > 0 && elem <= arena->num_types
        && pipeline_type_kind_ord_at(arena, elem) == (int32_t)ast_TypeKind_TYPE_NAMED)
      base_ty = elem;
    else
      return;
  } else if (bt_kind != (int32_t)ast_TypeKind_TYPE_NAMED) {
    return;
  }
  got_ty = pipeline_expr_resolved_type_ref(arena, expr_ref);
  if (ast_ref_is_null(got_ty) || got_ty <= 0 || got_ty > arena->num_types)
    return;
  if (pipeline_type_kind_ord_at(arena, got_ty) != (int32_t)ast_TypeKind_TYPE_NAMED)
    return;
  memset(gnm, 0, sizeof(gnm));
  gnl = pipeline_type_named_name_into(arena, got_ty, &gnm[0]);
  if (gnl <= 0 || gnl > 127)
    return;
  if (pipeline_typeck_named_is_module_concrete_c(module, &gnm[0], gnl))
    return;
  /* Map field type name → type-param slot on base layout name. */
  memset(bnm, 0, sizeof(bnm));
  bnl = pipeline_type_named_name_into(arena, base_ty, &bnm[0]);
  tp_slot = 0;
  if (bnl > 0) {
    for (sk = 0; sk < module->num_struct_layouts; sk++) {
      int32_t sl = pipeline_module_struct_layout_name_len(module, sk);
      uint8_t snm[128] /* wave577 Cap name into */;
      int32_t bi;
      int32_t match;
      int32_t ntp;
      int32_t tj;
      if (sl != bnl)
        continue;
      memset(snm, 0, sizeof(snm));
      pipeline_module_struct_layout_name_into(module, sk, snm);
      match = 1;
      for (bi = 0; bi < bnl; bi++) {
        if (snm[bi] != bnm[bi]) {
          match = 0;
          break;
        }
      }
      if (!match)
        continue;
      ntp = pipeline_module_struct_layout_num_type_params_at(module, sk);
      if (ntp > 0) {
        tp_slot = -1;
        for (tj = 0; tj < ntp; tj++) {
          int32_t tpl = pipeline_module_struct_layout_type_param_name_len(module, sk, tj);
          uint8_t tpn[128] /* wave577 Cap name into */;
          int32_t pi;
          int32_t peq;
          if (tpl != gnl)
            continue;
          memset(tpn, 0, sizeof(tpn));
          pipeline_module_struct_layout_type_param_name_into(module, sk, tj, tpn);
          peq = 1;
          for (pi = 0; pi < gnl; pi++) {
            if (tpn[pi] != gnm[pi]) {
              peq = 0;
              break;
            }
          }
          if (peq) {
            tp_slot = tj;
            break;
          }
        }
        if (tp_slot < 0)
          return;
      }
      break;
    }
  }
  mono_ty = pipeline_type_type_arg_ref_at(arena, base_ty, tp_slot);
  if (mono_ty <= 0 && tp_slot == 0)
    mono_ty = pipeline_type_elem_ref_at(arena, base_ty);
  if (mono_ty <= 0 || mono_ty > arena->num_types)
    return;
  pipeline_expr_set_resolved_type_ref(arena, expr_ref, mono_ty);
}

/*
 * G.7 / wave465: mega pipeline_x (OMIT_X_DUP, no STANDALONE_TU) keeps a local
 * copy only — product export must come from pipeline_glue_standalone.o so daily
 * L2 rebuilds of field_access are not silently overridden by a stale pipeline_x.o
 * (Linux first-def-wins). PLATFORM: SHARED link discipline.
 */
#if defined(XLANG_PIPELINE_GLUE_OMIT_X_DUP_EXPORTS) && !defined(XLANG_PIPELINE_GLUE_STANDALONE_TU)
static
#endif
int32_t pipeline_typeck_check_expr_field_access_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                                  int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  int32_t base_ref;
  int32_t base_ty;
  int32_t bt_kind;
  int32_t elem_ty;
  int32_t layout_rc;
  int32_t base_expected;
  int32_t base_kind;

  base_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
  if (ast_ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena->num_exprs)
    return -1;
  pipeline_typeck_field_prebind_c(module, arena, expr_ref, ctx);
  /** Import binding 特判：backend.foo(args) 中 backend 是 import binding，
   * foo 是 dep 模块中的函数；field access 的 typeck 应从 dep 模块查找函数返回类型。 */
  if (pipeline_typeck_field_import_binding_resolve_c(module, arena, expr_ref, base_ref, ctx))
    return 0;
  /*
   * wave454: do NOT pass field-result ambient (return_type_ref) into base.
   * Base type ≠ field type. For CALL/METHOD_CALL bases, reverse-infer a unique
   * owner struct from the field name so bare ret-only generics get the right
   * expected (`mk_default().v` → expected A, not i32).
   */
  base_expected = 0;
  base_kind = pipeline_expr_kind_ord_at(arena, base_ref);
  if (base_kind == (int32_t)ast_ExprKind_EXPR_CALL ||
      base_kind == (int32_t)ast_ExprKind_EXPR_METHOD_CALL) {
    base_expected = pipeline_typeck_field_reverse_infer_base_type_c(module, arena, expr_ref,
                                                                   return_type_ref);
  }
  /* wave454: never pass field-result ambient into base. wave465 uses ambient
   * only after field resolve (type-param field fill). */
  if (pipeline_typeck_check_expr_c(module, arena, base_ref, base_expected, ctx) != 0)
    return -1;
  /** DOD-S1：INDEX 基址的 SoA 字段访问优先于 AoS layout 回落。 */
  if (pipeline_typeck_field_soa_index_c(module, arena, expr_ref, base_ref) != 0)
    return 0;
  base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
  if (!ast_ref_is_null(base_ty) && base_ty > 0 && base_ty <= arena->num_types) {
    bt_kind = pipeline_type_kind_ord_at(arena, base_ty);
    if (bt_kind == (int32_t)ast_TypeKind_TYPE_PTR) {
      elem_ty = pipeline_type_elem_ref_at(arena, base_ty);
      if (!ast_ref_is_null(elem_ty))
        pipeline_typeck_field_known_ptr_types_c(module, arena, expr_ref, base_ref, module->num_struct_layouts);
    }
    layout_rc = pipeline_typeck_field_layout_named_c(module, arena, expr_ref, base_ref, ctx);
    if (layout_rc == 2) {
      /*
       * User enum variant (Method.GET): resolved to enum TYPE_NAMED.
       * wave472: do not mono/ambient — concrete, not type-param. PLATFORM: SHARED.
       */
      return 0;
    }
    pipeline_typeck_field_slice_c(arena, expr_ref, base_ref);
  }
  pipeline_typeck_field_name_fallback_c(arena, expr_ref, base_ref);
  pipeline_typeck_field_lexer_fallback_c(module, arena, expr_ref, base_ref, ctx);
  pipeline_typeck_field_apply_mono_type_arg_c(module, arena, expr_ref, base_ty);
  pipeline_typeck_field_apply_ambient_for_type_param_c(module, arena, expr_ref, return_type_ref);
  return 0;
}
