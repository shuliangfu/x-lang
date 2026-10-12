/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
int32_t typeck_module_entry_only(void *module) {
    if (!module)
        return -1;
    /* No arena/ctx — cannot call typeck_x_ast. Use pipeline_typeck_module_for_ctx. */
    return -1;
}

int32_t typeck_module_with_sidecar(void *module) {
    if (!module)
        return -1;
    /* C sidecar BSS obsolete under X frontend (deps live in PipelineDepCtx). */
    return -1;
}

int32_t pipeline_typeck_module_for_ctx_impl(void *module, void *arena, void *ctx_void) {
    int32_t mi;
    int32_t rc;
    if (!module)
        return -1;
    if (!arena || !ctx_void)
        return -1;
    mi = pipeline_module_main_func_index(module);
    if (mi < 0)
        rc = typeck_x_ast_library(module, arena, ctx_void);
    else
        rc = typeck_x_ast(module, arena, ctx_void);
    if (rc != 0)
        return -1;
    return 0;
}

/* G-02f-242：逻辑源 .x（真迁门闩）；seed 保留同语义 C 供产品 cold */
int32_t pipeline_typeck_module_for_ctx(void *module, void *arena, void *ctx_void) {
  if (module == NULL) {
    return -1;
  }
  {
    return pipeline_typeck_module_for_ctx_impl(module, arena, ctx_void);
  }
  return -1;
}
