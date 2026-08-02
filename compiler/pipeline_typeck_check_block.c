/**
 * pipeline_typeck_check_block.c — typeck check_block orchestration domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega block typeck orchestration:
 * - block_impl bind/restore/touch current_block_ref
 * - loop_depth / unsafe_depth push/pop/set (+ dep_ctx unsafe_depth_at)
 * - pipeline_typeck_check_block_impl_c (stmt_order / legacy one_* + final)
 * - XLANG_WEAK check_block_impl fallback
 * - pipeline_typeck_check_block_c → typeck_check_block
 * - pipeline_typeck_check_block_as_loop_body_c (loop_depth + check_block)
 *
 * G.7: single product-mega check_block orchestration path — typeck.x twins
 * (check_block / check_block_impl / check_block_as_loop_body) must stay
 * aligned; do not open a second block walker in emit or a parallel glue copy.
 * typeck.o one_* / final helpers remain external (typeck_x.o EMIT_HEAVY).
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c after
 * pipeline_typeck_check_expr_c and before x_ast_check_one_func.
 * g_typeck_unsafe_depth remains a static earlier in pipeline_glue.c (same TU).
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

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

/** typeck_check_block_one_if 包装：XLANG_DEBUG_PIPE 时打印失败 if 的条件类型，便于 dep prerun 定位。 */
static int32_t pipeline_typeck_check_block_one_if_dbg_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                        int32_t block_ref, int32_t return_type_ref,
                                                        struct ast_PipelineDepCtx *ctx, int32_t idx) {
  int32_t rc;
  int32_t ic_cr;
  int32_t got_ty;

  rc = typeck_check_block_one_if(module, arena, block_ref, return_type_ref, ctx, idx);
  if (rc != 0 && link_abi_getenv("XLANG_DEBUG_PIPE")) {
    ic_cr = ast_ast_block_if_cond_ref(arena, block_ref, idx);
    got_ty = ast_ref_is_null(ic_cr) ? 0 : pipeline_expr_resolved_type_ref(arena, ic_cr);
    fprintf(stderr,
            "xlang: [XLANG_DEBUG_PIPE] check_block_one_if fail func=%d block=%d idx=%d cond=%d got_ty=%d is_bool=%d\n",
            ctx ? (int)ctx->current_func_index : -1, (int)block_ref, (int)idx, (int)ic_cr, (int)got_ty,
            (int)pipeline_typeck_type_ref_is_bool_c(arena, got_ty));
    fflush(stderr);
  }
  return rc;
}

/**
 * typeck.x::check_block_impl 的 C 委托：stmt_order/legacy 编排（C while）+ typeck.o one_* / final。
 * strict+pipeline 链不链整颗 typeck.o 时须自包含，不可 extern X 递归 walker。
 */
