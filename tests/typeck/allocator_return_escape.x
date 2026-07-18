// See implementation.
const heap = import("std.heap");

/** Internal function `escape_alloc`.
 * Memory management helper `escape_alloc`.
 * @return heap.Allocator
 */
function escape_alloc(): heap.Allocator {
  with_arena(4096) {
    return heap.default_alloc();
  }
  return heap.heap_alloc();
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return 0;
}
