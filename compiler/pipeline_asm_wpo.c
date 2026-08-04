/* ============================================================================
 * pipeline_asm_wpo.c — backend asm WPO v0 (DCE) + PGO-Lite reach/emit order
 *
 * wave1256 BC 8.3.2 G.7 same-TU domain fold from ast_pool.c:
 *   AsmWpoReachState + g_asm_wpo + g_asm_wpo_pgo_{hot,depth,emit_*}
 *   + asm_wpo_mod_index/register_mod/func_id_of/register_func/func_id_in_module
 *   /func_id_by_name/add_edge
 *   + asm_wpo_call_callee_name/callee_id + asm_wpo_collect_edges_from_expr
 *   + asm_wpo_collect_from_stmt_order_one/from_block
 *   + asm_wpo_is_user_single_file_pgo_entry/is_user_program_entry/user_main_func_id
 *   + asm_wpo_scan_func_body_calls/precollect_all_func_edges
 *   + asm_wpo_user_pgo_force_main_callee_edge/prune_main_edges
 *   + asm_wpo_reach_fixpoint_expand/build_reach
 *   + asm_wpo_mod_is_std_heap/close_std_heap_helpers
 *   + asm_wpo_mark_pgo_hot/depth_user_from_main/depth/depth_of
 *   + asm_wpo_dce_env_enabled/pipeline_strict_preserve_emit
 *   + pipeline_asm_wpo_reach_clear/reach_compute_for_elf
 *   + pipeline_asm_wpo_should_emit_func
 *   + pipeline_asm_wpo_pgo_emit_order_prepare/count/at/is_hot_func
 *
 * WPO v0 (asm backend DCE): mark reachable funcs via typeck-resolved call
 * graph, skip dead exports at emit time. PGO-Lite: root + direct callees
 * marked hot, emit order sorted by call-depth (BFS). Keyed by (ast_Module*,
 * func_index) for .x asm backend query.
 * Included from ast_pool.c (replaces former inline body). Not a separate .o.
 *
 * PLATFORM: SHARED.
 * ============================================================================ */

/**
 * WPO v0（asm 后端 DCE）：按 typeck 解析后的 call graph 标记 reachable，emit 时跳过 dead export。
 * 与 codegen.c 的 codegen_wpo_reach 语义对齐，但 keyed by (ast_Module*, func_index) 供 .x asm 后端查询。
 */
#define ASM_WPO_MAX_FUNCS 1024
#define ASM_WPO_MAX_MODS 64
#define ASM_WPO_MAX_EDGES 4096

/** WPO call 边解析：与 backend emit_call 同读 pipeline_expr_*（勿裸 *Expr 字段，避免池布局偏差）。 */
extern int32_t pipeline_expr_call_callee_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_var_name_len(struct ast_ASTArena *a, int32_t expr_ref);
extern void pipeline_expr_var_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out);
extern int32_t pipeline_expr_call_resolved_func_index_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_call_resolved_dep_index_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_unary_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref);

typedef struct {
  int32_t valid;
  struct ast_Module *entry;
  struct ast_PipelineDepCtx *dep_ctx;
  struct ast_Module *mods[ASM_WPO_MAX_MODS];
  struct ast_ASTArena *arenas[ASM_WPO_MAX_MODS];
  int32_t nmods;
  struct ast_Module *func_mod[ASM_WPO_MAX_FUNCS];
  int32_t func_fi[ASM_WPO_MAX_FUNCS];
  int32_t nfuncs;
  int32_t root_id;
  unsigned char reachable[ASM_WPO_MAX_FUNCS];
  struct {
    int32_t from;
    int32_t to;
  } edges[ASM_WPO_MAX_EDGES];
  int32_t nedges;
} AsmWpoReachState;

static AsmWpoReachState g_asm_wpo;
/** PGO-Lite：root + 直接 callee（BFS depth≤1）标记为 hot emit 候选。 */
static unsigned char g_asm_wpo_pgo_hot[ASM_WPO_MAX_FUNCS];
/** PGO-Lite S2：自 root 的静态 call-depth（BFS）；未 reach 保持 -1。 */
static int32_t g_asm_wpo_pgo_depth[ASM_WPO_MAX_FUNCS];
/** 当前 module 的 emit 顺序（func_index 表；PGO 时按 depth 升序）。 */
static struct ast_Module *g_asm_wpo_pgo_emit_mod;
static int32_t g_asm_wpo_pgo_emit_order[ASM_WPO_MAX_FUNCS];
static int32_t g_asm_wpo_pgo_emit_n;

/** 清空 asm WPO 状态；elf emit 结束或失败时调用。 */
void pipeline_asm_wpo_reach_clear(void) {
  memset(&g_asm_wpo, 0, sizeof(g_asm_wpo));
  memset(g_asm_wpo_pgo_hot, 0, sizeof(g_asm_wpo_pgo_hot));
  memset(g_asm_wpo_pgo_depth, 0xff, sizeof(g_asm_wpo_pgo_depth));
  g_asm_wpo_pgo_emit_mod = NULL;
  g_asm_wpo_pgo_emit_n = 0;
}

/** 在 mods[] 中查找 module 下标；未注册返回 -1。 */
static int32_t asm_wpo_mod_index(struct ast_Module *m) {
  int32_t i;
  if (!m)
    return -1;
  for (i = 0; i < g_asm_wpo.nmods; i++) {
    if (g_asm_wpo.mods[i] == m)
      return i;
  }
  return -1;
}

/** 注册 module+arena；已存在则仅返回下标。 */
static int32_t asm_wpo_register_mod(struct ast_Module *m, struct ast_ASTArena *a) {
  int32_t ix;
  if (!m || !a)
    return -1;
  ix = asm_wpo_mod_index(m);
  if (ix >= 0)
    return ix;
  if (g_asm_wpo.nmods >= ASM_WPO_MAX_MODS)
    return -1;
  g_asm_wpo.mods[g_asm_wpo.nmods] = m;
  g_asm_wpo.arenas[g_asm_wpo.nmods] = a;
  return g_asm_wpo.nmods++;
}

/** (module, func_index) → 全局 func id；未注册返回 -1。 */
static int32_t asm_wpo_func_id_of(struct ast_Module *m, int32_t fi) {
  int32_t i;
  if (!m || fi < 0)
    return -1;
  for (i = 0; i < g_asm_wpo.nfuncs; i++) {
    if (g_asm_wpo.func_mod[i] == m && g_asm_wpo.func_fi[i] == fi)
      return i;
  }
  return -1;
}

/** 登记单个非 extern 函数节点。 */
static int32_t asm_wpo_register_func(struct ast_Module *m, int32_t fi) {
  struct ast_Func *f;
  int32_t id;
  if (!m || fi < 0 || g_asm_wpo.nfuncs >= ASM_WPO_MAX_FUNCS)
    return -1;
  f = module_func_at(m, fi);
  if (!f || f->is_extern)
    return -1;
  id = asm_wpo_func_id_of(m, fi);
  if (id >= 0)
    return id;
  id = g_asm_wpo.nfuncs;
  g_asm_wpo.func_mod[id] = m;
  g_asm_wpo.func_fi[id] = fi;
  g_asm_wpo.nfuncs++;
  return id;
}

/** 按函数名在指定 module 已注册节点中查找 id；未命中返回 -1。 */
static int32_t asm_wpo_func_id_in_module(struct ast_Module *m, uint8_t *name, int32_t name_len) {
  int32_t nf;
  int32_t fi;
  int32_t id;
  if (!m || !name || name_len <= 0)
    return -1;
  nf = pipeline_module_num_funcs(m);
  for (fi = 0; fi < nf; fi++) {
    if (!pipeline_module_func_name_equal_at(m, fi, name, name_len))
      continue;
    id = asm_wpo_func_id_of(m, fi);
    if (id >= 0)
      return id;
  }
  return -1;
}

/** 按函数名在已注册图中查找 id（跨模块）；重名时取首个。 */
static int32_t asm_wpo_func_id_by_name(uint8_t *name, int32_t name_len) {
  int32_t i;
  int32_t fi;
  if (!name || name_len <= 0)
    return -1;
  for (i = 0; i < g_asm_wpo.nfuncs; i++) {
    fi = g_asm_wpo.func_fi[i];
    if (pipeline_module_func_name_equal_at(g_asm_wpo.func_mod[i], fi, name, name_len))
      return i;
  }
  return -1;
}

