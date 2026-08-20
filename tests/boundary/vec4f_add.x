// Vec4f lane-scalar ADD: IEEE f32 addss, not integer ADD of the bits.
// HW addps is x86-only; AAPCS64 falls through to per-lane addss.
// PLATFORM: SHARED — Ubuntu gold; Darwin AAPCS64 is the red face.

/**
 * Native f32 SIMD VAR+VAR add plus mul/sub neighborhood.
 * @return i32 — 0 on success; 1..4 name the failed assertion
 */
function main(): i32 {
  let a: Vec4f = [1.0, 2.0, 3.0, 4.0];
  let b: Vec4f = [10.0, 20.0, 30.0, 40.0];
  let c: Vec4f = a + b;
  if (c[0] != 11.0) { return 1; }
  if (c[3] != 44.0) { return 2; }
  let d: Vec4f = b - a;
  if (d[0] != 9.0) { return 3; }
  let e: Vec4f = a * b;
  if (e[0] != 10.0) { return 4; }
  return 0;
}
