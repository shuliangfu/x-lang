// Stage 10 (10.5.1) slice8: language SIMD builtins hsum_f32x4 / dot_f32x4.
// Product xlang_asm must inline x86 SSE reduce — no extern CALL panic.
// PLATFORM: LINUX x86_64 asm; SHARED surface (host-C / aarch64 fallthrough panic).
const simd = import("std.simd.builtin");

/**
 * Language SIMD hsum/dot f32x4 smoke: reduce lanes to scalar f32.
 * @return i32 — 0 on success; 1 hsum fail; 2 dot fail
 * PLATFORM: LINUX x86_64 asm (SSE)
 */
function main(): i32 {
  let a: Vec4f = [1.0, 2.0, 3.0, 4.0];
  let b: Vec4f = [1.0, 1.0, 1.0, 1.0];
  let hs: f32 = simd.hsum_f32x4(a);
  if (hs < 9.99 || hs > 10.01) {
    return 1;
  }
  let d: f32 = simd.dot_f32x4(a, b);
  if (d < 9.99 || d > 10.01) {
    return 2;
  }
  return 0;
}