/** 去重登记 from→to 边。 */
static void asm_wpo_add_edge(int32_t from, int32_t to) {
  int32_t i;
  if (from < 0 || to < 0 || from >= g_asm_wpo.nfuncs || to >= g_asm_wpo.nfuncs)
    return;
  for (i = 0; i < g_asm_wpo.nedges; i++) {
    if (g_asm_wpo.edges[i].from == from && g_asm_wpo.edges[i].to == to)
      return;
  }
  if (g_asm_wpo.nedges >= ASM_WPO_MAX_EDGES)
    return;
  g_asm_wpo.edges[g_asm_wpo.nedges].from = from;
  g_asm_wpo.edges[g_asm_wpo.nedges].to = to;
  g_asm_wpo.nedges++;
}

/**
 * 从 CALL 的 callee expr 取函数名（pipeline_expr_* 优先；kind 非 VAR 时回退裸 var_name 槽）。
 * 返回名长度；0 表示无可用名。
 */
static int32_t asm_wpo_call_callee_name(struct ast_ASTArena *a, int32_t callee_ref, uint8_t *cname) {
  struct ast_Expr *callee_ex;
  int32_t clen;
  if (!a || callee_ref <= 0 || !cname)
    return 0;
  callee_ex = pipeline_arena_expr_ptr(a, callee_ref);
  /** import 限定 callee（vec.vec_u8_new / heap.alloc）：取字段名，勿误用 binding 基名。 */
  if (callee_ex && callee_ex->kind == ast_ExprKind_EXPR_FIELD_ACCESS) {
    clen = pipeline_expr_field_access_name_len(a, callee_ref);
    if (clen > 0 && clen <= 63) {
      pipeline_expr_field_access_name_into(a, callee_ref, cname);
      return clen;
    }
  }
  clen = pipeline_expr_var_name_len(a, callee_ref);
  if (clen > 0 && clen <= 63) {
    pipeline_expr_var_name_into(a, callee_ref, cname);
    return clen;
  }
  if (!callee_ex || callee_ex->var_name_len <= 0 || callee_ex->var_name_len > 127)
    return 0;
  clen = callee_ex->var_name_len;
  memcpy(cname, callee_ex->var_name, (size_t)clen);
  return clen;
}

/** 解析 CALL 的 func id（callee 名与 emit bl 一致；再回退 typeck call_resolved_*，须与名一致）。 */
static int32_t asm_wpo_call_callee_id(struct ast_ASTArena *a, int32_t call_expr_ref, struct ast_Module *caller_mod,
                                      struct ast_PipelineDepCtx *ctx) {
  struct ast_Module *callee_mod;
  int32_t dep_ix;
  int32_t func_ix;
  int32_t callee_ref;
  int32_t cid;
  int32_t clen;
  uint8_t cname[128];
  if (!a || call_expr_ref <= 0)
    return -1;
  callee_ref = pipeline_expr_call_callee_ref_at(a, call_expr_ref);
  clen = asm_wpo_call_callee_name(a, callee_ref, cname);
  /** overload：须按实参分派，勿仅按名取首个 pick。 */
  if (clen > 0 && caller_mod) {
    int32_t ov_n = 0;
    int32_t fi_ov;
    int32_t nf_ov = pipeline_module_num_funcs(caller_mod);
    for (fi_ov = 0; fi_ov < nf_ov; fi_ov++) {
      if (pipeline_asm_module_func_is_extern_at(caller_mod, fi_ov) != 0)
        continue;
      if (pipeline_module_func_name_equal_at(caller_mod, fi_ov, cname, clen))
        ov_n++;
    }
    if (ov_n > 1) {
      int32_t picked = pipeline_typeck_pick_overload_func_index_for_call_c(caller_mod, a, call_expr_ref);
      if (picked >= 0) {
        cid = asm_wpo_func_id_of(caller_mod, picked);
        if (cid >= 0)
          return cid;
      }
    }
  }
  if (clen > 0) {
    cid = asm_wpo_func_id_in_module(caller_mod, cname, clen);
    if (cid < 0)
      cid = asm_wpo_func_id_by_name(cname, clen);
    if (cid >= 0)
      return cid;
  }
  func_ix = pipeline_expr_call_resolved_func_index_at(a, call_expr_ref);
  if (func_ix >= 0) {
    dep_ix = pipeline_expr_call_resolved_dep_index_at(a, call_expr_ref);
    callee_mod = caller_mod;
    if (dep_ix >= 0 && ctx)
      callee_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);
    /** dep import / qualified callee：typeck resolved 为准；cname 与 FIELD_ACCESS 基名常不一致。 */
    if (clen > 0 && callee_mod && dep_ix < 0 &&
        pipeline_expr_kind_ord_at(a, callee_ref) != (int32_t)ast_ExprKind_EXPR_FIELD_ACCESS &&
        !pipeline_module_func_name_equal_at(callee_mod, func_ix, cname, clen))
      return -1;
    if (callee_mod) {
      cid = asm_wpo_func_id_of(callee_mod, func_ix);
      if (cid >= 0)
        return cid;
    }
  }
  return -1;
}

/** 前向声明：块内 call 边收集（collect_edges 与 collect_from_block 互递归）。 */
static void asm_wpo_collect_from_block(struct ast_ASTArena *a, int32_t block_ref, int32_t caller_id,
                                       struct ast_Module *caller_mod, struct ast_PipelineDepCtx *ctx);

