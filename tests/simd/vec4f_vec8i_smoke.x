// SIMD-S2 true-link smoke: Vec4f / Vec8i product faces plus select_lane.
// Must assert lane values. Returning placeholder() as the exit code is fake-green.
// PLATFORM: SHARED — Ubuntu gold for UNDEF; Darwin same names.
const simd = import("std.simd");

/**
 * Same-module CALL with Vec4f ambient: FLOAT_LIT 1.0 must stamp to formal f32.
 * splat emit-pack is a belt; this path is formal ABI (no try_inline_splat).
 * @param x f32 — lane value
 * @return Vec4f — [x, x, x, x]
 */
function fill4(x: f32): Vec4f {
  let v: Vec4f = [x, x, x, x];
  return v;
}

/**
 * SIMD-S2 product smoke: Vec8i/Vec4f splat/add lanes plus select_lane i32/f32
 * plus same-module CALL fill4(1.0) (typeck post-resolve FLOAT_LIT stamp)
 * plus METHOD(49) shuffle let-init (direct-slot stack reserve ≡ CALL).
 * @return i32 — 0 on success; 1..13 name the failed assertion
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
  let vfill: Vec4f = fill4(1.0);
  if (vfill[0] != 1.0) { return 10; }
  /* METHOD(49) vector let-init: classifier must treat as direct-slot like CALL.
   * Identity shuffle + trailing i32 marker: extra ARRAY/STRUCT reserve on the
   * METHOD would shift later locals and smash `marker` or vshuf lanes. */
  let vshuf: Vec4f = simd.shuffle(vfill, [0, 1, 2, 3]);
  let marker: i32 = 42;
  if (vshuf[0] != 1.0) { return 11; }
  if (vshuf[3] != 1.0) { return 12; }
  if (marker != 42) { return 13; }
  return 0;
}
