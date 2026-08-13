/* std/simd/formal_surface.c — host-C formal faces for pure-asm import METHOD mid.
 *
 * G.7 authority twin of std/simd/mod.x export mangle (codegen VECTOR = f32x4 / i32x8).
 *
 * ABI (Stage12 soft residual 2026-08-13):
 *   - Do NOT use `struct { float v[4]; }` for f32x4: gcc SysV classifies it as
 *     SSE (xmm0+xmm1) while pure-asm packs 16B POD as INTEGER dual-GP (rdi+rsi).
 *     That mismatch put mask bits in rdi → SEGV on mask[i].
 *   - Use uint64_t lo/hi so the type is INTEGER dual-GP ≡ pure-asm size=16 pack
 *     after glue_type_size_simple TYPE_VECTOR = lanes*esz.
 *   - i32x8 remains 32B MEMORY (stack) — pure-asm MEMORY path matches gcc.
 *
 * PLATFORM: SHARED formal .o for pure-asm link (Ubuntu gold + mac L2).
 * Bodies match mod.x scalar-lane semantics (STD-047).
 */
#include <stdint.h>
#include <string.h>

/* INTEGER dual-GP (16B) — pure-asm SysV rdi+rsi / ret rax+rdx. */
typedef struct {
  uint64_t lo;
  uint64_t hi;
} f32x4_t;

/* 32B MEMORY by-value — pure-asm stack pack. */
typedef struct {
  int32_t v[8];
} i32x8_t;

static void f32x4_from_lanes(f32x4_t *o, float a, float b, float c, float d) {
  float t[4];
  t[0] = a;
  t[1] = b;
  t[2] = c;
  t[3] = d;
  memcpy(o, t, 16);
}

static void f32x4_to_lanes(f32x4_t v, float out[4]) {
  memcpy(out, &v, 16);
}

f32x4_t std_simd_splat_f32(float x) {
  f32x4_t r;
  f32x4_from_lanes(&r, x, x, x, x);
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
  float src[4];
  float dst[4];
  int32_t i0 = mask ? mask[0] : 0;
  int32_t i1 = mask ? mask[1] : 0;
  int32_t i2 = mask ? mask[2] : 0;
  int32_t i3 = mask ? mask[3] : 0;
  f32x4_to_lanes(v, src);
  dst[0] = src[i0 & 3];
  dst[1] = src[i1 & 3];
  dst[2] = src[i2 & 3];
  dst[3] = src[i3 & 3];
  memcpy(&r, dst, 16);
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
  float m[4], aa[4], bb[4], out[4];
  f32x4_to_lanes(mask, m);
  f32x4_to_lanes(a, aa);
  f32x4_to_lanes(b, bb);
  out[0] = std_simd_select_lane_f32_f32_f32(m[0], aa[0], bb[0]);
  out[1] = std_simd_select_lane_f32_f32_f32(m[1], aa[1], bb[1]);
  out[2] = std_simd_select_lane_f32_f32_f32(m[2], aa[2], bb[2]);
  out[3] = std_simd_select_lane_f32_f32_f32(m[3], aa[3], bb[3]);
  memcpy(&r, out, 16);
  return r;
}

/* Remaining mod.x exports (STD-SIMD-INTRINSIC). Overload mids use VECTOR
 * suffixes; unique names (dot/hsum/fma/madd) stay bare — matches
 * glue_asm_build_func_overload_mid_c. Lane math ≡ mod.x (fma = a + b*c).
 * PLATFORM: SHARED formal face; Ubuntu gold + mac L2. */

f32x4_t std_simd_add_f32x4_f32x4(f32x4_t a, f32x4_t b) {
  f32x4_t r;
  float aa[4], bb[4], out[4];
  f32x4_to_lanes(a, aa);
  f32x4_to_lanes(b, bb);
  out[0] = aa[0] + bb[0];
  out[1] = aa[1] + bb[1];
  out[2] = aa[2] + bb[2];
  out[3] = aa[3] + bb[3];
  memcpy(&r, out, 16);
  return r;
}

i32x8_t std_simd_add_i32x8_i32x8(i32x8_t a, i32x8_t b) {
  i32x8_t r;
  int i;
  for (i = 0; i < 8; i++)
    r.v[i] = a.v[i] + b.v[i];
  return r;
}

f32x4_t std_simd_sub_f32x4_f32x4(f32x4_t a, f32x4_t b) {
  f32x4_t r;
  float aa[4], bb[4], out[4];
  f32x4_to_lanes(a, aa);
  f32x4_to_lanes(b, bb);
  out[0] = aa[0] - bb[0];
  out[1] = aa[1] - bb[1];
  out[2] = aa[2] - bb[2];
  out[3] = aa[3] - bb[3];
  memcpy(&r, out, 16);
  return r;
}

i32x8_t std_simd_sub_i32x8_i32x8(i32x8_t a, i32x8_t b) {
  i32x8_t r;
  int i;
  for (i = 0; i < 8; i++)
    r.v[i] = a.v[i] - b.v[i];
  return r;
}

f32x4_t std_simd_mul_f32x4_f32x4(f32x4_t a, f32x4_t b) {
  f32x4_t r;
  float aa[4], bb[4], out[4];
  f32x4_to_lanes(a, aa);
  f32x4_to_lanes(b, bb);
  out[0] = aa[0] * bb[0];
  out[1] = aa[1] * bb[1];
  out[2] = aa[2] * bb[2];
  out[3] = aa[3] * bb[3];
  memcpy(&r, out, 16);
  return r;
}

i32x8_t std_simd_mul_i32x8_i32x8(i32x8_t a, i32x8_t b) {
  i32x8_t r;
  int i;
  for (i = 0; i < 8; i++)
    r.v[i] = a.v[i] * b.v[i];
  return r;
}

float std_simd_hsum(f32x4_t v) {
  float a[4];
  f32x4_to_lanes(v, a);
  return a[0] + a[1] + a[2] + a[3];
}

float std_simd_dot(f32x4_t a, f32x4_t b) {
  return std_simd_hsum(std_simd_mul_f32x4_f32x4(a, b));
}

f32x4_t std_simd_fma(f32x4_t a, f32x4_t b, f32x4_t c) {
  /* mod.x: r[i] = a[i] + b[i] * c[i] (not a*b+c). */
  f32x4_t r;
  float aa[4], bb[4], cc[4], out[4];
  f32x4_to_lanes(a, aa);
  f32x4_to_lanes(b, bb);
  f32x4_to_lanes(c, cc);
  out[0] = aa[0] + bb[0] * cc[0];
  out[1] = aa[1] + bb[1] * cc[1];
  out[2] = aa[2] + bb[2] * cc[2];
  out[3] = aa[3] + bb[3] * cc[3];
  memcpy(&r, out, 16);
  return r;
}

f32x4_t std_simd_madd(f32x4_t a, f32x4_t b, f32x4_t c) {
  return std_simd_fma(a, b, c);
}
