// See implementation.

/** Internal function `hsum4`.
 * Implements `hsum4`.
 * @param v Vec4f
 * @return f32
 */
function hsum4(v: Vec4f): f32 {
  return v[0] + v[1] + v[2] + v[3];
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let limit: i32 = 2000000;
  let sum: f32 = 0.0;
  let i: i32 = 0;
  while (i < limit) {
    let t: f32 = (i % 256) as f32;
    let a: Vec4f = [t, t + 1.0, t + 2.0, t + 3.0];
    let b: Vec4f = [0.5, 0.25, 0.125, 0.0625];
    let p: Vec4f = a * b;
    sum = sum + hsum4(p);
    i = i + 1;
  }
  let _unused: f32 = sum;
  return 0;
}
