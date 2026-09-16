/*
 * Thin pure: wave261 glue_statics Cap bridges.
 * G.7: bodies match mega runtime_pipeline_abi.x wave261 leave /
 * seeds/runtime_pipeline_abi.from_x.c cold twins.
 *
 * Independent C thin (Darwin additive-leaf rule): do not grow prior named-BSS
 * emit_ctx C leaves. These faces are function bodies only (no new BSS cells).
 *
 *   glue_asm_ctx_set_scope_block
 *   glue_block_body_bind_module_dep_from_ctx
 *
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED freestanding emit · LP64 module_ref@16 / dep_pipe@1384.
 */

#include <stdint.h>
#include <string.h>

/* Per-ctx sidecar + layout helpers live in host residual / other leaves. */
extern void asm_ctx_set_scope_block(void *ctx, int32_t block_ref);
extern void *pipeline_asm_ctx_layout(void *ctx);
/* Process-local cells: wave221 scope_block + wave222 module/dep_pipe. */
extern void pipeline_asm_emit_ctx_scope_block_set(int32_t block_ref);
extern void pipeline_asm_emit_ctx_module_set(void *m);
extern void pipeline_asm_emit_ctx_dep_pipe_set(void *ctx);

/**
 * Set process-local emit scope block + per-ctx sidecar scope_block_ref.
 * PLATFORM: SHARED freestanding emit scope bookkeeping.
 */
void glue_asm_ctx_set_scope_block(void *ctx, int32_t block_ref) {
  pipeline_asm_emit_ctx_scope_block_set(block_ref);
  asm_ctx_set_scope_block(ctx, block_ref);
}

/**
 * Bind process-local emit module + dep_pipe from AsmFuncCtx layout fields.
 * LP64: module_ref@16 / dep_pipe@1384 (tail_join_label@1392 - 8).
 * PLATFORM: SHARED freestanding emit Cap bridge.
 */
void glue_block_body_bind_module_dep_from_ctx(void *ctx) {
  uint8_t *ly;
  void *mod;
  void *dep;
  if (!ctx) {
    return;
  }
  ly = (uint8_t *)pipeline_asm_ctx_layout(ctx);
  if (!ly) {
    return;
  }
  memcpy(&mod, ly + 16, sizeof(void *));
  if (mod) {
    pipeline_asm_emit_ctx_module_set(mod);
  }
  memcpy(&dep, ly + 1384, sizeof(void *));
  if (dep) {
    pipeline_asm_emit_ctx_dep_pipe_set(dep);
  }
}