int32_t pipeline_typeck_check_block_impl_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                           int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  int32_t saved_block_ref;
  int32_t nc;
  int32_t nl;
  int32_t nlp;
  int32_t nfp;
  int32_t nif;
  int32_t nes;
  int32_t nso;
  int32_t fin0;
  int32_t si;
  int32_t i;
  uint8_t sk;
  int32_t idx;
  int32_t es_ref;

  if (!arena || !ctx || block_ref <= 0)
    return -1;
  saved_block_ref = pipeline_typeck_block_impl_bind_ctx_c(ctx, block_ref);
  nc = ast_ast_block_num_consts(arena, block_ref);
  nl = ast_ast_block_num_lets(arena, block_ref);
  nlp = ast_ast_block_num_loops(arena, block_ref);
  nfp = ast_ast_block_num_for_loops(arena, block_ref);
  nif = ast_ast_block_num_if_stmts(arena, block_ref);
  nes = ast_ast_block_num_expr_stmts(arena, block_ref);
  nso = ast_ast_block_num_stmt_order(arena, block_ref);
  fin0 = ast_ast_block_final_expr_ref(arena, block_ref);
  driver_diagnostic_typeck_block_enter(ctx->current_func_index, block_ref, nc, nl, nlp, nfp, nes, fin0);
  if (nso > 0) {
    si = 0;
    while (si < nso && si < 96) {
      pipeline_typeck_block_impl_touch_ctx_block_c(ctx, block_ref);
      sk = ast_ast_block_stmt_order_kind(arena, block_ref, si);
      idx = ast_ast_block_stmt_order_idx(arena, block_ref, si);
      if (sk == 0) {
        if (idx >= 0 && idx < nc && idx < 128) {
          if (typeck_check_block_one_const(module, arena, block_ref, return_type_ref, ctx, idx) != 0) {
            if (link_abi_getenv("XLANG_DEBUG_PIPE"))
              fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] check_block fail func=%d sk=const idx=%d\n",
                      (int)ctx->current_func_index, (int)idx);
            pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
            return -1;
          }
        }
      } else if (sk == 1) {
        if (idx >= 0 && idx < nl && idx < 128) {
          if (typeck_check_block_one_let(module, arena, block_ref, return_type_ref, ctx, idx) != 0) {
            if (link_abi_getenv("XLANG_DEBUG_PIPE"))
              fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] check_block fail func=%d sk=let idx=%d\n",
                      (int)ctx->current_func_index, (int)idx);
            pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
            return -1;
          }
        }
      } else if (sk == 2) {
        if (idx >= 0 && idx < nes) {
          es_ref = ast_ast_block_expr_stmt_ref(arena, block_ref, idx);
          if (pipeline_typeck_check_expr_c(module, arena, es_ref, return_type_ref, ctx) != 0) {
            if (link_abi_getenv("XLANG_DEBUG_PIPE"))
              fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] check_block fail func=%d sk=expr idx=%d es_ref=%d\n",
                      (int)ctx->current_func_index, (int)idx, (int)es_ref);
            pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
            return -1;
          }
        }
      } else if (sk == 3) {
        if (idx >= 0 && idx < nlp) {
          if (typeck_check_block_one_while(module, arena, block_ref, return_type_ref, ctx, idx) != 0) {
            if (link_abi_getenv("XLANG_DEBUG_PIPE"))
              fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] check_block fail func=%d sk=while idx=%d\n",
                      (int)ctx->current_func_index, (int)idx);
            pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
            return -1;
          }
        }
      } else if (sk == 4) {
        if (idx >= 0 && idx < nfp) {
          if (typeck_check_block_one_for(module, arena, block_ref, return_type_ref, ctx, idx) != 0) {
            if (link_abi_getenv("XLANG_DEBUG_PIPE"))
              fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] check_block fail func=%d sk=for idx=%d\n",
                      (int)ctx->current_func_index, (int)idx);
            pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
            return -1;
          }
        }
      } else if (sk == 5) {
        if (idx >= 0 && idx < nif) {
          if (pipeline_typeck_check_block_one_if_dbg_c(module, arena, block_ref, return_type_ref, ctx, idx) != 0) {
            if (link_abi_getenv("XLANG_DEBUG_PIPE"))
              fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] check_block fail func=%d block=%d sk=if idx=%d\n",
                      (int)ctx->current_func_index, (int)block_ref, (int)idx);
            pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
            return -1;
          }
        }
      }
      si = si + 1;
    }
  } else {
    i = 0;
    while (i < nc) {
      if (typeck_check_block_one_const(module, arena, block_ref, return_type_ref, ctx, i) != 0) {
        pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
        return -1;
      }
      i = i + 1;
    }
    i = 0;
    while (i < nl) {
      if (typeck_check_block_one_let(module, arena, block_ref, return_type_ref, ctx, i) != 0) {
        pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
        return -1;
      }
      i = i + 1;
    }
    i = 0;
    while (i < nlp) {
      if (typeck_check_block_one_while(module, arena, block_ref, return_type_ref, ctx, i) != 0) {
        pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
        return -1;
      }
      i = i + 1;
    }
    i = 0;
    while (i < nfp) {
      if (typeck_check_block_one_for(module, arena, block_ref, return_type_ref, ctx, i) != 0) {
        pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
        return -1;
      }
      i = i + 1;
    }
    i = 0;
    while (i < nif) {
      if (pipeline_typeck_check_block_one_if_dbg_c(module, arena, block_ref, return_type_ref, ctx, i) != 0) {
        pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
        return -1;
      }
      i = i + 1;
    }
    i = 0;
    while (i < nes && i < 32) {
      es_ref = ast_ast_block_expr_stmt_ref(arena, block_ref, i);
      if (pipeline_typeck_check_expr_c(module, arena, es_ref, return_type_ref, ctx) != 0) {
        pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
        return -1;
      }
      i = i + 1;
    }
  }
  if (typeck_check_block_final(module, arena, block_ref, return_type_ref, ctx, fin0) != 0) {
    if (link_abi_getenv("XLANG_DEBUG_PIPE"))
      fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] check_block fail func=%d block=%d sk=final fin0=%d\n",
              (int)ctx->current_func_index, (int)block_ref, (int)fin0);
    pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
    return -1;
  }
  pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
  return 0;
}

