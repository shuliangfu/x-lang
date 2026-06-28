// 测试 std.io 带超时 API：io.write(ptr, len, 0) 等价于 write_stdout，0
// 表示无超时
const io = import("std.io");

function main(): i32 {
  let buf: u8[16] = [72, 105, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  io.write(&buf[0], 3, 0);
  if (io.stdin() != 0) { return 2; }
  if (io.stdout() != 1) { return 3; }
  return 0;
}
