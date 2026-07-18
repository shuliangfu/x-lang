/** Internal function `while_local_bool_branch_min`.
 * Implements `while_local_bool_branch_min`.
 * @param n i32
 * @return i32
 */
function while_local_bool_branch_min(n: i32): i32 {
  let i: i32 = 0;
  while (i < n) {
    let ok: bool = true;
    if (!ok) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return while_local_bool_branch_min(8);
}
