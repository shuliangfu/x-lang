const csv = import("std.csv");

function main(): i32 {
  let line: u8[8] = [97, 98, 0, 0, 0, 0, 0, 0];
  let buf: u8[64] = [];
  return csv.escape(&line[0], 2, &buf[0], 64);
}
