// Gate: AoS INDEX on a 12-byte named struct (esz not 1/4/8) inside a while
// loop. ARM64 must ADD X after mul_imm (scale1), not 32-bit ADD W.
// Expected: 8 (eight arr[i].x stores of 1).
struct Particle {
  x: i32
  y: i32
  z: i32
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let arr: Particle[8] = [];
  let i: i32 = 0;
  while (i < 8) {
    arr[i].x = 1;
    i = i + 1;
  }
  let s: i32 = 0;
  i = 0;
  while (i < 8) {
    s = s + arr[i].x;
    i = i + 1;
  }
  return s;
}
