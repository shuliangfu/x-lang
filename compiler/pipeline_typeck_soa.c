/**
 * pipeline_typeck_soa.c — DOD-S1 SoA 布局 typeck（从 typeck 路径机械抽出）。
 *
 * 由 pipeline_glue.c #include 并入同一翻译单元（须在 glue_type_size_simple 之后）。
 * - `SoAStruct[N]` 列主序总大小
 * - `arr[i].field` 列基址 + stride
 */

extern struct ast_PipelineDepCtx *pipeline_asm_emit_dep_pipe_c(void);
extern struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);

/**
 * 按 struct 名在 module.struct_layouts 中查下标；-1 表示未命中。
 */
static int32_t typeck_soa_find_layout_idx_by_name(struct ast_Module *module, uint8_t *name, int32_t name_len) {
  int32_t k;
  int32_t j;
  if (!module || !name || name_len <= 0 || name_len > 63)
    return -1;
  for (k = 0; k < (int32_t)module->num_struct_layouts; k++) {
    int32_t ln = pipeline_module_struct_layout_name_len(module, k);
    int32_t eq = 1;
    if (ln != name_len)
      continue;
    for (j = 0; j < name_len; j++) {
      if (pipeline_module_struct_layout_name_byte_at(module, k, j) != name[j]) {
        eq = 0;
        break;
      }
    }
    if (eq)
      return k;
  }
  return -1;
}

/**
 * 在当前 module 或 WPO dep 池中按名查 SoA layout；命中时写 *out_layout_mod。
 */
static int32_t typeck_soa_find_layout_module_and_idx(struct ast_Module *module, uint8_t *name, int32_t name_len,
                                                   struct ast_Module **out_layout_mod) {
  int32_t li;
  struct ast_PipelineDepCtx *pipe;
  int32_t nd;
  int32_t di;
  struct ast_Module *dm;
  if (out_layout_mod)
    *out_layout_mod = module;
  if (!module || !name || name_len <= 0)
    return -1;
  li = typeck_soa_find_layout_idx_by_name(module, name, name_len);
  if (li >= 0)
    return li;
  pipe = pipeline_asm_emit_dep_pipe_c();
  if (!pipe)
    return -1;
  nd = pipeline_dep_ctx_ndep(pipe);
  for (di = 0; di < nd; di++) {
    dm = pipeline_dep_ctx_module_at(pipe, di);
    if (!dm)
      continue;
    li = typeck_soa_find_layout_idx_by_name(dm, name, name_len);
    if (li >= 0) {
      if (out_layout_mod)
        *out_layout_mod = dm;
      return li;
    }
  }
  return -1;
}

/**
 * SoA 列基址：字段 fi 之前各列占 N * sizeof(field)（含对齐）。
 */
static int32_t typeck_soa_col_base_for_field(struct ast_Module *module, struct ast_ASTArena *arena, int32_t li,
                                             int32_t field_idx, int32_t array_len, int32_t depth) {
  int32_t col;
  int32_t j;
  int32_t nf;
  if (!module || !arena || li < 0 || field_idx < 0 || array_len <= 0 || depth > 64)
    return 0;
  col = 0;
  nf = pipeline_module_struct_layout_num_fields(module, li);
  for (j = 0; j < nf && j < field_idx; j++) {
    int32_t ftr = pipeline_module_struct_layout_field_type_ref(module, li, j);
    int32_t A;
    int32_t fsize;
    int32_t rem;
    int32_t gap;
    if (ftr <= 0)
      continue;
    A = glue_type_align_simple(module, arena, ftr, depth);
    fsize = glue_type_size_simple(module, arena, ftr, depth);
    if (A <= 0)
      A = 1;
    if (fsize <= 0)
      fsize = 4;
    rem = col % A;
    gap = A - rem;
    gap = gap % A;
    col = col + gap + array_len * fsize;
  }
  return col;
}

/**
 * DOD-S1：SoAStruct[N] 列主序总字节数；elem 非 SoA 或未命中 layout 时返回 0。
 */
int32_t typeck_soa_array_storage_size_glue(struct ast_Module *module, struct ast_ASTArena *arena, int32_t elem_type_ref,
                                           int32_t array_len, int32_t depth) {
  uint8_t name[64];
  int32_t nlen;
  int32_t li;
  int32_t nf;
  int32_t col;
  int32_t max_al;
  int32_t j;
  if (!module || !arena || elem_type_ref <= 0 || array_len <= 0 || depth > 64)
    return 0;
  if (pipeline_type_kind_ord_at(arena, elem_type_ref) != 8)
    return 0;
  nlen = pipeline_type_named_name_into(arena, elem_type_ref, name);
  if (nlen <= 0)
    return 0;
  li = typeck_soa_find_layout_idx_by_name(module, name, nlen);
  if (li < 0 || pipeline_module_struct_layout_soa_at(module, li) == 0)
    return 0;
  /* 仅 elem 为 SoA struct 时启用列主序尺寸；非 SoA 回落 AoS。 */
  nf = pipeline_module_struct_layout_num_fields(module, li);
  col = typeck_soa_col_base_for_field(module, arena, li, nf, array_len, depth + 1);
  max_al = 1;
  for (j = 0; j < nf; j++) {
    int32_t ftr = pipeline_module_struct_layout_field_type_ref(module, li, j);
    int32_t A;
    if (ftr <= 0)
      continue;
    A = glue_type_align_simple(module, arena, ftr, depth + 1);
    if (A > max_al)
      max_al = A;
  }
  if (max_al > 1 && (col % max_al) != 0)
    col = col + (max_al - (col % max_al));
  return col > 0 ? col : 0;
}

