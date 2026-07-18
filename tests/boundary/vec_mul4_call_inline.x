// See implementation.
/** Internal function `vec_mul4`.
 * Implements `vec_mul4`.
 * @param a i32x4
 * @param b i32x4
 * @return i32x4
 */
function vec_mul4(a: i32x4, b: i32x4): i32x4 {
  return a * b;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: i32x4 = [2, 3, 4, 5];
  let b: i32x4 = [10, 20, 30, 40];
  let c: i32x4 = vec_mul4(a, b);
  let expect: i32x4 = [20, 60, 120, 200];
  let d: i32x4 = c - expect;
  let z: i32x4 = d - d;
  return 0;
}
