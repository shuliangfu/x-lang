// AL-04 assign negative: writing heap.Allocator into an outer var from
// inside with_arena must typeck-fail (`allocator region escape`).
// Scalar outer writes (`k = 1`) are not this gate (dest extra-arm).
// PLATFORM: SHARED — MEM-C1 AL-04 assign.
const heap = import("std.heap");

/** Internal function `main`.
 * Program/test entry point. Expected: typeck reject, no binary.
 * @return i32
 */
function main(): i32 {
  let al: heap.Allocator = heap.heap_alloc();
  with_arena(4096) {
    al = heap.default_alloc();
  }
  return 0;
}
