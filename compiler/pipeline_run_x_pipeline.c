/* pipeline_run_x_pipeline.c — run_x_pipeline core orchestration domain
 * (extracted from ast_pool.c; wave1283 also hosts the public const-buf face).
 *
 * run_x_pipeline_typecheck_entry_c: EMIT_HEAVY typecheck entry C glue.
 * g_run_x_pipeline_last_rc + get/store: last pipeline rc sidecar.
 * pipeline_typeck_fail_return_c / null_fail_return_c: typeck fail mapping.
 * run_x_pipeline_load_deps_after_parse / typecheck_after_load: post-parse.
 * run_x_pipeline_parse_entry_do_parse: parse_into + set_main + diag.
 * run_x_pipeline_typecheck_entry_emit: entry typecheck + codegen emit.
 * pipeline_run_x_pipeline: public runtime face (const buf+len → _impl).
 * Deps: pipeline_typeck_* / parse_* / load_and_sync_* (parse_typeck_dispatch
 * before this include) + pipeline_should_skip_x_typeck. Same-TU #include
 * (after parse_typeck_dispatch, before codegen_dep). Public symbols + static rc.
 * PLATFORM: SHARED — host-cc residual. */

/**
 * run_x_pipeline_impl EMIT_HEAVY：typecheck entry 同模块 CALL asm emit 失败时走 C glue。
 */
int32_t run_x_pipeline_typecheck_entry_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                          struct ast_PipelineDepCtx *ctx) {
  if (!module || !arena || !ctx)
    return -1;
  if (pipeline_should_skip_x_typeck(ctx) != 0)
    return 0;
  return pipeline_typeck_entry_module_c(module, arena, ctx);
}

/**
 * run_x_pipeline_impl EMIT_HEAVY：if(CALL) 路径可 emit，let init CALL 会 tear patch；
 * 最近一次 phase C glue 返回值供 `return run_x_pipeline_last_rc_get()` 使用（避免重复 call）。
 */
static int32_t g_run_x_pipeline_last_rc;

/**
 * typeck 失败统一返回；C glue（X 内 fail_mapped 分支重复 emit 失败）。
 */
int32_t pipeline_typeck_fail_return_c(int32_t fail_mapped) {
  driver_diagnostic_typeck_fail();
  if (fail_mapped != 0)
    return fail_mapped;
  return -1;
}

/**
 * typeck 入口 null 检查失败返回；C glue（与 pipeline_typeck_parsed_module 语义一致）。
 */
int32_t pipeline_typeck_null_fail_return_c(int32_t fail_mapped) {
  if (fail_mapped != 0)
    return fail_mapped;
  return -1;
}

int32_t run_x_pipeline_last_rc_get(void) {
  return g_run_x_pipeline_last_rc;
}

/**
 * EMIT_HEAVY X 编排：写入 last_rc sidecar（避免 let rc=CALL assign tear patch）。
 */
void run_x_pipeline_last_rc_store_c(int32_t rc) {
  g_run_x_pipeline_last_rc = rc;
}

int32_t run_x_pipeline_load_deps_after_parse_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                struct ast_PipelineDepCtx *ctx) {
  g_run_x_pipeline_last_rc = pipeline_load_and_sync_direct_import_deps_c(module, arena, ctx);
  return g_run_x_pipeline_last_rc;
}

int32_t run_x_pipeline_typecheck_after_load_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                               struct ast_PipelineDepCtx *ctx) {
  g_run_x_pipeline_last_rc = run_x_pipeline_typecheck_entry_c(module, arena, ctx);
  return g_run_x_pipeline_last_rc;
}

/* 2026-08-05: pipeline_lsp_diag.c pure-owned leave retired.
 * Live = runtime_pipeline_abi pure lsp_diag_typeck_after_load_c /
 * lsp_diag_parse_entry_buf_c / lsp_diag_parse_typeck_buf_c (+ large-stack thread_fn).
 * parse_orch _impl_c still dispatches to those symbols (no same-TU include). */

/**
 * entry 尚未解析：parse_into_with_init_buf + set_main + 收尾诊断；C glue（scalars 路径）。
 */
