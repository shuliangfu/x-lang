// Test std.io write_stdout(ptr, len) bulk write to stdout
const io = import("std.io");

function main(): i32 {
  let buf: u8[16] = [72, 105, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  io.write_stdout(&buf[0], 3);
  return 0;
}
