/**
 * See implementation.
 */
const thread = import("std.thread");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let st: ThreadPoolStats = ThreadPoolStats { pending: 0, in_flight: 0, workers: 0 };
  if (thread.stats(&st) != -1) { return 1; }
  return 0;
}
