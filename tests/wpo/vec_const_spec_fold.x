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
  return lane0(vec_add4([1, 2, 3, 4], [10, 20, 30, 40])) - 11;
}
