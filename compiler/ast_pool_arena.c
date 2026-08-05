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

/* wave1183 G.7: ast_pipeline_arena_* forwarder cluster (12 fns) migrated
 * from pipeline_glue.c to this file's EOF.
 *
 * Why colocate: ast.x resolves extern pipeline_arena_* symbols with an ast_
 * module prefix at codegen time (e.g. ast_pipeline_arena_type_get_copy),
 * but the authoritative implementations live in ast_pool_arena.c with
 * unprefixed C names (pipeline_arena_type_get_copy). These 12 thin
 * forwarders exist solely to satisfy the linker name-mangling gap;
 * colocating them here keeps pipeline_glue.c focused on real glue logic.
 *
 * Members (12 fns):
 *  - ast_pipeline_arena_type_get_copy / set_copy (type arena get/set)
 *  - ast_pipeline_arena_expr_get_copy / set_copy (expr arena get/set)
 *  - ast_pipeline_arena_expr_write_var (write VAR name into expr)
 *  - ast_pipeline_arena_expr_write_binop (write BINOP kind+left+right)
 *  - ast_pipeline_arena_block_get_copy / set_copy (block arena get/set)
 *  - ast_pipeline_arena_func_get_copy / set_copy (func arena get/set)
 *
 * Contract: every function here is a pure pass-through -- no state mutation,
 *   no branch, single tail call to the underlying pipeline_arena_* impl.
 *
 * PLATFORM: SHARED -- forwarders are platform-agnostic.
 */
struct ast_Type ast_pipeline_arena_type_get_copy(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_arena_type_get_copy(a, ref);
}
void ast_pipeline_arena_type_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Type t) {
  pipeline_arena_type_set_copy(a, ref, t);
}
struct ast_Expr ast_pipeline_arena_expr_get_copy(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_arena_expr_get_copy(a, ref);
}
void ast_pipeline_arena_expr_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e) {
  pipeline_arena_expr_set_copy(a, ref, e);
}
void ast_pipeline_arena_expr_write_var(struct ast_ASTArena *a, int32_t ref, uint8_t *name, int32_t name_len) {
  pipeline_arena_expr_write_var(a, ref, name, name_len);
}
void ast_pipeline_arena_expr_write_binop(struct ast_ASTArena *a, int32_t ref, int32_t kind_ord, int32_t left_ref,
                                         int32_t right_ref) {
  pipeline_arena_expr_write_binop(a, ref, kind_ord, left_ref, right_ref);
}
struct ast_Block ast_pipeline_arena_block_get_copy(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_arena_block_get_copy(a, ref);
}
void ast_pipeline_arena_block_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Block b) {
  pipeline_arena_block_set_copy(a, ref, b);
}
struct ast_Func ast_pipeline_arena_func_get_copy(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_arena_func_get_copy(a, ref);
}
void ast_pipeline_arena_func_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Func f) {
  pipeline_arena_func_set_copy(a, ref, f);
}

/* wave1194 G.7: ast_ast_arena_type_get/set + ast_ast_arena_expr_get/set
 * migrated from pipeline_glue.c to this file (same-TU #include via
 * ast_pool.c L886). Colocated with ast_ast_arena_block/func_get/set (L342)
 * and ast_arena_* twin forwarders (L354). The ast_arena_* twins below
 * delegate to these definitions — forward decls no longer needed.
 *
 * Why: type/expr get/set are the same domain as block/func get/set
 * (arena slot accessors); pipeline_glue.c kept them only for historical
 * trace debugging. pipeline_arena_expr_set_copy already has equivalent
 * trace logic; the duplicate trace in expr_set is retained for now to
 * preserve identical behavior (will be cleaned in a later dedup pass).
 *
 * Members (4 fns):
 *  - ast_ast_arena_type_get (ref<=0 guard + delegate to pipeline_arena_type_get_copy)
 *  - ast_ast_arena_type_set (delegate to pipeline_arena_type_set_copy)
 *  - ast_ast_arena_expr_get (delegate to pipeline_arena_expr_get_copy)
 *  - ast_ast_arena_expr_set (trace debug + delegate to pipeline_arena_expr_set_copy)
 *
 * PLATFORM: SHARED — arena slot accessors are platform-agnostic. */

