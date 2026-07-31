/**
 * ast_pool_arena.c — ASTArena main-pool cold accessors domain (BC 8.3.2).
 *
 * Same-TU #include from ast_pool.c (itself #include'd into pipeline_glue /
 * pipeline_x). Not a separate .o.
 *
 * Domain (arena type/expr/block/func main pool cold APIs):
 * - pipeline_arena_{type,expr,block,func}_ptr
 * - pipeline_arena_{type,expr,block,func}_alloc
 * - pipeline_arena_{type,expr,block,func}_{get,set}_copy
 * - pipeline_arena_expr_write_var / write_binop
 * - pipeline_arena_num_types
 * - pipeline_arena_{type,expr,block,func}_cap
 *
 * Left in core (helpers / consumers / orchestration):
 * - static block_at / arena_sidecar_* / grow_vec_*
 * - module_layout_at / module_import_at (module domain)
 * - forward decl + body of ast_pool_block_on_alloc
 * - block append / region / defer / stmt_order fill (block domain residual)
 * - arena_func param_write / copy_slot (already in ast_pool_module_func.c)
 *
 * Depends on same-TU statics: block_at, arena_sidecar_get, grow_vec_*,
 * AST_POOL_NO_LIMIT, link_abi_getenv, diag_reportf, ast_pool_block_on_alloc.
 *
 * PLATFORM: SHARED — host-cc Cap residual; parser/typeck/codegen call these.
 * Wave: 987 · no semantic change · pin stays 77b334842.
 */

/** C/glue 用：主池元素指针；无效 ref 返回 NULL。 */
struct ast_Type *pipeline_arena_type_ptr(struct ast_ASTArena *a, int32_t ref) {
  ArenaSidecar *sc;
  if (!a || ref <= 0 || ref > a->num_types)
    return NULL;
  sc = arena_sidecar_get(a, 0);
  if (!sc)
    return NULL;
  return (struct ast_Type *)grow_vec_at(&sc->types, ref - 1);
}

struct ast_Expr *pipeline_arena_expr_ptr(struct ast_ASTArena *a, int32_t ref) {
  ArenaSidecar *sc;
  if (!a || ref <= 0 || ref > a->num_exprs)
    return NULL;
  sc = arena_sidecar_get(a, 0);
  if (!sc)
    return NULL;
  return (struct ast_Expr *)grow_vec_at(&sc->exprs, ref - 1);
}

struct ast_Block *pipeline_arena_block_ptr(struct ast_ASTArena *a, int32_t ref) {
  return block_at(a, ref);
}

struct ast_Func *pipeline_arena_func_ptr(struct ast_ASTArena *a, int32_t ref) {
  ArenaSidecar *sc;
  if (!a || ref <= 0 || ref > a->num_funcs)
    return NULL;
  sc = arena_sidecar_get(a, 0);
  if (!sc)
    return NULL;
  return (struct ast_Func *)grow_vec_at(&sc->funcs, ref - 1);
}


/** 主池 alloc/get/set（无固定上限）。 */
int32_t pipeline_arena_type_alloc(struct ast_ASTArena *a) {
  ArenaSidecar *sc;
  if (!a || !(sc = arena_sidecar_get(a, 1)))
    return 0;
  if (grow_vec_push(&sc->types) < 0)
    return 0;
  a->num_types = sc->types.len;
  return a->num_types;
}

int32_t pipeline_arena_expr_alloc(struct ast_ASTArena *a) {
  ArenaSidecar *sc;
  if (!a || !(sc = arena_sidecar_get(a, 1)))
    return 0;
  if (grow_vec_push(&sc->exprs) < 0)
    return 0;
  a->num_exprs = sc->exprs.len;
  return a->num_exprs;
}

int32_t pipeline_arena_block_alloc(struct ast_ASTArena *a) {
  ArenaSidecar *sc;
  int32_t br;
  if (!a || !(sc = arena_sidecar_get(a, 1)))
    return 0;
  if (grow_vec_push(&sc->blocks) < 0)
    return 0;
  a->num_blocks = sc->blocks.len;
  br = a->num_blocks;
  ast_pool_block_on_alloc(a, br);
  return br;
}

int32_t pipeline_arena_func_alloc(struct ast_ASTArena *a) {
  ArenaSidecar *sc;
  struct ast_Func *f;
  if (!a || !(sc = arena_sidecar_get(a, 1)))
    return 0;
  if (grow_vec_push(&sc->funcs) < 0)
    return 0;
  f = (struct ast_Func *)grow_vec_at(&sc->funcs, sc->funcs.len - 1);
  if (f) {
    memset(f, 0, sizeof(*f));
    f->param_base = -1;
  }
  a->num_funcs = sc->funcs.len;
  return a->num_funcs;
}

struct ast_Type pipeline_arena_type_get_copy(struct ast_ASTArena *a, int32_t ref) {
  struct ast_Type empty;
  struct ast_Type *tp;
  memset(&empty, 0, sizeof(empty));
  tp = pipeline_arena_type_ptr(a, ref);
  return tp ? *tp : empty;
}

void pipeline_arena_type_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Type t) {
  struct ast_Type *tp = pipeline_arena_type_ptr(a, ref);
  if (tp)
    *tp = t;
}

struct ast_Expr pipeline_arena_expr_get_copy(struct ast_ASTArena *a, int32_t ref) {
  struct ast_Expr empty;
  struct ast_Expr *ep;
  memset(&empty, 0, sizeof(empty));
  ep = pipeline_arena_expr_ptr(a, ref);
  return ep ? *ep : empty;
}

