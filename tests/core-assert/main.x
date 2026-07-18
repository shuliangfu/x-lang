// See implementation.
const assert_mod = import("core.assert");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: i32 = assert_mod.assert(true);
  let b: i32 = assert_mod.assert_eq_i32(1, 1);
  return if (a == 0 && b == 0) { 0 } else { 1 };
}
