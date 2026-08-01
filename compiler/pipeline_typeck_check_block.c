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
