/* ============================================================================
 * pipeline_scratch_bufs.c — codegen path/prefix scratch buffers
 *
 * wave1279 BC 8.3.2 G.7 same-TU domain fold from ast_pool.c:
 *   g_scratch64/128/256 pools + pipeline_scratch_buf{64,96,128,256}(+_slot)
 *
 * Used by codegen.x to avoid `u8[N] = []` emitting ExprKind=-1 under asm backend.
 * Pure leaf: no dependency on other ast_pool domains beyond stdint.
 * Included from ast_pool.c after pipeline_elf_ctx.c and before type_to_c domain.
 * Not a separate .o — textually #include'd into pipeline_glue / pipeline_x.
 *
 * PLATFORM: SHARED — host-cc residual; G.7 single authority.
 * ============================================================================ */

/** codegen.x: path/prefix scratch (avoid `u8[64] = []` ExprKind=-1 under asm emit). */
static uint8_t g_scratch64[4][128];
static uint8_t g_scratch128[2][128];
static uint8_t g_scratch256[2][256];

uint8_t *pipeline_scratch_buf64(void) {
  return g_scratch64[0];
}

uint8_t *pipeline_scratch_buf64_slot(int32_t slot) {
  if (slot < 0 || slot >= 4)
    return g_scratch64[0];
  return g_scratch64[slot];
}

uint8_t *pipeline_scratch_buf128(void) {
  return g_scratch128[0];
}

uint8_t *pipeline_scratch_buf128_slot(int32_t slot) {
  if (slot < 0 || slot >= 2)
    return g_scratch128[0];
  return g_scratch128[slot];
}

uint8_t *pipeline_scratch_buf96(void) {
  static uint8_t s[96];
  return s;
}

uint8_t *pipeline_scratch_buf256(void) {
  return g_scratch256[0];
}

uint8_t *pipeline_scratch_buf256_slot(int32_t slot) {
  if (slot < 0 || slot >= 2)
    return g_scratch256[0];
  return g_scratch256[slot];
}
