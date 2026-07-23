// wave289 Cap residual: ~ptr must hard-fail at typeck (T001), not host BLD001.
/** Illegal pointer unary BITNOT — expect typeck XT001 / check_block fail.
 * @return i32
 */
export function main(): i32 {
  let p: *u8 = "x";
  return (~p) as i32;
}
