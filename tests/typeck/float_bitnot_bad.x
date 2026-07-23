// wave289 Cap residual: f64 unary ~ must hard-fail at typeck (T001), not host BLD001.
/** Illegal float unary BITNOT — expect typeck XT001 / check_block fail.
 * @return i32
 */
export function main(): i32 {
  let a: f64 = 1.5;
  return (~a) as i32;
}