/** 递归收集表达式中的 call 边（depth 上限防栈溢出）。 */
static void asm_wpo_collect_edges_from_expr(struct ast_ASTArena *a, int32_t expr_ref, int32_t caller_id,
                                            struct ast_Module *caller_mod, struct ast_PipelineDepCtx *ctx, int32_t depth) {
  struct ast_Expr *ex;
  int32_t i;
  int32_t cid;
  int32_t *arg_slot;
  if (!a || expr_ref <= 0 || caller_id < 0 || depth > 64)
    return;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return;
  if (ex->kind == ast_ExprKind_EXPR_CALL) {
    cid = asm_wpo_call_callee_id(a, expr_ref, caller_mod, ctx);
    if (cid >= 0)
      asm_wpo_add_edge(caller_id, cid);
    for (i = 0; i < ex->call_num_args; i++) {
      arg_slot = expr_call_arg_slot(a, expr_ref, i, 0);
      if (arg_slot && *arg_slot > 0)
        asm_wpo_collect_edges_from_expr(a, *arg_slot, caller_id, caller_mod, ctx, depth + 1);
    }
    if (ex->call_callee_ref > 0)
      asm_wpo_collect_edges_from_expr(a, ex->call_callee_ref, caller_id, caller_mod, ctx, depth + 1);
    return;
  }
  /*
   * wave358 Cap residual pure — METHOD_CALL exclusive path (before binop peel).
   * Root: METHOD_CALL fell through to binop_left/right (union slots) and returned
   * without UFCS edge → freestanding emit_n skipped free get → ld UNDEF get.
   * G.7: same-module free method via call_resolved or method name match.
   * PLATFORM: SHARED freestanding WPO · LINUX gold.
   */
  /* kind via accessor (SoA-safe); 49 = EXPR_METHOD_CALL product ordinal. */
  if (ex->kind == ast_ExprKind_EXPR_METHOD_CALL ||
      pipeline_expr_kind_ord_at(a, expr_ref) == 49) {
    int32_t r_fn = pipeline_expr_call_resolved_func_index_at(a, expr_ref);
    int32_t r_dep = pipeline_expr_call_resolved_dep_index_at(a, expr_ref);
    int32_t mcid = -1;
    int32_t mlen = pipeline_expr_method_call_name_len(a, expr_ref);
    int32_t mbase = pipeline_expr_method_call_base_ref_at(a, expr_ref);
    int32_t mnargs = pipeline_expr_method_call_num_args_at(a, expr_ref);
    uint8_t mnm[128];
    if (r_fn >= 0 && r_dep < 0 && caller_mod)
      mcid = asm_wpo_func_id_of(caller_mod, r_fn);
    if (mcid < 0 && mlen > 0 && mlen <= 63) {
      pipeline_expr_method_call_name_into(a, expr_ref, mnm);
      mcid = asm_wpo_func_id_in_module(caller_mod, mnm, mlen);
      if (mcid < 0)
        mcid = asm_wpo_func_id_by_name(mnm, mlen);
      /* All same-name overloads: free get may not be first fi registration order. */
      if (caller_mod && mcid < 0) {
        int32_t fi_m;
        int32_t nf_m = pipeline_module_num_funcs(caller_mod);
        for (fi_m = 0; fi_m < nf_m; fi_m++) {
          if (pipeline_module_func_name_equal_at(caller_mod, fi_m, mnm, mlen)) {
            int32_t id_m = asm_wpo_func_id_of(caller_mod, fi_m);
            if (id_m >= 0)
              asm_wpo_add_edge(caller_id, id_m);
          }
        }
      }
    }
    if (mcid >= 0)
      asm_wpo_add_edge(caller_id, mcid);
    if (mbase > 0)
      asm_wpo_collect_edges_from_expr(a, mbase, caller_id, caller_mod, ctx, depth + 1);
    for (i = 0; i < mnargs; i++) {
      arg_slot = expr_method_call_arg_slot(a, expr_ref, i, 0);
      if (arg_slot && *arg_slot > 0)
        asm_wpo_collect_edges_from_expr(a, *arg_slot, caller_id, caller_mod, ctx, depth + 1);
    }
    return;
  }
  if (ex->kind == ast_ExprKind_EXPR_RETURN || ex->kind == ast_ExprKind_EXPR_PANIC || ex->kind == ast_ExprKind_EXPR_NEG ||
      ex->kind == ast_ExprKind_EXPR_BITNOT || ex->kind == ast_ExprKind_EXPR_LOGNOT || ex->kind == ast_ExprKind_EXPR_ADDR_OF ||
      ex->kind == ast_ExprKind_EXPR_DEREF || ex->kind == ast_ExprKind_EXPR_AWAIT || ex->kind == ast_ExprKind_EXPR_RUN ||
      ex->kind == ast_ExprKind_EXPR_SPAWN) {
    {
      int32_t uop = pipeline_expr_unary_operand_ref_at(a, expr_ref);
      if (uop > 0)
        asm_wpo_collect_edges_from_expr(a, uop, caller_id, caller_mod, ctx, depth + 1);
    }
    return;
  }
  if (ex->kind == ast_ExprKind_EXPR_AS) {
    if (ex->as_operand_ref > 0)
      asm_wpo_collect_edges_from_expr(a, ex->as_operand_ref, caller_id, caller_mod, ctx, depth + 1);
    return;
  }
  if (ex->kind == ast_ExprKind_EXPR_IF || ex->kind == ast_ExprKind_EXPR_TERNARY) {
    if (ex->if_cond_ref > 0)
      asm_wpo_collect_edges_from_expr(a, ex->if_cond_ref, caller_id, caller_mod, ctx, depth + 1);
    if (ex->if_then_ref > 0)
      asm_wpo_collect_edges_from_expr(a, ex->if_then_ref, caller_id, caller_mod, ctx, depth + 1);
    if (ex->if_else_ref > 0)
      asm_wpo_collect_edges_from_expr(a, ex->if_else_ref, caller_id, caller_mod, ctx, depth + 1);
    return;
  }
  if (ex->kind == ast_ExprKind_EXPR_BLOCK) {
    if (ex->block_ref > 0)
      asm_wpo_collect_from_block(a, ex->block_ref, caller_id, caller_mod, ctx);
    return;
  }
  if (ex->binop_left_ref > 0 || ex->binop_right_ref > 0) {
    if (ex->binop_left_ref > 0)
      asm_wpo_collect_edges_from_expr(a, ex->binop_left_ref, caller_id, caller_mod, ctx, depth + 1);
    if (ex->binop_right_ref > 0)
      asm_wpo_collect_edges_from_expr(a, ex->binop_right_ref, caller_id, caller_mod, ctx, depth + 1);
    return;
  }
  /*
   * wave351 Cap residual pure: STRUCT_LIT field inits and ARRAY_LIT elems must feed
   * the call graph. Root: `Box { a: fill(n) }` only-call-site left fill unreachable
   * (emit_n skipped fill → UNDEF). G.7: same collector; walk sidecar field/elem refs.
   * PLATFORM: SHARED freestanding WPO · LINUX gold.
   */
  if (ex->kind == ast_ExprKind_EXPR_STRUCT_LIT) {
    for (i = 0; i < ex->struct_lit_num_fields; i++) {
      int32_t iref = pipeline_expr_struct_lit_init_ref(a, expr_ref, i);
      if (iref > 0)
        asm_wpo_collect_edges_from_expr(a, iref, caller_id, caller_mod, ctx, depth + 1);
    }
    return;
  }
  if (ex->kind == ast_ExprKind_EXPR_ARRAY_LIT) {
    for (i = 0; i < ex->array_lit_num_elems; i++) {
      int32_t eref = pipeline_expr_array_lit_elem_ref(a, expr_ref, i);
      if (eref > 0)
        asm_wpo_collect_edges_from_expr(a, eref, caller_id, caller_mod, ctx, depth + 1);
    }
    return;
  }
  if (ex->field_access_base_ref > 0)
    asm_wpo_collect_edges_from_expr(a, ex->field_access_base_ref, caller_id, caller_mod, ctx, depth + 1);
  if (ex->index_base_ref > 0)
    asm_wpo_collect_edges_from_expr(a, ex->index_base_ref, caller_id, caller_mod, ctx, depth + 1);
  if (ex->index_index_ref > 0)
    asm_wpo_collect_edges_from_expr(a, ex->index_index_ref, caller_id, caller_mod, ctx, depth + 1);
}

/**
 * stmt_order 单步：按 kind 分派 const/let/expr/loop/for/if/region（与 typeck/codegen 一致）。
 * 现代 parser 以 stmt_order 为源码序权威；仅扫 legacy 池会漏 return/expr 边（WPO-S4 warm_mid UND）。
 */
static void asm_wpo_collect_from_stmt_order_one(struct ast_ASTArena *a, int32_t block_ref, int32_t caller_id,
                                              struct ast_Module *caller_mod, struct ast_PipelineDepCtx *ctx,
                                              int32_t si) {
  struct ast_Block *b;
  uint8_t sk;
  int32_t idx;
  int32_t er;
  if (!a || block_ref <= 0 || caller_id < 0)
    return;
  b = pipeline_arena_block_ptr(a, block_ref);
  if (!b || si < 0 || si >= b->num_stmt_order)
    return;
  sk = pipeline_block_stmt_order_kind(a, block_ref, si);
  idx = pipeline_block_stmt_order_idx(a, block_ref, si);
  if (sk == 0 && idx >= 0 && idx < b->num_consts) {
    er = pipeline_block_const_init_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
  } else if (sk == 1 && idx >= 0 && idx < b->num_lets) {
    er = pipeline_block_let_init_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
  } else if (sk == 2 && idx >= 0 && idx < b->num_expr_stmts) {
    er = pipeline_block_expr_stmt_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
  } else if (sk == 3 && idx >= 0 && idx < b->num_loops) {
    er = pipeline_block_while_cond_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    er = pipeline_block_while_body_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
  } else if (sk == 4 && idx >= 0 && idx < b->num_for_loops) {
    er = pipeline_block_for_init_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    er = pipeline_block_for_cond_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    er = pipeline_block_for_step_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    er = pipeline_block_for_body_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
  } else if (sk == 5 && idx >= 0 && idx < b->num_if_stmts) {
    er = pipeline_block_if_cond_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    er = pipeline_block_if_then_body_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
    er = pipeline_block_if_else_body_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
  } else if (sk == 6) {
    er = pipeline_block_region_body_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
  }
}

/** 收集块内全部 call 边。 */
static void asm_wpo_collect_from_block(struct ast_ASTArena *a, int32_t block_ref, int32_t caller_id,
                                       struct ast_Module *caller_mod, struct ast_PipelineDepCtx *ctx) {
  struct ast_Block *b;
  int32_t i;
  int32_t er;
  struct ast_LabeledStmt *ls;
  if (!a || block_ref <= 0 || caller_id < 0)
    return;
  b = pipeline_arena_block_ptr(a, block_ref);
  if (!b)
    return;
  /** num_stmt_order>0 时按源码序 walk（与 backend emit_block 一致）；否则回退 legacy 池扫描。 */
  if (b->num_stmt_order > 0) {
    for (i = 0; i < b->num_stmt_order; i++)
      asm_wpo_collect_from_stmt_order_one(a, block_ref, caller_id, caller_mod, ctx, i);
    /** stmt_order 与 expr_stmt 池偶发不同步；再扫 expr_stmt 兜底（WPO-S4 return warm_mid 漏边）。 */
    for (i = 0; i < b->num_expr_stmts; i++) {
      er = pipeline_block_expr_stmt_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    }
  } else {
    for (i = 0; i < b->num_consts; i++) {
      er = pipeline_block_const_init_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    }
    for (i = 0; i < b->num_lets; i++) {
      er = pipeline_block_let_init_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    }
    for (i = 0; i < b->num_loops; i++) {
      er = pipeline_block_while_cond_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
      er = pipeline_block_while_body_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
    }
    for (i = 0; i < b->num_for_loops; i++) {
      er = pipeline_block_for_init_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
      er = pipeline_block_for_cond_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
      er = pipeline_block_for_step_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
      er = pipeline_block_for_body_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
    }
    for (i = 0; i < b->num_if_stmts; i++) {
      er = pipeline_block_if_cond_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
      er = pipeline_block_if_then_body_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
      er = pipeline_block_if_else_body_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
    }
    for (i = 0; i < b->num_expr_stmts; i++) {
      er = pipeline_block_expr_stmt_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    }
  }
  /** C parser return 进 labeled 池且不进 stmt_order；须单独扫。 */
  for (i = 0; i < b->num_labeled_stmts; i++) {
    ls = pipeline_block_labeled_ptr(a, block_ref, i);
    if (!ls || ls->is_goto)
      continue;
    er = (int32_t)ls->return_expr_ref;
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
  }
  if (b->final_expr_ref > 0)
    asm_wpo_collect_edges_from_expr(a, b->final_expr_ref, caller_id, caller_mod, ctx, 0);
}

