// wave289 Cap residual: unary - on f64 still legal (emit/host path; cast to i32).
/** Legal float unary NEG regression — not rejected with ~float hard-fail.
 * @return i32 — (-1.5) as i32 → -1 (trunc toward zero) → exit 255 as u8
 */
export function main(): i32 {
  let a: f64 = 1.5;
  return (-a) as i32;
}
