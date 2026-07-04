// 测试 io.print：向标准输出打印整数
const io = import("std.io");

function main(): i32 {
  let n: i32 = io.print(42);
  return n;
}
