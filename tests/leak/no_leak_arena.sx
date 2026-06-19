// SAFE-005：Arena64 init/deinit 无堆泄漏。
const heap = import("std.heap");

function main(): i32 {
  let a: Arena64 = Arena64 { chunk: 0 as *u8, cap: 0 as usize, off: 0 as usize };
  if (heap.arena64_init(&a, 4096) != 0) {
    return 1;
  }
  let p: *u8 = heap.arena64_alloc(&a, 128, 8);
  if (p == 0 as *u8) {
    heap.arena64_deinit(&a);
    return 2;
  }
  heap.arena64_deinit(&a);
  return 0;
}
