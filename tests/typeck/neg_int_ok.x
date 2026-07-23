// wave290 Cap residual: unary NEG neighbor regression for BITNOT emit leaf.
/** Legal integer unary negation (asm -o).
 * @return i32 — -3 (process exit 253 on 8-bit status)
 */
export function main(): i32 {
  let x: i32 = 3;
  return (-x);
}
