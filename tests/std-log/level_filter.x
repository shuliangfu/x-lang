// See implementation.
const log = import("std.log");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  log.set_min_level(log.level_warn());
  let msg: u8[4] = [116, 101, 115, 116];
  if (log.log(log.level_info(), &msg[0], 4) != 0) {
    return 1;
  }
  if (log.log(log.level_error(), &msg[0], 4) != 0) {
    return 2;
  }
  return 0;
}
