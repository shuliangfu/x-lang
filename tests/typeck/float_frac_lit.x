// wave287 Cap residual: fractional float lit must not CTFE-truncate to int.
/** Internal function `main`.
 * let a = 1.5; let b = 2.5; return (a + b) as i32 → 4.
 * @return i32
 */
export function main(): i32 {
  let a: f64 = 1.5;
  let b: f64 = 2.5;
  let c: f64 = a + b;
  return c as i32;
}
