// See implementation.
const sqlite = import("std.db.sqlite");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let av: i32 = sqlite.is_available();
  if (av != 0 && av != 1) {
    return 1;
  }
  if (av == 1) {
    return 0;
  }
  let mem: u8[9] = [58, 109, 101, 109, 111, 114, 121, 58, 0];
  let c: DbConn = sqlite.open(&mem[0]);
  if (c.handle != 0) {
    return 2;
  }
  let err: DbError = sqlite.last_error();
  if (err.code != -9) {
    return 3;
  }
  let bn: *u8 = sqlite.backend_name();
  if (bn[0] != 115 || bn[1] != 116 || bn[2] != 117 || bn[3] != 98) {
    return 4;
  }
  return 0;
}
