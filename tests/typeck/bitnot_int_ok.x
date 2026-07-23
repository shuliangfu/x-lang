// wave289 Cap residual: integer unary ~ still legal (run = ~3 as u8/i32 = -4 → 252).
/** Legal integer BITNOT regression for wave289 unary hard-fail leaf.
 * @return i32
 */
export function main(): i32 {
  return (~3);
}
