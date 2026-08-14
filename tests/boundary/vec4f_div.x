// Vec4f lane-scalar DIV: IEEE f32 divss, not integer idiv of the bits.
// 0.0f divisor must not trip the integer zero-check (IEEE inf/nan).
// PLATFORM: SHARED — Ubuntu gold; Darwin AAPCS64 is the red face.

/**
 * Native f32 SIMD VAR/VAR divide plus neighborhood.
 * @return i32 — 0 on success; 1..4 name the failed assertion
 */
function main(): i32 {
  let a: Vec4f = [8.0, 12.0, 20.0, 4.0];
  let b: Vec4f = [2.0, 3.0, 4.0, 2.0];
  let c: Vec4f = a / b;
  if (c[0] != 4.0) { return 1; }
  if (c[1] != 4.0) { return 2; }
  if (c[3] != 2.0) { return 3; }
  let d: Vec4f = a + b;
  if (d[0] != 10.0) { return 4; }
  return 0;
}
