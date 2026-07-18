// See implementation.
// See implementation.
// See implementation.
const heap = import("std.heap");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let p: *u8 = heap.alloc(64 as usize);
  if (p == 0 as *u8) {
    return 1;
  }
  p[0] = 42;
  heap.free(p);
  return 0;
}