/**
 * ast_ast_arena_type_get — read a Type slot from the arena by ref.
 *
 * Why: ast.x hoisted extern calls expect this symbol; ref<=0 returns
 *      zeroed Type to avoid dereferencing an invalid slot pointer.
 * Contract: ref<=0 → zeroed struct ast_Type; ref>0 → delegates to
 *           pipeline_arena_type_get_copy (which NULL-guards the ptr).
 * PLATFORM: SHARED.
 */
struct ast_Type ast_ast_arena_type_get(struct ast_ASTArena *a, int32_t ref) {
  struct ast_Type empty;
  if (ref <= 0) {
    memset(&empty, 0, sizeof(empty));
    return empty;
  }
  return pipeline_arena_type_get_copy(a, ref);
}

/**
 * ast_ast_arena_type_set — write a Type slot in the arena by ref.
 *
 * Contract: delegates to pipeline_arena_type_set_copy (NULL-guarded).
 * PLATFORM: SHARED.
 */
void ast_ast_arena_type_set(struct ast_ASTArena *a, int32_t ref, struct ast_Type t) {
  pipeline_arena_type_set_copy(a, ref, t);
}

/**
 * ast_ast_arena_expr_get — read an Expr slot from the arena by ref.
 *
 * Contract: delegates to pipeline_arena_expr_get_copy (NULL-guarded,
 *           returns zeroed struct on failure).
 * PLATFORM: SHARED.
 */
struct ast_Expr ast_ast_arena_expr_get(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_arena_expr_get_copy(a, ref);
}

/**
 * ast_ast_arena_expr_set — write an Expr slot with optional trace debug.
 *
 * Why: XLANG_TRACE_EXPR_SET / _NAME / _TYPE_REF env vars enable
 *      targeted expr-set tracing for debugging ast corruption.
 * Note: pipeline_arena_expr_set_copy has equivalent trace logic; the
 *       duplicate trace here is retained to preserve identical output
 *       format ("expr ast set debug:" prefix) for existing diagnostics.
 * Contract: trace if env var matches; always delegates to
 *           pipeline_arena_expr_set_copy for the actual slot write.
 * PLATFORM: SHARED.
 */
void ast_ast_arena_expr_set(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e) {
  const char *trace_expr = link_abi_getenv("XLANG_TRACE_EXPR_SET");
  const char *trace_name = link_abi_getenv("XLANG_TRACE_EXPR_NAME");
  const char *trace_type = link_abi_getenv("XLANG_TRACE_TYPE_REF");
  int trace_hit = 0;
  int trace_ty = 0;
  if (trace_expr && *trace_expr && atoi(trace_expr) == ref) {
    fprintf(stderr,
            "note: expr ast set debug: expr=%d kind=%d block=%d ty=%d left=%d right=%d name_len=%d int_val=%d\n",
            (int)ref, (int)e.kind, (int)e.block_ref, (int)e.resolved_type_ref, (int)e.binop_left_ref,
            (int)e.binop_right_ref, (int)e.var_name_len, (int)e.int_val);
  }
  if (trace_name && *trace_name && e.kind == ast_ExprKind_EXPR_VAR && e.var_name_len > 0) {
    size_t want_len = strlen(trace_name);
    if ((int)want_len == e.var_name_len && want_len < sizeof(e.var_name) &&
        memcmp(e.var_name, trace_name, want_len) == 0)
      trace_hit = 1;
  }
  if (trace_type && *trace_type) {
    trace_ty = atoi(trace_type);
    if (trace_ty != 0 && e.resolved_type_ref == trace_ty)
      trace_hit = 1;
  }
  if (trace_hit) {
    fprintf(stderr,
            "note: expr ast watch: expr=%d kind=%d block=%d ty=%d left=%d right=%d name_len=%d int_val=%d name=%.*s\n",
            (int)ref, (int)e.kind, (int)e.block_ref, (int)e.resolved_type_ref, (int)e.binop_left_ref,
            (int)e.binop_right_ref, (int)e.var_name_len, (int)e.int_val, (int)e.var_name_len,
            (const char *)e.var_name);
  }
  pipeline_arena_expr_set_copy(a, ref, e);
}

