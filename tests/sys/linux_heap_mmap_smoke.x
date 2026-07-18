// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
const heap = import("std.heap.page_mmap");
const sys = import("std.sys");
const linux = import("std.sys.linux");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (heap.page_mmap_heap_available() != 1) {
    return 1;
  }
  if (linux.linux_syscall_invoke_available() != 1) {
    return 2;
  }
  let h: heap.PageMmapHeap = heap.PageMmapHeap {
    base: 0 as *u8,
    cap: 0 as usize,
    off: 0 as usize,
  };
  if (heap.page_mmap_heap_init(&h) != 0) {
    return 3;
  }
  // See implementation.
  if (h.base == 0 as *u8) {
    return 20;
  }
  if (h.cap != 65536 as usize) {
    return 21;
  }
  let p: *u8 = heap.page_mmap_heap_alloc(&h, 32 as usize, 8 as usize);
  if (p == 0 as *u8) {
    heap.page_mmap_heap_deinit(&h);
    return 4;
  }
  if (p == 1 as *u8) {
    return 40;
  }
  if (p == 2 as *u8) {
    return 41;
  }
  if (p == 3 as *u8) {
    return 42;
  }
  if (p == 4 as *u8) {
    return 43;
  }
  if (p == 5 as *u8) {
    return 44;
  }
  p[0] = 65 as u8;
  p[1] = 66 as u8;
  p[2] = 67 as u8;
  if (p[0] != 65 as u8 || p[1] != 66 as u8 || p[2] != 67 as u8) {
    heap.page_mmap_heap_deinit(&h);
    return 5;
  }
  let n: i32 = sys.write_stdout(p, 3);
  if (n != 3) {
    heap.page_mmap_heap_deinit(&h);
    return 6;
  }
  heap.page_mmap_heap_free(&h, p);
  heap.page_mmap_heap_deinit(&h);
  return 0;
}
