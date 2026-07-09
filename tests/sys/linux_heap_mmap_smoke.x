// NL-03：Linux freestanding mmap bump 堆 + stdout write 烟测（零 libc）。
//
// 【Why import】bug ①（const store-to-stack 缺失，commit 853c5e1b）+
// bug ②（i64 比较截断，commit 6d1e3922）+ bug ③（dep 前缀模型，commit c28d83e9/db201393）
// 三处 ASM 后端修复完成后，恢复为 import std.heap.page_mmap 版本（与 NL-06 manifest 一致）。
const heap = import("std.heap.page_mmap");
const sys = import("std.sys");
const linux = import("std.sys.linux");

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
  let p: *u8 = heap.page_mmap_heap_alloc(&h, 32 as usize, 8 as usize);
  if (p == 0 as *u8) {
    heap.page_mmap_heap_deinit(&h);
    return 4;
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