/* wave1183 G.7: ast_ast_arena_*_get/set + ast_arena_*_get/set forwarder
 * cluster (14 fns) migrated from pipeline_glue.c to this file's EOF.
 *
 * Why colocate: ast.x resolves extern pipeline_arena_* symbols with ast_
 * and ast_ast_ module prefixes at codegen time, but the authoritative
 * implementations live in ast_pool_arena.c with unprefixed C names
 * (pipeline_arena_*_get_copy / _set_copy). These 14 thin forwarders exist
 * solely to satisfy the linker name-mangling gap; colocating them here
 * keeps pipeline_glue.c focused on real glue logic.
 *
 * Members (14 fns):
 *  - ast_ast_arena_block_get / set (block arena get/set, ast_ast_ prefix)
 *  - ast_ast_arena_func_get / set (func arena get/set, ast_ast_ prefix)
 *  - ast_arena_type_get / set (type arena get/set, ast_ prefix, delegates to ast_ast_)
 *  - ast_arena_expr_get / set (expr arena get/set, ast_ prefix, delegates to ast_ast_)
 *  - ast_arena_block_get / set (block arena get/set, ast_ prefix, delegates to ast_ast_)
 *  - ast_arena_func_get / set (func arena get/set, ast_ prefix, delegates to ast_ast_)
 *
 * Contract: every function here is a pure pass-through -- no state mutation,
 *   no branch, single tail call to the underlying pipeline_arena_* impl.
 *
 * PLATFORM: SHARED -- forwarders are platform-agnostic.
 */
struct ast_Block ast_ast_arena_block_get(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_arena_block_get_copy(a, ref);
}
void ast_ast_arena_block_set(struct ast_ASTArena *a, int32_t ref, struct ast_Block b) {
  pipeline_arena_block_set_copy(a, ref, b);
}
struct ast_Func ast_ast_arena_func_get(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_arena_func_get_copy(a, ref);
}
void ast_ast_arena_func_set(struct ast_ASTArena *a, int32_t ref, struct ast_Func f) {
  pipeline_arena_func_set_copy(a, ref, f);
}
struct ast_Type ast_arena_type_get(struct ast_ASTArena *a, int32_t ref) {
  return ast_ast_arena_type_get(a, ref);
}
void ast_arena_type_set(struct ast_ASTArena *a, int32_t ref, struct ast_Type t) {
  ast_ast_arena_type_set(a, ref, t);
}
struct ast_Expr ast_arena_expr_get(struct ast_ASTArena *a, int32_t ref) {
  return ast_ast_arena_expr_get(a, ref);
}
void ast_arena_expr_set(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e) {
  ast_ast_arena_expr_set(a, ref, e);
}
struct ast_Block ast_arena_block_get(struct ast_ASTArena *a, int32_t ref) {
  return ast_ast_arena_block_get(a, ref);
}
void ast_arena_block_set(struct ast_ASTArena *a, int32_t ref, struct ast_Block b) {
  ast_ast_arena_block_set(a, ref, b);
}
struct ast_Func ast_arena_func_get(struct ast_ASTArena *a, int32_t ref) {
  return ast_ast_arena_func_get(a, ref);
}
void ast_arena_func_set(struct ast_ASTArena *a, int32_t ref, struct ast_Func f) {
  ast_ast_arena_func_set(a, ref, f);
}

/* wave1184 G.7: pipeline_parser_library_init_* + pipeline_parser_extern_init_arena_func
 * cluster (8 fns) migrated from pipeline_glue.c to this file's EOF.
 *
 * Why colocate: these functions initialize arena type/expr/block/func slots for
 * parser library path (parse_one_function_library / parse_one_extern_and_add_into).
 * They delegate to pipeline_arena_{type,expr,block,func}_ptr (defined earlier in
 * this same file) for slot access — colocating them here keeps the arena-slot
 * init path in a single domain file alongside the ptr/alloc/get/set authority.
 *
 * Members (8 fns):
 *  - pipeline_parser_library_init_bool_type_c (write TYPE_BOOL into arena type slot)
 *  - pipeline_parser_library_init_named_type_c (write TYPE_NAMED + name bytes)
 *  - pipeline_parser_library_init_var_expr_c (write EXPR_VAR + param name)
 *  - pipeline_parser_library_init_field_access_expr_c (write EXPR_FIELD_ACCESS)
 *  - pipeline_parser_library_init_enum_variant_expr_c (write EXPR_ENUM_VARIANT)
 *  - pipeline_parser_library_init_eq_expr_c (write EXPR_EQ binop)
 *  - pipeline_parser_library_init_labeled_block_c (init labeled return Block)
 *  - pipeline_parser_extern_init_arena_func_and_register_c (write Func slot + register)
 *
 * Forward decls below for functions defined later in the same TU (ast_pool_block.c
 * #include at L1602 / ast_pool_module_func.c #include at L1231 / pipeline_glue.c
 * L2133 for pipeline_module_fill_u8_64_from_src_c). All extern — no static.
 *
 * PLATFORM: SHARED — parser library init path; host-cc via ast_pool.c TU.
 */

