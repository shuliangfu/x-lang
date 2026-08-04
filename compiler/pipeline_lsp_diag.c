/* pipeline_lsp_diag.c — LSP 诊断 C glue 域（自 ast_pool.c 抽出）
 *
 * lsp_diag_typeck_after_load_c：load/sync + typeck（typeck 失败 -3）。
 * lsp_diag_parse_entry_buf_c：entry parse（set_main_from_buf 同路径）。
 * lsp_diag_parse_typeck_buf_c／_impl／_thread_fn：LSP 全路径（256MiB pthread 深栈 typeck）。
 * 依赖：lsp_diag_enabled/add*（extern 先于 include）+ pipeline_load_and_sync_* +
 *   pipeline_typeck_parsed_module_c + pipeline_parse_set_main_from_buf_c（先于 include）；
 *   driver_run_on_large_stack_pthread／driver_is_large_stack_thread（extern，本块内声明）。
 * 同 TU #include；公共符号，无先于此 include 的调用方。 */

/** LSP：load/sync + typeck（typeck 失败 -3）；C glue。 */
int32_t lsp_diag_typeck_after_load_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                     struct ast_PipelineDepCtx *ctx) {
  int32_t load_rc;

  if (!module || !arena || !ctx)
    return -1;
  load_rc = pipeline_load_and_sync_direct_import_deps_c(module, arena, ctx);
  if (load_rc != 0)
    return load_rc;
  return pipeline_typeck_parsed_module_c(module, arena, ctx, -3);
}

/** LSP entry parse：与 pipeline_parse_set_main_from_buf 同路径 C glue。 */
int32_t lsp_diag_parse_entry_buf_c(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                                   int32_t source_len) {
  return pipeline_parse_set_main_from_buf_c(module, arena, source_data, source_len);
}

/** C glue 经 pipeline_typeck_parsed_module_c 复用 typeck 分派。 */
extern int32_t pipeline_load_and_sync_direct_import_deps(struct ast_Module *module, struct ast_ASTArena *arena,
                                                         struct ast_PipelineDepCtx *ctx);

/**
 * LSP 全路径 C glue：set_main_c + load/sync + pipeline_typeck_parsed_module_c（typeck 失败 -3）。
 * typeck 深栈：在 256MiB pthread 上执行，避免 Alpine/ARM64 默认栈在 diag 时 SIGSEGV。
 */
extern void driver_run_on_large_stack_pthread(void *(*fn)(void *), void *arg);
extern int driver_is_large_stack_thread(void);

typedef struct LspDiagParseTypeckArgs {
  struct ast_Module *module;
  struct ast_ASTArena *arena;
  uint8_t *source_data;
  int32_t source_len;
  struct ast_PipelineDepCtx *ctx;
  int32_t result;
} LspDiagParseTypeckArgs;

static int32_t lsp_diag_parse_typeck_buf_impl(struct ast_Module *module, struct ast_ASTArena *arena,
                                            uint8_t *source_data, int32_t source_len,
                                            struct ast_PipelineDepCtx *ctx) {
  int32_t parse_rc;
  int32_t load_rc;

  if (!module || !arena || !ctx || !source_data || source_len <= 0)
    return -2;
  parse_rc = pipeline_parse_set_main_from_buf_c(module, arena, source_data, source_len);
  if (parse_rc != 0)
    return parse_rc;
  load_rc = pipeline_load_and_sync_direct_import_deps(module, arena, ctx);
  if (load_rc != 0)
    return load_rc;
  return pipeline_typeck_parsed_module_c(module, arena, ctx, 0 - 3);
}

static void *lsp_diag_parse_typeck_thread_fn(void *arg) {
  LspDiagParseTypeckArgs *a = (LspDiagParseTypeckArgs *)arg;
  a->result = lsp_diag_parse_typeck_buf_impl(a->module, a->arena, a->source_data, a->source_len, a->ctx);
  return NULL;
}

int32_t lsp_diag_parse_typeck_buf_c(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                                    int32_t source_len, struct ast_PipelineDepCtx *ctx) {
  /* LSP 主循环已在 256MiB pthread 内：直接 typeck，避免嵌套大栈分配在 Alpine 上 OOM/SIGSEGV。 */
  if (driver_is_large_stack_thread())
    return lsp_diag_parse_typeck_buf_impl(module, arena, source_data, source_len, ctx);
  LspDiagParseTypeckArgs args;
  args.module = module;
  args.arena = arena;
  args.source_data = source_data;
  args.source_len = source_len;
  args.ctx = ctx;
  args.result = -99;
  driver_run_on_large_stack_pthread(lsp_diag_parse_typeck_thread_fn, &args);
  if (args.result == -99)
    return lsp_diag_parse_typeck_buf_impl(module, arena, source_data, source_len, ctx);
  return args.result;
}
