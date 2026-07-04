// 测试 std.fs：fs_open_write、fs_write、fs_close（大块写）；fs_open_read、fs_read 由
// main.x 与 pipeline 等覆盖
const fs = import("std.fs");

function main(): i32 {
  let path: u8[16] = [47, 116, 109, 112, 47, 102, 115, 116, 101, 115, 116, 0, 0, 0, 0, 0];
  let fd_w: i32 = fs.create(&path[0]);
  if (fd_w < 0) { return 1; }
  let buf: u8[8] = [72, 105, 32, 102, 115, 10, 0, 0];
  let n: isize = fs.write(fd_w, &buf[0], 6);
  fs.close(fd_w);
  if (n != 6) { return 2; }
  return 0;
}
