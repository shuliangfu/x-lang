// SAFE-006：atomic fetch_add 递增（无数据竞争模式烟测）
const atomic = import("std.atomic");

function main(): i32 {
  let counter: i32 = 0;
  let i: i32 = 0;
  while (i < 200) {
    let _prev: i32 = atomic.fetch_add(&counter, 1);
    i = i + 1;
  }
  if (atomic.load(&counter) != 200) { return 1; }
  return 0;
}
