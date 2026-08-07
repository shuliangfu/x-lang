/**
 * pipeline_typeck_check_block.c — typeck check_block domain Cap residual thin
 * (BC 8.3.1 wave226 pure leave).
 *
 * wave226 G.7 pure leave: product-mega check_block orchestration bodies
 * retired from host-cc residual. Live walker authority is typeck.x
 * (typeck_check_block / typeck_check_block_impl / typeck_check_block_as_loop_body
 * + one_* / final / stmt_order). Cap residual keeps only:
 *   1. Ctx/depth sidecars typeck.x still calls via C ABI
 *      (bind/restore/touch, loop_depth, unsafe_depth)
 *   2. Thin product faces: check_block_c / impl_c / as_loop_body_c /
 *      XLANG_WEAK check_block_impl → typeck_x.o
 *   3. Linear move-tracking cluster (g_typeck_linear_moved_*; typeck.x
 *      still externs the _c faces — not dual walker)
 *   4. Implicit-return-tail cluster (has_implicit residual still live;
 *      tail face thin→typeck when typeck twin is complete)
 *   5. XLANG_WEAK patch_all_body_parent_links cold fallback
 *
 * Dual-export ban: do NOT re-open a second block walker here or in
 * runtime_pipeline_abi; typeck.x is single authority (includes region
 * stmt_order + parent_block_ref — residual C walker had drifted).
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c after
 * pipeline_typeck_check_expr_c and before x_ast_check_one_func.
 *
 * wave1282 G.7: typeck sidecar process-state folded here (was glue residual):
 *   g_typeck_unsafe_depth · TYPECK_LINEAR_MOVED_MAX / g_typeck_linear_moved_*
 *   g_typeck_active_ctx
 * Sole same-TU consumers of these statics are this file (unsafe/linear APIs).
 * g_typeck_active_module stays early in pipeline_glue.c (ctfe/assign/coerce
 * read it before this #include). PLATFORM: SHARED freestanding typeck.
 */

/** LANG-007 v2: unsafe { } nest depth sidecar (no PipelineDepCtx ABI growth). */
static int32_t g_typeck_unsafe_depth;

/** M-4: linear type use-once move tracking (per-func reset). */
#define TYPECK_LINEAR_MOVED_MAX 128
static int g_typeck_linear_moved_n;
static char g_typeck_linear_moved_names[TYPECK_LINEAR_MOVED_MAX][128];
static int32_t g_typeck_linear_moved_lens[TYPECK_LINEAR_MOVED_MAX];

/** WPO-S3: active typeck ctx for call-slice C glue without ctx param. */
static struct ast_PipelineDepCtx *g_typeck_active_ctx;

/** check_block_impl：绑定 ctx.current_block_ref，返回 saved。 */
int32_t pipeline_typeck_block_impl_bind_ctx_c(struct ast_PipelineDepCtx *ctx, int32_t block_ref) {
  int32_t saved;
  if (!ctx)
    return 0;
  saved = ctx->current_block_ref;
  ctx->current_block_ref = block_ref;
  return saved;
}

/** check_block_impl：恢复 ctx.current_block_ref。 */
void pipeline_typeck_block_impl_restore_ctx_c(struct ast_PipelineDepCtx *ctx, int32_t saved_block_ref) {
  if (!ctx)
    return;
  ctx->current_block_ref = saved_block_ref;
}

/** stmt_order 每步：保持 current_block_ref 与正在检查的块一致。 */
void pipeline_typeck_block_impl_touch_ctx_block_c(struct ast_PipelineDepCtx *ctx, int32_t block_ref) {
  if (!ctx)
    return;
  ctx->current_block_ref = block_ref;
}

/** check_block_as_loop_body：typeck_loop_depth++，返回进入前的深度。 */
int32_t pipeline_typeck_loop_depth_push_c(struct ast_PipelineDepCtx *ctx) {
  int32_t saved;
  if (!ctx)
    return 0;
  saved = ctx->typeck_loop_depth;
  ctx->typeck_loop_depth = saved + 1;
  return saved;
}

