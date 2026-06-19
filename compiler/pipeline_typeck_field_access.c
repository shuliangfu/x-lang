/**
 * pipeline_typeck_field_access.c — EXPR_FIELD_ACCESS 类型检查的 C glue（从 typeck.sx 机械移植）。
 *
 * 由 pipeline_glue.c #include 并入同一翻译单元；不单独编译。
 * 子逻辑导出 pipeline_typeck_field_*_c 供 typeck.sx EMIT_HEAVY 编排；仍保留 pipeline_typeck_check_expr_field_access_c（strict_glue）。
 * 依赖 typeck_sx_no_layout_partial 导出的 typeck_* helper 与 pipeline_* 池访问器。
 */

/* typeck_sx_no_layout_partial 符号（SU 经 C gen 带 typeck_ 前缀）；find_or_alloc_ptr 见 typeck_sx_link_alias.c。 */
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
extern int32_t typeck_expr_field_access_fallback_scalar_type_ref(struct ast_ASTArena *arena, uint8_t *field_name,
                                                                int32_t field_name_len);
extern int32_t typeck_field_access_lexer_wrapper_fallback(struct ast_ASTArena *arena, int32_t base_type_ref,
                                                          uint8_t *field_name, int32_t field_name_len);
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
  uint8_t vbuf[64];
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
  uint8_t inner_nm_buf[64];
  int32_t inner_nm_len;
  int32_t inner_ord;
  int32_t fl;
  uint8_t fn_buf[64];
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
  if (fl <= 0 || fl > 63)
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
  uint8_t layout_nm_buf[64];
  int32_t layout_nm_len;
  uint8_t fn_buf[64];
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
  if (fl2 <= 0 || fl2 > 63)
    return 0;
  pipeline_expr_field_access_name_into(arena, expr_ref, &fn_buf[0]);
  user_ev_tag = pipeline_module_enum_variant_tag_for_names(module, &layout_nm_buf[0], layout_nm_len, &fn_buf[0], fl2);
  if (user_ev_tag >= 0) {
    i32r_ev = typeck_ensure_i32_type_ref(arena);
    if (i32r_ev != 0) {
      pipeline_expr_set_field_access_enum_variant(arena, expr_ref, user_ev_tag);
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, i32r_ev);
    }
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
 * EXPR_FIELD_ACCESS：[]T 的 .length（usize）与 .data（*elem，当前仅 []u8）。
 */
void pipeline_typeck_field_slice_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t base_ref) {
  int32_t base_ty;
  int32_t elem_ty;
  int32_t fl;
  uint8_t fn_buf[64];
  static const uint8_t len_nm[6] = {108, 101, 110, 103, 116, 104};
  static const uint8_t dat_nm[4] = {100, 97, 116, 97};
  int32_t ut;
  int32_t ptr_ref;

  if (ast_ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena->num_exprs)
    return;
  base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
  if (ast_ref_is_null(base_ty) || base_ty <= 0 || base_ty > arena->num_types)
    return;
  if (pipeline_type_kind_ord_at(arena, base_ty) != (int32_t)ast_TypeKind_TYPE_SLICE)
    return;
  elem_ty = pipeline_type_elem_ref_at(arena, base_ty);
  if (ast_ref_is_null(elem_ty))
    return;
  fl = pipeline_expr_field_access_name_len(arena, expr_ref);
  if (fl <= 0 || fl > 63)
    return;
  pipeline_expr_field_access_name_into(arena, expr_ref, &fn_buf[0]);
  if (fl == 6 && typeck_name_equal(&fn_buf[0], fl, (uint8_t *)&len_nm[0], 6)) {
    ut = typeck_ensure_usize_type_ref(arena);
    if (ut != 0)
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, ut);
    return;
  }
  if (fl == 4 && typeck_name_equal(&fn_buf[0], fl, (uint8_t *)&dat_nm[0], 4)) {
    if (pipeline_type_kind_ord_at(arena, elem_ty) == (int32_t)ast_TypeKind_TYPE_U8) {
      ptr_ref = find_or_alloc_ptr_type_ref(arena, elem_ty);
      if (ptr_ref != 0)
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, ptr_ref);
    }
  }
}

/**
 * EXPR_FIELD_ACCESS：layout 未命中时的字段名回落（CodegenOutBuf/inline array/scalar）。
 */
void pipeline_typeck_field_name_fallback_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t base_ref) {
  int32_t fl;
  uint8_t fn_buf[64];
  int32_t base_ty;
  int32_t bt_kind;
  int32_t named_ref;
  uint8_t cob_nm[64];
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
  if (fl <= 0 || fl > 63)
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
  uint8_t fn_buf[64];
  uint8_t vbuf[64];
  int32_t vnlen;
  int32_t pr_fb;
  int32_t lx_fb;

  if (!ast_ref_is_null(pipeline_expr_resolved_type_ref(arena, expr_ref)))
    return;
  if (ast_ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena->num_exprs)
    return;
  fl = pipeline_expr_field_access_name_len(arena, expr_ref);
  if (fl <= 0 || fl > 63)
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
  if (vnlen <= 0 || vnlen > 63)
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
 * typeck.sx::typeck_check_expr_field_access 的 C 委托：prebind → check base → known_ptr/layout/slice/fallback。
 */
int32_t pipeline_typeck_check_expr_field_access_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                                  int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  int32_t base_ref;
  int32_t base_ty;
  int32_t bt_kind;
  int32_t elem_ty;
  int32_t layout_rc;

  base_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
  if (ast_ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena->num_exprs)
    return -1;
  pipeline_typeck_field_prebind_c(module, arena, expr_ref, ctx);
  if (pipeline_typeck_check_expr_c(module, arena, base_ref, return_type_ref, ctx) != 0)
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
    if (layout_rc == 2)
      return 0;
    pipeline_typeck_field_slice_c(arena, expr_ref, base_ref);
  }
  pipeline_typeck_field_name_fallback_c(arena, expr_ref, base_ref);
  pipeline_typeck_field_lexer_fallback_c(module, arena, expr_ref, base_ref, ctx);
  return 0;
}
