/* pipeline_codegen_dep.c — codegen dep 编排域（自 ast_pool.c 抽出）
 *
 * run_x_pipeline_codegen_*：dep 模块 codegen 编排——one_dep_emit／entry_emit／one_dep_c／
 *   deps_c／entry_c（按 dep 顺序 codegen + 链接判定 + diag）。
 * pipeline_debug_dump_std_heap_trace_call + pipeline_debug_name_eq_buf_lit：std heap trace 调试。
 * pipeline_fill_dep_import_path_from_buf / resolve_path_x_from_buf64 / run_x_pipeline_fill_dep_import_path /
 *   prepare_dep_codegen_path / finish_dep_codegen_diag：dep 路径填充与 codegen 前后处理。
 * pipeline_dep_ctx_has_earlier_same_import_path（static）／g_codegen_entry_arena_for_mono：去重 / mono arena。
 * 同 TU #include（emit_sidecar 之前）；extern（asm_asm_codegen_ast／codegen_codegen_x_ast／
 *   driver_diagnostic_*／pipeline_codegen_dep_skip_x_bootstrap_partial）本块内声明；公共符号，
 *   ast_pool 内无先于此 include 的调用方。 */

extern void driver_diagnostic_codegen_fail(int32_t dep_index, int32_t is_dep);
extern int32_t asm_asm_codegen_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                                   struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx);
extern int32_t codegen_codegen_x_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                                      struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx,
                                      int32_t dep_index);
int32_t pipeline_codegen_dep_skip_x_bootstrap_partial(uint8_t *path);
int32_t pipeline_codegen_std_dep_link_only(uint8_t *path);
int32_t ast_ast_block_final_expr_ref(struct ast_ASTArena *a, int32_t br);

static int pipeline_debug_name_eq_buf_lit(const uint8_t *buf, int32_t len, const char *lit) {
  size_t lit_len;
  if (!buf || !lit || len <= 0)
    return 0;
  lit_len = strlen(lit);
  return (int32_t)lit_len == len && memcmp(buf, lit, lit_len) == 0;
}

