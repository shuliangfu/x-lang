/* std/simd/formal_surface.c — host-C formal faces for pure-asm import METHOD mid.
 *
 * G.7 authority twin of std/simd/mod.x export mangle (codegen VECTOR = f32x4 / i32x8).
 * Use plain POD arrays (not gcc vector_size) so ABI matches pure-asm SysV MEMORY /
 * stack formals without requiring -mavx (vector_size(32) changes ABI without AVX).
 *
 * PLATFORM: SHARED formal .o for pure-asm link (Ubuntu gold + mac L2).
 * Bodies match mod.x scalar-lane semantics (STD-047).
 */
#include <stdint.h>
#include <string.h>

typedef struct { float v[4]; } f32x4_t;
typedef struct { int32_t v[8]; } i32x8_t;

f32x4_t std_simd_splat_f32(float x) {
  f32x4_t r;
  r.v[0] = r.v[1] = r.v[2] = r.v[3] = x;
  return r;
}

i32x8_t std_simd_splat_i32(int32_t x) {
  i32x8_t r;
  int i;
  for (i = 0; i < 8; i++)
    r.v[i] = x;
  return r;
}

f32x4_t std_simd_shuffle_f32x4_i32_a4(f32x4_t v, int32_t *mask) {
  f32x4_t r;
  int32_t i0 = mask ? mask[0] : 0;
  int32_t i1 = mask ? mask[1] : 0;
  int32_t i2 = mask ? mask[2] : 0;
  int32_t i3 = mask ? mask[3] : 0;
  r.v[0] = v.v[i0 & 3];
  r.v[1] = v.v[i1 & 3];
  r.v[2] = v.v[i2 & 3];
  r.v[3] = v.v[i3 & 3];
  return r;
}

i32x8_t std_simd_shuffle_i32x8_i32_a8(i32x8_t v, int32_t *mask) {
  i32x8_t r;
  int i;
  for (i = 0; i < 8; i++) {
    int32_t idx = mask ? mask[i] : 0;
    r.v[i] = v.v[idx & 7];
  }
  return r;
}

int32_t std_simd_select_lane_i32_i32_i32(int32_t mask_lane, int32_t a_lane, int32_t b_lane) {
  return mask_lane != 0 ? a_lane : b_lane;
}

float std_simd_select_lane_f32_f32_f32(float mask_lane, float a_lane, float b_lane) {
  return mask_lane != 0.0f ? a_lane : b_lane;
}

i32x8_t std_simd_select_i32x8_i32x8_i32x8(i32x8_t mask, i32x8_t a, i32x8_t b) {
  i32x8_t r;
  int i;
  for (i = 0; i < 8; i++)
    r.v[i] = std_simd_select_lane_i32_i32_i32(mask.v[i], a.v[i], b.v[i]);
  return r;
}

f32x4_t std_simd_select_f32x4_f32x4_f32x4(f32x4_t mask, f32x4_t a, f32x4_t b) {
  f32x4_t r;
  r.v[0] = std_simd_select_lane_f32_f32_f32(mask.v[0], a.v[0], b.v[0]);
  r.v[1] = std_simd_select_lane_f32_f32_f32(mask.v[1], a.v[1], b.v[1]);
  r.v[2] = std_simd_select_lane_f32_f32_f32(mask.v[2], a.v[2], b.v[2]);
  r.v[3] = std_simd_select_lane_f32_f32_f32(mask.v[3], a.v[3], b.v[3]);
  return r;
}
