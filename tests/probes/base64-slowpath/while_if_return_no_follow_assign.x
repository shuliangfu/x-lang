/** Internal function `while_if_return_no_follow_assign`.
 * Implements `while_if_return_no_follow_assign`.
 * @param n i32
 * @return i32
 */
function while_if_return_no_follow_assign(n: i32): i32 {
  let i: i32 = 0;
  while (i < n) {
    let ok: bool = true;
    if (!ok) {
      return -1;
    }
  }
  return 0;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return while_if_return_no_follow_assign(8);
}
