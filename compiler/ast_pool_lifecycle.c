/* ast_pool_lifecycle.c — ast 池生命周期/reset/release 域（自 ast_pool.c 抽出）
 *
 * sidecar entry 访问器：module_func_at + copy_func_params_between_sidecars +
 *   module_func_param_entry／arena_func_param_entry + module_layout_field_entry。
 * 池生命周期：ast_pool_block_on_alloc + ast_pool_module_reset／arena_reset／arena_release／
 *   module_release + ast_pool_drop_bodies_for_check + ast_pool_onefunc_reset／release。
 * 依赖：sidecar 全局（g_arena_sc／g_module_sc／g_onefunc_sc）+ sidecar_get 访问器 +
 *   GrowVec（均先于此 include，ast_pool.c 早期声明区）；ast_pool_block_on_alloc 经
 *   L1052 前向声明供 arena/type 域调用。同 TU #include（type.c 之后、module_func.c 之前）。 */

static struct ast_Func *module_func_at(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc;
  if (!m || idx < 0 || idx >= m->num_funcs)
    return NULL;
  sc = module_sidecar_get(m, 0);
  if (!sc || idx >= sc->funcs.len)
    return NULL;
  return (struct ast_Func *)grow_vec_at(&sc->funcs, idx);
}

/** 将 src 侧车 func_params 中 n 个形参复制到 dst 侧车，并写 *dst_base。 */
static void copy_func_params_between_sidecars(GrowVec *dst, int32_t *dst_base, int32_t n, GrowVec *src,
                                              int32_t src_base) {
  int32_t i, abs_src, abs_dst;
  FuncParamEntry *se, *de;
  if (!dst || !src || n <= 0)
    return;
  *dst_base = dst->len;
  for (i = 0; i < n; i++) {
    abs_src = src_base + i;
    se = (FuncParamEntry *)grow_vec_at(src, abs_src);
    if (grow_vec_push(dst) < 0)
      break;
    abs_dst = dst->len - 1;
    de = (FuncParamEntry *)grow_vec_at(dst, abs_dst);
    if (se && de)
      *de = *se;
  }
}

/** 读/写 module 函数形参 sidecar 槽；create=1 时按需 grow。 */
static FuncParamEntry *module_func_param_entry(struct ast_Module *m, int32_t fi, int32_t pi, int create) {
  ModuleSidecar *sc;
  struct ast_Func *f;
  int32_t abs;
  if (!m || fi < 0 || pi < 0)
    return NULL;
  f = module_func_at(m, fi);
  if (!f)
    return NULL;
  sc = module_sidecar_get(m, create ? 1 : 0);
  if (!sc)
    return NULL;
  if (!create) {
    if (pi >= f->num_params || f->param_base < 0)
      return NULL;
    abs = f->param_base + pi;
    if (abs < 0 || abs >= sc->func_params.len)
      return NULL;
    return (FuncParamEntry *)grow_vec_at(&sc->func_params, abs);
  }
  /** 与 struct_layout field_base 相同：-1=未挂接，0 是合法池起点。 */
  if (f->param_base < 0)
    f->param_base = sc->func_params.len;
  abs = f->param_base + pi;
  while (sc->func_params.len <= abs) {
    if (grow_vec_push(&sc->func_params) < 0)
      return NULL;
  }
  if (pi + 1 > f->num_params)
    f->num_params = pi + 1;
  return (FuncParamEntry *)grow_vec_at(&sc->func_params, abs);
}

/** 读/写 arena 函数形参 sidecar 槽；create=1 时按需 grow。 */
static FuncParamEntry *arena_func_param_entry(struct ast_ASTArena *a, int32_t func_ref, int32_t pi, int create) {
  ArenaSidecar *sc;
  struct ast_Func *f;
  int32_t abs;
  if (!a || func_ref <= 0 || func_ref > a->num_funcs || pi < 0)
    return NULL;
  f = pipeline_arena_func_ptr(a, func_ref);
  if (!f)
    return NULL;
  sc = arena_sidecar_get(a, create ? 1 : 0);
  if (!sc)
    return NULL;
  if (!create) {
    if (pi >= f->num_params || f->param_base < 0)
      return NULL;
    abs = f->param_base + pi;
    if (abs < 0 || abs >= sc->func_params.len)
      return NULL;
    return (FuncParamEntry *)grow_vec_at(&sc->func_params, abs);
  }
  if (f->param_base < 0)
    f->param_base = sc->func_params.len;
  abs = f->param_base + pi;
  while (sc->func_params.len <= abs) {
    if (grow_vec_push(&sc->func_params) < 0)
      return NULL;
  }
  if (pi + 1 > f->num_params)
    f->num_params = pi + 1;
  return (FuncParamEntry *)grow_vec_at(&sc->func_params, abs);
}

