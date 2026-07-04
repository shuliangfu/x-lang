// 测试 std.io.print：向标准输出打印无符号整数
const io = import("std.io");

function main(): i32 {
  let n: i32 = io.print(100);
  return n;
}
