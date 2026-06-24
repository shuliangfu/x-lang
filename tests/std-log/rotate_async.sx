// STD-106：异步缓冲 + async_flush API 烟测
const log = import("std.log");

function main(): i32 {
  log.set_min_level(log.level_info());
  if (log.set_async_enabled(1) != 0) {
    return 1;
  }
  let msg: u8[6] = [97, 115, 121, 110, 99, 49];
  if (log.log(log.level_info(), &msg[0], 6) != 0) {
    return 2;
  }
  if (log.async_flush() != 0) {
    return 3;
  }
  if (log.set_rotate_limit(1024, 2) != 0) {
    return 4;
  }
  if (log.set_async_enabled(0) != 0) {
    return 5;
  }
  return 0;
}
