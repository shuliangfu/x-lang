// Stage 10 (10.5.1) slice0: language SIMD builtins add_f32x4 / mul_f32x4.
// Product xlang_asm -o must inline SSE addps/mulps — no extern std_simd_* CALL.
// PLATFORM: LINUX x86_64 asm; SHARED surface (host-C / aarch64 panic).
const simd = import("std.simd.builtin");

/**
 * Language SIMD f32x4 builtin smoke: add then mul lane checks.
 * @return i32 — 0 on success; 1/2/3 on step failure
 * PLATFORM: LINUX x86_64 asm (SSE addps/mulps)
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
  return 0;
}