/** check_block_as_loop_body：恢复 typeck_loop_depth。 */
void pipeline_typeck_loop_depth_pop_c(struct ast_PipelineDepCtx *ctx, int32_t saved_loop_depth) {
  if (!ctx)
    return;
  ctx->typeck_loop_depth = saved_loop_depth;
}

/** LANG-007 v2：读 unsafe { } 嵌套深度侧车。 */
int32_t pipeline_dep_ctx_typeck_unsafe_depth_at(struct ast_PipelineDepCtx *ctx) {
  (void)ctx;
  return g_typeck_unsafe_depth;
}

/** LANG-007 v2：check_block unsafe { }：typeck_unsafe_depth++，返回进入前的深度。 */
int32_t pipeline_typeck_unsafe_depth_push_c(struct ast_PipelineDepCtx *ctx) {
  int32_t saved;
  (void)ctx;
  saved = g_typeck_unsafe_depth;
  g_typeck_unsafe_depth = saved + 1;
  return saved;
}

/** LANG-007 v2：check_block unsafe { }：恢复 typeck_unsafe_depth。 */
void pipeline_typeck_unsafe_depth_pop_c(struct ast_PipelineDepCtx *ctx, int32_t saved_unsafe_depth) {
  (void)ctx;
  g_typeck_unsafe_depth = saved_unsafe_depth;
}

/** 写 ctx.typeck_loop_depth；typeck_loop_depth_push/pop X emit 用。 */
void pipeline_typeck_loop_depth_set_c(struct ast_PipelineDepCtx *ctx, int32_t depth) {
  if (!ctx)
    return;
  ctx->typeck_loop_depth = depth;
}

/* Live walker authority in typeck_x.o (typeck.x exports, typeck_ prefix). */
extern int32_t typeck_check_block(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                  int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_block_impl(struct ast_Module *module, struct ast_ASTArena *arena,
                                       int32_t block_ref, int32_t return_type_ref,
                                       struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_block_as_loop_body(struct ast_Module *module, struct ast_ASTArena *arena,
                                               int32_t body_ref, int32_t return_type_ref,
                                               struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_func_body_tail_expr_ref_for_implicit_rule(struct ast_ASTArena *arena,
                                                               int32_t body_ref);

/**
 * Product-mega C face for block typeck orchestration.
 *
 * Why thin (wave226): residual C walker was dual of typeck.x check_block_impl
 * and had drifted (no region stmt_order, no parent_block_ref stamp). Product
 * always links typeck_x.o (PREFER_X_O / pure-ld); G.7 single authority.
 *
 * Callers: x_frontend_link_alias check_block_impl, XLANG_WEAK check_block_impl.
 * Contract: same as typeck_check_block_impl — 0 ok, -1 fail.
 * PLATFORM: SHARED freestanding typeck.
 */
int32_t pipeline_typeck_check_block_impl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                           int32_t block_ref, int32_t return_type_ref,
                                           struct ast_PipelineDepCtx *ctx) {
  return typeck_check_block_impl(module, arena, block_ref, return_type_ref, ctx);
}

/**
 * Cold fallback when no strong check_block_impl is linked (frontend_link_alias
 * / typeck_x own the product face). Still routes to typeck_x.o via thin impl_c.
 * PLATFORM: SHARED.
 */
XLANG_WEAK int32_t check_block_impl(struct ast_Module *module, struct ast_ASTArena *arena,
                                    int32_t block_ref, int32_t return_type_ref,
                                    struct ast_PipelineDepCtx *ctx) {
  return pipeline_typeck_check_block_impl_c(module, arena, block_ref, return_type_ref, ctx);
}

/**
 * typeck.x::check_block Cap residual face: bounds then typeck_x.o walker.
 * orch residual + nested paths call this name; never re-open monolithic body.
 * PLATFORM: SHARED freestanding typeck.
 */
int32_t pipeline_typeck_check_block_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                      int32_t block_ref, int32_t return_type_ref,
                                      struct ast_PipelineDepCtx *ctx) {
  if (ast_ref_is_null(block_ref))
    return 0;
  if (block_ref <= 0 || !arena || block_ref > arena->num_blocks)
    return 0;
  return typeck_check_block(module, arena, block_ref, return_type_ref, ctx);
}

/**
 * typeck.x::check_block_as_loop_body Cap residual face — thin to typeck_x.o
 * (loop_depth push/pop lives inside typeck authority).
 * PLATFORM: SHARED freestanding typeck.
 */
int32_t pipeline_typeck_check_block_as_loop_body_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   int32_t body_ref, int32_t return_type_ref,
                                                   struct ast_PipelineDepCtx *ctx) {
  return typeck_check_block_as_loop_body(module, arena, body_ref, return_type_ref, ctx);
}

