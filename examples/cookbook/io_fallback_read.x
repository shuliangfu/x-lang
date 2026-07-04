/**
 * Cookbook IO-04：非 Linux io_uring 回退路径 typeck（STD-026）。
 */
const io = import("std.io");

function main(): i32 {
  let buf: u8[8] = [];
  let _r: i32 = io.read_fd(0, &buf[0], 8);
  let _w: i32 = io.write_fd(1, &buf[0], 0);
  return 0;
}
