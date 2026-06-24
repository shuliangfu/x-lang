// seed 回归：import("std.csv") 后 main 内 call + if（曾跨函数 .L_* 标签串台 SIGSEGV）
const csv = import("std.csv");

function main(): i32 {
  let line: u8[8] = [34, 97, 34, 44, 34, 98, 34, 0];
  let start: i32 = 0;
  let flen: i32 = 0;
  csv.next_field(&line[0], 7, 0, &start, &flen);
  if (0 != 0) {
    return 1;
  }
  return 0;
}
