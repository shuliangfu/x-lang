// wave286 Cap residual: f64 << int must hard-fail at typeck (T001), not host BLD001.
/** Internal function `main`.
 * Illegal float shift — expect typeck XT001 / check_block fail.
 * @return i32
 */
export function main(): i32 {
  let a: f64 = 4.0;
  return (a << 1) as i32;
}