/* Forward declarations for same-TU functions defined after this file's #include
 * point in ast_pool.c (L886). Needed because the migrated functions below call
 * them before their definitions appear in the same translation unit. */
void pipeline_module_fill_u8_64_from_src_c(uint8_t *dst, const uint8_t *src, int32_t n, int32_t src_cap);
int32_t ast_pipeline_block_append_labeled(struct ast_ASTArena *a, int32_t br, int32_t label_len, int32_t is_goto,
                                           int32_t goto_target_len, int32_t return_expr_ref);
int32_t pipeline_module_func_alloc_slot(struct ast_Module *m);
void pipeline_module_func_name_write(struct ast_Module *m, int32_t func_index, uint8_t *name_bytes, int32_t name_len);
void pipeline_module_func_set_num_params(struct ast_Module *m, int32_t fi, int32_t n);
void pipeline_module_func_set_return_type(struct ast_Module *m, int32_t fi, int32_t type_ref);
void pipeline_module_func_set_body_ref(struct ast_Module *m, int32_t fi, int32_t body_ref);
void pipeline_module_func_set_body_expr_ref(struct ast_Module *m, int32_t fi, int32_t body_expr_ref);
void pipeline_module_func_set_is_extern(struct ast_Module *m, int32_t fi, int32_t is_extern);
void pipeline_module_func_set_is_async(struct ast_Module *m, int32_t fi, int32_t is_async);
void pipeline_module_func_ref_set(struct ast_Module *m, int32_t func_index, int32_t func_ref);

/** parse_one_function_library X emit: write TYPE_BOOL into arena type slot. */
void pipeline_parser_library_init_bool_type_c(struct ast_ASTArena *arena, int32_t type_ref) {
  struct ast_Type *t;
  if (!arena || type_ref <= 0)
    return;
  t = pipeline_arena_type_ptr(arena, type_ref);
  if (!t)
    return;
  t->kind = (int32_t)ast_TypeKind_TYPE_BOOL;
  t->name_len = 0;
  t->elem_type_ref = 0;
  t->array_size = 0;
}

/** parse_one_function_library X emit: write TYPE_NAMED + name bytes into arena type slot. */
void pipeline_parser_library_init_named_type_c(struct ast_ASTArena *arena, int32_t type_ref, const uint8_t *name,
                                               int32_t name_len) {
  struct ast_Type *t;
  if (!arena || type_ref <= 0)
    return;
  t = pipeline_arena_type_ptr(arena, type_ref);
  if (!t)
    return;
  t->kind = (int32_t)ast_TypeKind_TYPE_NAMED;
  t->name_len = name_len;
  pipeline_module_fill_u8_64_from_src_c(t->name, name, name_len, 64);
  t->elem_type_ref = 0;
  t->array_size = 0;
}

/** parse_one_function_library X emit: write EXPR_VAR + param name into arena expr slot. */
void pipeline_parser_library_init_var_expr_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t type_ref,
                                            const uint8_t *param_name, int32_t param_name_len) {
  struct ast_Expr *ve;
  if (!arena || expr_ref <= 0)
    return;
  ve = pipeline_arena_expr_ptr(arena, expr_ref);
  if (!ve)
    return;
  ve->kind = (int32_t)ast_ExprKind_EXPR_VAR;
  ve->resolved_type_ref = type_ref;
  ve->line = 0;
  ve->col = 0;
  ve->var_name_len = param_name_len;
  pipeline_module_fill_u8_64_from_src_c(ve->var_name, param_name, param_name_len, 32);
  ve->match_arm_base = 0;
  ve->enum_variant_tag = 0;
  ve->field_access_base_ref = 0;
  ve->field_access_field_len = 0;
  ve->field_access_is_enum_variant = 0;
  ve->field_access_offset = 0;
}

