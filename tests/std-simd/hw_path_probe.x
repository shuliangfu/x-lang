// STD-153 product probe: import METHOD hw_available / recommend_path.
// Exit code = hw * 10 + path (default 11; XLANG_SIMD_HW=0 → 10).
// PLATFORM: SHARED — Ubuntu gold; Darwin same product faces.
const simd = import("std.simd");

/**
 * Report std.simd runtime strategy as a two-digit exit code.
 * Tens = hw_available (0/1); ones = recommend_path (0=scalar, 1=hw).
 * @return i32 — hw * 10 + path
 */
function main(): i32 {
  let hw: i32 = simd.hw_available();
  let path: i32 = simd.recommend_path();
  return hw * 10 + path;
}
