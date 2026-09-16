// Stage 10 (10.5.1) slice10: host-C fallthrough for language SIMD builtins.
// Must run under xlang-c (no asm HW intercept) and exit 0 via scalar bodies.
// PLATFORM: SHARED · host-C / xlang-c gold.
const simd = import("std.simd.builtin");

/**
 * Host-C fallthrough smoke: f32x4 add/mul/sub/fma/hsum/dot via scalar bodies.
 * @return i32 — 0 on success; 1..6 on step failure
 * PLATFORM: SHARED host-C
 */
function main(): i32 {
  let a: Vec4f = [1.0, 2.0, 3.0, 4.0];
  let b: Vec4f = [1.0, 1.0, 1.0, 1.0];
  let s: Vec4f = simd.add_f32x4(a, b);
  if (s[0] < 1.99 || s[0] > 2.01) {
    return 1;
  }
  let p: Vec4f = simd.mul_f32x4(s, b);
  if (p[0] < 1.99 || p[0] > 2.01) {
    return 2;
  }
  let d: Vec4f = simd.sub_f32x4(p, b);
  if (d[0] < 0.99 || d[0] > 1.01) {
    return 3;
  }
  let fa: Vec4f = [1.0, 1.0, 1.0, 1.0];
  let fb: Vec4f = [2.0, 2.0, 2.0, 2.0];
  let fc: Vec4f = [3.0, 3.0, 3.0, 3.0];
  let fr: Vec4f = simd.fma_f32x4(fa, fb, fc);
  if (fr[0] < 6.99 || fr[0] > 7.01) {
    return 4;
  }
  let hs: f32 = simd.hsum_f32x4(a);
  if (hs < 9.99 || hs > 10.01) {
    return 5;
  }
  let dt: f32 = simd.dot_f32x4(a, b);
  if (dt < 9.99 || dt > 10.01) {
    return 6;
  }
  return 0;
}
