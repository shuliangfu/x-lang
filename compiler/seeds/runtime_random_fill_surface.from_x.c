/* seeds/runtime_random_fill_surface.from_x.c
 * G-02f-132 runtime_random_fill R2 thin surface — isomorphic with src/asm/runtime_random_fill.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o + seed-rest (-DXLANG_RUNTIME_RANDOM_FILL_FROM_X) ld -r
 * Prove: full.x vs this seed → nm IDENTICAL (2 #[no_mangle] + 1 doc_anchor)
 * Cap residual: 2 _impl OS bridges (random_get_alg_impl BCrypt handle lazy init +
 *   random_fill_bytes_impl BCryptGenRandom/getrandom/getentropy) in runtime_random_fill.from_x.c rest
 * Regen: ./xlang-c -E ... runtime_random_fill.x | filter DBG + polish prologue
 */
#include <stdint.h>

extern uint8_t * random_get_alg_impl(void);
extern int32_t random_fill_bytes_impl(uint8_t * buf, int32_t len);

int32_t runtime_random_fill_x_doc_anchor(void) { return 0; }

uint8_t * random_get_alg(void) {
  return random_get_alg_impl();
}

int32_t random_fill_bytes_c(uint8_t * buf, int32_t len) {
  if (buf == 0 || len < 0) {
    return -1;
  }
  if (len == 0) {
    return 0;
  }
  return random_fill_bytes_impl(buf, len);
}
