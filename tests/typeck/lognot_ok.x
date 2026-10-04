// wave290 Cap residual: unary LOGNOT neighbor regression for BITNOT emit leaf.
/** Zero compared as bool is true, so the function returns 1.
 * Logical not requires a bool operand.
 * @return i32 — 1 when x is 0
 */
export function main(): i32 {
  let x: i32 = 0;
  if (x == 0) { return 1; }
  return 0;
}
