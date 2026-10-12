/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X /* reopen wave178 FROM_X after leftover-PE sret */

/*
 * wave224 cold twins: typeck_active module BSS (G.7 pure leave).
 * Working freestanding BSS twin of pure g_typeck_active_module.
 * Hybrid product links pure; cold seed keeps local static under #ifndef FROM_X.
 * PLATFORM: SHARED freestanding typeck active-module cell.
 */
/* XLANG_PABI_TYPECK_ACTIVE_THIN_BEGIN */
static void *g_wave224_typeck_active_module = 0;

void *pipeline_typeck_active_module_c(void) {
  return g_wave224_typeck_active_module;
}
void pipeline_typeck_active_module_set_c(void *m) {
  g_wave224_typeck_active_module = m;
}
/* XLANG_PABI_TYPECK_ACTIVE_THIN_END */

/*
 * wave261 cold twins: glue_statics Cap residual pure leave.
 * Working freestanding twins of pure glue_asm_ctx_set_scope_block +
 * glue_block_body_bind_module_dep_from_ctx. Hybrid product links pure;
 * cold seed keeps bodies under #ifndef FROM_X (scope process-local cell via
 * wave221 cold twin; module/dep via wave222 cold twins; per-ctx sidecar via
 * extern asm_ctx_set_scope_block residual).
 * M2 Class E: .x thin leave = runtime_pipeline_abi_glue_statics_thin.x
 * (wave295 C→.x via -E+$CC inject; was wave261 C thin).
 * PLATFORM: SHARED freestanding emit Cap bridges.
 */
/* XLANG_PABI_GLUE_STATICS_THIN_BEGIN */
extern void asm_ctx_set_scope_block(void *ctx, int32_t block_ref);
extern void *pipeline_asm_ctx_layout(void *ctx);
/* wave221/222 cold twins provide these process-local cells when pure absent. */
extern void pipeline_asm_emit_ctx_scope_block_set(int32_t block_ref);
extern void pipeline_asm_emit_ctx_module_set(void *m);
extern void pipeline_asm_emit_ctx_dep_pipe_set(void *ctx);

void glue_asm_ctx_set_scope_block(void *ctx, int32_t block_ref) {
  pipeline_asm_emit_ctx_scope_block_set(block_ref);
  asm_ctx_set_scope_block(ctx, block_ref);
}

void glue_block_body_bind_module_dep_from_ctx(void *ctx) {
  uint8_t *ly;
  void *mod;
  void *dep;
  if (!ctx)
    return;
  ly = (uint8_t *)pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return;
  /* LP64: module_ref@16 */
  memcpy(&mod, ly + 16, sizeof(void *));
  if (mod)
    pipeline_asm_emit_ctx_module_set(mod);
  /* LP64: dep_pipe@1384 (tail_join_label@1392 - 8) */
  memcpy(&dep, ly + 1384, sizeof(void *));
  if (dep)
    pipeline_asm_emit_ctx_dep_pipe_set(dep);
}
/* XLANG_PABI_GLUE_STATICS_THIN_END */

#endif /* close wave178 FROM_X for leftover-PE type_alias storage unique */
