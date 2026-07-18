/** Internal function `while_direct_return_min`.
 * Implements `while_direct_return_min`.
 * @param n i32
 * @return i32
 */
function while_direct_return_min(n: i32): i32 {
  let i: i32 = 0;
  while (i < n) {
    return -1;
  }
  return 0;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return while_direct_return_min(8);
}
