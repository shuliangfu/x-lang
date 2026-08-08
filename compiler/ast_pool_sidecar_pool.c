/* ast_pool_sidecar_pool.c — sidecar pool domain (from ast_pool.c)
 *
 * Process-wide pointer-keyed pools: g_arena_sc / g_module_sc / g_onefunc_sc +
 * MAX_*_SIDECARS + sidecar_get + ensure_slot + sidecar_free (grow_vec_free).
 * wave272: DepCtx sidecar table + pipeline_dep_ctx_sidecar_release retired from host-cc —
 * authority is runtime_pipeline_abi pure (g_pipe_dep_sc_blob). Do NOT reintroduce
 * g_xlang_depctx_sc here (dual-table ban).
 * 2026-08-05: g_driver_emit_sc retired with pipeline_emit_sidecar pure leave.
 * Depends on sidecar typedefs + GrowVec. Same-TU #include after typedefs.
 * PLATFORM: SHARED — residual arena/module/onefunc host-cc Cap residual.
 */

/* PLATFORM: SHARED — sidecar table caps (pointer-keyed global pools).
 * MAX_ONEFUNC_SIDECARS: raised 256→1024 for codegen M1 (2026-07-17).
 * Peak observed under XLANG_DEBUG_PIPE while -E src/codegen/codegen.x:
 *   onefunc≈385 (typeck mega only ≈206). Old 256 exhausted → dep=ast
 *   parse_set_main stopped at num_funcs=5 / collect pr_ok=-2 (XT001).
 * Arena/module remain 512 (peak observed arena=3 module=3 on codegen M1). */
#define MAX_ARENA_SIDECARS 512
#define MAX_MODULE_SIDECARS 512
#define MAX_ONEFUNC_SIDECARS 1024

static ArenaSidecar g_arena_sc[MAX_ARENA_SIDECARS];
static ModuleSidecar g_module_sc[MAX_MODULE_SIDECARS];
static OneFuncSidecar g_onefunc_sc[MAX_ONEFUNC_SIDECARS];
static ArenaSidecar *arena_sidecar_get(struct ast_ASTArena *a, int create) {
  int i;
  if (!a)
    return NULL;
  for (i = 0; i < MAX_ARENA_SIDECARS; i++) {
    if (g_arena_sc[i].used && g_arena_sc[i].arena == a)
      return &g_arena_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_ARENA_SIDECARS; i++) {
    if (!g_arena_sc[i].used) {
      g_arena_sc[i].arena = a;
      g_arena_sc[i].used = 1;
      if (!grow_vec_init(&g_arena_sc[i].types, sizeof(struct ast_Type), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].exprs, sizeof(struct ast_Expr), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].blocks, sizeof(struct ast_Block), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].funcs, sizeof(struct ast_Func), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].consts, sizeof(struct ast_ConstDecl), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].lets, sizeof(struct ast_LetDecl), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].ifs, sizeof(struct ast_IfStmt), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].regions, sizeof(RegionBlockEntry), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].loops, sizeof(struct ast_WhileLoop), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].for_loops, sizeof(struct ast_ForLoop), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].defer_block_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].labeled_stmts, sizeof(struct ast_LabeledStmt), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].expr_stmt_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].stmt_order, sizeof(struct ast_StmtOrderItem), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].expr_call_arg_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].expr_call_type_arg_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].expr_call_type_arg_bases, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].type_type_arg_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].type_type_arg_bases, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].type_type_arg_counts, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].expr_method_call_arg_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].expr_match_arms, sizeof(MatchArmEntry), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].expr_struct_lit_fields, sizeof(StructLitFieldEntry), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].expr_array_lit_elem_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].func_params, sizeof(FuncParamEntry), AST_POOL_INIT_CAP))
        return NULL;
      return &g_arena_sc[i];
    }
  }
  return NULL;
}

