// MEM-AUTO-005 负例：scope_allocator 不得在 with_arena 块外调用。
const heap = import("std.heap");

function main(): i32 {
  let al: Allocator = heap.scope_alloc();
  return al.kind;
}
