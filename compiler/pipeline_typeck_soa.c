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
 * Find struct layout index by name in module.struct_layouts; -1 if not found.
 * wave1219: made non-static extern — typeck.x authority typeck_soa_array_storage_size_glue
 * calls this (extern decl at typeck.x). Retained here because pipeline_typeck_field_soa_index_c
 * (L153 below) also uses it for arr[i].field SoA col_base + stride resolution.
 * PLATFORM: SHARED — visible via pipeline_x.o TU.
 */
/* R2 (8.3.3): impl migrated to typeck.x authority; .c callers resolve via link to typeck_x.o. */
int32_t typeck_soa_find_layout_idx_by_name(struct ast_Module *module, uint8_t *name, int32_t name_len);

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
 * SoA column base: columns before field fi occupy N * sizeof(field) (with align).
 * R2 (8.3.3): impl migrated to typeck.x authority (uses typeck_x_type_align/size).
 * .c callers (pipeline_typeck_field_soa_index_c below) resolve via link to typeck_x.o.
 * PLATFORM: SHARED — visible via pipeline_x.o TU + typeck_x.o.
 */
int32_t typeck_soa_col_base_for_field(struct ast_Module *module, struct ast_ASTArena *arena, int32_t li,
                                      int32_t field_idx, int32_t array_len, int32_t depth);

