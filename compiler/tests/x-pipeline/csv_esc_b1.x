const csv = import("std.csv");

function main(): i32 {
  let line: u8[8] = [97, 98, 0, 0, 0, 0, 0, 0];
  let buf: u8[64] = [];
  let n: i32 = csv.escape(&line[0], 2, &buf[0], 64);
  if (n != 4) {
    return 100 + n;
  }
  return buf[1];
}