static void pipeline_debug_dump_std_heap_trace_call(struct ast_Module *dep_mod, struct ast_ASTArena *arena,
                                                    struct ast_PipelineDepCtx *ctx, int32_t dep_j,
                                                    uint8_t *dep_path_buf) {
  int32_t n_imp, j, expr_ref;
  if (!dep_mod || !arena || !ctx || !dep_path_buf)
    return;
  if (!link_abi_getenv("XLANG_DEBUG_PIPE"))
    return;
  if (strcmp((const char *)dep_path_buf, "std.heap") != 0)
    return;
  n_imp = parser_get_module_num_imports(dep_mod);
  fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] std.heap probe dep_j=%d imports=%d ctx_ndep=%d arena_exprs=%d\n",
          (int)dep_j, (int)n_imp, (int)pipeline_dep_ctx_ndep(ctx), (int)arena->num_exprs);
  for (j = 0; j < pipeline_dep_ctx_ndep(ctx); j++) {
    uint8_t ctx_path_buf[128];
    int32_t ctx_path_len = pipeline_dep_ctx_import_path_len(ctx, j);
    struct ast_Module *ctx_mod = pipeline_dep_ctx_module_at(ctx, j);
    memset(ctx_path_buf, 0, sizeof(ctx_path_buf));
    if (ctx_path_len > 0)
      pipeline_dep_ctx_import_path_copy64(ctx, j, ctx_path_buf);
    fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] std.heap ctx dep[%d] path=%.*s funcs=%d mod=%p\n", (int)j,
            (int)ctx_path_len, (char *)ctx_path_buf, ctx_mod ? (int)pipeline_module_num_funcs(ctx_mod) : -1,
            (void *)ctx_mod);
  }
  for (j = 0; j < n_imp; j++) {
    uint8_t path_buf[128];
    uint8_t bind_buf[128];
    int32_t path_len = pipeline_module_import_path_len(dep_mod, j);
    int32_t bind_len = pipeline_module_import_binding_name_len(dep_mod, j);
    int32_t k;
    memset(path_buf, 0, sizeof(path_buf));
    memset(bind_buf, 0, sizeof(bind_buf));
    pipeline_module_import_path_copy(dep_mod, j, path_buf, (int32_t)sizeof(path_buf));
    for (k = 0; k < bind_len && k < (int32_t)sizeof(bind_buf) - 1; k++)
      bind_buf[k] = pipeline_module_import_binding_name_byte_at(dep_mod, j, k);
    fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] std.heap import idx=%d kind=%d path=%.*s bind=%.*s\n", (int)j,
            (int)pipeline_module_import_kind_at(dep_mod, j), (int)path_len, (char *)path_buf, (int)bind_len,
            (char *)bind_buf);
  }
  for (j = 0; j < pipeline_module_num_funcs(dep_mod); j++) {
    uint8_t fn_buf[128];
    int32_t fn_len = pipeline_module_func_name_len_at(dep_mod, j);
    int32_t body_ref;
    int32_t nso;
    int32_t si;
    memset(fn_buf, 0, sizeof(fn_buf));
    if (fn_len <= 0 || fn_len > 127)
      continue;
    pipeline_module_func_name_copy64(dep_mod, j, fn_buf);
    if (!pipeline_debug_name_eq_buf_lit(fn_buf, fn_len, "trace_on"))
      continue;
    body_ref = pipeline_module_func_body_ref_at(dep_mod, j);
    nso = body_ref > 0 ? ast_ast_block_num_stmt_order(arena, body_ref) : -1;
    fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] std.heap func fi=%d name=%.*s body_ref=%d nso=%d fin=%d\n", (int)j,
            (int)fn_len, (char *)fn_buf, (int)body_ref, (int)nso,
            body_ref > 0 ? (int)ast_ast_block_final_expr_ref(arena, body_ref) : -1);
    for (si = 0; body_ref > 0 && si < nso; si++) {
      int32_t so_idx = pipeline_block_stmt_order_idx(arena, body_ref, si);
      int32_t expr_stmt_ref = pipeline_block_expr_stmt_ref(arena, body_ref, so_idx);
      struct ast_Expr *expr_stmt = expr_stmt_ref > 0 ? pipeline_arena_expr_ptr(arena, expr_stmt_ref) : NULL;
      fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] std.heap func stmt si=%d kind=%u idx=%d\n", (int)si,
              (unsigned)pipeline_block_stmt_order_kind(arena, body_ref, si),
              (int)so_idx);
      fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] std.heap func expr_stmt si=%d expr_ref=%d expr_kind=%d\n", (int)si,
              (int)expr_stmt_ref, expr_stmt ? (int)expr_stmt->kind : -1);
      if (expr_stmt && expr_stmt->unary_operand_ref > 0) {
        struct ast_Expr *ret_op = pipeline_arena_expr_ptr(arena, expr_stmt->unary_operand_ref);
        fprintf(stderr,
                "xlang: [XLANG_DEBUG_PIPE] std.heap func return_op si=%d op_ref=%d op_kind=%d callee=%d base=%d name_len=%d var=%.*s field=%.*s\n",
                (int)si, (int)expr_stmt->unary_operand_ref, ret_op ? (int)ret_op->kind : -1,
                ret_op ? (int)ret_op->call_callee_ref : -1, ret_op ? (int)ret_op->field_access_base_ref : -1,
                ret_op ? (int)ret_op->var_name_len : -1, ret_op ? (int)ret_op->var_name_len : 0,
                ret_op ? (const char *)ret_op->var_name : "",
                ret_op ? (int)ret_op->field_access_field_len : 0,
                ret_op ? (const char *)ret_op->field_access_field_name : "");
      }
    }
  }
  for (expr_ref = 1; expr_ref <= arena->num_exprs; expr_ref++) {
    struct ast_Expr *call_ex = pipeline_arena_expr_ptr(arena, expr_ref);
    struct ast_Expr *callee_ex;
    struct ast_Expr *base_ex;
    int32_t dep_ix;
    int32_t func_ix;
    uint8_t dep_resolved_path[128];
    if (!call_ex || call_ex->kind != ast_ExprKind_EXPR_CALL || call_ex->call_callee_ref <= 0)
      continue;
    callee_ex = pipeline_arena_expr_ptr(arena, call_ex->call_callee_ref);
    if (!callee_ex || callee_ex->kind != ast_ExprKind_EXPR_FIELD_ACCESS || callee_ex->field_access_base_ref <= 0)
      continue;
    base_ex = pipeline_arena_expr_ptr(arena, callee_ex->field_access_base_ref);
    if (!base_ex || base_ex->kind != ast_ExprKind_EXPR_VAR)
      continue;
    if (!pipeline_debug_name_eq_buf_lit(base_ex->var_name, base_ex->var_name_len, "heap_libc"))
      continue;
    if (!pipeline_debug_name_eq_buf_lit(callee_ex->field_access_field_name, callee_ex->field_access_field_len,
                                        "heap_trace_enabled_c"))
      continue;
    dep_ix = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
    func_ix = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
    memset(dep_resolved_path, 0, sizeof(dep_resolved_path));
    if (dep_ix >= 0 && dep_ix < pipeline_dep_ctx_ndep(ctx))
      pipeline_dep_ctx_import_path_copy64(ctx, dep_ix, dep_resolved_path);
    fprintf(stderr,
            "xlang: [XLANG_DEBUG_PIPE] std.heap trace_on call expr=%d callee=%d dep_ix=%d func_ix=%d global_dep=%s\n",
            (int)expr_ref, (int)call_ex->call_callee_ref, (int)dep_ix, (int)func_ix,
            dep_ix >= 0 ? (char *)dep_resolved_path : "<none>");
  }
  for (expr_ref = 1; expr_ref <= arena->num_exprs; expr_ref++) {
    struct ast_Expr *ex = pipeline_arena_expr_ptr(arena, expr_ref);
    int hit = 0;
    if (!ex)
      continue;
    if (ex->kind == ast_ExprKind_EXPR_VAR &&
        pipeline_debug_name_eq_buf_lit(ex->var_name, ex->var_name_len, "heap_libc"))
      hit = 1;
    if (ex->kind == ast_ExprKind_EXPR_FIELD_ACCESS &&
        pipeline_debug_name_eq_buf_lit(ex->field_access_field_name, ex->field_access_field_len, "heap_trace_enabled_c"))
      hit = 1;
    if (!hit)
      continue;
    fprintf(stderr,
            "xlang: [XLANG_DEBUG_PIPE] std.heap expr expr=%d kind=%d callee=%d base=%d name_len=%d var=%.*s field=%.*s dep_ix=%d func_ix=%d\n",
            (int)expr_ref, (int)ex->kind, (int)ex->call_callee_ref, (int)ex->field_access_base_ref,
            (int)ex->var_name_len, (int)ex->var_name_len, (const char *)ex->var_name, (int)ex->field_access_field_len,
            (const char *)ex->field_access_field_name, (int)ex->call_resolved_dep_index,
            (int)ex->call_resolved_func_index);
  }
}

