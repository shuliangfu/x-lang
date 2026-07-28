// wave286 Cap residual: legal float mul must typeck-pass and run.
// Direct lit mul folds at emit (6.0*7.0→42). Variable f64 mul runtime on
// Ubuntu freestanding is a separate residual (leave-off).
/** Internal function `main`.
 * Return (6.0 * 7.0) as i32 → 42.
 * @return i32
 */
export function main(): i32 {
  return (6.0 * 7.0) as i32;
}
