// wave287 Cap residual: 0.5 * 84 must yield 42 (not 0*84=0).
/** Internal function `main`.
 * return (0.5 * 84.0) as i32 → 42.
 * @return i32
 */
export function main(): i32 {
  return (0.5 * 84.0) as i32;
}