static int32_t pipeline_dep_ctx_has_earlier_same_import_path_c(struct ast_PipelineDepCtx *ctx, int32_t dep_j);

/**
 * 对单个 dep 执行 asm/C codegen；C glue（dep_mod->num_funcs 读 + asm 深栈 emit 仍须 C）。
 */
int32_t run_x_pipeline_codegen_one_dep_emit(struct ast_Module *dep_mod, struct codegen_CodegenOutBuf *out_buf,
                                             struct ast_PipelineDepCtx *ctx, int32_t dep_j, int32_t skip_asm_dep_codegen,
                                             int32_t use_asm_backend) {
  uint8_t dep_path_buf[128];

  if (!out_buf || !ctx || dep_j < 0)
    return -1;
  if (pipeline_dep_ctx_has_earlier_same_import_path_c(ctx, dep_j) != 0) {
    if (link_abi_getenv("XLANG_DEBUG_PIPE")) {
      memset(dep_path_buf, 0, sizeof(dep_path_buf));
      pipeline_dep_ctx_import_path_copy64(ctx, dep_j, dep_path_buf);
      fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] skip duplicate dep emit j=%d path=%s\n", (int)dep_j,
              (char *)dep_path_buf);
    }
    return 0;
  }
  memset(dep_path_buf, 0, sizeof(dep_path_buf));
  pipeline_dep_ctx_import_path_copy64(ctx, dep_j, dep_path_buf);
  /*
   * wave578 Cap residual (Ubuntu L2): product path is
   * pipeline_run_x_pipeline_codegen_one_dep → emit(module_at(...)), not the _c
   * wrapper. After name[64]→[128], DepCtx sidecar module_at can be NULL while
   * driver_dep_module_buf still holds the pre-parsed dep (num_funcs>0). Rebind
   * here so both seed weak one_dep and C one_dep_c paths share one authority.
   * PLATFORM: SHARED — mac L2 often hit sidecar; Ubuntu gold exposed NULL.
   */
  if (!dep_mod) {
    int32_t sync_slot = driver_dep_slot_for_path(dep_path_buf);
    if (sync_slot < 0)
      sync_slot = dep_j;
    dep_mod = (struct ast_Module *)driver_dep_module_buf(sync_slot);
    if (dep_mod) {
      pipeline_dep_ctx_set_module(ctx, dep_j, dep_mod);
      pipeline_dep_ctx_set_arena(ctx, dep_j, (struct ast_ASTArena *)driver_dep_arena_buf(sync_slot));
      if (link_abi_getenv("XLANG_DEBUG_PIPE"))
        fprintf(stderr,
                "xlang: [XLANG_DEBUG_PIPE] rebind dep emit j=%d path=%s slot=%d funcs=%d\n",
                (int)dep_j, (char *)dep_path_buf, (int)sync_slot,
                (int)pipeline_module_num_funcs(dep_mod));
    }
  }
  if (link_abi_getenv("XLANG_DEBUG_PIPE"))
    fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] dep emit j=%d path=%s use_asm=%d funcs=%d\n", (int)dep_j,
            (char *)dep_path_buf, (int)use_asm_backend,
            dep_mod ? (int)pipeline_module_num_funcs(dep_mod) : -1);
  pipeline_debug_dump_std_heap_trace_call(dep_mod, pipeline_dep_ctx_arena_at(ctx, dep_j), ctx, dep_j, dep_path_buf);
  if (pipeline_codegen_dep_skip_x_bootstrap_partial(dep_path_buf) != 0) {
    if (link_abi_getenv("XLANG_DEBUG_PIPE"))
      fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] skip dep emit j=%d path=%s\n", (int)dep_j, (char *)dep_path_buf);
    return 0;
  }
  /** 产品轨：std 模块有预编 *.o 时勿 co-emit（.o 权威）。
   * 【Why】co-emit wrapper（std_json_* 调 json_*_c）+ 链 json.o → 双权威 duplicate；
   *   仅 co-emit 则缺 _c 桩。base64/csv/heap/http 同形。core.mem 仍 co-emit（mem 测自洽）。 */
  if (pipeline_codegen_std_dep_link_only(dep_path_buf) != 0) {
    if (link_abi_getenv("XLANG_DEBUG_PIPE"))
      fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] skip dep emit (prebuilt .o) j=%d path=%s\n", (int)dep_j,
              (char *)dep_path_buf);
    return 0;
  }
  /** asm_entry_module_only / skip_asm_dep_codegen：dep 符号由并列 *.o 提供，勿 co-emit 进 entry 的 C/asm。 */
  if (skip_asm_dep_codegen != 0)
    return 0;
  if (dep_mod && pipeline_module_num_funcs(dep_mod) > 0) {
    if (use_asm_backend != 0) {
      if (skip_asm_dep_codegen == 0 &&
          asm_asm_codegen_ast(dep_mod, pipeline_dep_ctx_arena_at(ctx, dep_j), out_buf, ctx) != 0) {
        if (link_abi_getenv("XLANG_DEBUG_PIPE"))
          fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] dep emit asm fail j=%d path=%s\n", (int)dep_j,
                  (char *)dep_path_buf);
        return -6;
      }
    } else if (codegen_codegen_x_ast(dep_mod, pipeline_dep_ctx_arena_at(ctx, dep_j), out_buf, ctx, dep_j) != 0) {
      if (link_abi_getenv("XLANG_DEBUG_PIPE")) {
        /* PLATFORM: SHARED — use codegen_out_buf_len (offset ABI); field name is length
         * (wave382) not len; direct out_buf->len fails when compiling against seed pipeline_gen. */
        fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] dep emit c fail j=%d path=%s last_func_idx=%d out_len=%zu\n",
                (int)dep_j, (char *)dep_path_buf, (int)ctx->current_func_index,
                (size_t)codegen_out_buf_len(out_buf));
      }
      return -6;
    }
  }
  return 0;
}