/** 用户单文件 + XLANG_WPO_PGO_HOT：非自举 compiler 模块（pgo_hot_smoke 等）。 */
static int32_t asm_wpo_is_user_single_file_pgo_entry(void) {
  if (!pipeline_elf_pgo_hot_enabled() || !g_asm_wpo.entry || g_asm_wpo.nmods != 1)
    return 0;
  if (asm_module_is_main_driver_selfhost(g_asm_wpo.entry))
    return 0;
  if (asm_module_is_pipeline_selfhost(g_asm_wpo.entry) || asm_module_is_typeck_selfhost(g_asm_wpo.entry) ||
      asm_module_is_backend_selfhost(g_asm_wpo.entry) || asm_module_is_parser_selfhost(g_asm_wpo.entry))
    return 0;
  return 1;
}

/** 前向声明：user_program_entry 判定须查 main 的 WPO id。 */
static int32_t asm_wpo_user_main_func_id(void);

/**
 * 用户可执行/单测 .x（非 compiler 自举模块且含 main）：WPO root/reach 须从 main 出发。
 * main_func_index 误指 #0/mk 时若 root 从 mk 起算，main 虽 force emit 但 get_a 等 callee 会被 DCE。
 */
static int32_t asm_wpo_is_user_program_entry(void) {
  if (!g_asm_wpo.entry || g_asm_wpo.nmods != 1)
    return 0;
  if (asm_module_is_main_driver_selfhost(g_asm_wpo.entry))
    return 0;
  if (asm_module_is_pipeline_selfhost(g_asm_wpo.entry) || asm_module_is_typeck_selfhost(g_asm_wpo.entry) ||
      asm_module_is_backend_selfhost(g_asm_wpo.entry) || asm_module_is_parser_selfhost(g_asm_wpo.entry))
    return 0;
  return asm_wpo_user_main_func_id() >= 0 ? 1 : 0;
}

/** 用户程序 main 的 WPO func id；未找到返回 -1。 */
static int32_t asm_wpo_user_main_func_id(void) {
  static const uint8_t main_nm[5] = {'m', 'a', 'i', 'n', 0};
  int32_t nf;
  int32_t fi;
  int32_t id;
  if (!g_asm_wpo.entry)
    return -1;
  nf = pipeline_module_num_funcs(g_asm_wpo.entry);
  for (fi = 0; fi < nf; fi++) {
    if (!pipeline_module_func_name_equal_at(g_asm_wpo.entry, fi, main_nm, 4))
      continue;
    id = asm_wpo_func_id_of(g_asm_wpo.entry, fi);
    if (id >= 0)
      return id;
  }
  return -1;
}

/** 扫描单函数体中的 call 边（caller_id 固定为图节点 id）。 */
static void asm_wpo_scan_func_body_calls(struct ast_ASTArena *a, struct ast_Module *mod, int32_t func_fi,
                                         int32_t caller_id, struct ast_PipelineDepCtx *ctx) {
  struct ast_Func *f;
  if (!a || !mod || caller_id < 0 || func_fi < 0)
    return;
  f = module_func_at(mod, func_fi);
  if (!f)
    return;
  if (f->body_ref > 0)
    asm_wpo_collect_from_block(a, f->body_ref, caller_id, mod, ctx);
  else if (f->body_expr_ref > 0)
    asm_wpo_collect_edges_from_expr(a, f->body_expr_ref, caller_id, mod, ctx, 0);
}

/** BFS 前预收集全模块 call 边（避免 root 误指 #0 时漏扫 main 体）。 */
static void asm_wpo_precollect_all_func_edges(void) {
  int32_t fid;
  int32_t mi;
  struct ast_ASTArena *a;
  for (fid = 0; fid < g_asm_wpo.nfuncs; fid++) {
    mi = asm_wpo_mod_index(g_asm_wpo.func_mod[fid]);
    a = (mi >= 0) ? g_asm_wpo.arenas[mi] : NULL;
    asm_wpo_scan_func_body_calls(a, g_asm_wpo.func_mod[fid], g_asm_wpo.func_fi[fid], fid, g_asm_wpo.dep_ctx);
  }
}

/**
 * 用户 PGO：强制补 main 尾 return/expr_stmt 的直接 call 边；返回 callee func id 或 -1。
 */
static int32_t asm_wpo_user_pgo_force_main_callee_edge(struct ast_Module *entry, struct ast_ASTArena *a) {
  int32_t main_id;
  int32_t main_fi;
  struct ast_Func *f;
  struct ast_Block *b;
  int32_t er;
  int32_t op;
  int32_t cid;
  int32_t ko;
  if (!entry || !a)
    return -1;
  main_id = asm_wpo_user_main_func_id();
  if (main_id < 0)
    return -1;
  main_fi = g_asm_wpo.func_fi[main_id];
  f = module_func_at(entry, main_fi);
  if (!f || f->body_ref <= 0)
    return -1;
  b = pipeline_arena_block_ptr(a, f->body_ref);
  if (!b)
    return -1;
  er = 0;
  if (b->num_expr_stmts > 0)
    er = pipeline_block_expr_stmt_ref(a, f->body_ref, b->num_expr_stmts - 1);
  if (er <= 0 && b->final_expr_ref > 0)
    er = b->final_expr_ref;
  if (er <= 0)
    return -1;
  ko = pipeline_expr_kind_ord_at(a, er);
  if (ko == (int32_t)ast_ExprKind_EXPR_RETURN) {
    op = pipeline_expr_unary_operand_ref_at(a, er);
    if (op <= 0)
      return -1;
    er = op;
  }
  ko = pipeline_expr_kind_ord_at(a, er);
  /* wave358: UFCS METHOD_CALL same-module free method (not only CALL). */
  if (ko == (int32_t)ast_ExprKind_EXPR_METHOD_CALL) {
    int32_t r_fn = pipeline_expr_call_resolved_func_index_at(a, er);
    int32_t r_dep = pipeline_expr_call_resolved_dep_index_at(a, er);
    int32_t nlen = pipeline_expr_method_call_name_len(a, er);
    uint8_t mnm[128];
    cid = -1;
    if (r_fn >= 0 && r_dep < 0)
      cid = asm_wpo_func_id_of(entry, r_fn);
    if (cid < 0 && nlen > 0 && nlen <= 63) {
      pipeline_expr_method_call_name_into(a, er, mnm);
      cid = asm_wpo_func_id_in_module(entry, mnm, nlen);
      if (cid < 0)
        cid = asm_wpo_func_id_by_name(mnm, nlen);
    }
    if (cid >= 0)
      asm_wpo_add_edge(main_id, cid);
    return cid;
  }
  if (ko != (int32_t)ast_ExprKind_EXPR_CALL)
    return -1;
  cid = asm_wpo_call_callee_id(a, er, entry, g_asm_wpo.dep_ctx);
  if (cid >= 0)
    asm_wpo_add_edge(main_id, cid);
  return cid;
}

/** 用户 PGO：删除 main 上除 legit_to 外的误边（main 体误指 warm_mid 块时 main→hot_add）。 */
static void asm_wpo_user_pgo_prune_main_edges(int32_t main_id, int32_t legit_to) {
  int32_t ei;
  if (main_id < 0 || legit_to < 0)
    return;
  ei = 0;
  while (ei < g_asm_wpo.nedges) {
    if (g_asm_wpo.edges[ei].from == main_id && g_asm_wpo.edges[ei].to != legit_to) {
      g_asm_wpo.edges[ei] = g_asm_wpo.edges[g_asm_wpo.nedges - 1];
      g_asm_wpo.nedges--;
      continue;
    }
    ei++;
  }
}

/**
 * 在已有 reachable 集合上反复补边 + BFS 扩展（至多 16 轮）。
 * SKIP_TYPECK 自举模块 call graph 首轮常不完整，须 fixpoint 才能保留编排链 callee。
 */
