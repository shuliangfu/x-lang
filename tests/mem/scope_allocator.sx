// MEM-C1：scope_alloc() 在 with_arena 内展开为当前 scope Allocator（kind=1 即 arena）。
const heap = import("std.heap");

function main(): i32 {
  with_arena(4096) {
    let al: Allocator = heap.scope_alloc();
    if (al.kind != 1) {
      return 1;
    }
    if (al.arena == 0 as *Arena64) {
      return 2;
    }
  }
  return 0;
}
