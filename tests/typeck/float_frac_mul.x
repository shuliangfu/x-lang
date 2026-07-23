// wave287 Cap residual: fractional float mul must not fold via truncated i32 CTFE.
/** Internal function `main`.
 * return (1.5 * 2.0) as i32 → 3 (not 1*2=2).
 * @return i32
 */
export function main(): i32 {
  return (1.5 * 2.0) as i32;
}