/* ============================================================
 * wave1132 G.7: typeck_linear_name_already_moved (migrated from
 * glue.c L9785-9792).
 *
 * Why here: linear use-once move tracking is consulted by
 * pipeline_typeck_linear_use_var_c (glue.c L9797+) which is invoked
 * during check_expr / check_block walks for VAR reads of TYPE_LINEAR.
 * Colocating with the check_block domain keeps the linear-move bookkeeping
 * next to the only walker that triggers it (no other module reads
 * g_typeck_linear_moved_*).
 *
 * Invariant: globals g_typeck_linear_moved_{n,names,lens} are defined
 * earlier in pipeline_glue.c (L9745-9747) BEFORE the #include of this
 * leaf at L11606 — so the function body sees them. The single callsite
 * at glue.c L9805 (pipeline_typeck_linear_use_var_c) PRECEDES the
 * #include; a static forward decl is added at glue.c L9784 to keep it
 * visible.
 *
 * Contract:
 *   - name non-NULL; name_len > 0; else return 0 (no match).
 *   - Reads g_typeck_linear_moved_n + g_typeck_linear_moved_names/lens
 *     arrays (capacity TYPECK_LINEAR_MOVED_MAX=128, name width 128).
 *   - Returns 1 if name already in moved set; 0 otherwise.
 *
 * PLATFORM: SHARED — pure name lookup; no platform ABI dependency.
 * ============================================================ */

/**
 * M-4 linear move set lookup: scan g_typeck_linear_moved_names[] for an
 * exact (len, bytes) match. Returns 1 if the named variable was already
 * moved this function (set by pipeline_typeck_linear_use_var_c), else 0.
 */
static int typeck_linear_name_already_moved(const uint8_t *name, int32_t name_len) {
  int i;
  for (i = 0; i < g_typeck_linear_moved_n; i++)
    if (g_typeck_linear_moved_lens[i] == name_len && name_len > 0 &&
        memcmp(g_typeck_linear_moved_names[i], name, (size_t)name_len) == 0)
      return 1;
  return 0;
}

