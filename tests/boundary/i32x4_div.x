// i32x4 lane-scalar DIV: 4B signed load, not 64-bit ldr of two packed lanes.
// AAPCS64 later lanes used ldr x0 + sdiv x0,x0,x1 so c[2] became 2 not 5.
// PLATFORM: SHARED — Ubuntu gold (esz==4 already eax32); Darwin is the red face.

/**
 * Native i32 SIMD VAR/VAR divide plus neighborhood.
 * @return i32 — 0 on success; 1..8 name the failed assertion
 */
function main(): i32 {
  let a: i32x4 = [8, 12, 20, 4];
  let b: i32x4 = [2, 3, 4, 2];
  let c: i32x4 = a / b;
  if (c[0] != 4) { return 1; }
  if (c[1] != 4) { return 2; }
  if (c[2] != 5) { return 3; }
  if (c[3] != 2) { return 4; }
  let s: i32x4 = a + b;
  if (s[0] != 10) { return 5; }
  if (s[2] != 24) { return 6; }
  let p: i32x4 = a * b;
  if (p[0] != 16) { return 7; }
  if (p[2] != 80) { return 8; }
  return 0;
}
