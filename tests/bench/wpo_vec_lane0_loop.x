// See implementation.
// See implementation.
// See implementation.
/** Internal function `vec_add4`.
 * Implements `vec_add4`.
 * @param a i32x4
 * @param b i32x4
 * @return i32x4
 */
function vec_add4(a: i32x4, b: i32x4): i32x4 {
  return a + b;
}

/** Internal function `lane0`.
 * Implements `lane0`.
 * @param v i32x4
 * @return i32
 */
function lane0(v: i32x4): i32 {
  return v[0];
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let limit: i32 = 10000000;
  let s: i32 = 0;
  let i: i32 = 0;
  while (i < limit) {
    s = s + lane0(vec_add4([1, 2, 3, 4], [10, 20, 30, 40]));
    i = i + 1;
  }
  /* See implementation. */
  if (s != 110000000) {
    return 1;
  }
  return 0;
}
