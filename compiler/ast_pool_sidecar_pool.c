/* ast_pool_sidecar_pool.c — sidecar 池管理域（自 ast_pool.c 抽出）
 *
 * 进程级 pointer-keyed sidecar 池：g_arena_sc／g_module_sc／g_onefunc_sc／g_driver_emit_sc／
 * g_xlang_depctx_sc 全局数组 + MAX_*_SIDECARS 上限 + sidecar_get（查找／分配）+ ensure_slot +
 * sidecar_free（grow_vec_free 归还）+ pipeline_dep_ctx_sidecar_release（批量 check teardown）。
 * g_xlang_depctx_sc／depctx_sidecar_get 故意非 static（pure crt0 embed 双份需求）。
 * 依赖 sidecar typedef（先于此 include）+ GrowVec + ast 结构头。同 TU #include（typedefs 后）。 */

/* 32 was the hard failure point for `check compiler` (32×tiny + next file IMP001).
 * Keep modest headroom; release on free is the real fix. */
#define MAX_DRIVER_EMIT_SIDECARS 64

#define MAX_DEP_CTX_SIDECARS 64
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
/*
 * PLATFORM: SHARED — process-wide DepCtx sidecar table (G.7 single authority).
 *
 * Must NOT be `static`: pure static crt0 embeds depctx_sidecar_get in both
 * pipeline_x / glue_standalone (global) and crt0 L5 pipeline partial (local).
 * Per-TU static BSS → dual tables keyed by the same PipelineDepCtx*:
 *   load_and_sync set_module/path writes table A;
 *   Cap run_x_pipeline_codegen_one_dep module_at reads table B;
 *   codegen_x_ast path_copy reads table A → module/path split
 *   (NL-07 pure static si -o: core.types body emitted as core_result_*).
 *
 * Non-static global: multi-def objects share one BSS under
 * --allow-multiple-definition (product + nostdlib crt0). Weak so a single
 * surviving definition owns all references when the linker merges.
 *
 * ALSO required: ld_partial_export (build_xlang_asm.sh / relink strict glue) must
 * keep this symbol GLOBAL when extracting pipeline partials. Linux
 * objcopy --keep-global-symbols and Darwin -exported_symbols_list localize
 * unlisted symbols; a localized copy + static depctx_sidecar_get reopens the
 * dual-table split even when this definition is weak in the source .o.
 */
#if defined(__GNUC__) || defined(__clang__)
__attribute__((weak))
#endif
DepCtxSidecar g_xlang_depctx_sc[MAX_DEP_CTX_SIDECARS];
static DriverEmitSidecar g_driver_emit_sc[MAX_DRIVER_EMIT_SIDECARS];

static DepCtxSidecar *depctx_sidecar_get(struct ast_PipelineDepCtx *ctx, int create) {
  int i;
  if (!ctx)
    return NULL;
  for (i = 0; i < MAX_DEP_CTX_SIDECARS; i++) {
    if (g_xlang_depctx_sc[i].used && g_xlang_depctx_sc[i].ctx == ctx)
      return &g_xlang_depctx_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_DEP_CTX_SIDECARS; i++) {
    if (!g_xlang_depctx_sc[i].used) {
      g_xlang_depctx_sc[i].ctx = ctx;
      g_xlang_depctx_sc[i].used = 1;
      if (!grow_vec_init(&g_xlang_depctx_sc[i].dep_modules, sizeof(void *), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_xlang_depctx_sc[i].dep_arenas, sizeof(void *), AST_POOL_INIT_CAP))
        return NULL;
      /* wave579 Cap: path row width 64→128 (import paths may be >63 after Cap).
       * PLATFORM: SHARED — must match set_import_path memcpy cap below. */
      if (!grow_vec_init(&g_xlang_depctx_sc[i].dep_path_rows, 128, AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_xlang_depctx_sc[i].dep_path_lens, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_xlang_depctx_sc[i].lib_root_rows, 256, AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_xlang_depctx_sc[i].lib_root_lens, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_xlang_depctx_sc[i].empty_param_indices, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_xlang_depctx_sc[i].empty_param_backup, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      return &g_xlang_depctx_sc[i];
    }
  }
  return NULL;
}

/** 确保 dep 侧车池至少有 idx+1 个槽。 */
static int depctx_ensure_slot(DepCtxSidecar *sc, int32_t idx) {
  int32_t need;
  void **pm;
  void **pa;
  uint8_t *row;
  int32_t *pl;
  if (!sc || idx < 0)
    return 0;
  need = idx + 1;
  while (sc->dep_modules.len < need) {
    if (grow_vec_push(&sc->dep_modules) < 0)
      return 0;
    pm = (void **)grow_vec_at(&sc->dep_modules, sc->dep_modules.len - 1);
    if (pm)
      *pm = NULL;
    if (grow_vec_push(&sc->dep_arenas) < 0)
      return 0;
    pa = (void **)grow_vec_at(&sc->dep_arenas, sc->dep_arenas.len - 1);
    if (pa)
      *pa = NULL;
    if (grow_vec_push(&sc->dep_path_rows) < 0)
      return 0;
    row = (uint8_t *)grow_vec_at(&sc->dep_path_rows, sc->dep_path_rows.len - 1);
    if (row)
      memset(row, 0, 128);
    if (grow_vec_push(&sc->dep_path_lens) < 0)
      return 0;
    pl = (int32_t *)grow_vec_at(&sc->dep_path_lens, sc->dep_path_lens.len - 1);
    if (pl)
      *pl = 0;
  }
  return 1;
}

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

/**
 * Free DepCtxSidecar GrowVecs and mark the process-wide slot unused.
 *
 * Why: pipeline_dep_ctx_heap_destroy used to free(ctx) only. That left
 * g_xlang_depctx_sc[MAX=64] used with dangling ctx keys; batch check exhausts
 * the table and subsequent dep path mapping / parse degrades (num_funcs drop).
 * PLATFORM: SHARED — pair with free(ctx) in heap_destroy (wave1228).
 */
static void depctx_sidecar_free(DepCtxSidecar *sc) {
  if (!sc)
    return;
  grow_vec_free(&sc->dep_modules);
  grow_vec_free(&sc->dep_arenas);
  grow_vec_free(&sc->dep_path_rows);
  grow_vec_free(&sc->dep_path_lens);
  grow_vec_free(&sc->lib_root_rows);
  grow_vec_free(&sc->lib_root_lens);
  grow_vec_free(&sc->empty_param_indices);
  grow_vec_free(&sc->empty_param_backup);
  memset(sc, 0, sizeof(*sc));
}

/**
 * Release process-wide DepCtx sidecar for this PipelineDepCtx pointer.
 * Call before free(ctx). Safe no-op if null or untracked.
 * PLATFORM: SHARED — G.7 single teardown for batch check (wave1228).
 */
void pipeline_dep_ctx_sidecar_release(struct ast_PipelineDepCtx *ctx) {
  int i;
  if (!ctx)
    return;
  for (i = 0; i < MAX_DEP_CTX_SIDECARS; i++) {
    if (g_xlang_depctx_sc[i].used && g_xlang_depctx_sc[i].ctx == ctx) {
      depctx_sidecar_free(&g_xlang_depctx_sc[i]);
      return;
    }
  }
}
