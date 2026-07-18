// See implementation.
const heap = import("std.heap");

/** Internal function `proxy_bump`.
 * Implements `proxy_bump`.
 * @param al heap.Allocator
 * @param size usize
 * @return *u8
 */
#[alloc]
function proxy_bump(al: heap.Allocator, size: usize): *u8 {
  return heap.bump_alloc(al, size);
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let p: *u8 = proxy_bump(4 as usize);
  if (p == 0) { return 1; }
  return 0;
}