static void asm_wpo_reach_fixpoint_expand(void) {
  int32_t queue[ASM_WPO_MAX_FUNCS];
  int32_t qh;
  int32_t qt;
  int32_t pass;
  int32_t fid;
  int32_t expanded;
  struct ast_Module *m;
  struct ast_ASTArena *a;
  struct ast_Func *f;
  int32_t mi;
  int32_t fi;
  int32_t ei;
  int32_t to;

  for (pass = 0; pass < 16; pass++) {
    expanded = 0;
    for (fid = 0; fid < g_asm_wpo.nfuncs; fid++) {
      if (!g_asm_wpo.reachable[(size_t)fid])
        continue;
      m = g_asm_wpo.func_mod[fid];
      fi = g_asm_wpo.func_fi[fid];
      mi = asm_wpo_mod_index(m);
      a = (mi >= 0) ? g_asm_wpo.arenas[mi] : NULL;
      f = module_func_at(m, fi);
      if (!a || !f)
        continue;
      if (f->body_ref > 0)
        asm_wpo_collect_from_block(a, f->body_ref, fid, m, g_asm_wpo.dep_ctx);
      else if (f->body_expr_ref > 0)
        asm_wpo_collect_edges_from_expr(a, f->body_expr_ref, fid, m, g_asm_wpo.dep_ctx, 0);
    }
    qh = 0;
    qt = 0;
    for (fid = 0; fid < g_asm_wpo.nfuncs; fid++) {
      if (g_asm_wpo.reachable[(size_t)fid] && qt < ASM_WPO_MAX_FUNCS)
        queue[qt++] = fid;
    }
    while (qh < qt && qh < ASM_WPO_MAX_FUNCS) {
      fid = queue[qh++];
      for (ei = 0; ei < g_asm_wpo.nedges; ei++) {
        if (g_asm_wpo.edges[ei].from != fid)
          continue;
        to = g_asm_wpo.edges[ei].to;
        if (to < 0 || to >= g_asm_wpo.nfuncs)
          continue;
        if (!g_asm_wpo.reachable[(size_t)to]) {
          g_asm_wpo.reachable[(size_t)to] = 1;
          expanded = 1;
          if (qt < ASM_WPO_MAX_FUNCS)
            queue[qt++] = to;
        }
      }
    }
    if (!expanded)
      break;
  }
}

/** 从 root 起 BFS 标记 reachable 并补全边（与 codegen WPO 同语义）。 */
static void asm_wpo_build_reach(void) {
  int32_t queue[ASM_WPO_MAX_FUNCS];
  int32_t qh;
  int32_t qt;
  int32_t fid;
  struct ast_Module *m;
  struct ast_ASTArena *a;
  struct ast_Func *f;
  int32_t mi;
  int32_t fi;
  int32_t ei;
  int32_t to;
  int32_t user_pgo;
  if (g_asm_wpo.root_id < 0 || g_asm_wpo.root_id >= g_asm_wpo.nfuncs)
    return;
  user_pgo = asm_wpo_is_user_single_file_pgo_entry();
  /** 预收集全图边 + 用户 PGO 补 main→直接 callee 并修剪误边（warm_mid UND / hot_add 误 hot）。 */
  asm_wpo_precollect_all_func_edges();
  if (user_pgo && g_asm_wpo.entry && g_asm_wpo.nmods > 0) {
    int32_t main_callee = asm_wpo_user_pgo_force_main_callee_edge(g_asm_wpo.entry, g_asm_wpo.arenas[0]);
    int32_t main_id = asm_wpo_user_main_func_id();
    if (main_id >= 0 && main_callee >= 0)
      asm_wpo_user_pgo_prune_main_edges(main_id, main_callee);
  }
  qh = 0;
  qt = 0;
  g_asm_wpo.reachable[(size_t)g_asm_wpo.root_id] = 1;
  queue[qt++] = g_asm_wpo.root_id;
  while (qh < qt && qh < ASM_WPO_MAX_FUNCS) {
    fid = queue[qh++];
    m = g_asm_wpo.func_mod[fid];
    fi = g_asm_wpo.func_fi[fid];
    mi = asm_wpo_mod_index(m);
    a = (mi >= 0) ? g_asm_wpo.arenas[mi] : NULL;
    f = module_func_at(m, fi);
    if (a && f) {
      if (f->body_ref > 0)
        asm_wpo_collect_from_block(a, f->body_ref, fid, m, g_asm_wpo.dep_ctx);
      else if (f->body_expr_ref > 0)
        asm_wpo_collect_edges_from_expr(a, f->body_expr_ref, fid, m, g_asm_wpo.dep_ctx, 0);
    }
    for (ei = 0; ei < g_asm_wpo.nedges; ei++) {
      if (g_asm_wpo.edges[ei].from != fid)
        continue;
      to = g_asm_wpo.edges[ei].to;
      if (to < 0 || to >= g_asm_wpo.nfuncs)
        continue;
      if (!g_asm_wpo.reachable[(size_t)to]) {
        g_asm_wpo.reachable[(size_t)to] = 1;
        if (qt < ASM_WPO_MAX_FUNCS)
          queue[qt++] = to;
      }
    }
  }
  asm_wpo_reach_fixpoint_expand();
}

/**
 * 模块是否含 allocator_kind_heap（std.heap 特征 export）。
 */
static int32_t asm_wpo_mod_is_std_heap(struct ast_Module *m) {
  int32_t fi;
  int32_t nf;
  if (!m)
    return 0;
  nf = pipeline_module_num_funcs(m);
  for (fi = 0; fi < nf; fi++) {
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"allocator_kind_heap", 19))
      return 1;
  }
  return 0;
}

/**
 * std.heap allocator_* 同模块 helpers 偶发漏边（return-in-if）；reachable 时强制保留 alloc/arena64_alloc/realloc。
 */
static void asm_wpo_close_std_heap_helpers(void) {
  int32_t fid;
  struct ast_Module *heap_mod;
  heap_mod = 0;
  for (fid = 0; fid < g_asm_wpo.nfuncs; fid++) {
    if (!g_asm_wpo.reachable[(size_t)fid])
      continue;
    if (asm_wpo_mod_is_std_heap(g_asm_wpo.func_mod[fid])) {
      heap_mod = g_asm_wpo.func_mod[fid];
      break;
    }
  }
  if (!heap_mod)
    return;
  for (fid = 0; fid < g_asm_wpo.nfuncs; fid++) {
    uint8_t fn[128];
    int32_t fl;
    int32_t fi;
    if (g_asm_wpo.func_mod[fid] != heap_mod)
      continue;
    fi = g_asm_wpo.func_fi[fid];
    fl = pipeline_module_func_name_len_at(heap_mod, fi);
    if (fl <= 0 || fl > 127)
      continue;
    pipeline_module_func_name_copy64(heap_mod, fi, fn);
    if (pipeline_module_func_name_equal_at(heap_mod, fi, (uint8_t *)"alloc", 5) ||
        pipeline_module_func_name_equal_at(heap_mod, fi, (uint8_t *)"arena64_alloc", 11) ||
        pipeline_module_func_name_equal_at(heap_mod, fi, (uint8_t *)"realloc", 7))
      g_asm_wpo.reachable[(size_t)fid] = 1;
  }
  {
    static const uint8_t *hc_names[3];
    static const int32_t hc_lens[3] = {20, 12, 15};
    int32_t hj;
    hc_names[0] = (const uint8_t *)"heap_arena64_alloc_c";
    hc_names[1] = (const uint8_t *)"heap_alloc_c";
    hc_names[2] = (const uint8_t *)"heap_realloc_c";
    for (hj = 0; hj < 3; hj++) {
      int32_t cid2 = asm_wpo_func_id_by_name((uint8_t *)hc_names[hj], hc_lens[hj]);
      if (cid2 >= 0)
        g_asm_wpo.reachable[(size_t)cid2] = 1;
    }
  }
}

