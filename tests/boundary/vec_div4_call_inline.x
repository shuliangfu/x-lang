// See implementation.
/** Internal function `vec_div4`.
 * Implements `vec_div4`.
 * @param a i32x4
 * @param b i32x4
 * @return i32x4
 */
function vec_div4(a: i32x4, b: i32x4): i32x4 {
  return a / b;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: i32x4 = [8, 12, 20, 4];
  let b: i32x4 = [2, 3, 4, 2];
  let c: i32x4 = vec_div4(a, b);
  let expect: i32x4 = [4, 4, 5, 2];
  let d: i32x4 = c - expect;
  let z: i32x4 = d - d;
  return 0;
}
