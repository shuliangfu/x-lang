// SAFE-005：heap alloc/free 无泄漏（ASAN/LSAN 夜跑用例）。
// alloc 有 *u64/*u8/*f64 等同名重载；字面量 64 会按 i32 打到 *u64。
// 字节缓冲须用 usize 入口：alloc(size: usize): *u8。
const heap = import("std.heap");

function main(): i32 {
  let p: *u8 = heap.alloc(64 as usize);
  if (p == 0 as *u8) {
    return 1;
  }
  p[0] = 42;
  heap.free(p);
  return 0;
}
