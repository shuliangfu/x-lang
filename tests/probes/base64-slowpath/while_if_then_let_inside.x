/** Internal function `while_if_then_let_inside`.
 * Implements `while_if_then_let_inside`.
 * @param n i32
 * @return i32
 */
function while_if_then_let_inside(n: i32): i32 {
  let i: i32 = 0;
  while (i < n) {
    let ok: bool = true;
    if (!ok) {
      return -1;
    }
    let j: i32 = 1;
  }
  return 0;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return while_if_then_let_inside(8);
}
