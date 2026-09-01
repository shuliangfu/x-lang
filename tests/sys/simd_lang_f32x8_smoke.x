// Stage 10 (10.5.1) slice3: language SIMD builtins add_f32x8 / mul_f32x8.
// Product xlang_asm -o must inline AVX vaddps/vmulps — no extern std_simd_* CALL.
// PLATFORM: LINUX x86_64 asm; SHARED surface (host-C / aarch64 panic).
const simd = import("std.simd.builtin");

/**
 * Language SIMD f32x8 builtin smoke: add then mul lane checks (32B sret let).
 * @return i32 — 0 on success; 1/2/3 on step failure
 * PLATFORM: LINUX x86_64 asm (AVX2 vaddps/vmulps or SSE dual-half)
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
  return 0;
}