/** parse_one_function_library X emit: write EXPR_FIELD_ACCESS into arena expr slot. */
void pipeline_parser_library_init_field_access_expr_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t base_ref,
                                                     const uint8_t *field_name, int32_t field_len) {
  struct ast_Expr *fe;
  if (!arena || expr_ref <= 0)
    return;
  fe = pipeline_arena_expr_ptr(arena, expr_ref);
  if (!fe)
    return;
  fe->kind = (int32_t)ast_ExprKind_EXPR_FIELD_ACCESS;
  fe->resolved_type_ref = 0;
  fe->line = 0;
  fe->col = 0;
  fe->field_access_base_ref = base_ref;
  fe->field_access_field_len = field_len;
  pipeline_module_fill_u8_64_from_src_c(fe->field_access_field_name, field_name, field_len, 64);
  fe->field_access_is_enum_variant = 0;
  fe->field_access_offset = 0;
  fe->match_arm_base = 0;
  fe->enum_variant_tag = 0;
  fe->binop_left_ref = 0;
  fe->binop_right_ref = 0;
}

/** parse_one_function_library X emit: write EXPR_ENUM_VARIANT placeholder into arena expr slot. */
void pipeline_parser_library_init_enum_variant_expr_c(struct ast_ASTArena *arena, int32_t expr_ref) {
  struct ast_Expr *ene;
  if (!arena || expr_ref <= 0)
    return;
  ene = pipeline_arena_expr_ptr(arena, expr_ref);
  if (!ene)
    return;
  ene->kind = (int32_t)ast_ExprKind_EXPR_ENUM_VARIANT;
  ene->resolved_type_ref = 0;
  ene->line = 0;
  ene->col = 0;
  ene->enum_variant_tag = 0;
  ene->match_arm_base = 0;
  ene->field_access_base_ref = 0;
  ene->field_access_field_len = 0;
}

/** parse_one_function_library X emit: write EXPR_EQ binop into arena expr slot. */
void pipeline_parser_library_init_eq_expr_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t bool_type_ref,
                                             int32_t left_ref, int32_t right_ref) {
  struct ast_Expr *eqe;
  if (!arena || expr_ref <= 0)
    return;
  eqe = pipeline_arena_expr_ptr(arena, expr_ref);
  if (!eqe)
    return;
  eqe->kind = (int32_t)ast_ExprKind_EXPR_EQ;
  eqe->resolved_type_ref = bool_type_ref;
  eqe->line = 0;
  eqe->col = 0;
  eqe->binop_left_ref = left_ref;
  eqe->binop_right_ref = right_ref;
  eqe->match_arm_base = 0;
  eqe->enum_variant_tag = 0;
  eqe->field_access_base_ref = 0;
  eqe->field_access_field_len = 0;
}

/** parse_one_function_library X emit: init library-form labeled return Block. */
int32_t pipeline_parser_library_init_labeled_block_c(struct ast_ASTArena *arena, int32_t block_ref, int32_t eq_ref) {
  struct ast_Block *b;
  if (!arena || block_ref <= 0)
    return -1;
  b = pipeline_arena_block_ptr(arena, block_ref);
  if (!b)
    return -1;
  b->num_consts = 0;
  b->num_lets = 0;
  b->num_early_lets = 0;
  b->num_loops = 0;
  b->num_for_loops = 0;
  b->num_if_stmts = 0;
  b->num_defers = 0;
  if (ast_pipeline_block_append_labeled(arena, block_ref, 0, 0, 0, eq_ref) < 0)
    return -1;
  b = pipeline_arena_block_ptr(arena, block_ref);
  if (!b)
    return -1;
  b->num_expr_stmts = 0;
  b->final_expr_ref = 0;
  b->num_stmt_order = 0;
  return 0;
}

/**
 * parse_one_extern_and_add_into X emit: write arena Func slot and register in module,
 * avoiding X `f.name[i]` INDEX ASSIGN. Returns module func index; -1 on pool full or
 * invalid args.
 */
int32_t pipeline_parser_extern_init_arena_func_and_register_c(struct ast_ASTArena *arena, struct ast_Module *module,
                                                             int32_t func_ref, const uint8_t *name, int32_t name_len,
                                                             int32_t num_params, int32_t return_ty_ref) {
  struct ast_Func *fp;
  int32_t fi;
  if (!arena || !module || func_ref <= 0)
    return -1;
  /* wave577 Cap: Func.name u8[128] */
  if (name_len < 0 || name_len > 127)
    return -1;
  fp = pipeline_arena_func_ptr(arena, func_ref);
  if (!fp)
    return -1;
  pipeline_module_fill_u8_64_from_src_c(fp->name, name, name_len, 64);
  fp->name_len = name_len;
  fp->num_params = num_params;
  fp->return_type_ref = return_ty_ref;
  fp->body_ref = 0;
  fp->body_expr_ref = 0;
  fp->is_extern = 1;
  fp->is_async = 0;
  fi = pipeline_module_func_alloc_slot(module);
  if (fi < 0)
    return -1;
  pipeline_module_func_name_write(module, fi, (uint8_t *)name, name_len);
  pipeline_module_func_set_num_params(module, fi, num_params);
  pipeline_module_func_set_return_type(module, fi, return_ty_ref);
  pipeline_module_func_set_body_ref(module, fi, 0);
  pipeline_module_func_set_body_expr_ref(module, fi, 0);
  pipeline_module_func_set_is_extern(module, fi, 1);
  pipeline_module_func_set_is_async(module, fi, 0);
  pipeline_module_func_ref_set(module, fi, func_ref);
  return fi;
}

