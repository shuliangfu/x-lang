/* seeds/runtime_ed25519_ref10_glue_surface.from_x.c
 * G-02f-134 runtime_ed25519_ref10_glue R2 thin surface — isomorphic with src/asm/runtime_ed25519_ref10_glue.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o + seed-rest (-DXLANG_RUNTIME_ED25519_REF10_GLUE_FROM_X) ld -r
 * Prove: full.x vs this seed → nm IDENTICAL (3 #[no_mangle] + 1 doc_anchor)
 * Cap residual: 3 _impl bridges (ed25519_ref10_create_keypair/sign/verify_impl_c) emitted by
 *   .inc files (sha512/fe/ge/sc/keypair/sign/verify + fixedint.h) via macro rename in
 *   runtime_ed25519_ref10_glue.from_x.c rest — pure C with macros, .x-inexpressible
 * Note: #[no_mangle] ensures symbol names match ed25519.x extern declarations (no _c suffix)
 * Regen: ./xlang-c -E ... runtime_ed25519_ref10_glue.x | filter DBG + polish prologue
 */
#include <stdint.h>

extern void ed25519_ref10_create_keypair_impl_c(uint8_t * public_key, uint8_t * private_key, uint8_t * seed);
extern void ed25519_ref10_sign_impl_c(uint8_t * signature, uint8_t * message, uint64_t message_len,
                                       uint8_t * public_key, uint8_t * private_key);
extern int32_t ed25519_ref10_verify_impl_c(uint8_t * signature, uint8_t * message, uint64_t message_len,
                                            uint8_t * public_key);

int32_t runtime_ed25519_ref10_glue_x_doc_anchor(void) { return 0; }

void ed25519_ref10_create_keypair(uint8_t * public_key, uint8_t * private_key, uint8_t * seed) {
  ed25519_ref10_create_keypair_impl_c(public_key, private_key, seed);
}

void ed25519_ref10_sign(uint8_t * signature, uint8_t * message, uint64_t message_len,
                        uint8_t * public_key, uint8_t * private_key) {
  ed25519_ref10_sign_impl_c(signature, message, message_len, public_key, private_key);
}

int32_t ed25519_ref10_verify(uint8_t * signature, uint8_t * message, uint64_t message_len,
                             uint8_t * public_key) {
  return ed25519_ref10_verify_impl_c(signature, message, message_len, public_key);
}