/**
 * entry module 最终 codegen emit；C glue（asm_asm_codegen_ast / codegen_codegen_x_ast 深栈保留 C）。
 */
int32_t run_x_pipeline_codegen_entry_emit(struct ast_Module *module, struct ast_ASTArena *arena,
                                           struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx,
                                           int32_t use_asm_backend) {
  if (!module || !arena || !out_buf || !ctx)
    return -1;
  if (use_asm_backend != 0) {
    if (asm_asm_codegen_ast(module, arena, out_buf, ctx) != 0)
      return -6;
  } else if (codegen_codegen_x_ast(module, arena, out_buf, ctx, -1) != 0) {
    return -6;
  }
  return 0;
}

extern int32_t driver_skip_codegen_dep_0_get(void);
extern void driver_set_current_dep_path_for_codegen(uint8_t *path);
extern void driver_diagnostic_entry_already(int32_t v);
extern void driver_diagnostic_after_entry_parse(int32_t num_funcs);
extern void driver_diagnostic_entry_module(struct ast_Module *module, struct ast_ASTArena *arena);
extern int32_t pipeline_dep_ctx_entry_already_parsed(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern void pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *path, int32_t len);
extern void pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx *ctx, int32_t dep_j, uint8_t *dst);

/** entry parse 薄编排 C glue（EMIT_HEAVY 勿 X let init CALL）。 */
int32_t run_x_pipeline_parse_entry_if_needed_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                uint8_t *source_data, size_t source_len,
                                                struct ast_PipelineDepCtx *ctx) {
  if (!module || !arena || !ctx)
    return -1;
  driver_diagnostic_entry_already(pipeline_dep_ctx_entry_already_parsed(ctx));
  if (pipeline_dep_ctx_entry_already_parsed(ctx) != 0) {
    driver_diagnostic_after_entry_parse(pipeline_module_num_funcs(module));
    driver_diagnostic_entry_module(module, arena);
    return 0;
  }
  return run_x_pipeline_parse_entry_do_parse_c(module, arena, source_data, source_len, ctx);
}

