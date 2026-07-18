// See implementation.
const backtrace = import("std.backtrace");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  backtrace.collect_crash_evidence(1, 4242);
  return 0;
}
