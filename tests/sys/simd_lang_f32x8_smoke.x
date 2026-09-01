// Stage 10 (10.5.1) slice4/6: language SIMD builtins add/mul/sub_f32x8.
// Product xlang_asm must inline x86 AVX/SSE or aarch64 NEON — no extern std_simd_* CALL.
// PLATFORM: LINUX x86_64 asm · aarch64 NEON (slice6); SHARED surface (host-C fallback).
const simd = import("std.simd.builtin");

/**
 * Language SIMD f32x8 builtin smoke: add, mul, then sub lane checks (32B sret let).
 * @return i32 — 0 on success; 1/2/3/4 on step failure
 * PLATFORM: LINUX x86_64 asm (AVX2/SSE) · aarch64 NEON (fadd/fmul/fsub dual-half)
 */
function main(): i32 {
  let a: f32x8 = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0];
  let b: f32x8 = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0];
  let s: f32x8 = simd.add_f32x8(a, b);
  if (s[0] < 1.99 || s[0] > 2.01) {
    return 1;
  }
  if (s[7] < 8.99 || s[7] > 9.01) {
    return 2;
  }
  let p: f32x8 = simd.mul_f32x8(s, b);
  if (p[0] < 1.99 || p[0] > 2.01) {
    return 3;
  }
  let d: f32x8 = simd.sub_f32x8(p, b);
  if (d[0] < 1.99 || d[0] > 2.01) {
    return 4;
  }
  return 0;
}
