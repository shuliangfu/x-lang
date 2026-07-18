// See implementation.
const heap = import("std.heap");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let st: HeapTraceStats = HeapTraceStats {
    alloc_count: 0 as u64,
    free_count: 0 as u64,
    realloc_count: 0 as u64,
    bytes_allocated: 0 as u64
  };
  heap.trace_reset();
  heap.trace_stats(&st);
  if (st.alloc_count != 0 as u64 || st.free_count != 0 as u64) { return 1; }

  let p: *u8 = heap.alloc(32 as usize);
  if (p == 0 as *u8) { return 2; }
  heap.free(p);

  heap.trace_stats(&st);
  if (heap.trace_on() == 0) {
    // See implementation.
    if (st.alloc_count != 0 as u64) { return 3; }
    if (st.free_count != 0 as u64) { return 4; }
    return 0;
  }

  // See implementation.
  if (st.alloc_count < 1 as u64) { return 5; }
  if (st.free_count < 1 as u64) { return 6; }
  if (st.bytes_allocated < 32 as u64) { return 7; }
  return 0;
}
