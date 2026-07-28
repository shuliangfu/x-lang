/* seeds/backend_seed_mega_fallback_surface.from_x.c
 * G-02f-80 backend_seed_mega_fallback R2 DIRECT surface - isomorphic with src/asm/backend_seed_mega_fallback.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/backend_seed_mega_fallback.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (2 #[no_mangle] + 3 helper + 1 doc_anchor)
 * Mode: DIRECT - 2 #[no_mangle] (pipeline_seed_mega_ctx_reset + pipeline_dep_ctx_target_arch_local)
 *   + 3 non-no_mangle helpers (mega_load_i32_le + mega_store_i32_le + mega_store_ptr_le)
 * Cap residual: memset + pipeline_dep_ctx_target_arch (extern bridges, not #[no_mangle])
 * doc_anchor backend_seed_mega_fallback_x_doc_anchor (no ast_; no module prefix on doc_anchor).
 * Note: mega_/pipeline_ prefix not trigger ast_ (confirmed wave545+).
 * Module prefix: .x export function (no #[no_mangle]) gets backend_seed_mega_fallback_ prefix.
 * Logic: 2 DIRECT + 3 helper. seed 全守卫 #ifndef XLANG_BACKEND_SEED_MEGA_FALLBACK_FROM_X.
 * Regen: ./xlang-c -E ... backend_seed_mega_fallback.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

/* extern bridges — .x declares memset with i32 n; C ABI compatible via zero-extend */
extern void *memset(void *p, int c, size_t n);
extern int32_t pipeline_dep_ctx_target_arch(uint8_t *ctx);

int32_t backend_seed_mega_fallback_x_doc_anchor(void) { return 0; }

/* === 3 helper functions (export function, no #[no_mangle] → module prefix backend_seed_mega_fallback_) === */

int32_t backend_seed_mega_fallback_mega_load_i32_le(uint8_t *p, int32_t off) {
  if (p == 0) { return 0; }
  int32_t m = 256;
  int32_t a = (int32_t)p[off];
  a = a + (int32_t)p[off + 1] * m;
  a = a + (int32_t)p[off + 2] * (m * m);
  a = a + (int32_t)p[off + 3] * (m * m * m);
  return a;
}

void backend_seed_mega_fallback_mega_store_i32_le(uint8_t *p, int32_t off, int32_t v) {
  if (p == 0) { return; }
  uint32_t u = (uint32_t)v;
  p[off] = (uint8_t)(u & 255u);
  p[off + 1] = (uint8_t)((u / 256u) & 255u);
  p[off + 2] = (uint8_t)((u / 65536u) & 255u);
  p[off + 3] = (uint8_t)((u / 16777216u) & 255u);
}

void backend_seed_mega_fallback_mega_store_ptr_le(uint8_t *p, int32_t off, uint8_t *val) {
  if (p == 0) { return; }
  uintptr_t a = (uintptr_t)val;
  uintptr_t m = 256;
  p[off + 0] = (uint8_t)(a % m);
  a = a / m;
  p[off + 1] = (uint8_t)(a % m);
  a = a / m;
  p[off + 2] = (uint8_t)(a % m);
  a = a / m;
  p[off + 3] = (uint8_t)(a % m);
  a = a / m;
  p[off + 4] = (uint8_t)(a % m);
  a = a / m;
  p[off + 5] = (uint8_t)(a % m);
  a = a / m;
  p[off + 6] = (uint8_t)(a % m);
  a = a / m;
  p[off + 7] = (uint8_t)(a % m);
}

/* === 2 #[no_mangle] DIRECT functions === */

void pipeline_seed_mega_ctx_reset(uint8_t *ctx, uint8_t *mod) {
  if (ctx == 0) { return; }
  int32_t label_counter = backend_seed_mega_fallback_mega_load_i32_le(ctx, 12);
  /* sizeof(pipeline_glue_AsmFuncCtxLayout) = 1336 */
  memset(ctx, 0, 1336);
  backend_seed_mega_fallback_mega_store_i32_le(ctx, 12, label_counter);
  backend_seed_mega_fallback_mega_store_ptr_le(ctx, 16, mod);
}

int32_t pipeline_dep_ctx_target_arch_local(uint8_t *ctx) {
  if (ctx == 0) { return 0; }
  return pipeline_dep_ctx_target_arch(ctx);
}
