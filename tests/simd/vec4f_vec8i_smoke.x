// SIMD-S2 true-link smoke: Vec4f / Vec8i product faces plus select_lane.
// Must assert lane values. Returning placeholder() as the exit code is fake-green.
// PLATFORM: SHARED — Ubuntu gold for UNDEF; Darwin same names.
const simd = import("std.simd");

/**
 * SIMD-S2 product smoke: Vec8i/Vec4f splat/add lanes plus select_lane i32/f32.
 * @return i32 — 0 on success; 1..9 name the failed assertion
 */
function main(): i32 {
  let vi: Vec8i = simd.splat(1);
  let vj: Vec8i = simd.splat(2);
  let vk: Vec8i = simd.add(vi, vj);
  if (vk[0] != 3) { return 1; }
  if (vk[7] != 3) { return 2; }
  let vf: Vec4f = simd.splat(1.0);
  let vg: Vec4f = simd.splat(2.0);
  let vh: Vec4f = simd.add(vf, vg);
  if (vf[0] != 1.0) { return 3; }
  if (vh[0] != 3.0) { return 4; }
  // Product helper: sole select_lane must pull std/simd/simd.o via g18 needles.
  let li: i32 = simd.select_lane(1, 10, 20);
  if (li != 10) { return 5; }
  let lj: i32 = simd.select_lane(0, 10, 20);
  if (lj != 20) { return 6; }
  let lf: f32 = simd.select_lane(1.0, 3.0, 4.0);
  if (lf != 3.0) { return 7; }
  let lg: f32 = simd.select_lane(0.0, 3.0, 4.0);
  if (lg != 4.0) { return 8; }
  if (simd.placeholder() != 0) { return 9; }
  return 0;
}
