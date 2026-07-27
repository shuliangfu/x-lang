/* seeds/runtime_arrow_simd_glue_surface.from_x.c
 * G-02f-131 runtime_arrow_simd_glue R2 thin surface — isomorphic with src/asm/runtime_arrow_simd_glue.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o + seed-rest (-DXLANG_RUNTIME_ARROW_SIMD_GLUE_FROM_X) ld -r
 * Prove: full.x vs this seed → nm IDENTICAL (4 #[no_mangle] + 1 doc_anchor)
 * Cap residual: 4 _impl bridges (arrow_f32_sum/dot/i32_sum_valid/f32_sum_valid_kernel_impl)
 *   in runtime_arrow_simd_glue.from_x.c rest — SIMD intrinsics require C compiler target attributes
 * Regen: ./xlang-c -E ... runtime_arrow_simd_glue.x | filter DBG + polish prologue
 */
#include <stdint.h>

extern float arrow_f32_sum_kernel_impl(uint8_t * data, int32_t n);
extern float arrow_f32_dot_kernel_impl(uint8_t * a, uint8_t * b, int32_t n);
extern int32_t arrow_i32_sum_valid_kernel_impl(uint8_t * data, uint8_t * bm, int32_t n);
extern float arrow_f32_sum_valid_kernel_impl(uint8_t * data, uint8_t * bm, int32_t n);

int32_t runtime_arrow_simd_glue_x_doc_anchor(void) { return 0; }

float arrow_f32_sum_kernel(uint8_t * data, int32_t n) {
  return arrow_f32_sum_kernel_impl(data, n);
}

float arrow_f32_dot_kernel(uint8_t * a, uint8_t * b, int32_t n) {
  return arrow_f32_dot_kernel_impl(a, b, n);
}

int32_t arrow_i32_sum_valid_kernel(uint8_t * data, uint8_t * bm, int32_t n) {
  return arrow_i32_sum_valid_kernel_impl(data, bm, n);
}

float arrow_f32_sum_valid_kernel(uint8_t * data, uint8_t * bm, int32_t n) {
  return arrow_f32_sum_valid_kernel_impl(data, bm, n);
}