/**
 * 读/写 struct_layout 字段 sidecar 槽；create=1 时按需 grow。
 *
 * field_base 语义：-1 = 尚未分配字段池起点；>=0 = 在 struct_layout_fields 中的绝对下标。
 * 禁止用 field_base==0 兼作「未初始化」——首个 layout 的合法 base 就是 0，
 * 否则后续 layout 会误把 field_base 留在 0 上，读写落到 Lexer 等同池前缀（lexer TIMEOUT 根因）。
 */
static StructLayoutFieldEntry *module_layout_field_entry(struct ast_Module *m, int32_t li, int32_t j, int create) {
  ModuleSidecar *sc;
  struct ast_StructLayout *sl;
  int32_t abs;
  if (!m || li < 0 || j < 0)
    return NULL;
  sl = module_layout_at(m, li);
  if (!sl)
    return NULL;
  sc = module_sidecar_get(m, create ? 1 : 0);
  if (!sc)
    return NULL;
  if (!create) {
    if (j >= sl->num_fields || sl->field_base < 0)
      return NULL;
    abs = sl->field_base + j;
    if (abs < 0 || abs >= sc->struct_layout_fields.len)
      return NULL;
    return (StructLayoutFieldEntry *)grow_vec_at(&sc->struct_layout_fields, abs);
  }
  if (sl->field_base < 0)
    sl->field_base = sc->struct_layout_fields.len;
  abs = sl->field_base + j;
  while (sc->struct_layout_fields.len <= abs) {
    if (grow_vec_push(&sc->struct_layout_fields) < 0)
      return NULL;
  }
  if (j + 1 > sl->num_fields)
    sl->num_fields = j + 1;
  return (StructLayoutFieldEntry *)grow_vec_at(&sc->struct_layout_fields, abs);
}

/** 新 Block 分配后记录各池 base 下标。 */
void ast_pool_block_on_alloc(struct ast_ASTArena *a, int32_t block_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  if (!a || block_ref <= 0)
    return;
  sc = arena_sidecar_get(a, 1);
  if (!sc)
    return;
  b = block_at(a, block_ref);
  if (!b)
    return;
  /* 新块槽可能复用旧内存；先整体清零，避免 num_lets/num_stmt_order 等继承脏值污染后续写盘。 */
  memset(b, 0, sizeof(*b));
  b->const_base = sc->consts.len;
  b->let_base = sc->lets.len;
  b->loop_base = sc->loops.len;
  b->for_loop_base = sc->for_loops.len;
  b->if_base = sc->ifs.len;
  b->region_base = sc->regions.len;
  b->defer_base = sc->defer_block_refs.len;
  b->labeled_base = sc->labeled_stmts.len;
  b->expr_stmt_base = sc->expr_stmt_refs.len;
  b->stmt_order_base = sc->stmt_order.len;
}

/* wave262 pure strong / seed cold twin — soft-reset pure TypeAliasEntry live count. */
void pipeline_module_type_alias_storage_reset(struct ast_Module *m);
/* wave264 pure strong / seed cold twin — soft-reset pure ModuleEnumEntry live count. */
void pipeline_module_enum_storage_reset(struct ast_Module *m);
/* wave265 pure strong / seed cold twin — soft-reset pure TopLevelLetEntry live count. */
void pipeline_module_top_level_let_storage_reset(struct ast_Module *m);
/* wave266 pure strong / seed cold twin — soft-reset pure StructLayout live counts. */
void pipeline_module_struct_layout_storage_reset(struct ast_Module *m);

/**
 * 复用同一 Module* 再次 parse 前清空 sidecar 动态池。
 * runtime 在 memset(module) 后仍保留指针对应的 sidecar，须显式 reset，否则 num_funcs 与 funcs.len 不一致导致重复 main。
 */