/** glue-only 链无 typeck.o 时回退 impl_c。 */
XLANG_WEAK int32_t check_block_impl(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                              int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  return pipeline_typeck_check_block_impl_c(module, arena, block_ref, return_type_ref, ctx);
}

extern int32_t typeck_check_block(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                  int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);

/** typeck.x::check_block 的 C 委托：边界检查后委托 typeck_x.o::typeck_check_block（与嵌套 if/while 同一路径，勿混用 glue monolithic impl）。 */
int32_t pipeline_typeck_check_block_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                      int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  if (ast_ref_is_null(block_ref))
    return 0;
  if (block_ref <= 0 || !arena || block_ref > arena->num_blocks)
    return 0;
  return typeck_check_block(module, arena, block_ref, return_type_ref, ctx);
}

/** typeck.x::check_block_as_loop_body 的 C 委托：loop_depth push/pop + check_block（无 typeck.o 时自包含）。 */
int32_t pipeline_typeck_check_block_as_loop_body_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   int32_t body_ref, int32_t return_type_ref,
                                                   struct ast_PipelineDepCtx *ctx) {
  int32_t saved_ld;
  int32_t rc;

  if (!ctx)
    return -1;
  saved_ld = pipeline_typeck_loop_depth_push_c(ctx);
  rc = pipeline_typeck_check_block_c(module, arena, body_ref, return_type_ref, ctx);
  pipeline_typeck_loop_depth_pop_c(ctx, saved_ld);
  return rc;
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
 * by typeck_x_ast). Updates g_typeck_active_module (defined at glue.c L135)
 * and g_typeck_active_ctx (defined at glue.c L8955).
 */
void pipeline_typeck_set_active_ctx_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx) {
  g_typeck_active_module = module;
  g_typeck_active_ctx = ctx;
}

/**
 * C5-enum-variant: read-only accessor for the active typeck module.
 *
 * Why: The const-init whitelist (pipeline_typeck_block_const_init_is_const_c)
 *      runs BEFORE the typeck-time marker pipeline_typeck_try_mark_enum_field_access
 *      fires inside typeck_check_expr (seed typeck_gen L6839 vs L6850). To pre-mark
 *      FIELD_ACCESS nodes at whitelist time we need the active module — but the
 *      whitelist signature takes only (arena, block_ref, idx), no module param.
 *      Rather than widening the signature (which would force seed modifications
 *      across many call sites), we expose a getter for the active module that
 *      the strict_minimal seed whitelist mirrors via extern.
 *
 * Invariant: Returns NULL outside the typeck phase; non-NULL throughout
 *            typeck_parsed_module_c (ast_pool.c L6428 sets it; L22027 sets
 *            it for the parse-coupled entry). Callers must NULL-check.
 *
 * PLATFORM: SHARED — populated identically on macOS arm64 and Ubuntu x86_64.
 */
struct ast_Module *pipeline_typeck_active_module_c(void) {
  return g_typeck_active_module;
}

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
 * typeck.x::func_body_tail_expr_ref_for_implicit_rule C twin.
 *
 * Why: W-tail analysis — find the effective tail expression of a function
 *      body for implicit return rule. RETURN/PANIC/BREAK/CONTINUE final
 *      wins; else peel trailing unsafe region; else fall through to final
 *      expr / last expr_stmt.
 * Invariant: arena non-null; body_ref valid or null (returns 0).
 * Asm/Perf: N/A (typeck pass; no codegen).
 * Contract: returns expr_ref > 0 if tail found; 0 if none.
 * PLATFORM: SHARED — product path (seed typeck → this glue).
 */
