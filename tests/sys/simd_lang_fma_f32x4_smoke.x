// Stage 10 (10.5.1) slice7: language SIMD builtin fma_f32x4 (a + b*c).
// Product xlang_asm must inline x86 FMA3 or mulps+addps — no extern CALL.
// PLATFORM: LINUX x86_64 asm; SHARED surface (host-C / aarch64 fallthrough panic).
const simd = import("std.simd.builtin");

/**
 * Language SIMD fma_f32x4 smoke: lane-wise a + b*c == 7.
 * @return i32 — 0 on success; 1 on lane failure
 * PLATFORM: LINUX x86_64 asm (SSE/FMA3)
 */
function main(): i32 {
  let a: Vec4f = [1.0, 1.0, 1.0, 1.0];
  let b: Vec4f = [2.0, 2.0, 2.0, 2.0];
  let c: Vec4f = [3.0, 3.0, 3.0, 3.0];
  let r: Vec4f = simd.fma_f32x4(a, b, c);
  if (r[0] < 6.99 || r[0] > 7.01) {
    return 1;
  }
  if (r[3] < 6.99 || r[3] > 7.01) {
    return 1;
  }
  return 0;
}
