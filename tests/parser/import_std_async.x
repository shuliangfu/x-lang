// See implementation.
const async_mod = import("std.async");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  async_mod.scheduler_reset();
  return 0;
}
