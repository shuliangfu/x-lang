// See implementation.
const test = import("std.test");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (test.expect(1) != 0) { return 1; }
  if (test.expect_eq_i32(42, 42) != 0) { return 2; }
  if (test.expect_ne_i32(1, 2) != 0) { return 3; }
  if (test.expect(0) != 1) { return 4; }
  return 0;
}
