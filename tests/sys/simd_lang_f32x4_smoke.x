// Stage 10 (10.5.1) slice0/5: language SIMD builtins add/mul/sub_f32x4.
// Product xlang_asm must inline x86 SSE or aarch64 NEON — no extern std_simd_* CALL.
// PLATFORM: LINUX x86_64 asm · aarch64 NEON (slice5); SHARED surface (host-C fallback).
const simd = import("std.simd.builtin");

/**
 * Language SIMD f32x4 builtin smoke: add then mul lane checks.
 * @return i32 — 0 on success; 1/2/3/4 on step failure
 * PLATFORM: LINUX x86_64 asm (SSE) · aarch64 NEON (fadd/fmul/fsub)
 */
function main(): i32 {
  let a: Vec4f = [1.0, 2.0, 3.0, 4.0];
  let b: Vec4f = [1.0, 1.0, 1.0, 1.0];
  let s: Vec4f = simd.add_f32x4(a, b);
  if (s[0] < 1.99 || s[0] > 2.01) {
    return 1;
  }
  if (s[3] < 4.99 || s[3] > 5.01) {
    return 2;
  }
  let p: Vec4f = simd.mul_f32x4(s, b);
  if (p[0] < 1.99 || p[0] > 2.01) {
    return 3;
  }
  let d: Vec4f = simd.sub_f32x4(p, b);
  if (d[0] < 0.99 || d[0] > 1.01) {
    return 4;
  }
  return 0;
}