/** dep 路径 buf 非空时写入 ctx import_path；C glue（X u8[128] 栈后单点 set）。 */
int32_t pipeline_fill_dep_import_path_from_buf_c(struct ast_PipelineDepCtx *ctx, int32_t dep_j, uint8_t *path_buf) {
  int32_t path_len = 0;

  if (!ctx || !path_buf || dep_j < 0)
    return -1;
  /* wave584 Cap residual: scan ≤127 (dep_path_rows content). */
  while (path_len < 127 && path_buf[path_len] != 0)
    path_len = path_len + 1;
  if (path_len > 0)
    pipeline_dep_ctx_set_import_path(ctx, dep_j, path_buf, path_len);
  return 0;
}

/**
 * 扫描 buf 长度后 resolve_path_x；C glue（X 栈 path + assign CALL emit 失败）。
 * wave584: scan width 64→127.
 */
int32_t pipeline_resolve_path_x_from_buf64_c(struct ast_PipelineDepCtx *ctx, uint8_t *path_buf) {
  int32_t path_len = 0;

  if (!ctx || !path_buf)
    return -1;
  while (path_len < 127 && path_buf[path_len] != 0)
    path_len = path_len + 1;
  if (path_len <= 0)
    return -1;
  return pipeline_resolve_path_x(ctx, path_buf, path_len);
}

/**
 * dep import 路径补全；C glue。
 *
 * 【Why 根源】旧实现无条件用 entry import[dep_j] 覆写 ctx path。
 *   闭包 seed 时 dep_j 是 BFS 下标（0=driver, 1=core…），entry 仅有
 *   import[0]=net、import[1]=driver → path 被冲成 net/driver，module 仍为
 *   driver/core。后果：j=0 被 link_only(std.net) 跳过、core 以 driver 前缀
 *   co-emit（std_io_driver_xlang_io_*）→ run-net 缺 xlang_io_submit_*_batch。
 * 【Invariant】ctx 槽 path 已设（plen>0）则保留闭包权威；仅空槽才从 entry 补。
 * PLATFORM: SHARED.
 */
