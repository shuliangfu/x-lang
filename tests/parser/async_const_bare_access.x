// See implementation.
const async_mod = import("std.async");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (POLL_PENDING != 0) { return 1; }
  if (POLL_READY != 1) { return 2; }
  return 0;
}