void ast_pool_module_reset(struct ast_Module *m) {
  ModuleSidecar *sc;
  if (!m)
    return;
  sc = module_sidecar_get(m, 0);
  if (!sc)
    return;
  sc->funcs.len = 0;
  sc->func_refs.len = 0;
  sc->imports.len = 0;
  sc->struct_layouts.len = 0;
  /* wave266: pure StructLayout map soft-reset (G.7 product authority). */
  pipeline_module_struct_layout_storage_reset(m);
  sc->top_level_lets.len = 0;
  /* wave265: pure TopLevelLetEntry map soft-reset (G.7 product authority). */
  pipeline_module_top_level_let_storage_reset(m);
  sc->type_aliases.len = 0;
  /* wave262: pure TypeAliasEntry map soft-reset (G.7 product authority). */
  pipeline_module_type_alias_storage_reset(m);
  sc->module_enums.len = 0;
  /* wave264: pure ModuleEnumEntry map soft-reset (G.7 product authority). */
  pipeline_module_enum_storage_reset(m);
  sc->import_select_name_rows.len = 0;
  sc->import_select_name_lens.len = 0;
  sc->func_params.len = 0;
  sc->struct_layout_fields.len = 0;
  sc->struct_layout_type_params.len = 0;
  sc->struct_layout_type_param_meta.len = 0;
}

/**
 * 复用同一 ASTArena* 再次 parse 前清空 sidecar 动态池（与 ast_arena_init 计数清零配对）。
 */
void ast_pool_arena_reset(struct ast_ASTArena *a) {
  ArenaSidecar *sc;
  if (!a)
    return;
  sc = arena_sidecar_get(a, 0);
  if (!sc)
    return;
  sc->types.len = 0;
  sc->exprs.len = 0;
  sc->blocks.len = 0;
  sc->funcs.len = 0;
  sc->consts.len = 0;
  sc->lets.len = 0;
  sc->ifs.len = 0;
  sc->regions.len = 0;
  sc->loops.len = 0;
  sc->for_loops.len = 0;
  sc->defer_block_refs.len = 0;
  sc->labeled_stmts.len = 0;
  sc->expr_stmt_refs.len = 0;
  sc->stmt_order.len = 0;
  sc->expr_call_arg_refs.len = 0;
  sc->expr_call_type_arg_refs.len = 0;
  sc->expr_call_type_arg_bases.len = 0;
  sc->type_type_arg_refs.len = 0;
  sc->type_type_arg_bases.len = 0;
  sc->type_type_arg_counts.len = 0;
  sc->expr_method_call_arg_refs.len = 0;
  sc->expr_match_arms.len = 0;
  sc->expr_struct_lit_fields.len = 0;
  sc->expr_array_lit_elem_refs.len = 0;
  sc->func_params.len = 0;
}

/**
 * Release (free) all GrowVec data buffers associated with the given arena
 * and mark its ArenaSidecar slot as unused so it can be reused.
 *
 * Why: `free(arena)` only releases the 16-byte `struct ast_ASTArena`;
 * the 20 GrowVec data buffers (types/exprs/blocks/funcs/...) in the
 * ArenaSidecar slot are leaked. This API releases them.
 *
 * Invariant: caller MUST guarantee `a` is no longer accessed by
 * typeck/codegen/pipeline. Safe to call with NULL or untracked arena
 * (no-op if no ArenaSidecar slot matches).
 *
 * PLATFORM: SHARED — see `arena_sidecar_free`.
 */
void ast_pool_arena_release(struct ast_ASTArena *a) {
  int i;
  if (!a)
    return;
  for (i = 0; i < MAX_ARENA_SIDECARS; i++) {
    if (g_arena_sc[i].used && g_arena_sc[i].arena == a) {
      arena_sidecar_free(&g_arena_sc[i]);
      return;
    }
  }
}

/**
 * Release (free) all GrowVec data buffers associated with the given module
 * and mark its ModuleSidecar slot as unused so it can be reused.
 *
 * Why: `free(module)` only releases `sizeof(struct ast_Module)`; the 11
 * GrowVec data buffers (funcs/imports/struct_layouts/...) in the
 * ModuleSidecar slot are leaked. This API releases them.
 *
 * Invariant: caller MUST guarantee `m` is no longer accessed by
 * typeck/codegen/pipeline. Safe to call with NULL or untracked module.
 *
 * PLATFORM: SHARED — see `module_sidecar_free`.
 */
/* wave110 pure strong / Cap XLANG_WEAK empty cold — free pure ImportEntry map. */
void pipeline_module_import_storage_release(struct ast_Module *m);
/* wave262 pure strong / seed cold twin — free pure TypeAliasEntry map. */
void pipeline_module_type_alias_storage_release(struct ast_Module *m);
/* wave264 pure strong / seed cold twin — free pure ModuleEnumEntry map. */
void pipeline_module_enum_storage_release(struct ast_Module *m);
/* wave265 pure strong / seed cold twin — free pure TopLevelLetEntry map. */
void pipeline_module_top_level_let_storage_release(struct ast_Module *m);
/* wave266 pure strong / seed cold twin — free pure StructLayout maps. */
void pipeline_module_struct_layout_storage_release(struct ast_Module *m);

