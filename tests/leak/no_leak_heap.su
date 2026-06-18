// SAFE-005：heap alloc/free 无泄漏（ASAN/LSAN 夜跑用例）。
const heap = import("std.heap");

function main(): i32 {
  let p: *u8 = heap.alloc(64);
  if (p == 0 as *u8) {
    return 1;
  }
  p[0] = 42;
  heap.free(p);
  return 0;
}