/** XLANG_WPO_PGO_HOT=1 时：root 与其直接 callee 标记 hot（静态 call-depth 代理）。 */
static void asm_wpo_mark_pgo_hot(void) {
  int32_t root;
  int32_t ei;
  int32_t to;
  int32_t nf;
  int32_t fi;
  int32_t mid;
  static const uint8_t main_nm[5] = {'m', 'a', 'i', 'n', 0};
  memset(g_asm_wpo_pgo_hot, 0, sizeof(g_asm_wpo_pgo_hot));
  if (!pipeline_elf_pgo_hot_enabled())
    return;
  root = g_asm_wpo.root_id;
  if (root < 0 || root >= g_asm_wpo.nfuncs)
    return;
  g_asm_wpo_pgo_hot[(size_t)root] = 1;
  /** 用户 PGO：main + 其 return 直接 callee 进 .text.hot（勿用误扫的 main→hot_add 边）。 */
  if (asm_wpo_is_user_single_file_pgo_entry()) {
    int32_t main_id = asm_wpo_user_main_func_id();
    int32_t main_callee;
    if (main_id >= 0) {
      g_asm_wpo_pgo_hot[(size_t)main_id] = 1;
      if (g_asm_wpo.entry && g_asm_wpo.nmods > 0) {
        main_callee = asm_wpo_user_pgo_force_main_callee_edge(g_asm_wpo.entry, g_asm_wpo.arenas[0]);
        if (main_callee >= 0 && g_asm_wpo.reachable[(size_t)main_callee])
          g_asm_wpo_pgo_hot[(size_t)main_callee] = 1;
      }
    }
    return;
  }
  /** 用户程序：入口 main 须进 .text.hot（root 误指 #0 占位符时兜底，与 should_emit main 保留配套）。 */
  if (g_asm_wpo.entry && !asm_module_is_main_driver_selfhost(g_asm_wpo.entry)) {
    nf = pipeline_module_num_funcs(g_asm_wpo.entry);
    for (fi = 0; fi < nf; fi++) {
      if (!pipeline_module_func_name_equal_at(g_asm_wpo.entry, fi, main_nm, 4))
        continue;
      mid = asm_wpo_func_id_of(g_asm_wpo.entry, fi);
      if (mid >= 0)
        g_asm_wpo_pgo_hot[(size_t)mid] = 1;
    }
  }
  for (ei = 0; ei < g_asm_wpo.nedges; ei++) {
    if (g_asm_wpo.edges[ei].from != root)
      continue;
    to = g_asm_wpo.edges[ei].to;
    if (to < 0 || to >= g_asm_wpo.nfuncs)
      continue;
    if (g_asm_wpo.reachable[(size_t)to])
      g_asm_wpo_pgo_hot[(size_t)to] = 1;
  }
}

/** PGO-Lite S2：自 root BFS 标记 call-depth（供 .text.hot / unlikely emit 排序）。 */
static void asm_wpo_mark_pgo_depth_user_from_main(void) {
  int32_t main_id;
  int32_t queue[ASM_WPO_MAX_FUNCS];
  int32_t qh;
  int32_t qt;
  int32_t fid;
  int32_t ei;
  int32_t to;
  int32_t nd;
  main_id = asm_wpo_user_main_func_id();
  if (main_id < 0 || main_id >= g_asm_wpo.nfuncs)
    return;
  memset(g_asm_wpo_pgo_depth, 0xff, sizeof(g_asm_wpo_pgo_depth));
  g_asm_wpo_pgo_depth[(size_t)main_id] = 0;
  qh = 0;
  qt = 1;
  queue[0] = main_id;
  while (qh < qt && qh < ASM_WPO_MAX_FUNCS) {
    fid = queue[qh++];
    nd = g_asm_wpo_pgo_depth[(size_t)fid];
    if (nd < 0)
      continue;
    for (ei = 0; ei < g_asm_wpo.nedges; ei++) {
      if (g_asm_wpo.edges[ei].from != fid)
        continue;
      to = g_asm_wpo.edges[ei].to;
      if (to < 0 || to >= g_asm_wpo.nfuncs)
        continue;
      if (!g_asm_wpo.reachable[(size_t)to])
        continue;
      if (g_asm_wpo_pgo_depth[(size_t)to] >= 0)
        continue;
      g_asm_wpo_pgo_depth[(size_t)to] = nd + 1;
      if (qt < ASM_WPO_MAX_FUNCS)
        queue[qt++] = to;
    }
  }
}

/** PGO-Lite S2：自 root BFS 标记 call-depth（供 .text.hot / unlikely emit 排序）。 */
static void asm_wpo_mark_pgo_depth(void) {
  int32_t root;
  int32_t queue[ASM_WPO_MAX_FUNCS];
  int32_t qh;
  int32_t qt;
  int32_t fid;
  int32_t ei;
  int32_t to;
  int32_t nd;
  memset(g_asm_wpo_pgo_depth, 0xff, sizeof(g_asm_wpo_pgo_depth));
  if (!pipeline_elf_pgo_hot_enabled() || !g_asm_wpo.valid)
    return;
  /** 用户 PGO 单文件：depth 恒以 main 为根（勿用误 root 导致 warm_mid depth0 先于 main emit）。 */
  if (asm_wpo_is_user_single_file_pgo_entry()) {
    asm_wpo_mark_pgo_depth_user_from_main();
    return;
  }
  root = g_asm_wpo.root_id;
  if (root < 0 || root >= g_asm_wpo.nfuncs)
    return;
  g_asm_wpo_pgo_depth[(size_t)root] = 0;
  qh = 0;
  qt = 1;
  queue[0] = root;
  while (qh < qt && qh < ASM_WPO_MAX_FUNCS) {
    fid = queue[qh++];
    nd = g_asm_wpo_pgo_depth[(size_t)fid];
    if (nd < 0)
      continue;
    for (ei = 0; ei < g_asm_wpo.nedges; ei++) {
      if (g_asm_wpo.edges[ei].from != fid)
        continue;
      to = g_asm_wpo.edges[ei].to;
      if (to < 0 || to >= g_asm_wpo.nfuncs)
        continue;
      if (!g_asm_wpo.reachable[(size_t)to])
        continue;
      if (g_asm_wpo_pgo_depth[(size_t)to] >= 0)
        continue;
      g_asm_wpo_pgo_depth[(size_t)to] = nd + 1;
      if (qt < ASM_WPO_MAX_FUNCS)
        queue[qt++] = to;
    }
  }
}

/** 取 (module, fi) 的 PGO call-depth；未知/不可达返回 9999。 */
static int32_t asm_wpo_pgo_depth_of(struct ast_Module *m, int32_t fi) {
  int32_t id;
  int32_t d;
  if (!m || fi < 0)
    return 9999;
  id = asm_wpo_func_id_of(m, fi);
  if (id < 0)
    return 9999;
  d = g_asm_wpo_pgo_depth[(size_t)id];
  if (d < 0)
    return 9999;
  return d;
}

/** 读 XLANG_ASM_WPO_DCE：未设或非 "0" 时启用 asm WPO DCE；设为 0 时关闭（A/B __text bench）。
 * XLANG_WPO_NO_FOLD=1 时亦关闭：对照 bench 须保留 lane0/scale 等 callee 定义，避免 reach 漏边导致 UNDEF。 */
static int32_t asm_wpo_dce_env_enabled(void) {
  if (link_abi_getenv("XLANG_WPO_NO_FOLD"))
    return 0;
  const char *e = link_abi_getenv("XLANG_ASM_WPO_DCE");
  if (!e || e[0] == '\0')
    return 1;
  if (e[0] == '0' && (e[1] == '\0' || e[1] == '\n'))
    return 0;
  return 1;
}