void ast_pool_module_release(struct ast_Module *m) {
  int i;
  if (!m)
    return;
  /* wave110: pure ImportEntry map free (strong pure / weak empty cold). */
  pipeline_module_import_storage_release(m);
  /* wave262: pure TypeAliasEntry map free (strong pure / seed cold twin). */
  pipeline_module_type_alias_storage_release(m);
  /* wave264: pure ModuleEnumEntry map free (strong pure / seed cold twin). */
  pipeline_module_enum_storage_release(m);
  /* wave265: pure TopLevelLetEntry map free (strong pure / seed cold twin). */
  pipeline_module_top_level_let_storage_release(m);
  /* wave266: pure StructLayout maps free (strong pure / seed cold twin). */
  pipeline_module_struct_layout_storage_release(m);
  for (i = 0; i < MAX_MODULE_SIDECARS; i++) {
    if (g_module_sc[i].used && g_module_sc[i].module == m) {
      module_sidecar_free(&g_module_sc[i]);
      return;
    }
  }
}

/**
 * Drop function-body AST pools after a dep parse, keeping signatures for typeck.
 *
 * Why (check peak RSS): `xlang check` of modules that import parser/typeck/codegen
 * (e.g. pipeline.x) holds full body ASTs of every transitive dep at once. Each
 * mega module alone is ~0.6–2GB because `struct ast_Expr` embeds four 128-byte
 * name arrays (~600B+/node). Directory `check compiler` peak matched single-file
 * pipeline.x (~4.9GB) — not multi-session leak (cleanup already frees deps).
 *
 * For check, deps are already parse_only (no library body typeck). Entry typeck
 * only needs dep export signatures: Func name/params/return + Type pool +
 * struct_layouts / imports / type_aliases. Body expr/block GrowVecs are pure
 * waste after parse_only and dominate RSS.
 *
 * What is kept:
 *   - ArenaSidecar: types, type_type_arg_*, func_params
 *   - ModuleSidecar: funcs (headers), imports, struct_layouts, type_aliases, enums
 * What is freed (body pools):
 *   - exprs, blocks, consts/lets/ifs/regions/loops, stmt_order, call/match/lit arg pools
 * Func body_ref / body_expr_ref are nulled so typeck treats them as body-less
 * (same as extern / empty library stubs).
 *
 * Invariant: call only after dep parse_only for check sessions; never on the
 * entry module while entry typeck still needs its own bodies.
 * PLATFORM: SHARED — mac + Ubuntu check RSS; dual L2 after change.
 */
