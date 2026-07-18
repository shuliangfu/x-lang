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
  return scale(1024, 64);
}
