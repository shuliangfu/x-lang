// wave286 Cap residual: legal float arithmetic must stay green (f64 +).
// Note: fractional float-lit emit (1.5→1) is a separate residual; use whole values.
/** Internal function `main`.
 * Return (10.0 + 32.0) as i32 → 42.
 * @return i32
 */
export function main(): i32 {
  let a: f64 = 10.0;
  let b: f64 = 32.0;
  return (a + b) as i32;
}