/* wave1195 G.7: ast_ref_is_null migrated from pipeline_glue.c L4187.
 *
 * Why colocate: ast_ref_is_null is a trivial arena ref validator used
 * by 21 files (typeck / codegen / parser domains). Colocated with
 * arena accessors since it validates arena ref semantics.
 *
 * PLATFORM: SHARED — arena ref validation is platform-agnostic. */

/**
 * ast_ref_is_null — check if an arena ref is null (== 0).
 *
 * Contract: returns 1 if ref == 0, else 0.
 * PLATFORM: SHARED.
 */
int ast_ref_is_null(int32_t ref) {
  return ref == 0;
}

/* wave1196 G.7: ast_expr_layout_prime_call_resolved + ast_ast_arena_init
 * + ast_ast_arena_type/expr/block/func_alloc (6 fns) migrated from
 * pipeline_glue.c L3739-3762.
 *
 * Why colocate: arena init/alloc are the arena pool's core lifecycle
 * functions. ast_ast_arena_init zeroes arena counters then calls
 * ast_expr_layout_prime_call_resolved (empty C-side hook). The 4 alloc
 * fns delegate to pipeline_arena_*_alloc (defined at L66-99 in this
 * file). Colocated with arena accessors.
 *
 * Visibility: ast_pool.c L886 #includes this file; ast_ast_arena_init
 * is called at ast_pool.c L1278 (after L886, so definition visible).
 * pipeline_parse_orch.c L88 has extern fwd decl (called at L380).
 * Cross-TU: parser/typeck/codegen seeds via extern.
 *
 * Members (6 fns):
 *  - ast_expr_layout_prime_call_resolved (empty C-side hook)
 *  - ast_ast_arena_init (zero arena counters)
 *  - ast_ast_arena_type_alloc (delegate to pipeline_arena_type_alloc)
 *  - ast_ast_arena_expr_alloc (delegate to pipeline_arena_expr_alloc)
 *  - ast_ast_arena_block_alloc (delegate to pipeline_arena_block_alloc)
 *  - ast_ast_arena_func_alloc (delegate to pipeline_arena_func_alloc)
 *
 * PLATFORM: SHARED — arena lifecycle is platform-agnostic. */

/**
 * ast_expr_layout_prime_call_resolved — empty C-side hook for
 * ast.x expr_layout_prime_call_resolved.
 *
 * Why: ast.x expects this symbol at link time; C glue has no extra
 *      state to prime. Called by ast_ast_arena_init.
 * PLATFORM: SHARED.
 */
void ast_expr_layout_prime_call_resolved(void) {
  /* ast.x expr_layout_prime_call_resolved; C glue side has no extra state. */
}

/**
 * ast_ast_arena_init — initialize an ASTArena by zeroing counters.
 *
 * Why: ast.x pool init — must run before strict parse to ensure
 *      num_types/exprs/blocks/funcs start at 0. Called by
 *      ast_pool.c strict parse path + parser seeds.
 * Contract: NULL arena is a no-op; else zeros 4 counters.
 * PLATFORM: SHARED.
 */
void ast_ast_arena_init(struct ast_ASTArena *arena) {
  if (!arena)
    return;
  ast_expr_layout_prime_call_resolved();
  arena->num_types = 0;
  arena->num_exprs = 0;
  arena->num_blocks = 0;
  arena->num_funcs = 0;
}

/**
 * ast_ast_arena_type_alloc — allocate a new Type slot in the arena.
 *
 * Contract: delegates to pipeline_arena_type_alloc (NULL-guarded).
 * PLATFORM: SHARED.
 */
int32_t ast_ast_arena_type_alloc(struct ast_ASTArena *a) {
  return pipeline_arena_type_alloc(a);
}

