/* seeds/runtime_compress_zlib_glue_surface.from_x.c
 * G-02f-130 runtime_compress_zlib_glue R2 thin surface — isomorphic with src/asm/runtime_compress_zlib_glue.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o + seed-rest (-DXLANG_RUNTIME_COMPRESS_ZLIB_GLUE_FROM_X) ld -r
 * Prove: full.x vs this seed → nm IDENTICAL (2 #[no_mangle] + 1 doc_anchor)
 * Cap residual: 2 _impl bridges (deflateInit2_impl_c / inflateInit2_impl_c) in
 *   runtime_compress_zlib_glue.from_x.c rest — #include <zlib.h> + #undef macros + call real
 *   deflateInit2_ / inflateInit2_ with ZLIB_VERSION and sizeof(z_stream)
 * Note: #[no_mangle] ensures symbol name is deflateInit2/inflateInit2 (no _c suffix),
 *   matching extern declarations in std/compress/gzip/libz.x
 * Regen: ./xlang-c -E ... runtime_compress_zlib_glue.x | filter DBG + polish prologue
 */
#include <stdint.h>

extern int32_t deflateInit2_impl_c(uint8_t * strm, int32_t level, int32_t method,
                                    int32_t windowBits, int32_t memLevel, int32_t strategy);
extern int32_t inflateInit2_impl_c(uint8_t * strm, int32_t windowBits);

int32_t runtime_compress_zlib_glue_x_doc_anchor(void) { return 0; }

int32_t deflateInit2(uint8_t * strm, int32_t level, int32_t method,
                     int32_t windowBits, int32_t memLevel, int32_t strategy) {
  return deflateInit2_impl_c(strm, level, method, windowBits, memLevel, strategy);
}

int32_t inflateInit2(uint8_t * strm, int32_t windowBits) {
  return inflateInit2_impl_c(strm, windowBits);
}