/* wave1219 G.3/G.4 + 8.3.3 R2: typeck_soa_array_storage_size_glue and
 * typeck_soa_col_base_for_field / typeck_soa_find_layout_idx_by_name are .x
 * authority (typeck.x → typeck_x.o). This file keeps:
 *   - extern decls for the two helpers (same-TU field_soa_index calls)
 *   - pipeline_typeck_field_soa_index_c (still C; uses glue_type_size_simple for stride)
 */

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
  /* wave583 Cap residual: SoA name/field buffers 64→128. */
  uint8_t elem_nm[128];
  int32_t elem_nlen;
  int32_t li;
  int32_t fl;
  uint8_t fn_buf[128];
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
  /** skip .x typeck：形参 VAR 常无 resolved_type；按 emit 函数或全 module 形参表回落。 */
  if (base_ty <= 0 && pipeline_expr_kind_ord_at(arena, ix_base_ref) == 3) {
    int32_t fi;
    uint8_t vname[128];
    int32_t vlen = pipeline_expr_var_name_len(arena, ix_base_ref);
    if (vlen > 0 && vlen <= 127) {
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
  if (elem_nlen <= 0 || elem_nlen > 127)
    return 0;
  li = typeck_soa_find_layout_module_and_idx(module, elem_nm, elem_nlen, &layout_mod);
  if (li < 0 || !layout_mod || pipeline_module_struct_layout_soa_at(layout_mod, li) == 0)
    return 0;
  fl = pipeline_expr_field_access_name_len(arena, expr_ref);
  if (fl <= 0 || fl > 127)
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
      uint8_t fb[128];
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

/* ============================================================
 * wave1230 G.7: public SoA / field-access fill entry for asm emit
 * (migrated from pipeline_glue.c; colocated with pipeline_typeck_field_soa_index_c).
 *
 * Why here: primary non-trivial callee for arr[i].field is
 * pipeline_typeck_field_soa_index_c (static-domain peer above). Public entry
 * also repairs skip-typeck STRUCT_LIT layouts, DOD-CL field_align inheritance,
 * and AoS FIELD_ACCESS layout offsets so emit can load the correct column /
 * field without a full .x typeck pass.
 *
 * Callers (cross-TU / same-TU after this #include):
 *  - ast_pool.c (extern decl + call on backend prepare / skip-typeck path)
 *  - runtime_pipeline_abi.x / seeds (export / surface)
 *  - runtime_driver_strict_glue_stubs.from_x.c (XLANG_WEAK cold stub)
 *
 * Deps (visible via earlier same-TU #includes / decls in pipeline_glue.c):
 *  - pipeline_debug_trace_named_func_bodies / g_pipeline_asm_emit_func_index
 *  - glue_sync_struct_layout_field_offsets_c (struct_lit.c #include < soa)
 *  - glue_fill_var_types_from_lets_in_block / _from_params_for_func
 *    (block_inits.c #include < soa)
 *  - glue_field_layout_offset_for_base_field (field_access.c #include < soa)
 *  - typeck_ensure_struct_layout_from_struct_lit (extern below; typeck_gen)
 *
 * PLATFORM: SHARED — pure orchestration, no arch dependency.
 * ============================================================ */

/** skip typeck: register STRUCT_LIT fields into module.struct_layouts
 * (typeck.x ensure_struct_layout_from_struct_lit twin). */
extern int32_t typeck_ensure_struct_layout_from_struct_lit(struct ast_Module *module, struct ast_ASTArena *arena,
                                                           int32_t expr_ref);

/**
 * Before asm emit: fill SoA col_base+stride and AoS layout offsets for
 * FIELD_ACCESS expressions when C/X typeck was skipped or incomplete.
 *
 * Why: emit of `arr[i].field` needs col_base + stride stamped on the
 * FIELD_ACCESS node; AoS `base.field` needs layout field offset. Skip-typeck
 * paths also miss STRUCT_LIT → struct_layouts registration and DOD-CL
 * field_align inheritance for align(N) columns.
 *
 * Contract:
 *  - NULL module or arena → no-op.
 *  - Skips extern func slots (EMIT_HEAVY declarations without body; walking
 *    them would SIGSEGV).
 *  - Requires INDEX base types resolved T[N] before SoA fill — walks each
 *    non-extern func body with glue_fill_var_types_from_lets_in_block /
 *    glue_fill_var_types_from_params_for_func first.
 *  - SoA FIELD_ACCESS with soa_stride > 0 is left alone (do not overwrite
 *    column offsets with AoS layout_off).
 *
 * Invariant: for base_ref kind INDEX (47), delegates to
 * pipeline_typeck_field_soa_index_c; otherwise stamps AoS layout offset via
 * glue_field_layout_offset_for_base_field when known.
 *
 * PLATFORM: SHARED.
 */
void pipeline_fill_soa_field_access_for_asm_emit(struct ast_Module *m, struct ast_ASTArena *arena) {
  int32_t fi;
  int32_t ei;
  int32_t saved_fi;
  if (!m || !arena)
    return;
  pipeline_debug_trace_named_func_bodies("fill_cl_pre", m, arena);
  /* skip typeck: merge STRUCT_LIT fields into module.struct_layouts (parser may
   * have registered only the head when a tail field appears later). */
  for (ei = 1; ei <= arena->num_exprs; ei++) {
    if (pipeline_expr_kind_ord_at(arena, ei) == (int32_t)ast_ExprKind_EXPR_STRUCT_LIT)
      (void)typeck_ensure_struct_layout_from_struct_lit(m, arena, ei);
  }
  /* DOD-CL: when parser only wrote align(N) on the first field, inherit the
   * same line align onto following u32 fields before recomputing offsets. */
  {
    int32_t li;
    int32_t nf2;
    int32_t j;
    for (li = 0; li < pipeline_module_num_struct_layouts_at(m); li++) {
      nf2 = pipeline_module_struct_layout_num_fields(m, li);
      for (j = 0; j + 1 < nf2; j++) {
        int32_t fa0 = pipeline_module_struct_layout_field_align_at(m, li, j);
        if (fa0 >= 64 && pipeline_module_struct_layout_field_align_at(m, li, j + 1) == 0)
          pipeline_module_struct_layout_set_field_align(m, li, j + 1, fa0);
      }
    }
  }
  /* DOD-CL-S1: recompute field offsets from field_align, then fill FIELD_ACCESS. */
  glue_sync_struct_layout_field_offsets_c(m, arena);
  if (link_abi_getenv("XLANG_ASM_DEBUG")) {
    fprintf(stderr, "xlang: fill_cl n_layouts=%d n_exprs=%d\n", (int)pipeline_module_num_struct_layouts_at(m),
            (int)arena->num_exprs);
  }
  saved_fi = g_pipeline_asm_emit_func_index;
  for (fi = 0; fi < (int32_t)m->num_funcs; fi++) {
    int32_t br;
    /* parser EMIT_HEAVY: extern bl→glue declarations occupy func slots without
     * body/params; fill would SIGSEGV. */
    if (pipeline_asm_module_func_is_extern_at(m, fi) != 0)
      continue;
    br = pipeline_module_func_body_ref_at(m, fi);
    if (br <= 0)
      continue;
    g_pipeline_asm_emit_func_index = fi;
    glue_fill_var_types_from_lets_in_block(arena, br);
    glue_fill_var_types_from_params_for_func(m, arena, fi);
  }
  if (link_abi_getenv("XLANG_ASM_DEBUG"))
    fprintf(stderr, "xlang: fill_cl func_loop done nf=%d\n", (int)m->num_funcs);
  for (ei = 1; ei <= arena->num_exprs; ei++) {
    int32_t base_ref;
    int32_t flen;
    uint8_t fname[128];
    int32_t layout_off;
    if (pipeline_expr_kind_ord_at(arena, ei) != 44)
      continue;
    base_ref = pipeline_expr_field_access_base_ref(arena, ei);
    if (base_ref <= 0)
      continue;
    if (pipeline_expr_kind_ord_at(arena, base_ref) == 47)
      (void)pipeline_typeck_field_soa_index_c(m, arena, ei, base_ref);
    flen = pipeline_expr_field_access_name_len(arena, ei);
    if (flen <= 0 || flen > 127)
      continue;
    pipeline_expr_field_access_name_into(arena, ei, fname);
    /* SoA arr[i].field: col_base+stride already written by typeck_field_soa_index;
     * do not overwrite y-column etc. with AoS layout offset. */
    if (pipeline_expr_field_access_soa_stride(arena, ei) > 0)
      continue;
    layout_off = glue_field_layout_offset_for_base_field(arena, m, base_ref, fname, flen);
    if (layout_off >= 0)
      pipeline_expr_set_field_access_offset(arena, ei, layout_off);
  }
  if (link_abi_getenv("XLANG_ASM_DEBUG"))
    fprintf(stderr, "xlang: fill_cl expr_loop done\n");
  g_pipeline_asm_emit_func_index = saved_fi;
  pipeline_debug_trace_named_func_bodies("fill_cl_post", m, arena);
}