/* ============================================================
 * wave1157 G.7: linear type use-once move tracking cluster (6 fns)
 * (migrated from pipeline_glue.c L8957-9083).
 *
 * Why here: the linear move tracking cluster is colocated with
 * typeck_linear_name_already_moved (wave1132, already in this file)
 * and the check_block walker domain. The linear_use_var_c entry point
 * is invoked during check_expr / check_block walks for VAR reads of
 * TYPE_LINEAR — colocating with the walker keeps the linear-move
 * bookkeeping next to the only walker that triggers it.
 *
 * Cluster (6 fns, ~125 LOC):
 *   - pipeline_typeck_set_active_ctx_c (4 LOC; active module/ctx setter)
 *   - pipeline_typeck_active_module_c (4 LOC; active module getter)
 *   - pipeline_typeck_linear_reset_c (3 LOC; per-function moved set reset)
 *   - pipeline_typeck_linear_use_var_c (24 LOC; VAR read double-move gate)
 *   - pipeline_typeck_linear_accepts_init_c (10 LOC; Linear(T) init accept)
 *   - pipeline_typeck_reject_addr_of_linear_c (42 LOC; ADDR_OF reject)
 *
 * Dependencies (all visible via same-TU globals or extern):
 *   - g_typeck_active_module (static global at glue.c L135; before
 *     #include L10250 — visible)
 *   - g_typeck_active_ctx (static global at glue.c L8955; before
 *     #include L10250 — visible)
 *   - g_typeck_linear_moved_{n,names,lens} + TYPECK_LINEAR_MOVED_MAX
 *     (static globals at glue.c L8949-8952; before #include L10250 — visible)
 *   - typeck_linear_name_already_moved (static, wave1132, same file —
 *     direct call, no fwd needed)
 *   - pipeline_type_kind_ord_at / pipeline_type_elem_ref_at /
 *     pipeline_expr_kind_ord_at / pipeline_expr_var_name_len / _into /
 *     pipeline_expr_line_at / pipeline_expr_col_at (all extern)
 *   - pipeline_typeck_type_refs_equal_c (extern, defined at glue.c L7375;
 *     before #include L10250 — visible)
 *   - pipeline_block_resolve_var_type_ref (extern, declared at glue.c L1326)
 *   - pipeline_module_func_param_type_ref_for_name (extern, declared at
 *     glue.c L264)
 *   - lsp_diag_report_typeck (extern, declared at glue.c L8943; before
 *     #include L10250 — visible)
 *   - driver_diagnostic_typeck_linear_addr_of (extern, inline-declared
 *     in function body)
 *
 * Visibility:
 *   - glue.c callsite for set_active_ctx_c at L6109 PRECEDES check_block.c
 *     #include at L10250 → extern fwd decl added in glue.c before L6109.
 *   - glue.c callsites for linear_reset_c at L10267/10331/10398 are AFTER
 *     #include L10250 → visible, no fwd decl needed.
 *   - Other functions have no glue.c callsites (called from typeck.x /
 *     ast_pool.c / seeds — all cross-TU extern calls).
 *
 * PLATFORM: SHARED — pure typeck linear-type bookkeeping; no platform ABI dep.
 * ============================================================ */

/**
 * WPO-S3: set active typeck module/ctx before check (called per-function
 * by typeck_x_ast). wave224: process-local module cell is pure BSS via
 * pipeline_typeck_active_module_set_c (G.7 single cell authority); residual
 * only updates g_typeck_active_ctx (check_block-local).
 * PLATFORM: SHARED freestanding typeck bookkeeping.
 */
void pipeline_typeck_set_active_ctx_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx) {
  pipeline_typeck_active_module_set_c(module);
  g_typeck_active_ctx = ctx;
}

/* wave224 pure-owned leave: pipeline_typeck_active_module_c live =
 * runtime_pipeline_abi pure (G.7 dual-export ban — do not redefine here). */

/**
 * M-4: clear moved set before entering a new function's typeck pass.
 */
void pipeline_typeck_linear_reset_c(void) {
  g_typeck_linear_moved_n = 0;
}

/**
 * M-4: VAR read of Linear(T) checks double-move; on success marks moved.
 * Returns 0 if acceptable, -1 if already moved (diagnostic emitted).
 */
int32_t pipeline_typeck_linear_use_var_c(struct ast_ASTArena *arena, int32_t type_ref, int32_t expr_ref,
                                         uint8_t *name, int32_t name_len) {
  int32_t line;
  int32_t col;
  if (!arena || name_len <= 0 || name_len > 127 || !name)
    return 0;
  if (type_ref <= 0 || pipeline_type_kind_ord_at(arena, type_ref) != (int32_t)ast_TypeKind_TYPE_LINEAR)
    return 0;
  if (typeck_linear_name_already_moved(name, name_len)) {
    line = 0;
    col = 0;
    if (expr_ref > 0 && expr_ref <= arena->num_exprs) {
      line = pipeline_expr_line_at(arena, expr_ref);
      col = pipeline_expr_col_at(arena, expr_ref);
    }
    lsp_diag_report_typeck((int)line, (int)col, "linear value used after move");
    return -1;
  }
  if (g_typeck_linear_moved_n < TYPECK_LINEAR_MOVED_MAX) {
    memcpy(g_typeck_linear_moved_names[g_typeck_linear_moved_n], name, (size_t)name_len);
    g_typeck_linear_moved_lens[g_typeck_linear_moved_n] = name_len;
    g_typeck_linear_moved_n++;
  }
  return 0;
}

/**
 * M-4: whether Linear(T) let accepts inner T or Linear(T) init value.
 */
