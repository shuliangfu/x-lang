// MEM-C1 AL-01/02：default_allocator — with_arena 内 kind=arena，块外 kind=heap。
const heap = import("std.heap");

function main(): i32 {
  with_arena(4096) {
    let al: Allocator = heap.default_alloc();
    if (al.kind != 1) {
      return 1;
    }
  }
  let al2: Allocator = heap.default_alloc();
  if (al2.kind != 0) {
    return 2;
  }
  return 0;
}
