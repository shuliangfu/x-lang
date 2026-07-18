// See implementation.
const debug = import("core.debug");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (debug.debug_assert_eq_i32_diag(1, 1, 99) != 0) { return 1; }
  debug.debug_diag_store(10, 20, 1);
  return 0;
}
