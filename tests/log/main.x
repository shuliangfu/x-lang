// 测试 std.log：set_min_level、log.log(level, ptr, len)
const log = import("std.log");

function main(): i32 {
  log.set_min_level(log.level_info());
  let msg: u8[5] = [111, 107, 32, 49, 0];
  if (log.log(log.level_info(), &msg[0], 4) != 0) { return 1; }
  return 0;
}