void ast_pool_drop_bodies_for_check(struct ast_ASTArena *a, struct ast_Module *m) {
  ArenaSidecar *sc;
  int32_t i;
  int32_t n;
  size_t freed_approx = 0;
  int32_t n_expr = 0;
  int32_t n_block = 0;
  int32_t n_type = 0;

  if (m) {
    n = m->num_funcs;
    for (i = 0; i < n; i++) {
      struct ast_Func *f = module_func_at(m, i);
      if (!f)
        continue;
      f->body_ref = 0;
      f->body_expr_ref = 0;
    }
  }
  if (!a)
    return;
  sc = arena_sidecar_get(a, 0);
  if (!sc)
    return;
  n_expr = sc->exprs.len;
  n_block = sc->blocks.len;
  n_type = sc->types.len;
  freed_approx += (size_t)sc->exprs.cap * sc->exprs.elem_sz;
  freed_approx += (size_t)sc->blocks.cap * sc->blocks.elem_sz;
  freed_approx += (size_t)sc->consts.cap * sc->consts.elem_sz;
  freed_approx += (size_t)sc->lets.cap * sc->lets.elem_sz;
  freed_approx += (size_t)sc->ifs.cap * sc->ifs.elem_sz;
  freed_approx += (size_t)sc->regions.cap * sc->regions.elem_sz;
  freed_approx += (size_t)sc->loops.cap * sc->loops.elem_sz;
  freed_approx += (size_t)sc->for_loops.cap * sc->for_loops.elem_sz;
  freed_approx += (size_t)sc->stmt_order.cap * sc->stmt_order.elem_sz;
  freed_approx += (size_t)sc->expr_call_arg_refs.cap * sc->expr_call_arg_refs.elem_sz;
  freed_approx += (size_t)sc->expr_method_call_arg_refs.cap * sc->expr_method_call_arg_refs.elem_sz;
  freed_approx += (size_t)sc->expr_match_arms.cap * sc->expr_match_arms.elem_sz;
  freed_approx += (size_t)sc->expr_struct_lit_fields.cap * sc->expr_struct_lit_fields.elem_sz;
  /* Free body-associated GrowVec data; keep types + func_params. */
  grow_vec_free(&sc->exprs);
  grow_vec_free(&sc->blocks);
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
  grow_vec_free(&sc->expr_method_call_arg_refs);
  grow_vec_free(&sc->expr_match_arms);
  grow_vec_free(&sc->expr_struct_lit_fields);
  grow_vec_free(&sc->expr_array_lit_elem_refs);
  /* Arena-local func pool (if any) is not the module Func table; bodies live in
   * module funcs + expr/block pools. Keep sc->funcs / sc->func_params intact. */
  a->num_exprs = 0;
  a->num_blocks = 0;
  /*
   * PLATFORM: SHARED — return freed pages to the OS so directory/mega-import
   * check peak RSS is max(single dep) not sum(sequential parse peaks).
   * macOS keeps free'd large blocks in-process by default (high-water climbs);
   * Linux glibc similarly retains arenas without malloc_trim.
   * Ubuntu nostdlib: malloc_trim is weak no-op if not linked; large mmap free
   * already munmaps in bootstrap_nostdlib_stubs (wave1241).
   */
#if defined(__APPLE__)
  {
    extern void *malloc_default_zone(void);
    extern size_t malloc_zone_pressure_relief(void *zone, size_t goal);
    (void)malloc_zone_pressure_relief(malloc_default_zone(), 0);
  }
#elif defined(__linux__)
  {
    extern int malloc_trim(size_t pad) __attribute__((weak));
    if (malloc_trim)
      (void)malloc_trim(0);
  }
#endif
  if (link_abi_getenv("XLANG_DEBUG_CHECK_MEM")) {
    size_t live_expr_cap = 0;
    size_t live_type_cap = 0;
    int live_arenas = 0;
    int j;
    for (j = 0; j < MAX_ARENA_SIDECARS; j++) {
      if (!g_arena_sc[j].used)
        continue;
      live_arenas++;
      live_expr_cap += (size_t)g_arena_sc[j].exprs.cap * g_arena_sc[j].exprs.elem_sz;
      live_type_cap += (size_t)g_arena_sc[j].types.cap * g_arena_sc[j].types.elem_sz;
    }
    fprintf(stderr,
            "xlang: [CHECK_MEM] drop_bodies arena=%p n_expr=%d n_block=%d n_type=%d "
            "n_func=%d freed_body_approx=%zuMB | live_arenas=%d live_expr_cap=%zuMB "
            "live_type_cap=%zuMB\n",
            (void *)a, (int)n_expr, (int)n_block, (int)n_type,
            m ? (int)m->num_funcs : -1, freed_approx / (1024 * 1024), live_arenas,
            live_expr_cap / (1024 * 1024), live_type_cap / (1024 * 1024));
  }
}

void ast_pool_onefunc_reset(uint8_t *out) {
  OneFuncSidecar *sc;
  if (!out)
    return;
  sc = onefunc_sidecar_get(out, 0);
  if (!sc)
    return;
  sc->if_cond_refs.len = 0;
  sc->if_then_body_refs.len = 0;
  sc->if_else_body_refs.len = 0;
  sc->const_names.len = 0;
  sc->const_name_lens.len = 0;
  sc->const_init_vals.len = 0;
  sc->const_init_refs.len = 0;
  sc->const_type_refs.len = 0;
  sc->let_names.len = 0;
  sc->let_name_lens.len = 0;
  sc->let_init_vals.len = 0;
  sc->let_init_refs.len = 0;
  sc->let_type_refs.len = 0;
  sc->src_stmt_kind.len = 0;
  sc->src_stmt_idx.len = 0;
  sc->src_body_expr_stmt_refs.len = 0;
  sc->while_cond_refs.len = 0;
  sc->while_body_refs.len = 0;
  sc->for_init_refs.len = 0;
  sc->for_cond_refs.len = 0;
  sc->for_step_refs.len = 0;
  sc->for_body_refs.len = 0;
  sc->param_names.len = 0;
  sc->param_name_lens.len = 0;
  sc->param_type_refs.len = 0;
  sc->call_arg_vals.len = 0;
  sc->regions.len = 0;
  sc->defer_body_refs.len = 0;
  sc->labeleds.len = 0;
}

void ast_pool_onefunc_release(uint8_t *out) {
  int i;
  if (!out)
    return;
  for (i = 0; i < MAX_ONEFUNC_SIDECARS; i++) {
    if (g_onefunc_sc[i].used && g_onefunc_sc[i].onefunc == out) {
      onefunc_sidecar_free(&g_onefunc_sc[i]);
      return;
    }
  }
}
