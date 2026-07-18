// See implementation.
/** Internal function `sum_f32`.
 * Implements `sum_f32`.
 * @param n i32
 * @param ap *f32
 * @return f32
 */
function sum_f32(n: i32, ap: *f32): f32 {
  let s: f32 = 0.0;
  let i: i32 = 0;
  while (i < n) {
    s = s + ap[i];
    i = i + 1;
  }
  return s;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let x: f32[4] = [1.0, 2.0, 3.0, 4.0];
  let t: f32 = sum_f32(4, &x[0]);
  /* 1+2+3+4 = 10 */
  if (t < 9.99 || t > 10.01) {
    return 1;
  }
  return 0;
}
