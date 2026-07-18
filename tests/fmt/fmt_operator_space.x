// fmt_op_demo: see function docblock below.

/** Internal function `fmt_op_demo`.
 * Implements `fmt_op_demo`.
 * @param a i32
 * @param b i32
 * @return i32
 */
function fmt_op_demo(a: i32, b: i32): i32 {
  let s: i32 = 1 + 2 * 3;
  let t: i32 = a + b;
  if (a == 0) { return t; }
  return s + t - a * b;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return fmt_op_demo(1, 2);
}