int32_t run_x_pipeline_parse_entry_do_parse_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                              uint8_t *source_data, size_t source_len,
                                              struct ast_PipelineDepCtx *ctx) {
  int32_t len_i32 = (int32_t)source_len;
  int32_t parse_rc;

  if (!module || !arena || !ctx)
    return -1;
  driver_diagnostic_source_len(len_i32);
  parse_rc = pipeline_parse_set_main_from_buf_c(module, arena, source_data, len_i32);
  if (parse_rc != 0)
    return parse_rc;
  driver_diagnostic_after_entry_parse(pipeline_module_num_funcs(module));
  extern void driver_diagnostic_after_entry_parse_module(struct ast_Module *module);
  driver_diagnostic_after_entry_parse_module(module);
  driver_diagnostic_entry_module(module, arena);
  return 0;
}

/**
 * entry typeck emit；C glue（skip 判定 + typeck 深栈 + module 字段读）。
 */
extern int32_t pipeline_typeck_dep_prerun_module_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                 struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_entry_module_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                            struct ast_PipelineDepCtx *ctx);
extern int32_t parser_get_module_num_imports(struct ast_Module *module);
int32_t run_x_pipeline_typecheck_entry_emit_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                               struct ast_PipelineDepCtx *ctx) {
  if (!module || !arena || !ctx)
    return -1;
  if (link_abi_getenv("XLANG_DEBUG_PIPE")) {
    fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] typecheck_entry_emit ctx=%p ndep=%d num_funcs=%d\n", (void *)ctx,
            (int)pipeline_dep_ctx_ndep(ctx), (int)pipeline_module_num_funcs(module));
    fflush(stderr);
  }
  /** 优先读 runtime 全局标志（C 预检后 set）；勿仅依赖 X pipeline_should_skip_x_typeck（strict 链 thin bl 偶发失效）。 */
    if (driver_x_pipeline_skip_typeck_get() != 0) {
    /*
     * 用户 asm -o 单文件：runtime 仍设 skip_typeck，但须全量 typeck 填 field_access_offset；
     * build_xlang_asm（XLANG_ASM_BUILD_SKIP_TYPECK）多文件 import 入口仅 dep_prerun；
     * 用户 -o 有 import 时仍须全量 typeck（ERR-01 负例 result_try_bad 等）。
     */
    if (parser_get_module_num_imports(module) == 0 && driver_x_pipeline_skip_codegen_get() != 0)
      return pipeline_typeck_entry_module_c(module, arena, ctx);
    if (pipeline_driver_asm_build_skip_typeck() != 0)
      return pipeline_typeck_dep_prerun_module_c(module, arena, ctx);
    return pipeline_typeck_entry_module_c(module, arena, ctx);
  }
  if (pipeline_should_skip_x_typeck(ctx) != 0)
    return 0;
  return pipeline_typeck_entry_module_c(module, arena, ctx);
}

#ifndef XLANG_PARSER_EXE_PIPELINE_GLUE
/**
 * wave1283 G.7: public C face for runtime.c — (data, len) thin wrapper over
 * pipeline_run_x_pipeline_impl (const source → non-const for parse_into path).
 * Guard matches former glue.c site: omitted from parser.x single-file exe TU.
 * PLATFORM: SHARED — sole external consumer is runtime product path.
 */
extern int32_t pipeline_run_x_pipeline_impl(struct ast_Module *module, struct ast_ASTArena *arena,
                                           uint8_t *source_data, size_t source_len,
                                           struct codegen_CodegenOutBuf *out_buf,
                                           struct ast_PipelineDepCtx *ctx);

int32_t pipeline_run_x_pipeline(struct ast_Module *module, struct ast_ASTArena *arena,
                               const uint8_t *source_data, size_t source_len,
                               struct codegen_CodegenOutBuf *out_buf,
                               struct ast_PipelineDepCtx *ctx) {
  return pipeline_run_x_pipeline_impl(module, arena, (uint8_t *)source_data, source_len, out_buf, ctx);
}
#endif /* !XLANG_PARSER_EXE_PIPELINE_GLUE */