int32_t pipeline_typeck_linear_accepts_init_c(struct ast_ASTArena *arena, int32_t decl_ref,
                                                int32_t init_ref) {
  if (!arena || decl_ref <= 0 || init_ref <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, decl_ref) != (int32_t)ast_TypeKind_TYPE_LINEAR)
    return 0;
  if (pipeline_typeck_type_refs_equal_c(arena, decl_ref, init_ref))
    return 1;
  return pipeline_typeck_type_refs_equal_c(arena, pipeline_type_elem_ref_at(arena, decl_ref), init_ref);
}

/**
 * M-4: reject ADDR_OF on Linear variable (must be called before
 * pipeline_typeck_linear_use_var_c). Returns 0 to continue; -1 if
 * diagnostic emitted.
 */
int32_t pipeline_typeck_reject_addr_of_linear_c(struct ast_ASTArena *arena, int32_t op_ref,
    int32_t addr_expr_ref, struct ast_Module *module, struct ast_PipelineDepCtx *ctx) {
  int32_t vnlen;
  int32_t block_ref;
  int32_t vd_tr;
  int32_t func_ix;
  int32_t pr;
  int32_t line;
  int32_t col;
  uint8_t vbuf[128];
  extern void driver_diagnostic_typeck_linear_addr_of(int32_t line, int32_t col);
  if (!arena || !module || !ctx || op_ref <= 0 || op_ref > arena->num_exprs)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, op_ref) != 3)
    return 0;
  vnlen = pipeline_expr_var_name_len(arena, op_ref);
  if (vnlen <= 0 || vnlen > 127)
    return 0;
  pipeline_expr_var_name_into(arena, op_ref, vbuf);
  block_ref = ctx->current_block_ref;
  if (block_ref > 0 && block_ref <= arena->num_blocks) {
    vd_tr = pipeline_block_resolve_var_type_ref(arena, block_ref, vbuf, vnlen);
    if (vd_tr > 0 && pipeline_type_kind_ord_at(arena, vd_tr) == (int32_t)ast_TypeKind_TYPE_LINEAR)
      goto reject;
  }
  func_ix = ctx->current_func_index;
  if (func_ix >= 0 && func_ix < module->num_funcs) {
    pr = pipeline_module_func_param_type_ref_for_name(module, func_ix, vbuf, vnlen);
    if (pr > 0 && pipeline_type_kind_ord_at(arena, pr) == (int32_t)ast_TypeKind_TYPE_LINEAR)
      goto reject;
  }
  return 0;
reject:
  line = 0;
  col = 0;
  if (addr_expr_ref > 0 && addr_expr_ref <= arena->num_exprs) {
    line = pipeline_expr_line_at(arena, addr_expr_ref);
    col = pipeline_expr_col_at(arena, addr_expr_ref);
  }
  driver_diagnostic_typeck_linear_addr_of(line, col);
  return -1;
}

/* ===========================================================================
 * wave1191 G.7: typeck func_body implicit return tail cluster (3 fns)
 * migrated from pipeline_glue.c. Colocated with check_block walker domain
 * — func_body tail analysis is a sub-domain of block typeck (block walk
 * needs implicit-return-tail check at final expr).
 *
 * Forward decls visible at #include point (glue.c L6114) via earlier decls:
 * - ast_ast_block_num_stmt_order / final_expr_ref / num_regions /
 *   region_body_ref / num_expr_stmts (extern in ast_pool_block.c)
 * - pipeline_expr_kind_ord_at / pipeline_block_stmt_order_kind/idx (extern)
 * - pipeline_block_region_is_unsafe (extern at glue.c L4824)
 * - pipeline_block_expr_stmt_ref (extern at glue.c L92)
 * - pipeline_expr_block_ref_at / pipeline_module_func_body_ref_at (extern)
 * - ast_ast_arena_patch_block_parent_links (extern)
 * - implicit_tail_expr_disallowed_by_glue (defined at glue.c L831, before
 *   check_block.c #include at L6114 — visible)
 * - link_abi_getenv (extern at glue.c L51)
 * - pipeline_debug_trace_named_func_bodies (extern at glue.c L418)
 * PLATFORM: SHARED.
 * ========================================================================== */

