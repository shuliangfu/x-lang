// See implementation.
const heap = import("std.heap");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let al: Allocator = heap.scope_alloc();
  return al.kind;
}
