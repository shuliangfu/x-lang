// wave290 Cap residual: non-folded integer unary ~ must emit notl/mvn on asm -o.
/** Legal BITNOT on a local (forces runtime emit, not CTFE imm fold alone).
 * @return i32 — ~3 as i32 → -4 (process exit 252 on 8-bit status)
 */
export function main(): i32 {
  let x: i32 = 3;
  return (~x);
}
