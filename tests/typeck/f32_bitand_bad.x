// wave286 Cap residual: f32 & f32 must hard-fail at typeck (T001), not host BLD001.
/** Internal function `main`.
 * Illegal f32 bitwise AND — expect typeck XT001 / check_block fail.
 * @return i32
 */
export function main(): i32 {
  let a: f32 = 1.0;
  let b: f32 = 2.0;
  return (a & b) as i32;
}
