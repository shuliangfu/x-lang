// Stage 10 (10.5.1) slice1/6: language SIMD builtins add/mul/sub_i32x8.
// Product xlang_asm must inline x86 SSE/AVX or aarch64 NEON — no extern std_simd_* CALL.
// PLATFORM: LINUX x86_64 asm · aarch64 NEON (slice6); SHARED surface (host-C fallback).
const simd = import("std.simd.builtin");

/**
 * Language SIMD i32x8 builtin smoke: add then mul lane checks (32B sret let).
 * @return i32 — 0 on success; 1/2/3/4/5 on step failure
 * PLATFORM: LINUX x86_64 asm (SSE2/AVX2) · aarch64 NEON (add/mul/sub .4s dual-half)
 */
function main(): i32 {
  let a: Vec8i = [1, 2, 3, 4, 5, 6, 7, 8];
  let b: Vec8i = [1, 1, 1, 1, 1, 1, 1, 1];
  let s: Vec8i = simd.add_i32x8(a, b);
  if (s[0] != 2) {
    return 1;
  }
  if (s[7] != 9) {
    return 2;
  }
  let p: Vec8i = simd.mul_i32x8(s, b);
  if (p[0] != 2) {
    return 3;
  }
  let d: Vec8i = simd.sub_i32x8(p, b);
  if (d[0] != 1) {
    return 4;
  }
  if (d[7] != 8) {
    return 5;
  }
  return 0;
}
