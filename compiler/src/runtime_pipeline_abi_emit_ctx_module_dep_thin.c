/*
 * Thin pure: wave222 emit_ctx module + dep_pipe named BSS + get/set.
 * G.7: bodies match mega runtime_pipeline_abi.x wave222 leave.
 *
 * Split from emit_ctx_bss_thin.c (wave220–221) so Darwin can first-wins
 * ingest without re-merging already-strong named data from the prior C thin
 * (Apple ld -r rejects data dups even after weaken; Linux allows multidef).
 *
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED freestanding.
 */

#include <stdint.h>

/* wave222: emit module + dep_pipe cells (canonical names). */
void *g_pipeline_asm_emit_module = 0;
void *g_pipeline_asm_emit_dep_pipe = 0;

/** wave222: get emit module pointer. PLATFORM: SHARED. */
void *pipeline_asm_emit_ctx_module_get(void) {
  return g_pipeline_asm_emit_module;
}

/** wave222: set emit module pointer. PLATFORM: SHARED. */
void pipeline_asm_emit_ctx_module_set(void *m) {
  g_pipeline_asm_emit_module = m;
}

/** wave222: get emit dep pipe pointer. PLATFORM: SHARED. */
void *pipeline_asm_emit_ctx_dep_pipe_get(void) {
  return g_pipeline_asm_emit_dep_pipe;
}

/** wave222: set emit dep pipe pointer. PLATFORM: SHARED. */
void pipeline_asm_emit_ctx_dep_pipe_set(void *ctx) {
  g_pipeline_asm_emit_dep_pipe = ctx;
}