static ModuleSidecar *module_sidecar_get(struct ast_Module *m, int create) {
  int i;
  if (!m)
    return NULL;
  for (i = 0; i < MAX_MODULE_SIDECARS; i++) {
    if (g_module_sc[i].used && g_module_sc[i].module == m)
      return &g_module_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_MODULE_SIDECARS; i++) {
    if (!g_module_sc[i].used) {
      g_module_sc[i].module = m;
      g_module_sc[i].used = 1;
      if (!grow_vec_init(&g_module_sc[i].funcs, sizeof(struct ast_Func), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].func_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].imports, sizeof(ImportEntry), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].struct_layouts, sizeof(struct ast_StructLayout), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].top_level_lets, sizeof(TopLevelLetEntry), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].type_aliases, sizeof(TypeAliasEntry), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].module_enums, sizeof(ModuleEnumEntry), AST_POOL_INIT_CAP))
        return NULL;
      /* wave584 Cap residual: select name row width 64→128 (content ≤127). */
      if (!grow_vec_init(&g_module_sc[i].import_select_name_rows, 128, AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].import_select_name_lens, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].func_params, sizeof(FuncParamEntry), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].struct_layout_fields, sizeof(StructLayoutFieldEntry), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].struct_layout_type_params, sizeof(LayoutTypeParamEntry),
                         AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].struct_layout_type_param_meta, sizeof(LayoutTypeParamMeta),
                         AST_POOL_INIT_CAP))
        return NULL;
      return &g_module_sc[i];
    }
  }
  return NULL;
}

static OneFuncSidecar *onefunc_sidecar_get(uint8_t *out, int create) {
  int i;
  if (!out)
    return NULL;
  for (i = 0; i < MAX_ONEFUNC_SIDECARS; i++) {
    if (g_onefunc_sc[i].used && g_onefunc_sc[i].onefunc == out)
      return &g_onefunc_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_ONEFUNC_SIDECARS; i++) {
    if (!g_onefunc_sc[i].used) {
      g_onefunc_sc[i].onefunc = out;
      g_onefunc_sc[i].used = 1;
      if (!grow_vec_init(&g_onefunc_sc[i].if_cond_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].if_then_body_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].if_else_body_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      /* wave581 Cap residual: OneFunc const/let name rows 64→128 (match AST name[128]). */
      if (!grow_vec_init(&g_onefunc_sc[i].const_names, 128, AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].const_name_lens, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].const_init_vals, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].const_init_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].const_type_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].let_names, 128, AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].let_name_lens, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].let_init_vals, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].let_init_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].let_type_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].src_stmt_kind, sizeof(uint8_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].src_stmt_idx, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].src_body_expr_stmt_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].while_cond_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].while_body_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].for_init_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].for_cond_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].for_step_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].for_body_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      /* wave585 Cap residual: OneFunc param name rows 32→128 (match FuncParamEntry). */
      if (!grow_vec_init(&g_onefunc_sc[i].param_names, 128, AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].param_name_lens, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].param_type_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].call_arg_vals, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].regions, sizeof(OneFuncRegionEntry), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].defer_body_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      /* wave379: goto/label OneFunc scratch (stmt_order kind=7). PLATFORM: SHARED. */
      if (!grow_vec_init(&g_onefunc_sc[i].labeleds, sizeof(OneFuncLabeledEntry), AST_POOL_INIT_CAP))
        return NULL;
      return &g_onefunc_sc[i];
    }
  }
  return NULL;
}

static void onefunc_sidecar_free(OneFuncSidecar *sc) {
  if (!sc)
    return;
  grow_vec_free(&sc->if_cond_refs);
  grow_vec_free(&sc->if_then_body_refs);
  grow_vec_free(&sc->if_else_body_refs);
  grow_vec_free(&sc->const_names);
  grow_vec_free(&sc->const_name_lens);
  grow_vec_free(&sc->const_init_vals);
  grow_vec_free(&sc->const_init_refs);
  grow_vec_free(&sc->const_type_refs);
  grow_vec_free(&sc->let_names);
  grow_vec_free(&sc->let_name_lens);
  grow_vec_free(&sc->let_init_vals);
  grow_vec_free(&sc->let_init_refs);
  grow_vec_free(&sc->let_type_refs);
  grow_vec_free(&sc->src_stmt_kind);
  grow_vec_free(&sc->src_stmt_idx);
  grow_vec_free(&sc->src_body_expr_stmt_refs);
  grow_vec_free(&sc->while_cond_refs);
  grow_vec_free(&sc->while_body_refs);
  grow_vec_free(&sc->for_init_refs);
  grow_vec_free(&sc->for_cond_refs);
  grow_vec_free(&sc->for_step_refs);
  grow_vec_free(&sc->for_body_refs);
  grow_vec_free(&sc->param_names);
  grow_vec_free(&sc->param_name_lens);
  grow_vec_free(&sc->param_type_refs);
  grow_vec_free(&sc->call_arg_vals);
  grow_vec_free(&sc->regions);
  grow_vec_free(&sc->defer_body_refs);
  grow_vec_free(&sc->labeleds);
  memset(sc, 0, sizeof(*sc));
}

