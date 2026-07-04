/**
 * Cookbook HEAP-01：heap_trace_reset 与 trace 统计入口（STD-017）。
 */
const heap = import("std.heap");

function main(): i32 {
  heap.trace_reset();
  let en: i32 = heap.trace_on();
  if (en != 0 && en != 1) { return 1; }
  return 0;
}
