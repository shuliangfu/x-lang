// See implementation.
// neg: see function docblock below.

/** Internal function `neg`.
 * Implements `neg`.
 * @param i i32
 * @return i32
 */
function neg(i: i32): i32 {
  return -i;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: i32 = -1;
  let b: i32 = a - 1;
  let c: i32 = neg(-1);
  if (a < 0) {
    return -1;
  }
  return b + c;
}