/**
 * typeck.x::func_body_tail_expr_ref_for_implicit_rule Cap residual face.
 *
 * wave226 pure leave: dual W-tail body retired; live authority is typeck.x
 * (typeck_func_body_tail_expr_ref_for_implicit_rule). has_implicit residual
 * below still calls this face name (thin → typeck).
 *
 * Contract: expr_ref > 0 if tail found; 0 if none.
 * PLATFORM: SHARED freestanding typeck.
 */
int32_t pipeline_typeck_func_body_tail_expr_ref_for_implicit_rule_c(struct ast_ASTArena *arena,
                                                                    int32_t body_ref) {
  return typeck_func_body_tail_expr_ref_for_implicit_rule(arena, body_ref);
}

/**
 * typeck.x::func_body_has_implicit_return_tail C twin.
 *
 * Why: G-02f-477 — determine if block tail has disallowed implicit return.
 *      EXPR_BLOCK (ord=26) recurses into inner block to check for explicit
 *      return (unsafe { return ...; } parsed as EXPR_BLOCK not region).
 * Invariant: arena non-null; body_ref valid or null (returns 0).
 * Asm/Perf: N/A (typeck pass; no codegen).
 * Contract: returns 1 if implicit tail return present; 0 if none / disallowed.
 * PLATFORM: SHARED — product path (seed typeck → this glue).
 */
int32_t pipeline_typeck_func_body_has_implicit_return_tail_c(struct ast_ASTArena *arena, int32_t body_ref) {
  int32_t tail_ref;
  int32_t tail_kind;

  if (ast_ref_is_null(body_ref) || body_ref <= 0 || !arena || body_ref > arena->num_blocks)
    return 0;
  tail_ref = pipeline_typeck_func_body_tail_expr_ref_for_implicit_rule_c(arena, body_ref);
  if (ast_ref_is_null(tail_ref))
    return 0;
  tail_kind = pipeline_expr_kind_ord_at(arena, tail_ref);
  if (link_abi_getenv("XLANG_DEBUG_PIPE"))
    fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] implicit_tail_result body=%d tail=%d kind=%d\n", (int)body_ref,
            (int)tail_ref, (int)tail_kind);
  if (implicit_tail_expr_disallowed_by_glue(arena, tail_ref) != 0)
    return 0;
  /* G-02f-477: EXPR_BLOCK (ord=26) — recurse into inner block for explicit return.
   * Unsafe block `unsafe { return expr; }` is parsed as EXPR_BLOCK not region;
   * must recurse into block_ref to check tail expr, avoiding false implicit
   * tail return report. Uses pipeline_expr_block_ref_at accessor (consistent
   * with line 19812) to avoid direct Expr struct access. */
  if (tail_kind == 26) {
    int32_t inner_block = pipeline_expr_block_ref_at(arena, tail_ref);
    if (link_abi_getenv("XLANG_DEBUG_PIPE"))
      fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] implicit_tail_block body=%d tail=%d inner_block=%d\n",
              (int)body_ref, (int)tail_ref, (int)inner_block);
    if (!ast_ref_is_null(inner_block))
      return pipeline_typeck_func_body_has_implicit_return_tail_c(arena, inner_block);
  }
  return 1;
}

/*
 * wave92: product pure owns pipeline_typeck_patch_all_body_parent_links_c
 * (runtime_pipeline_abi.x thin → typeck_patch_all_body_parent_links). Keep XLANG_WEAK cold
 * fallback for links without pure pipeline_abi / PREFER hybrid.
 * PLATFORM: SHARED — ELF weak overridden by pure; same walk as typeck.x.
 */
XLANG_WEAK void pipeline_typeck_patch_all_body_parent_links_c(struct ast_Module *module,
                                                                         struct ast_ASTArena *arena) {
  int32_t i;
  int32_t br;

  if (!module || !arena)
    return;
  for (i = 0; i < module->num_funcs; i++) {
    br = pipeline_module_func_body_ref_at(module, i);
    if (!ast_ref_is_null(br))
      ast_ast_arena_patch_block_parent_links(arena, br, 0);
  }
}
