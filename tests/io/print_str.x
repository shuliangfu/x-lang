// 测试 std.io：io.print 向 stdout 写一段字节，等价于 write_stdout
const io = import("std.io");

function main(): i32 {
  let buf: u8[8] = [111, 107, 10, 0, 0, 0, 0, 0];
  let n: i32 = io.print(buf, 3);
  if (n != 3) { return 1; }
  return 0;
}
