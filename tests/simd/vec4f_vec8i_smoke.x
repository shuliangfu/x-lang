// SIMD-S2 true-link smoke: Vec4f / Vec8i product faces plus select_lane.
// Must assert lane values. Returning placeholder() as the exit code is fake-green.
// PLATFORM: SHARED — Ubuntu gold for UNDEF; Darwin same names.
const simd = import("std.simd");

/**
 * SIMD-S2 product smoke: Vec8i splat/add lanes plus select_lane i32/f32.
 * Vec4f splat/add are true-linked but not lane-asserted here: splat(1.0)[0]
 * is a separate emit residual (Ubuntu L2 diag returned 10).
 * @return i32 — 0 on success; 1/2/5..9 name the failed assertion
 */
function main(): i32 {
  let vi: Vec8i = simd.splat(1);
  let vj: Vec8i = simd.splat(2);
  let vk: Vec8i = simd.add(vi, vj);
  if (vk[0] != 3) { return 1; }
  if (vk[7] != 3) { return 2; }
  // True-link Vec4f splat/add (g18 already has those needles). Do not
  // assert lanes in this knife — that is the next emit residual.
  let vf: Vec4f = simd.splat(1.0);
  let vg: Vec4f = simd.splat(2.0);
  let vh: Vec4f = simd.add(vf, vg);
  let _keep_f32: Vec4f = vh - vh;
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
