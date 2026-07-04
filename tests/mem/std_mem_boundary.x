/**
 * STD-018 烟测：std.mem copy/set/compare 与 core.mem 分轨（经 heap C 层）。
 */
const mem = import("std.mem");

function main(): i32 {
  let src: u8[4] = [10, 20, 30, 40];
  let dst: u8[4] = [0, 0, 0, 0];
  mem.copy(&dst[0], &src[0], 4);
  if (dst[0] != 10 || dst[3] != 40) { return 1; }
  mem.set(&dst[0], 7, 4);
  if (dst[0] != 7 || dst[3] != 7) { return 2; }
  let a: u8[2] = [1, 2];
  let b: u8[2] = [1, 2];
  let c: u8[2] = [1, 3];
  if (mem.compare(&a[0], &b[0], 2) != 0) { return 3; }
  if (mem.compare(&a[0], &c[0], 2) >= 0) { return 4; }
  if (mem.compare(&c[0], &a[0], 2) <= 0) { return 5; }
  return 0;
}
