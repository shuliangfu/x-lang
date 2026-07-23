// wave290 Cap residual: unary LOGNOT neighbor regression for BITNOT emit leaf.
/** Legal logical not on integer (normalized 0/1).
 * @return i32 — !0 → 1
 */
export function main(): i32 {
  let x: i32 = 0;
  return (!x);
}
