/**
 * See implementation.
 * See implementation.
 */
struct Particle soa {
  x: f32
  y: f32
  z: f32
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let arr: Particle[16] = [];
  let i: i32 = 0;
  while (i < 10) {
    arr[i].x = 1.0;
    i = i + 1;
  }
  let s: f32 = 0.0;
  i = 0;
  while (i < 10) {
    s = s + arr[i].x;
    i = i + 1;
  }
  return s as i32;
}
