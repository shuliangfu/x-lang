// pgo_hot_smoke.x — WPO-S4 PGO-Lite：main(d0)+warm_mid(d1)→.text.hot；hot_add/cold_deep(d2)→.text.unlikely
// See implementation.
// See implementation.

/** Internal function `hot_add`.
 * Implements `hot_add`.
 * @param a i32
 * @param b i32
 * @return i32
 */
function hot_add(a: i32, b: i32): i32 {
  return a + b;
}

/** Internal function `cold_deep`.
 * Implements `cold_deep`.
 * @return i32
 */
function cold_deep(): i32 {
  return 99;
}

/** Internal function `warm_mid`.
 * Implements `warm_mid`.
 * @return i32
 */
function warm_mid(): i32 {
  return cold_deep() + hot_add(1, 2);
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return warm_mid();
}