int32_t pipeline_typeck_func_body_tail_expr_ref_for_implicit_rule_c(struct ast_ASTArena *arena, int32_t body_ref) {
  int32_t fin_ref;
  int32_t nso;
  int32_t nes2;
  const uint8_t stmt_order_kind_expr_stmt = 2;
  const uint8_t stmt_order_kind_region_c_parser = 5;
  const uint8_t stmt_order_kind_region_x_parser = 6;

  nso = ast_ast_block_num_stmt_order(arena, body_ref);
  fin_ref = ast_ast_block_final_expr_ref(arena, body_ref);
  /* W-tail:
   * 1) final RETURN/PANIC/BREAK/CONTINUE wins (return after unsafe assign).
   * 2) else peel trailing unsafe region (sole `unsafe { return ... }` may leave stale EXPR_LIT final).
   * 3) else fall through to final / expr_stmt. */
  if (!ast_ref_is_null(fin_ref)) {
    int32_t fin_kind = pipeline_expr_kind_ord_at(arena, fin_ref);
    if (fin_kind == 41 || fin_kind == 42 || fin_kind == 39 || fin_kind == 40)
      return fin_ref;
  }
  if (nso > 0) {
    uint8_t last_k = (uint8_t)pipeline_block_stmt_order_kind(arena, body_ref, nso - 1);
    if (last_k == stmt_order_kind_region_c_parser || last_k == stmt_order_kind_region_x_parser) {
      int32_t idx = pipeline_block_stmt_order_idx(arena, body_ref, nso - 1);
      int32_t nreg = ast_ast_block_num_regions(arena, body_ref);
      int32_t is_unsafe =
          (idx >= 0 && idx < nreg) ? pipeline_block_region_is_unsafe(arena, body_ref, idx) : 0;
      if (link_abi_getenv("XLANG_DEBUG_PIPE"))
        fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] implicit_tail_region_peel body=%d idx=%d nreg=%d unsafe=%d\n",
                (int)body_ref, (int)idx, (int)nreg, (int)is_unsafe);
      if (idx >= 0 && idx < nreg && is_unsafe != 0) {
        int32_t inner_ref = ast_ast_block_region_body_ref(arena, body_ref, idx);
        if (!ast_ref_is_null(inner_ref))
          return pipeline_typeck_func_body_tail_expr_ref_for_implicit_rule_c(arena, inner_ref);
      }
    }
  }
  if (!ast_ref_is_null(fin_ref))
    return fin_ref;
  if (link_abi_getenv("XLANG_DEBUG_PIPE"))
    fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] implicit_tail_scan body=%d fin=%d nso=%d\n", (int)body_ref,
            (int)fin_ref, (int)nso);
  if (nso > 0) {
    uint8_t last_k;
    int32_t idx;
    int32_t nes;
    if (link_abi_getenv("XLANG_DEBUG_PIPE")) {
      int32_t si;
      int32_t nes_dbg = ast_ast_block_num_expr_stmts(arena, body_ref);
      fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] implicit_tail_dump body=%d exprs=%d\n", (int)body_ref, (int)nes_dbg);
      for (si = 0; si < nso; si++) {
        int32_t so_idx = pipeline_block_stmt_order_idx(arena, body_ref, si);
        uint8_t so_kind = (uint8_t)pipeline_block_stmt_order_kind(arena, body_ref, si);
        int32_t expr_ref = 0;
        int32_t expr_kind = -1;
        if (so_kind == stmt_order_kind_expr_stmt && so_idx >= 0 && so_idx < nes_dbg) {
          expr_ref = pipeline_block_expr_stmt_ref(arena, body_ref, so_idx);
          expr_kind = pipeline_expr_kind_ord_at(arena, expr_ref);
        }
        fprintf(stderr,
                "xlang: [XLANG_DEBUG_PIPE] implicit_tail_item body=%d si=%d so_kind=%u so_idx=%d expr=%d expr_kind=%d\n",
                (int)body_ref, (int)si, (unsigned)so_kind, (int)so_idx, (int)expr_ref, (int)expr_kind);
      }
    }

    last_k = (uint8_t)pipeline_block_stmt_order_kind(arena, body_ref, nso - 1);
    if (link_abi_getenv("XLANG_DEBUG_PIPE"))
      fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] implicit_tail_last body=%d kind=%u\n", (int)body_ref,
              (unsigned)last_k);
    if (last_k == stmt_order_kind_expr_stmt) {
      idx = pipeline_block_stmt_order_idx(arena, body_ref, nso - 1);
      nes = ast_ast_block_num_expr_stmts(arena, body_ref);
      if (idx >= 0 && idx < nes)
        return pipeline_block_expr_stmt_ref(arena, body_ref, idx);
    }
    return 0;
  }
  nes2 = ast_ast_block_num_expr_stmts(arena, body_ref);
  if (nes2 > 0)
    return pipeline_block_expr_stmt_ref(arena, body_ref, nes2 - 1);
  return 0;
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
