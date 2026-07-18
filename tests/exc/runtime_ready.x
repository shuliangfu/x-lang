// See implementation.
const runtime = import("std.runtime");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (runtime.ready() != 0) { return 1; }
  return 0;
}
