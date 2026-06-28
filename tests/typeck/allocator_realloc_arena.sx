// MEM-C1 AL-05 负例：arena Allocator 上 allocator_realloc 须 typeck 拒错。
const heap = import("std.heap");

function main(): i32 {
  with_arena(4096) {
    let al: heap.Allocator = heap.default_alloc();
    let p: *u8 = heap.alloc(al, 8);
    let q: *u8 = heap.realloc(al, p, 16);
    if (q == 0) { return 0; }
    return 1;
  }
  return 0;
}
