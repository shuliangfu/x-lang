// 最小用例：let 上下文消解 heap.alloc(count:i32) 重载
const heap = import("std.heap");

function main(): i32 {
  let k: *i32 = heap.alloc(8);
  let o: *u8 = heap.alloc(8);
  return 0;
}
