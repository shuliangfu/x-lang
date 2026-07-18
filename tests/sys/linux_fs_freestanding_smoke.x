// See implementation.
//
// See implementation.
const fs = import("std.fs.freestanding_linux");
const heap = import("std.heap.page_mmap");
const sys = import("std.sys");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (fs.freestanding_fs_available() != 1) {
    return 1;
  }
  if (heap.page_mmap_heap_available() != 1) {
    return 2;
  }
  /* See implementation. */
  let path: u8[32] = [
    47, 116, 109, 112, 47, 115, 104, 117, 120, 95, 110, 111, 108, 105, 98, 99,
    95, 102, 115, 95, 103, 97, 116, 101, 46, 116, 120, 116, 0, 0, 0, 0,
  ];
  let h: heap.PageMmapHeap = heap.PageMmapHeap {
    base: 0 as *u8,
    cap: 0 as usize,
    off: 0 as usize,
  };
  if (heap.page_mmap_heap_init(&h) != 0) {
    return 3;
  }
  let buf: *u8 = heap.page_mmap_heap_alloc(&h, 16 as usize, 8 as usize);
  if (buf == 0 as *u8) {
    heap.page_mmap_heap_deinit(&h);
    return 4;
  }
  let n: i32 = fs.freestanding_read_file_into(&path[0], buf, 16);
  if (n != 2) {
    heap.page_mmap_heap_deinit(&h);
    return 5;
  }
  if (buf[0] != 70 as u8 || buf[1] != 83 as u8) {
    heap.page_mmap_heap_deinit(&h);
    return 6;
  }
  let w: i32 = sys.write_stdout(buf, n);
  if (w != n) {
    heap.page_mmap_heap_deinit(&h);
    return 7;
  }
  heap.page_mmap_heap_deinit(&h);
  return 0;
}
