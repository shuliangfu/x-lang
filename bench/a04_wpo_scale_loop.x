// See implementation.
// See implementation.
// See implementation.
/** Internal function `scale`.
 * Implements `scale`.
 * @param n i32
 * @param k i32
 * @return i32
 */
function scale(n: i32, k: i32): i32 {
  return n * k;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let limit: i32 = 10000000;
  let s: i32 = 0;
  let i: i32 = 0;
  while (i < limit) {
    s = s + scale(1024, 64);
    i = i + 1;
  }
  return s;
}
