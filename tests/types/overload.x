// pick: see function docblock below.
/** Internal function `pick`.
 * Implements `pick`.
 * @param x i32
 * @return i32
 */
function pick(x: i32): i32 { return x + 1; }
/** Internal function `pick`.
 * Implements `pick`.
 * @param x i64
 * @return i32
 */
function pick(x: i64): i32 { return x as i32 + 2; }

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (pick(10) != 11) { return 1; }
  if (pick(20 as i64) != 22) { return 2; }
  return 0;
}
