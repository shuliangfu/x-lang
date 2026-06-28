// MEM-C1 AL-04 负例：with_arena 内 return Allocator 须 typeck 拒错。
const heap = import("std.heap");

function escape_alloc(): heap.Allocator {
  with_arena(4096) {
    return heap.default_alloc();
  }
  return heap.heap_alloc();
}

function main(): i32 {
  return 0;
}
