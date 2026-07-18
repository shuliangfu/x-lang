/** Internal function `while_branch_no_return_min`.
 * Implements `while_branch_no_return_min`.
 * @param n i32
 * @return i32
 */
function while_branch_no_return_min(n: i32): i32 {
  let i: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    let ok: bool = true;
    if (!ok) {
      acc = -1;
    }
    i = i + 1;
  }
  return acc;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return while_branch_no_return_min(8);
}