/**
 * EXPR_FIELD_ACCESS 且 base 为 INDEX：SoA 数组 `arr[i].field` 写 col_base + stride。
 * 返回 1 表示已处理；0 表示非 SoA 路径。
 */
int32_t pipeline_typeck_field_soa_index_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                          int32_t base_ref) {
  int32_t ix_base_ref;
  int32_t base_ty;
  int32_t bt_kind;
  int32_t elem_ty;
  int32_t array_sz;
  uint8_t elem_nm[64];
  int32_t elem_nlen;
  int32_t li;
  int32_t fl;
  uint8_t fn_buf[64];
  int32_t j;
  int32_t fnlen;
  int32_t ftr;
  int32_t col_base;
  int32_t stride;
  struct ast_Module *layout_mod;
  if (!module || !arena || expr_ref <= 0 || base_ref <= 0)
    return 0;
  layout_mod = module;
  if (pipeline_expr_kind_ord_at(arena, base_ref) != 47)
    return 0;
  ix_base_ref = pipeline_expr_index_base_ref(arena, base_ref);
  if (ix_base_ref <= 0)
    return 0;
  base_ty = pipeline_expr_resolved_type_ref(arena, ix_base_ref);
  /** skip .sx typeck：形参 VAR 常无 resolved_type；按 emit 函数或全 module 形参表回落。 */
  if (base_ty <= 0 && pipeline_expr_kind_ord_at(arena, ix_base_ref) == 3) {
    int32_t fi;
    uint8_t vname[64];
    int32_t vlen = pipeline_expr_var_name_len(arena, ix_base_ref);
    if (vlen > 0 && vlen <= 63) {
      pipeline_expr_var_name_into(arena, ix_base_ref, vname);
      fi = g_pipeline_asm_emit_func_index;
      if (fi >= 0 && fi < (int32_t)module->num_funcs)
        base_ty = pipeline_module_func_param_type_ref_for_name(module, fi, vname, vlen);
      if (base_ty <= 0) {
        for (fi = 0; fi < (int32_t)module->num_funcs; fi++) {
          base_ty = pipeline_module_func_param_type_ref_for_name(module, fi, vname, vlen);
          if (base_ty > 0)
            break;
        }
      }
      if (base_ty > 0)
        pipeline_expr_set_resolved_type_ref(arena, ix_base_ref, base_ty);
    }
  }
  if (base_ty <= 0 || base_ty > arena->num_types)
    return 0;
  bt_kind = pipeline_type_kind_ord_at(arena, base_ty);
  if (bt_kind != 10 && bt_kind != 13)
    return 0;
  elem_ty = pipeline_type_elem_ref_at(arena, base_ty);
  array_sz = pipeline_type_array_size_at(arena, base_ty);
  if (elem_ty <= 0 || array_sz <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, elem_ty) != 8)
    return 0;
  elem_nlen = pipeline_type_named_name_into(arena, elem_ty, elem_nm);
  if (elem_nlen <= 0)
    return 0;
  li = typeck_soa_find_layout_module_and_idx(module, elem_nm, elem_nlen, &layout_mod);
  if (li < 0 || !layout_mod || pipeline_module_struct_layout_soa_at(layout_mod, li) == 0)
    return 0;
  fl = pipeline_expr_field_access_name_len(arena, expr_ref);
  if (fl <= 0 || fl > 63)
    return 0;
  pipeline_expr_field_access_name_into(arena, expr_ref, fn_buf);
  ftr = 0;
  stride = 0;
  col_base = 0;
  for (j = 0; j < pipeline_module_struct_layout_num_fields(layout_mod, li); j++) {
    fnlen = pipeline_module_struct_layout_field_name_len(layout_mod, li, j);
    int32_t feq = 1;
    int32_t fi;
    if (fnlen != fl)
      continue;
    for (fi = 0; fi < fnlen; fi++) {
      uint8_t fb[64];
      pipeline_module_struct_layout_field_name_into(layout_mod, li, j, fb);
      if (fb[fi] != fn_buf[fi]) {
        feq = 0;
        break;
      }
    }
    if (!feq)
      continue;
    ftr = pipeline_module_struct_layout_field_type_ref(layout_mod, li, j);
    stride = glue_type_size_simple(layout_mod, arena, ftr, 0);
    if (stride <= 0)
      stride = 4;
    col_base = typeck_soa_col_base_for_field(layout_mod, arena, li, j, array_sz, 0);
    break;
  }
  if (ftr <= 0)
    return 0;
  pipeline_expr_set_field_access_offset(arena, expr_ref, col_base);
  pipeline_expr_set_field_access_soa_stride(arena, expr_ref, stride);
  pipeline_expr_set_resolved_type_ref(arena, expr_ref, ftr);
  return 1;
}
