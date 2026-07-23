// wave286 Cap residual: legal float mul/div stay green.
// Note: fractional float-lit emit is a separate residual; use whole values.
/** Internal function `main`.
 * Return (6.0 * 7.0) as i32 → 42.
 * @return i32
 */
export function main(): i32 {
  let a: f64 = 6.0;
  let b: f64 = 7.0;
  return (a * b) as i32;
}
