/* PLATFORM: SHARED — pure-asm formal vehicle for std/compress (class-batch 2).
 *
 * Why C face: .x monofile co-emits bare deflate/inflate that conflict with zlib
 * C API types in the same TU. Product body stays in mod.x + submodules (C path).
 * This vehicle only exports std_compress_* with unavailable semantics (return -1),
 * matching product when codecs are not linked (tests/compress/main.x allows n<=0).
 *
 * G.7: single formal vehicle for pure-asm product link (catalog key
 * std/compress/compress.o). formal_mod kind=c_face.
 */
#include <stdint.h>

int32_t std_compress_gzip_compress(uint8_t *in, int32_t in_len, uint8_t *out, int32_t out_cap) {
  (void)in;
  (void)in_len;
  (void)out;
  (void)out_cap;
  return -1;
}

int32_t std_compress_gzip_decompress(uint8_t *in, int32_t in_len, uint8_t *out, int32_t out_cap) {
  (void)in;
  (void)in_len;
  (void)out;
  (void)out_cap;
  return -1;
}

int32_t std_compress_brotli_compress(uint8_t *in, int32_t in_len, uint8_t *out, int32_t out_cap) {
  (void)in;
  (void)in_len;
  (void)out;
  (void)out_cap;
  return -1;
}

int32_t std_compress_brotli_decompress(uint8_t *in, int32_t in_len, uint8_t *out, int32_t out_cap) {
  (void)in;
  (void)in_len;
  (void)out;
  (void)out_cap;
  return -1;
}

int32_t std_compress_zstd_compress(uint8_t *in, int32_t in_len, uint8_t *out, int32_t out_cap) {
  (void)in;
  (void)in_len;
  (void)out;
  (void)out_cap;
  return -1;
}

int32_t std_compress_zstd_decompress(uint8_t *in, int32_t in_len, uint8_t *out, int32_t out_cap) {
  (void)in;
  (void)in_len;
  (void)out;
  (void)out_cap;
  return -1;
}