/** 在 asm_codegen_elf_o 入口：登记 entry+deps 全部函数并构建 WPO reach。 */
void pipeline_asm_wpo_reach_compute_for_elf(struct ast_Module *entry, struct ast_ASTArena *entry_arena,
                                            struct ast_PipelineDepCtx *ctx) {
  int32_t ndep;
  int32_t j;
  struct ast_Module *dm;
  struct ast_ASTArena *da;
  int32_t mi;
  int32_t nf;
  int32_t fi;
  int32_t main_ix;
  uint8_t main_nm[5] = {'m', 'a', 'i', 'n', 0};
  pipeline_asm_wpo_reach_clear();
  if (!entry || !entry_arena)
    return;
  /** A/B bench：XLANG_ASM_WPO_DCE=0 时不构图，emit 全量函数。 */
  if (!asm_wpo_dce_env_enabled())
    return;
  /**
   * 用户库 module .o（无 main、无 entry）：须全量 export 进 .o，勿 WPO 误留 emit_n=1 空壳。
   * PLATFORM: SHARED — compiler selfhost dogfood（typeck/pipeline/backend/driver_compile）
   * 使用下方命名 WPO root；禁止走此 early-return（否则 typeck_wpo __text 全量 ~100KiB 压不进 baseline）。
   * 历史债：2026-06-24 加用户库门时误伤 selfhost；typeck_wpo max 2048 从此红。
   */
  main_ix = pipeline_module_main_func_index(entry);
  if (main_ix < 0) {
    static const uint8_t entry_nm[6] = {'e', 'n', 't', 'r', 'y', 0};
    nf = pipeline_module_num_funcs(entry);
    for (fi = 0; fi < nf; fi++) {
      if (pipeline_module_func_name_equal_at(entry, fi, entry_nm, 5))
        break;
    }
    if (fi >= nf) {
      if (!asm_module_is_typeck_selfhost(entry) && !asm_module_is_pipeline_selfhost(entry) &&
          !asm_module_is_backend_selfhost(entry) && !asm_module_is_driver_compile_selfhost(entry))
        return;
    }
  }
  /**
   * build_xlang_asm EMIT_HEAVY 第二遍：全 compiler 自举模块均可 WPO（root 按模块名设置）。
   * pipeline/typeck/backend 分别以 run_x_pipeline_impl / typeck_x_ast / asm_codegen_ast 为 root。
   */
  g_asm_wpo.entry = entry;
  g_asm_wpo.dep_ctx = ctx;
  if (asm_wpo_register_mod(entry, entry_arena) < 0)
    return;
  if (ctx) {
    ndep = pipeline_dep_ctx_ndep(ctx);
    for (j = 0; j < ndep; j++) {
      dm = pipeline_dep_ctx_module_at(ctx, j);
      da = pipeline_dep_ctx_arena_at(ctx, j);
      if (!dm || !da || dm == entry)
        continue;
      (void)asm_wpo_register_mod(dm, da);
    }
  }
  for (mi = 0; mi < g_asm_wpo.nmods; mi++) {
    nf = pipeline_module_num_funcs(g_asm_wpo.mods[mi]);
    for (fi = 0; fi < nf; fi++)
      (void)asm_wpo_register_func(g_asm_wpo.mods[mi], fi);
  }
  /** driver main.x 可执行入口为 entry；须优先于 main_func_index（常误指 #0 占位符 → 32B 错杀 entry）。 */
  {
    static const uint8_t entry_nm[6] = {'e', 'n', 't', 'r', 'y', 0};
    nf = pipeline_module_num_funcs(entry);
    for (fi = 0; fi < nf; fi++) {
      if (pipeline_module_func_name_equal_at(entry, fi, entry_nm, 5)) {
        g_asm_wpo.root_id = asm_wpo_func_id_of(entry, fi);
        break;
      }
    }
  }
  /** 用户程序 root 为 main；须先于 main_func_index（首函数 mk/占位常误设 #0）。 */
  if (g_asm_wpo.root_id < 0) {
    nf = pipeline_module_num_funcs(entry);
    for (fi = 0; fi < nf; fi++) {
      if (pipeline_module_func_name_equal_at(entry, fi, main_nm, 4)) {
        g_asm_wpo.root_id = asm_wpo_func_id_of(entry, fi);
        break;
      }
    }
  }
  /** pipeline.x 编排根：run_x_pipeline_impl（优于 main_func_index #0 占位符）。
   * PLATFORM: SHARED — name must be "run_x_pipeline_impl" (strlen 19); historical "su" + len 20 never matched after SU→SX rename. */
  if (g_asm_wpo.root_id < 0 && asm_module_is_pipeline_selfhost(entry)) {
    nf = pipeline_module_num_funcs(entry);
    for (fi = 0; fi < nf; fi++) {
      if (pipeline_module_func_name_equal_at(entry, fi, (uint8_t *)"run_x_pipeline_impl", 19)) {
        g_asm_wpo.root_id = asm_wpo_func_id_of(entry, fi);
        break;
      }
    }
  }
  /** typeck.x 编排根：typeck_x_ast（S2 gate + pipeline typecheck 入口）。
   * PLATFORM: SHARED — name must be "typeck_x_ast" (strlen 12); historical "typeck_su_ast" + len 13 never matched. */
  if (g_asm_wpo.root_id < 0 && asm_module_is_typeck_selfhost(entry)) {
    nf = pipeline_module_num_funcs(entry);
    for (fi = 0; fi < nf; fi++) {
      if (pipeline_module_func_name_equal_at(entry, fi, (uint8_t *)"typeck_x_ast", 12)) {
        g_asm_wpo.root_id = asm_wpo_func_id_of(entry, fi);
        break;
      }
    }
  }
  /** backend.x 编排根：asm_codegen_ast（pipeline codegen 入口；mega 仍 EMIT_HEAVY 桩）。 */
  if (g_asm_wpo.root_id < 0 && asm_module_is_backend_selfhost(entry)) {
    static uint8_t backend_root_nm[16] = {'a', 's', 'm', '_', 'c', 'o', 'd', 'e', 'g', 'e', 'n', '_', 'a', 's', 't', 0};
    nf = pipeline_module_num_funcs(entry);
    for (fi = 0; fi < nf; fi++) {
      if (pipeline_module_func_name_equal_at(entry, fi, backend_root_nm, 15)) {
        g_asm_wpo.root_id = asm_wpo_func_id_of(entry, fi);
        break;
      }
    }
  }
  /**
   * driver/compile.x dogfood root：compile_dispatch_asm_backend（薄 bl→C，~145B）。
   * PLATFORM: SHARED — full parse_argv / run_compiler_full_x live in driver_compile_emit_heavy.o.
   * Prefer thin dispatch over run_compiler_full_x so build_asm/driver_compile.o stays WPO-compressed.
   */
  if (g_asm_wpo.root_id < 0 && asm_module_is_driver_compile_selfhost(entry)) {
    nf = pipeline_module_num_funcs(entry);
    for (fi = 0; fi < nf; fi++) {
      if (pipeline_module_func_name_equal_at(entry, fi, (uint8_t *)"compile_dispatch_asm_backend", 28)) {
        g_asm_wpo.root_id = asm_wpo_func_id_of(entry, fi);
        break;
      }
    }
    if (g_asm_wpo.root_id < 0) {
      for (fi = 0; fi < nf; fi++) {
        if (pipeline_module_func_name_equal_at(entry, fi, (uint8_t *)"run_compiler_full_x", 19)) {
          g_asm_wpo.root_id = asm_wpo_func_id_of(entry, fi);
          break;
        }
      }
    }
  }
  main_ix = pipeline_module_main_func_index(entry);
  /** main_func_index 仅当其确实指向名为 main 的函数时作 fallback（勿用 #0 误根）。 */
  if (g_asm_wpo.root_id < 0 && main_ix >= 0 &&
      pipeline_module_func_name_equal_at(entry, main_ix, main_nm, 4))
    g_asm_wpo.root_id = asm_wpo_func_id_of(entry, main_ix);
  if (g_asm_wpo.root_id < 0 || g_asm_wpo.nfuncs <= 0)
    return;
  /** 用户程序：root 强制 main（#0/mk 误根会导致 main 所调 get_a 等 callee UND）。 */
  if (asm_wpo_is_user_program_entry()) {
    int32_t user_main = asm_wpo_user_main_func_id();
    if (user_main >= 0)
      g_asm_wpo.root_id = user_main;
  } else if (asm_wpo_is_user_single_file_pgo_entry()) {
    int32_t user_main = asm_wpo_user_main_func_id();
    if (user_main >= 0)
      g_asm_wpo.root_id = user_main;
  }
  asm_wpo_build_reach();
  asm_wpo_close_std_heap_helpers();
  /** main force emit 时须纳入 reach 闭包，fixpoint 从 main 补全 callee 边。 */
  if (asm_wpo_is_user_program_entry()) {
    int32_t user_main = asm_wpo_user_main_func_id();
    if (user_main >= 0)
      g_asm_wpo.reachable[(size_t)user_main] = 1;
  }
  asm_wpo_reach_fixpoint_expand();
  g_asm_wpo.valid = 1;
  asm_wpo_mark_pgo_hot();
  asm_wpo_mark_pgo_depth();
}

/** 前向声明：emit 顺序构建须过滤 WPO dead export。 */
int32_t pipeline_asm_wpo_should_emit_func(struct ast_Module *m, int32_t fi);

/**
 * 为 module 构建 emit 顺序表：WPO 过滤后按 call-depth 升序（同 depth 按 func_index）。
 * asm_codegen_ast_to_elf 每 Module 入口调用一次。
 */
void pipeline_asm_wpo_pgo_emit_order_prepare(struct ast_Module *m) {
  int32_t nf;
  int32_t fi;
  int32_t n;
  int32_t a;
  int32_t b;
  int32_t tmp;
  int32_t da;
  int32_t db;
  if (!m) {
    g_asm_wpo_pgo_emit_mod = NULL;
    g_asm_wpo_pgo_emit_n = 0;
    return;
  }
  g_asm_wpo_pgo_emit_mod = m;
  n = 0;
  nf = pipeline_module_num_funcs(m);
  fi = 0;
  while (fi < nf) {
    if (pipeline_asm_module_func_is_extern_at(m, fi) == 0 && pipeline_asm_wpo_should_emit_func(m, fi) != 0) {
      if (n < ASM_WPO_MAX_FUNCS)
        g_asm_wpo_pgo_emit_order[n] = fi;
      n = n + 1;
    }
    fi = fi + 1;
  }
  /**
   * asm -o 不能让 WPO/reach 误判把待 emit 集合裁成空集，否则 backend 连当前函数名都拿不到，
   * 最终只会以 empty __text / func unknown 的形式失败。仅在空集合时保守退回全部非 extern 函数。
   */
  if (n == 0 && nf > 0) {
    fi = 0;
    while (fi < nf) {
      if (pipeline_asm_module_func_is_extern_at(m, fi) == 0) {
        if (n < ASM_WPO_MAX_FUNCS)
          g_asm_wpo_pgo_emit_order[n] = fi;
        n = n + 1;
      }
      fi = fi + 1;
    }
  }
  if (pipeline_elf_pgo_hot_enabled() && g_asm_wpo.valid) {
    a = 0;
    while (a < n) {
      b = a + 1;
      while (b < n) {
        da = asm_wpo_pgo_depth_of(m, g_asm_wpo_pgo_emit_order[a]);
        db = asm_wpo_pgo_depth_of(m, g_asm_wpo_pgo_emit_order[b]);
        if (da > db || (da == db && g_asm_wpo_pgo_emit_order[a] > g_asm_wpo_pgo_emit_order[b])) {
          tmp = g_asm_wpo_pgo_emit_order[a];
          g_asm_wpo_pgo_emit_order[a] = g_asm_wpo_pgo_emit_order[b];
          g_asm_wpo_pgo_emit_order[b] = tmp;
        }
        b = b + 1;
      }
      a = a + 1;
    }
  }
  g_asm_wpo_pgo_emit_n = n;
}

