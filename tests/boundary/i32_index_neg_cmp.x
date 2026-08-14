// INDEX of signed i32 must sign-extend before a 64-bit compare.
// AAPCS64 used ldr w0 (zext) so a[0] != -5 was true (RUN=3).
// PLATFORM: SHARED — Ubuntu gold already CDQE on x86; Darwin is the red face.

/**
 * Negative i32 INDEX / i32x4 lane compare plus neighborhood.
 * @return i32 — 0 on success; 1..8 name the failed assertion
 */
function neg5(): i32 {
  return 0 - 5;
}

function main(): i32 {
  let x: i32 = 0 - 5;
  if (x != 0 - 5) { return 1; }
  if (x != -5) { return 2; }

  let a: [2]i32 = [0 - 5, 4];
  if (a[0] != 0 - 5) { return 3; }
  if (a[0] != -5) { return 4; }
  if (a[1] != 4) { return 5; }

  let q: i32x4 = [0 - 20, 12, 20, 4];
  let d: i32x4 = [4, 3, 4, 2];
  let c: i32x4 = q / d;
  if (c[0] != 0 - 5) { return 6; }
  if (c[0] != -5) { return 7; }
  if (c[2] != 5) { return 8; }

  if (neg5() != 0 - 5) { return 9; }
  if (neg5() != -5) { return 10; }
  return 0;
}
