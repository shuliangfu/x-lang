/*
 * DIG s231: host-cc twin for emit_ctx module/dep_pipe get/set (SHARED).
 *
 * TipU bodies in runtime_pipeline_abi_emit_ctx_module_dep_thin.x allocate
 * ~0x868 frames and never touch BSS: module_get returns 0, set writes stack
 * only, dep_pipe_get returns uninitialized stack. That feeds
 * pipe_local_slot_bytes_mod → pipeline_dep_ctx_ndep(truncated/garbage) →
 * tip -c struct let SEGV in pipe_load_i32_le.
 *
 * Soft Cap: host-cc BSS + get/set first-wins (same names as .x). Matches
 * wave222 leave semantics. PLATFORM: SHARED.
 */
#include <stdint.h>

/* BSS: same symbol names as tip .x so set/get share one cell. */
uint8_t *g_pipeline_asm_emit_module = 0;
uint8_t *g_pipeline_asm_emit_dep_pipe = 0;

/**
 * Return current asm emit module pointer (ast_Module* as *u8).
 */
uint8_t *pipeline_asm_emit_ctx_module_get(void) {
  return g_pipeline_asm_emit_module;
}

/**
 * Store current asm emit module pointer.
 * @param m may be null
 */
void pipeline_asm_emit_ctx_module_set(uint8_t *m) {
  g_pipeline_asm_emit_module = m;
}

/**
 * Return current asm emit dep pipe (ast_PipelineDepCtx* as *u8).
 */
uint8_t *pipeline_asm_emit_ctx_dep_pipe_get(void) {
  return g_pipeline_asm_emit_dep_pipe;
}

/**
 * Store current asm emit dep pipe pointer.
 * @param ctx may be null
 */
void pipeline_asm_emit_ctx_dep_pipe_set(uint8_t *ctx) {
  g_pipeline_asm_emit_dep_pipe = ctx;
}