/** 返回 module 待 emit 函数个数（须先 prepare 或 lazy prepare）。 */
int32_t pipeline_asm_wpo_pgo_emit_order_count(struct ast_Module *m) {
  if (m != g_asm_wpo_pgo_emit_mod)
    pipeline_asm_wpo_pgo_emit_order_prepare(m);
  return g_asm_wpo_pgo_emit_n;
}

/** 第 order_index 个待 emit 函数的 func_index；越界返回 -1。 */
int32_t pipeline_asm_wpo_pgo_emit_order_at(struct ast_Module *m, int32_t order_index) {
  if (m != g_asm_wpo_pgo_emit_mod)
    pipeline_asm_wpo_pgo_emit_order_prepare(m);
  if (order_index < 0 || order_index >= g_asm_wpo_pgo_emit_n)
    return -1;
  return g_asm_wpo_pgo_emit_order[order_index];
}

/**
 * PGO-Lite emit 查询：1=写入 .text.hot，0=写入 .text；未启用 XLANG_WPO_PGO_HOT 时恒 0。
 */
int32_t pipeline_asm_wpo_pgo_is_hot_func(struct ast_Module *m, int32_t fi) {
  int32_t id;
  if (!pipeline_elf_pgo_hot_enabled())
    return 0;
  if (!g_asm_wpo.valid)
    return 1;
  id = asm_wpo_func_id_of(m, fi);
  if (id < 0)
    return 0;
  return g_asm_wpo_pgo_hot[(size_t)id] ? 1 : 0;
}

/** pipeline.x WPO：strict 编排链 export 须保留（SKIP_TYPECK 时 call graph 兜底）。 */
static int32_t asm_wpo_pipeline_strict_preserve_emit(struct ast_Module *m, int32_t fi) {
  if (!m || fi < 0 || !asm_module_is_pipeline_selfhost(m))
    return 0;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"run_x_pipeline_impl", 19))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"run_x_pipeline_parse_entry_if_needed", 37))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"run_x_pipeline_parse_entry_do_parse", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"run_x_pipeline_typecheck_entry", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"run_x_pipeline_codegen_deps", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"run_x_pipeline_codegen_entry", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"run_x_pipeline_codegen_one_dep", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"pipeline_typeck_entry_module", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"pipeline_typeck_parsed_module", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"resolve_path_x", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"pipeline_should_skip_x_typeck", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"read_file_x", 12))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"pipeline_load_and_sync_direct_import_deps", 41))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"pipeline_parse_into_buf", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"pipeline_parse_set_main_from_buf", 32))
    return 1;
  return 0;
}

/**
 * asm emit 前查询：1=应发射，0= WPO dead export 跳过；未启用 WPO 或 extern 保守保留。
 */
int32_t pipeline_asm_wpo_should_emit_func(struct ast_Module *m, int32_t fi) {
  struct ast_Func *f;
  int32_t id;
  if (!g_asm_wpo.valid)
    return 1;
  f = module_func_at(m, fi);
  if (!f || f->is_extern)
    return 1;
  /** 入口模块的 entry 符号须保留（CLI / crt0 / bridge 链）。 */
  if (m == g_asm_wpo.entry && pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"entry", 5))
    return 1;
  /** 用户程序须 export main（WPO root 误指 #0/mk 时兜底，与 root 按名 main 优先配套）。 */
  if (m == g_asm_wpo.entry && !asm_module_is_main_driver_selfhost(m) &&
      pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"main", 4))
    return 1;
  /**
   * build_asm/main.o 生产链：WPO 启用时仅 export entry（~512B 内），
   * 其余 driver helper 由 runtime_driver / driver_*_x.o 提供。
   */
  if (m == g_asm_wpo.entry && asm_module_is_main_driver_selfhost(m))
    return 0;
  /**
   * build_asm/driver_compile.o WPO 压缩：仅 export 薄 dispatch（~145B）；
   * parse_argv / run_compiler_full_x 由 driver_compile_emit_heavy.o + link.o 提供。
   * PLATFORM: SHARED — must keep dispatch before blanket skip (else valid WPO emits empty .text).
   */
  if (m == g_asm_wpo.entry && asm_module_is_driver_compile_selfhost(m)) {
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"compile_dispatch_asm_backend", 28))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"compile_dispatch_emit_c_path", 28))
      return 1;
    return 0;
  }
  /**
   * pipeline.x WPO：gate/strict 关键 export 须保留；其余走 reach DCE（勿 blanket return 0）。
   */
  if (asm_wpo_pipeline_strict_preserve_emit(m, fi))
    return 1;
  if (m == g_asm_wpo.entry && asm_module_is_pipeline_selfhost(m)) {
    /* 遗留显式名单已由 asm_wpo_pipeline_strict_preserve_emit 覆盖；保留 reach 路径。 */
  }
  /**
   * typeck.x WPO：S2 gate 关键 export + pipeline merge 须保留；其余走 reach DCE。
   */
  if (m == g_asm_wpo.entry && asm_module_is_typeck_selfhost(m)) {
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"typeck_x_ast", 12))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"typeck_x_ast_library", 20))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"check_block", 11))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"check_expr", 10))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"typeck_merge_dep_struct_layouts_into_entry", 42))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"typeck_wpo_unify_soa_layouts", 28))
      return 1;
  }
  /**
   * backend.x WPO：codegen 入口 export 须保留；其余走 reach DCE（M8-tail 薄包装 bl→C）。
   */
  if (m == g_asm_wpo.entry && asm_module_is_backend_selfhost(m)) {
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"asm_codegen_ast", 15))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"asm_codegen_ast_to_elf", 22))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"emit_expr_elf", 13))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"emit_block_body_elf", 19))
      return 1;
  }
  id = asm_wpo_func_id_of(m, fi);
  if (id < 0)
    return 1;
  /**
   * std.heap：allocator_* reach 时 co-emit default_alloc/allocator_heap（薄模块缺 alloc 等，由 call redirect→libc）。
   */
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"default_alloc", 13) ||
      pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"heap_alloc", 14) ||
      pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"alloc", 5) ||
      pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"arena64_alloc", 11) ||
      pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"realloc", 7)) {
    int32_t j;
    for (j = 0; j < g_asm_wpo.nfuncs; j++) {
      int32_t jfi;
      struct ast_Module *jm;
      if (!g_asm_wpo.reachable[(size_t)j])
        continue;
      jm = g_asm_wpo.func_mod[j];
      jfi = g_asm_wpo.func_fi[j];
      if (!jm || jfi < 0)
        continue;
      if (pipeline_module_func_name_equal_at(jm, jfi, (uint8_t *)"alloc", 5) ||
          pipeline_module_func_name_equal_at(jm, jfi, (uint8_t *)"realloc", 7))
        return 1;
    }
  }
  /** heap_libc：std.heap allocator 已 reach 时 co-emit heap_*_c 桥。 */
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"heap_arena64_alloc_c", 20) ||
      pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"heap_alloc_c", 12) ||
      pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"heap_realloc_c", 15)) {
    int32_t j;
    for (j = 0; j < g_asm_wpo.nfuncs; j++) {
      struct ast_Module *hm;
      int32_t jfi;
      if (!g_asm_wpo.reachable[(size_t)j])
        continue;
      hm = g_asm_wpo.func_mod[j];
      if (!asm_wpo_mod_is_std_heap(hm))
        continue;
      jfi = g_asm_wpo.func_fi[j];
      if (pipeline_module_func_name_equal_at(hm, jfi, (uint8_t *)"alloc", 5) ||
          pipeline_module_func_name_equal_at(hm, jfi, (uint8_t *)"realloc", 7))
        return 1;
    }
  }
  return g_asm_wpo.reachable[(size_t)id] ? 1 : 0;
}
