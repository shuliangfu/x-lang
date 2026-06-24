// STD-054：bench_report 占位输出
const test = import("std.test");

function main(): i32 {
  let name: u8[5] = [115, 109, 111, 107, 101];
  if (test.bench_report(&name[0], 5, 42 as i64) != 0) {
    return 1;
  }
  return 0;
}