void pipeline_arena_expr_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e) {
  struct ast_Expr *ep = pipeline_arena_expr_ptr(a, ref);
  const char *trace_expr = link_abi_getenv("XLANG_TRACE_EXPR_SET");
  const char *trace_name = link_abi_getenv("XLANG_TRACE_EXPR_NAME");
  const char *trace_type = link_abi_getenv("XLANG_TRACE_TYPE_REF");
  int trace_hit = 0;
  if (trace_expr && *trace_expr && atoi(trace_expr) == ref)
    trace_hit = 1;
  if (!trace_hit && trace_name && *trace_name && e.var_name_len > 0) {
    size_t want_len = strlen(trace_name);
    if ((int32_t)want_len == e.var_name_len && want_len < sizeof(e.var_name) &&
        memcmp(e.var_name, trace_name, want_len) == 0)
      trace_hit = 1;
  }
  if (!trace_hit && trace_type && *trace_type) {
    int trace_ty = atoi(trace_type);
    if (trace_ty != 0 && e.resolved_type_ref == trace_ty)
      trace_hit = 1;
  }
  if (trace_hit) {
    fprintf(stderr,
            "note: arena expr set debug: expr=%d kind=%d block=%d ty=%d left=%d right=%d name_len=%d name=%.*s\n",
            (int)ref, (int)e.kind, (int)e.block_ref, (int)e.resolved_type_ref, (int)e.binop_left_ref,
            (int)e.binop_right_ref, (int)e.var_name_len, (int)e.var_name_len, (const char *)e.var_name);
  }
  if (ep)
    *ep = e;
}

/**
 * 在 C 侧初始化 EXPR_VAR，避免 X→C 整结构 ast_arena_expr_set 拷贝导致 kind 等字段错位。
 */
void pipeline_arena_expr_write_var(struct ast_ASTArena *a, int32_t ref, uint8_t *name, int32_t name_len) {
  struct ast_Expr *ep;
  int32_t n;
  if (!a || ref <= 0 || !name || name_len <= 0)
    return;
  ep = pipeline_arena_expr_ptr(a, ref);
  if (!ep)
    return;
  memset(ep, 0, sizeof(*ep));
  ep->kind = ast_ExprKind_EXPR_VAR;
  n = name_len;
  if (n > 127)
    n = 63;
  ep->var_name_len = n;
  memcpy(ep->var_name, name, (size_t)n);
  ep->call_resolved_func_index = -1;
  ep->call_resolved_dep_index = -1;
}

/**
 * 在 C 侧初始化二元运算节点（kind 为 ast_ExprKind 序数值，与 .x ExprKind 一致）。
 */
void pipeline_arena_expr_write_binop(struct ast_ASTArena *a, int32_t ref, int32_t kind_ord, int32_t left_ref,
                                     int32_t right_ref) {
  struct ast_Expr *ep;
  if (!a || ref <= 0)
    return;
  ep = pipeline_arena_expr_ptr(a, ref);
  if (!ep)
    return;
  memset(ep, 0, sizeof(*ep));
  ep->kind = (enum ast_ExprKind)kind_ord;
  ep->binop_left_ref = left_ref;
  ep->binop_right_ref = right_ref;
  ep->call_resolved_func_index = -1;
  ep->call_resolved_dep_index = -1;
}

struct ast_Block pipeline_arena_block_get_copy(struct ast_ASTArena *a, int32_t ref) {
  struct ast_Block empty;
  struct ast_Block *bp;
  memset(&empty, 0, sizeof(empty));
  bp = pipeline_arena_block_ptr(a, ref);
  return bp ? *bp : empty;
}

void pipeline_arena_block_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Block b) {
  struct ast_Block *bp = pipeline_arena_block_ptr(a, ref);
  const char *dbg_block_set = link_abi_getenv("XLANG_DEBUG_BLOCK_SET");
  if (bp) {
    if (dbg_block_set && dbg_block_set[0] && atoi(dbg_block_set) == ref) {
      diag_reportf(NULL, 0, 0, "note", NULL,
                   "block set debug: ref=%d old(c=%d l=%d if=%d reg=%d so=%d fin=%d) new(c=%d l=%d if=%d reg=%d so=%d fin=%d)",
                   (int)ref, (int)bp->num_consts, (int)bp->num_lets, (int)bp->num_if_stmts, (int)bp->num_regions,
                   (int)bp->num_stmt_order, (int)bp->final_expr_ref, (int)b.num_consts, (int)b.num_lets,
                   (int)b.num_if_stmts, (int)b.num_regions, (int)b.num_stmt_order, (int)b.final_expr_ref);
    }
    *bp = b;
  }
}

struct ast_Func pipeline_arena_func_get_copy(struct ast_ASTArena *a, int32_t ref) {
  struct ast_Func empty;
  struct ast_Func *fp;
  memset(&empty, 0, sizeof(empty));
  fp = pipeline_arena_func_ptr(a, ref);
  return fp ? *fp : empty;
}

void pipeline_arena_func_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Func f) {
  struct ast_Func *fp = pipeline_arena_func_ptr(a, ref);
  if (fp)
    *fp = f;
}

/** pipeline.x：读 arena.num_types（诊断 parse fail）。 */
int32_t pipeline_arena_num_types(struct ast_ASTArena *a) {
  return a ? (int32_t)a->num_types : 0;
}

/** 主池容量查询：无固定上限，返回 INT32_MAX 兼容旧边界检查。 */
int32_t pipeline_arena_type_cap(void) { return AST_POOL_NO_LIMIT; }
int32_t pipeline_arena_expr_cap(void) { return AST_POOL_NO_LIMIT; }
int32_t pipeline_arena_block_cap(void) { return AST_POOL_NO_LIMIT; }
int32_t pipeline_arena_func_cap(void) { return AST_POOL_NO_LIMIT; }
