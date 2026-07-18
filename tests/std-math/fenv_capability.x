// See implementation.
const math = import("std.math");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let avail: i32 = fenv_available();
  if (avail != 0 && avail != 1) {
    return 1;
  }
  // See implementation.
  if (avail == 0) {
    if (test_exceptions(31) != -9) { return 2; }
    return 0;
  }
  // See implementation.
  if (clear_exceptions(31) != 0) { return 3; }
  if (test_exceptions(31) != 0) { return 4; }
  if (raise_exceptions(4) != 0) { return 5; }
  if ((test_exceptions(4) & 4) == 0) { return 6; }
  if (clear_exceptions(31) != 0) { return 7; }
  return 0;
}
