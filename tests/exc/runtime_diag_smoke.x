// See implementation.
const runtime = import("std.runtime");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (runtime.diag_enabled() != 1) { return 1; }
  runtime.diag_collect(0, 0);
  return 0;
}
