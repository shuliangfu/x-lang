/** 探针：csv.escape("ab") 应返回 4，buf = "\"ab\"" */
const csv = import("std.csv");

function main(): i32 {
  let line: u8[8] = [97, 98, 0, 0, 0, 0, 0, 0];
  let buf: u8[64] = [];
  let n: i32 = csv.escape(&line[0], 2, &buf[0], 64);
  if (n != 4) {
    return n;
  }
  if (buf[0] != 34) {
    return 10;
  }
  if (buf[1] != 97) {
    return 11;
  }
  if (buf[2] != 98) {
    return 12;
  }
  if (buf[3] != 34) {
    return 13;
  }
  return 0;
}
