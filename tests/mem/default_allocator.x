// See implementation.
const heap = import("std.heap");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  with_arena(4096) {
    let al: Allocator = heap.default_alloc();
    if (al.kind != 1) {
      return 1;
    }
  }
  let al2: Allocator = heap.default_alloc();
  if (al2.kind != 0) {
    return 2;
  }
  return 0;
}
