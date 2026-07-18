// See implementation.
const debug = import("core.debug");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let ok: i32 = debug.assert(true);
  debug.debug_assert(true);
  debug.assert_eq_i32(1, 1);
  debug.assert_ne_i32(1, 2);
  debug.assert_eq_u32(3, 3);
  debug.assert_ne_u32(3, 4);
  debug.assert_eq_bool(true, true);
  return ok;
}
