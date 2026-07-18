/**
 * See implementation.
 * See implementation.
 */
const heap = import("std.heap");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  /* See implementation. */
  let a: Arena64 = Arena64 { chunk: 0 as *u8, cap: 0 as usize, off: 0 as usize };
  if (heap.arena64_init(&a, 4096) != 0) {
    return 1;
  }
  if (heap.ptr_mod(a.chunk, 64) != 0) {
    heap.arena64_deinit(&a);
    return 2;
  }
  let p: *u8 = heap.arena64_alloc(&a, 128 as usize, 64 as usize);
  if (p == 0 as *u8) {
    heap.arena64_deinit(&a);
    return 3;
  }
  if (heap.ptr_mod(p, 64) != 0) {
    heap.arena64_deinit(&a);
    return 4;
  }
  heap.arena64_deinit(&a);
  return 0;
}
