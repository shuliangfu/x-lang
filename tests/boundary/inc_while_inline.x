// See implementation.
/** Internal function `inc`.
 * Implements `inc`.
 * @param x i32
 * @return i32
 */
function inc(x: i32): i32 {
  return x + 1;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let n: i32 = 5;
  let s: i32 = 0;
  let i: i32 = 0;
  while (i < n) {
    s = s + inc(i);
    i = i + 1;
  }
  return s;
}
