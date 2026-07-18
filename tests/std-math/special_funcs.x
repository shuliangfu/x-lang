// See implementation.
const math = import("std.math");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (math.special_smoke() != 0) {
    return 1;
  }
  return 0;
}