int32_t run_x_pipeline_fill_dep_import_path_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx,
                                                int32_t dep_j) {
  uint8_t path_buf[128];
  int32_t path_len;
  int32_t existing;

  if (!module || !ctx || dep_j < 0)
    return -1;
  existing = pipeline_dep_ctx_import_path_len(ctx, dep_j);
  if (existing > 0)
    return 0;
  memset(path_buf, 0, sizeof(path_buf));
  (void)parser_copy_module_import_path64(module, dep_j, path_buf);
  path_len = 0;
  /* wave584 Cap residual: scan ≤127 (path_buf[128] / dep row). */
  while (path_len < 127 && path_buf[path_len] != 0)
    path_len = path_len + 1;
  if (path_len > 0)
    pipeline_dep_ctx_set_import_path(ctx, dep_j, path_buf, path_len);
  return 0;
}

/** codegen 前设置 dep 符号前缀；C glue。 */
int32_t pipeline_prepare_dep_codegen_path_c(struct ast_PipelineDepCtx *ctx, int32_t dep_j, uint8_t *dst) {
  if (!ctx || !dst || dep_j < 0)
    return -1;
  pipeline_dep_ctx_import_path_copy64(ctx, dep_j, dst);
  driver_set_current_dep_path_for_codegen(dst);
  return 0;
}

/** dep codegen 后清理前缀并打诊断；C glue。 */
int32_t pipeline_finish_dep_codegen_diag_c(int32_t dep_j, struct codegen_CodegenOutBuf *out_buf) {
  if (!out_buf)
    return -1;
  /* PLATFORM: SHARED — length via codegen_out_buf_len (seed field name: length). */
  driver_diagnostic_after_dep_codegen(dep_j, codegen_out_buf_len(out_buf));
  driver_set_current_dep_path_for_codegen(NULL);
  return 0;
}

/** 单 dep codegen 编排；C glue。 */
int32_t run_x_pipeline_codegen_one_dep_c(struct ast_Module *module, struct codegen_CodegenOutBuf *out_buf,
                                          struct ast_PipelineDepCtx *ctx, int32_t dep_j,
                                          int32_t skip_asm_dep_codegen) {
  uint8_t dep_path_buf[128];
  struct ast_Module *dep_mod;
  int32_t use_asm;

  if (!module || !out_buf || !ctx || dep_j < 0)
    return -1;
  if (dep_j == 0 && driver_skip_codegen_dep_0_get() != 0)
    return 0;
  if (run_x_pipeline_fill_dep_import_path_c(module, ctx, dep_j) != 0)
    return -1;
  memset(dep_path_buf, 0, sizeof(dep_path_buf));
  pipeline_prepare_dep_codegen_path_c(ctx, dep_j, dep_path_buf);
  dep_mod = pipeline_dep_ctx_module_at(ctx, dep_j);
  /*
   * wave578 Cap residual (Ubuntu L2): after name[64]→[128], DepCtx sidecar
   * module_at can be NULL at codegen while driver_dep_module_buf still holds the
   * pre-parsed dep (parse_set_main_from_buf saw num_funcs>0). Same pattern as
   * load_and_sync closure rebind (ast_pool ~7486): rebind from driver publish
   * slots via this TU's set_module (G.7 single sidecar authority).
   * PLATFORM: SHARED — mac L2 stayed green (sidecar hit); Ubuntu gold exposed NULL.
   */
  if (!dep_mod) {
    int32_t sync_slot = driver_dep_slot_for_path(dep_path_buf);
    if (sync_slot < 0)
      sync_slot = dep_j;
    dep_mod = (struct ast_Module *)driver_dep_module_buf(sync_slot);
    if (dep_mod) {
      pipeline_dep_ctx_set_module(ctx, dep_j, dep_mod);
      pipeline_dep_ctx_set_arena(ctx, dep_j, (struct ast_ASTArena *)driver_dep_arena_buf(sync_slot));
      if (link_abi_getenv("XLANG_DEBUG_PIPE"))
        fprintf(stderr,
                "xlang: [XLANG_DEBUG_PIPE] rebind dep j=%d path=%s slot=%d funcs=%d\n",
                (int)dep_j, (char *)dep_path_buf, (int)sync_slot,
                (int)pipeline_module_num_funcs(dep_mod));
    }
  }
  if (link_abi_getenv("XLANG_DEBUG_PIPE"))
    fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] dep codegen j=%d path=%s funcs=%d\n", (int)dep_j,
            (char *)dep_path_buf, dep_mod ? (int)pipeline_module_num_funcs(dep_mod) : -1);
  /** bootstrap partial：前端模块勿整库 C emit（符号由 *_x.o 提供）。 */
  if (pipeline_codegen_dep_skip_x_bootstrap_partial(dep_path_buf) != 0) {
    if (link_abi_getenv("XLANG_DEBUG_PIPE"))
      fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] skip dep codegen j=%d path=%s\n", (int)dep_j,
              (char *)dep_path_buf);
    driver_set_current_dep_path_for_codegen(NULL);
    return 0;
  }
  use_asm = pipeline_dep_ctx_use_asm_backend(ctx);
  if (run_x_pipeline_codegen_one_dep_emit(dep_mod, out_buf, ctx, dep_j, skip_asm_dep_codegen, use_asm) != 0) {
    driver_diagnostic_codegen_fail(dep_j, 1);
    return -6;
  }
  pipeline_finish_dep_codegen_diag_c(dep_j, out_buf);
  return 0;
}

