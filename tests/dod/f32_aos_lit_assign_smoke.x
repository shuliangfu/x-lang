/**
 * See implementation.
 * See implementation.
 */
struct Particle {
  x: f32
  y: f32
  z: f32
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let arr: Particle[4] = [];
  arr[0].x = 1.0;
  arr[1].x = 2.0;
  arr[2].x = 3.0;
  arr[3].x = 4.0;
  let s: f32 = 0.0;
  let i: i32 = 0;
  while (i < 4) {
    s = s + arr[i].x;
    i = i + 1;
  }
  return s as i32;
}
