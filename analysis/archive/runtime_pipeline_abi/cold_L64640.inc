/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
XLANG_WEAK int32_t pipeline_parse_into_buf(struct ast_ASTArena *arena, struct ast_Module *module,
                                           uint8_t *buf, int32_t buf_len) {
  return pipeline_parse_into_buf_impl_c(arena, module, buf, buf_len);
}
XLANG_WEAK int32_t pipeline_load_import_from_disk(struct ast_Module *module, struct ast_ASTArena *arena,
                                                  struct ast_PipelineDepCtx *ctx, int32_t import_idx) {
  return pipeline_load_import_from_disk_impl_c(module, arena, ctx, import_idx);
}
XLANG_WEAK int32_t pipeline_sync_dep_slots_from_driver(struct ast_Module *module,
                                                       struct ast_PipelineDepCtx *ctx) {
  return pipeline_sync_dep_slots_from_driver_impl_c(module, ctx);
}
XLANG_WEAK int32_t pipeline_resolve_path_x(struct ast_PipelineDepCtx *ctx, uint8_t *import_path,
                                           int32_t path_len) {
  return pipeline_resolve_path_x_impl_c(ctx, import_path, path_len);
}
/* pipeline_read_file_x cold twin already defined earlier in this seed (~4212). */
/* wave308: pipeline_parse_into_with_init_buf Cap face is ALWAYS above (not cold-only). */
/* M2 Class E: .x thin leave = runtime_pipeline_abi_import_heap_thin.x
 * (wave298 C→.x via -E+$CC; was C strong overlay). Seed WEAK fallback below. */
XLANG_WEAK int32_t pipeline_load_import_from_disk_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    struct ast_PipelineDepCtx *ctx, int32_t import_idx) {
  return pipeline_load_import_from_disk(module, arena, ctx, import_idx);
}
XLANG_WEAK int32_t pipeline_sync_dep_slots_from_driver_c(struct ast_Module *module,
                                                         struct ast_PipelineDepCtx *ctx) {
  return pipeline_sync_dep_slots_from_driver(module, ctx);
}
XLANG_WEAK size_t pipeline_sizeof_arena(void) { return W284_ARENA_SZ; }
XLANG_WEAK size_t pipeline_sizeof_module(void) { return W284_MODULE_SZ; }