static int32_t pipeline_dep_ctx_has_earlier_same_import_path_c(struct ast_PipelineDepCtx *ctx, int32_t dep_j) {
  int32_t path_len;
  int32_t prev_j;
  uint8_t path_buf[128];

  if (!ctx || dep_j <= 0)
    return 0;
  path_len = pipeline_dep_ctx_import_path_len(ctx, dep_j);
  if (path_len <= 0 || path_len > (int32_t)sizeof(path_buf))
    return 0;
  memset(path_buf, 0, sizeof(path_buf));
  pipeline_dep_ctx_import_path_copy64(ctx, dep_j, path_buf);
  prev_j = 0;
  while (prev_j < dep_j) {
    int32_t prev_len = pipeline_dep_ctx_import_path_len(ctx, prev_j);
    uint8_t prev_buf[128];
    if (prev_len == path_len && prev_len > 0 && prev_len <= (int32_t)sizeof(prev_buf)) {
      memset(prev_buf, 0, sizeof(prev_buf));
      pipeline_dep_ctx_import_path_copy64(ctx, prev_j, prev_buf);
      if (memcmp(prev_buf, path_buf, (size_t)path_len) == 0)
        return 1;
    }
    prev_j = prev_j + 1;
  }
  return 0;
}

/** 各 dep codegen while 循环；C glue。 */
void pipeline_codegen_c_file_prologue_done_reset(void);

/** entry arena：dep 先于 entry emit，跨模块泛型 mono 须扫 entry 上 CALL。 */
static struct ast_ASTArena *g_codegen_entry_arena_for_mono;
struct ast_ASTArena *pipeline_codegen_entry_arena_for_mono_get(void) {
  return g_codegen_entry_arena_for_mono;
}

int32_t run_x_pipeline_codegen_deps_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                       struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx,
                                       int32_t skip_asm_dep_codegen) {
  int32_t ndep;
  int32_t j;

  if (!module || !arena || !out_buf || !ctx)
    return -1;
  g_codegen_entry_arena_for_mono = arena;
  /* 新一轮 -E/-o codegen：允许首个 codegen_x_ast 写 prologue。 */
  pipeline_codegen_c_file_prologue_done_reset();
  ndep = pipeline_dep_ctx_ndep(ctx);
  j = 0;
  while (j < ndep) {
    if (pipeline_dep_ctx_has_earlier_same_import_path_c(ctx, j) != 0) {
      if (link_abi_getenv("XLANG_DEBUG_PIPE")) {
        uint8_t dup_path_buf[128];
        memset(dup_path_buf, 0, sizeof(dup_path_buf));
        pipeline_dep_ctx_import_path_copy64(ctx, j, dup_path_buf);
        fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] skip duplicate dep codegen j=%d path=%s\n", (int)j,
                (char *)dup_path_buf);
      }
      j = j + 1;
      continue;
    }
    if (run_x_pipeline_codegen_one_dep_c(module, out_buf, ctx, j, skip_asm_dep_codegen) != 0)
      return -6;
    j = j + 1;
  }
  return 0;
}

/** entry module 最终 codegen 编排；C glue。 */
int32_t run_x_pipeline_codegen_entry_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                         struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx) {
  if (!module || !arena || !out_buf || !ctx)
    return -1;
  driver_diagnostic_entry_module(module, arena);
  if (run_x_pipeline_codegen_entry_emit(module, arena, out_buf, ctx,
                                         pipeline_dep_ctx_use_asm_backend(ctx)) != 0) {
    driver_diagnostic_codegen_fail(0, 0);
    return -6;
  }
  return 0;
}
