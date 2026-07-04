/**
 * Cookbook THREAD-01：thread_pool_stats 未启动池（STD-165）。
 */
const thread = import("std.thread");

function main(): i32 {
  let st: ThreadPoolStats = ThreadPoolStats { pending: 0, in_flight: 0, workers: 0 };
  if (thread.stats(&st) != -1) { return 1; }
  return 0;
}
