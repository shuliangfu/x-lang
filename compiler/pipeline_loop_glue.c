/* pipeline_loop_glue.c — pipeline 有界循环谓词 + dep prepare glue 域（自 ast_pool.c 抽出）
 *
 * pipeline_loop_should_continue_ndep／imports／lib_root：X while 裸 CALL 条件（勿 CALL==0 比较 emit 失败）。
 * pipeline_loop_index_at_or_beyond_ndep／imports：X 用 if(CALL!=0) 循环 exit。
 * pipeline_load_and_sync_set_ndep_from_module：import 循环结束后写 ndep（勿 X stmt 内嵌双 CALL）。
 * run_x_pipeline_codegen_one_dep_prepare：one_dep codegen 前 prepare path prefix（X 侧 u8[64] 栈数组）。
 * 依赖：pipeline_dep_ctx_ndep／set_ndep + parser_get_module_num_imports + pipeline_ctx_lib_root_count +
 *   pipeline_prepare_dep_codegen_path_c（codegen_dep.c，先于此 include）。同 TU #include；公共符号。 */

/**
 * 有界循环 continue：idx < ndep 时返回 1（X while 裸 CALL 条件，勿 CALL==0 比较 emit 失败）。
 */
int32_t pipeline_loop_should_continue_ndep_c(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  if (!ctx)
    return 0;
  return idx < pipeline_dep_ctx_ndep(ctx) ? 1 : 0;
}

/**
 * 有界 import 循环 continue：idx < num_imports 时返回 1。
 */
int32_t pipeline_loop_should_continue_imports_c(struct ast_Module *module, int32_t idx) {
  if (!module)
    return 0;
  return idx < parser_get_module_num_imports(module) ? 1 : 0;
}

/**
 * 有界 lib_root 循环 continue：idx < lib_root_count 时返回 1（resolve_path_x X while）。
 */
int32_t pipeline_loop_should_continue_lib_root_c(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  if (!ctx)
    return 0;
  return idx < pipeline_ctx_lib_root_count(ctx) ? 1 : 0;
}

/**
 * 有界循环 exit：idx >= ndep 时返回 1（X 用 if(CALL!=0)，勿 idx>=ndep(ctx) 比较 emit 失败）。
 */
int32_t pipeline_loop_index_at_or_beyond_ndep_c(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  if (!ctx)
    return 1;
  return idx >= pipeline_dep_ctx_ndep(ctx) ? 1 : 0;
}

/**
 * 有界 import 循环 exit：idx >= num_imports 时返回 1。
 */
int32_t pipeline_loop_index_at_or_beyond_imports_c(struct ast_Module *module, int32_t idx) {
  if (!module)
    return 1;
  return idx >= parser_get_module_num_imports(module) ? 1 : 0;
}

/** load_and_sync import 循环结束后写 ndep；C glue（勿 X stmt 内嵌双 CALL）。 */
void pipeline_load_and_sync_set_ndep_from_module_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx) {
  if (module && ctx)
    pipeline_dep_ctx_set_ndep(ctx, parser_get_module_num_imports(module));
}

/** one_dep codegen 前 prepare path prefix；C glue（X 侧 u8[64] 栈数组）。 */
int32_t run_x_pipeline_codegen_one_dep_prepare_c(struct ast_PipelineDepCtx *ctx, int32_t dep_j) {
  uint8_t dep_path_buf[128];

  if (!ctx || dep_j < 0)
    return -1;
  memset(dep_path_buf, 0, sizeof(dep_path_buf));
  return pipeline_prepare_dep_codegen_path_c(ctx, dep_j, dep_path_buf);
}
