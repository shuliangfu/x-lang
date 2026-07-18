/**
 * See implementation.
 */
const heap = import("std.heap");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  heap.trace_reset();
  let en: i32 = heap.trace_on();
  if (en != 0 && en != 1) { return 1; }
  return 0;
}
