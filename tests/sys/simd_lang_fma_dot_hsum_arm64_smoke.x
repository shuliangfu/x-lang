// Stage 10 (10.5.1) slice9: aarch64 NEON fma/hsum/dot lang builtins (cross-emit smoke).
// Ubuntu gold: compile -target aarch64; gate scans NEON opcode bytes (no qemu).
// Darwin arm64: optional native run of lane checks.
// PLATFORM: SHARED surface · LINUX aarch64 cross-emit · MACOS|ARM64 native run.
const simd = import("std.simd.builtin");

/**
 * Language SIMD aarch64 fma/hsum/dot smoke (also valid on x86 when run native).
 * @return i32 — 0 on success; 1/2/3 on step failure
 * PLATFORM: LINUX|aarch64 NEON · LINUX|x86_64 SSE · MACOS|ARM64
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
  let fa: Vec4f = [1.0, 1.0, 1.0, 1.0];
  let fb: Vec4f = [2.0, 2.0, 2.0, 2.0];
  let fc: Vec4f = [3.0, 3.0, 3.0, 3.0];
  let fr: Vec4f = simd.fma_f32x4(fa, fb, fc);
  if (fr[0] < 6.99 || fr[0] > 7.01) {
    return 3;
  }
  return 0;
}