/**
 * ast_ast_arena_expr_alloc — allocate a new Expr slot in the arena.
 *
 * Contract: delegates to pipeline_arena_expr_alloc (NULL-guarded).
 * PLATFORM: SHARED.
 */
int32_t ast_ast_arena_expr_alloc(struct ast_ASTArena *a) {
  return pipeline_arena_expr_alloc(a);
}

/**
 * ast_ast_arena_block_alloc — allocate a new Block slot in the arena.
 *
 * Contract: delegates to pipeline_arena_block_alloc (NULL-guarded).
 * PLATFORM: SHARED.
 */
int32_t ast_ast_arena_block_alloc(struct ast_ASTArena *a) {
  return pipeline_arena_block_alloc(a);
}

/**
 * ast_ast_arena_func_alloc — allocate a new Func slot in the arena.
 *
 * Contract: delegates to pipeline_arena_func_alloc (NULL-guarded).
 * PLATFORM: SHARED.
 */
int32_t ast_ast_arena_func_alloc(struct ast_ASTArena *a) {
  return pipeline_arena_func_alloc(a);
}

/* wave1196 G.7: implicit_tail_expr_disallowed_by_glue migrated from
 * pipeline_glue.c L628-637.
 *
 * Why colocate: arena expr kind inspection is the arena accessor
 * domain. The original called glue_arena_expr_kind_at_ref (static in
 * glue.c L434); migrated version inlines the same logic via
 * pipeline_arena_expr_ptr (defined at L41 in this file).
 *
 * Visibility: ast_pool_block.c L1599 calls this via
 * ast_ast_expr_disallows_implicit_tail (wave1183 wrapper).
 * ast_pool_block.c is #included at ast_pool.c L1602 (after this
 * file's L886 #include) — definition visible.
 * pipeline_typeck_check_block.c L677 calls this; check_block.c is
 * #included at pipeline_glue.c L5504 (after ast_pool.c L4005) —
 * definition visible via ast_pool_arena.c #include chain.
 * Cross-TU: ast_gen.c / typeck_gen.c / codegen_gen.c / parser_gen.c
 * seeds via extern.
 *
 * PLATFORM: SHARED — arena expr kind inspection is platform-agnostic. */

/**
 * implicit_tail_expr_disallowed_by_glue — check if an expr kind is a
 * control-flow terminator that disallows implicit tail returns.
 *
 * Why: typeck.x block tail analysis — RETURN/PANIC/BREAK/CONTINUE
 *      are explicit control flow; a block ending in these cannot
 *      have an implicit tail return. C reads kind directly from
 *      arena pool (X cannot safely typeck Expr struct field access).
 * Contract: returns 1 if expr is RETURN/PANIC/BREAK/CONTINUE (or
 *           invalid ref), else 0.
 * PLATFORM: SHARED.
 */
int implicit_tail_expr_disallowed_by_glue(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return 1;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return 1;
  if (ex->kind == ast_ExprKind_EXPR_RETURN || ex->kind == ast_ExprKind_EXPR_PANIC ||
      ex->kind == ast_ExprKind_EXPR_BREAK || ex->kind == ast_ExprKind_EXPR_CONTINUE)
    return 1;
  return 0;
}

/* ========================================================================== *
 * wave1203 G.7: pipeline_module_fill_u8_64_from_src_c migrated from
 * pipeline_glue.c L1702-1716. Colocated with wave1184 parser_library_init
 * cluster (L517-677) — the 4 primary consumers of this utility (L541/560/
 * 584/676) are in this file. The 5th caller is in pipeline_parser_result.c
 * (L262, via extern fwd decl at L50 — retained for cross-file visibility).
 *
 * Forward decl at L503 retained (callsites at L541+ precede EOF definition).
 * No static deps — pure utility (loop + bounds check). All extern.
 * PLATFORM: SHARED — pure byte copy, no arch dependency.
 * ========================================================================== */

/**
 * Copy src[0..n-1] (capped at src_cap) into dst[0..63], zero-fill remainder.
 *
 * Why: parse_one_function_library X emit must not use per-element INDEX
 *      ASSIGN on local Type/Expr arrays (asm INDEX emit fails). This helper
 *      provides a C-side bulk fill for 64-byte name slots (type names, var
 *      names, field names, func names) consumed by the wave1184 library_init
 *      cluster above.
 * Contract: NULL dst → no-op; n<0 → treated as 0; src_cap<0 → treated as 0.
 *           Writes exactly 64 bytes to dst (valid bytes from src, zero-padded).
 * Invariant: dst[0..min(n,src_cap,64)-1] = src[0..min(n,src_cap,64)-1];
 *            dst[min(n,src_cap,64)..63] = 0.
 * Asm/Perf: O(64) — fixed 64-iteration loop. Cold path (parser library init).
 * PLATFORM: SHARED.
 */
