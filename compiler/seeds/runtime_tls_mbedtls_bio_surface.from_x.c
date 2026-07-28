/* seeds/runtime_tls_mbedtls_bio_surface.from_x.c
 * G-02f-133 runtime_tls_mbedtls_bio R2 thin surface — isomorphic with src/asm/runtime_tls_mbedtls_bio.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o + seed-rest (-DXLANG_RUNTIME_TLS_MBEDTLS_BIO_FROM_X) ld -r
 * Prove: full.x vs this seed → nm IDENTICAL (2 #[no_mangle] + 1 doc_anchor)
 * Cap residual: 2 _impl bridges (xlang_mbedtls_bio_send_impl / _recv_impl) in
 *   runtime_tls_mbedtls_bio.from_x.c rest — mbedtls SSL context callback dispatch
 * Regen: ./xlang-c -E ... runtime_tls_mbedtls_bio.x | filter DBG + polish prologue
 */
#include <stdint.h>

extern int32_t xlang_mbedtls_bio_send_impl(uint8_t * ctx, uint8_t * buf, uint64_t len);
extern int32_t xlang_mbedtls_bio_recv_impl(uint8_t * ctx, uint8_t * buf, uint64_t len);

int32_t runtime_tls_mbedtls_bio_x_doc_anchor(void) { return 0; }

int32_t xlang_mbedtls_bio_send(uint8_t * ctx, uint8_t * buf, uint64_t len) {
  return xlang_mbedtls_bio_send_impl(ctx, buf, len);
}

int32_t xlang_mbedtls_bio_recv(uint8_t * ctx, uint8_t * buf, uint64_t len) {
  return xlang_mbedtls_bio_recv_impl(ctx, buf, len);
}
