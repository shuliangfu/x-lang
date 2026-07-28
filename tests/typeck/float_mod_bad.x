// wave286 Cap residual: f64 % must hard-fail at typeck (T001), not host BLD001.
/** Internal function `main`.
 * Illegal float remainder — expect typeck XT001 / check_block fail.
 * @return i32
 */
export function main(): i32 {
  let a: f64 = 5.0;
  let b: f64 = 2.0;
  let c: f64 = a % b;
  return c as i32;
}