void pipeline_module_fill_u8_64_from_src_c(uint8_t *dst, const uint8_t *src, int32_t n, int32_t src_cap) {
  int32_t i;
  if (!dst)
    return;
  if (n < 0)
    n = 0;
  if (src_cap < 0)
    src_cap = 0;
  for (i = 0; i < 64; i++) {
    if (src && i < n && i < src_cap)
      dst[i] = src[i];
    else
      dst[i] = 0;
  }
}

/* wave138: typeck float bit helpers (asm symbols; product mega TU). */
extern int typeck_float64_bits_lo(double d);
extern int typeck_float64_bits_hi(double d);


/* wave138 Cap residual (was pipeline_asm_emit_as.c): arena expr slot + float bits.
 * G.7: pool accessors live with pipeline_arena_expr_ptr; pure as emit Cap residual
 * calls these faces. PLATFORM: SHARED host-cc residual. */

/**
 * Arena expr slot pointer with bounds check.
 * Thin wrapper over pipeline_arena_expr_ptr (same bounds).
 * Residual C leaves keep the glue_arena_expr_at_ref name for historical
 * call sites (field_access / struct_lit / expr_rec / typeck_* / coerce).
 * wave138: un-static + moved from as.c EOF after pure-owned leave.
 * PLATFORM: SHARED.
 */
struct ast_Expr *glue_arena_expr_at_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_arena_expr_ptr(a, expr_ref);
}

/**
 * Low 32 bits of float64 IEEE-754 representation for expr_ref.
 * FLOAT_LIT: recompute from float_val via typeck_float64_bits_lo.
 * Else: stored float_bits_lo field.
 * wave138 Cap residual (was as.c); pure float-lit emit Cap residual this face.
 * PLATFORM: SHARED — typeck_float64_bits_lo is external asm.
 */
int32_t pipeline_expr_float_bits_lo_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return 0;
  if (ex->kind == ast_ExprKind_EXPR_FLOAT_LIT)
    return typeck_float64_bits_lo(ex->float_val);
  return ex->float_bits_lo;
}

/**
 * High 32 bits of float64 IEEE-754 representation for expr_ref.
 * Symmetric to pipeline_expr_float_bits_lo_at.
 * PLATFORM: SHARED.
 */
int32_t pipeline_expr_float_bits_hi_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return 0;
  if (ex->kind == ast_ExprKind_EXPR_FLOAT_LIT)
    return typeck_float64_bits_hi(ex->float_val);
  return ex->float_bits_hi;
}

/**
 * Convert f64 IEEE bits (lo/hi) to f32 IEEE bits (truncating convert).
 * wave138 Cap residual for pure float-lit / array scalar pack (host float ops).
 * PLATFORM: SHARED.
 */
int32_t glue_ieee_f64_bits_to_f32_bits(int32_t lo, int32_t hi) {
  double dv;
  float fv;
  uint32_t fb;
  int32_t parts[2];
  parts[0] = lo;
  parts[1] = hi;
  memcpy(&dv, parts, sizeof(dv));
  fv = (float)dv;
  memcpy(&fb, &fv, sizeof(fb));
  return (int32_t)fb;
}

/**
 * Widen f32 IEEE bits to f64 IEEE lo half.
 * PLATFORM: SHARED.
 */
int32_t glue_ieee_f32_bits_to_f64_lo(int32_t fb) {
  float fv;
  double dv;
  uint64_t u64;
  memcpy(&fv, &fb, sizeof(fv));
  dv = (double)fv;
  memcpy(&u64, &dv, sizeof(u64));
  return (int32_t)(u64 & 0xffffffffu);
}

/**
 * Widen f32 IEEE bits to f64 IEEE hi half.
 * PLATFORM: SHARED.
 */
int32_t glue_ieee_f32_bits_to_f64_hi(int32_t fb) {
  float fv;
  double dv;
  uint64_t u64;
  memcpy(&fv, &fb, sizeof(fv));
  dv = (double)fv;
  memcpy(&u64, &dv, sizeof(u64));
  return (int32_t)(u64 >> 32);
}
