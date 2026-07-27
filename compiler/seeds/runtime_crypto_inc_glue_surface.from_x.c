/* seeds/runtime_crypto_inc_glue_surface.from_x.c
 * G-02f-141 runtime_crypto_inc_glue R2 thin surface — isomorphic with src/asm/runtime_crypto_inc_glue.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o + seed-rest (-DXLANG_RUNTIME_CRYPTO_INC_GLUE_FROM_X) ld -r
 * Prove: full.x vs this seed → nm IDENTICAL (6 #[no_mangle] + 1 doc_anchor)
 * Mode: thin+rest — .x provides 6 thin wrappers; seed provides 6 _impl functions
 * Cap residual: 6 _impl bridges in runtime_crypto_inc_glue.from_x.c (sha256 block/rotr/ch/maj +
 *   crypto_i32_sub + crypto_rotl32 — pure C arithmetic, no OS calls)
 * Note: doc_anchor has no ast_ prefix — xlang_/crypto_ #[no_mangle] does not trigger ast_ prefix
 *   (only net_ prefix triggers, per wave545-546 discovery)
 * Regen: ./xlang-c -E ... runtime_crypto_inc_glue.x | filter DBG + polish prologue
 */
#include <stdint.h>

extern void xlang_sha256_block_impl(uint32_t *H, const uint8_t *block);
extern uint32_t xlang_sha256_rotr32_impl(uint32_t x, uint32_t n);
extern uint32_t xlang_sha256_ch_impl(uint32_t x, uint32_t y, uint32_t z);
extern uint32_t xlang_sha256_maj_impl(uint32_t x, uint32_t y, uint32_t z);
extern int32_t crypto_i32_sub_impl(int32_t a, int32_t b);
extern uint32_t crypto_rotl32_impl(uint32_t x, uint32_t n);

int32_t runtime_crypto_inc_glue_x_doc_anchor(void) { return 0; }

void xlang_sha256_block(uint32_t *H, uint8_t *block) {
  xlang_sha256_block_impl(H, block);
}

uint32_t xlang_sha256_rotr32(uint32_t x, uint32_t n) {
  return xlang_sha256_rotr32_impl(x, n);
}

uint32_t xlang_sha256_ch(uint32_t x, uint32_t y, uint32_t z) {
  return xlang_sha256_ch_impl(x, y, z);
}

uint32_t xlang_sha256_maj(uint32_t x, uint32_t y, uint32_t z) {
  return xlang_sha256_maj_impl(x, y, z);
}

int32_t crypto_i32_sub_c(int32_t a, int32_t b) {
  return crypto_i32_sub_impl(a, b);
}

uint32_t crypto_rotl32_c(uint32_t x, uint32_t n) {
  return crypto_rotl32_impl(x, n);
}