/**
 * Free all GrowVec data buffers owned by an ArenaSidecar and mark the slot
 * as unused, so the static `g_arena_sc[]` slot can be reused by a future
 * arena allocation.
 *
 * Why: Without this, every `malloc(arena_sz)` + `parser_parse_into_init`
 * in the dep loop of `driver_run_x_emit_c` allocates a fresh ArenaSidecar
 * slot (20 GrowVecs, each with its own calloc'd data buffer) that is never
 * released — only `free(arena)` (16 bytes) is called, leaking all GrowVec
 * data. For 50 deps this leaks ~215 MB of init cap alone (pre-INIT_CAP fix)
 * or ~14 MB (post-INIT_CAP=256); with actual AST nodes it can reach GBs.
 *
 * Invariant: caller MUST guarantee the arena is no longer accessed by
 * typeck/codegen/pipeline. In `driver_run_x_emit_c`, this holds because
 * the release calls happen after `xlang_pipeline_run_x_pipeline_large_stack`
 * returns (typeck+codegen+emit all done).
 *
 * Asm/Perf: O(20) grow_vec_free calls (each is a free()+memset). Negligible
 * vs. the malloc/parse cost. The slot's `used` flag is cleared so the next
 * `arena_sidecar_get(create=1)` can reuse it instead of advancing to the
 * next free slot (preventing MAX_ARENA_SIDECARS=512 exhaustion).
 *
 * PLATFORM: SHARED — affects mac arm64 + Ubuntu x86_64 (any pipeline_x.o
 * rebuild; ast_pool.c is #included by pipeline_glue.c).
 */
static void arena_sidecar_free(ArenaSidecar *sc) {
  if (!sc)
    return;
  grow_vec_free(&sc->types);
  grow_vec_free(&sc->exprs);
  grow_vec_free(&sc->blocks);
  grow_vec_free(&sc->funcs);
  grow_vec_free(&sc->consts);
  grow_vec_free(&sc->lets);
  grow_vec_free(&sc->ifs);
  grow_vec_free(&sc->regions);
  grow_vec_free(&sc->loops);
  grow_vec_free(&sc->for_loops);
  grow_vec_free(&sc->defer_block_refs);
  grow_vec_free(&sc->labeled_stmts);
  grow_vec_free(&sc->expr_stmt_refs);
  grow_vec_free(&sc->stmt_order);
  grow_vec_free(&sc->expr_call_arg_refs);
  grow_vec_free(&sc->expr_call_type_arg_refs);
  grow_vec_free(&sc->expr_call_type_arg_bases);
  grow_vec_free(&sc->type_type_arg_refs);
  grow_vec_free(&sc->type_type_arg_bases);
  grow_vec_free(&sc->type_type_arg_counts);
  grow_vec_free(&sc->expr_method_call_arg_refs);
  grow_vec_free(&sc->expr_match_arms);
  grow_vec_free(&sc->expr_struct_lit_fields);
  grow_vec_free(&sc->expr_array_lit_elem_refs);
  grow_vec_free(&sc->func_params);
  memset(sc, 0, sizeof(*sc));
}

/**
 * Free all GrowVec data buffers owned by a ModuleSidecar and mark the slot
 * as unused, so the static `g_module_sc[]` slot can be reused.
 *
 * Why: Same leak pattern as ArenaSidecar — `free(module)` (sizeof Module)
 * does not release the 11 GrowVec data buffers in the ModuleSidecar slot.
 *
 * Invariant: caller MUST guarantee the module is no longer accessed by
 * typeck/codegen/pipeline. See `arena_sidecar_free` above.
 *
 * PLATFORM: SHARED — same as `arena_sidecar_free`.
 */
static void module_sidecar_free(ModuleSidecar *sc) {
  if (!sc)
    return;
  grow_vec_free(&sc->funcs);
  grow_vec_free(&sc->func_refs);
  grow_vec_free(&sc->imports);
  grow_vec_free(&sc->struct_layouts);
  grow_vec_free(&sc->top_level_lets);
  grow_vec_free(&sc->type_aliases);
  grow_vec_free(&sc->module_enums);
  grow_vec_free(&sc->import_select_name_rows);
  grow_vec_free(&sc->import_select_name_lens);
  grow_vec_free(&sc->func_params);
  grow_vec_free(&sc->struct_layout_fields);
  grow_vec_free(&sc->struct_layout_type_params);
  grow_vec_free(&sc->struct_layout_type_param_meta);
  memset(sc, 0, sizeof(*sc));
}

